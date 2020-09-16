public class PrefetchDataCleanupBatch implements 
    Database.Batchable<sObject>, Database.Stateful {
    
    // Instance member variables to preserve data throughout the batch execution
    public Scheduled_Batch_Execution__c currentExecution = null;
    Batch_Config__mdt config = null;
    public Integer totalAccountsIdentified = 0;
    public Integer totalAccountsFailed = 0;
    public Integer noOfRecordsIdentifiedForRemoval = 0;
    public Integer noOfRecordsRemovedSuccessfully = 0;
    public Integer minDMLPerTransaction = 0;
    public Integer maxDMLPerTransaction = 0;
    public Integer noOfTransactions = 0;
    public Boolean skippedProcessing = false;
    public String errorMessage;
    public Datetime startTime;
    public Datetime endTime;

    public Database.QueryLocator start(Database.BatchableContext bc) {

        System.debug('PrefetchDataCleanupBatch:start Begin with Job Id - ' + bc.getJobId());
        String batchName = 'CUSTOMER360_DATA_CLEANUP';

        // The first step is to figure out what is the time window to query the records for the data cleanup
        // Time window for the current batch exeuction depends on the last execution and what was the time 
        // window used in that combined with the configuration values set for this Customer360 batch.

        // Lets load the batch and previous executions that were not SKIPPED. A batch processing will be skipped
        // only where we clearly know that there is nothing to process and hence skipped ones are not useful.
        // We only need the latest run, so sorting by time in descending order and LIMIT to 1 will fetch it

        Scheduled_Batch__c batch;

        List<Scheduled_Batch__c> batches = [SELECT Id, Batch_Name__c,
                                                    (SELECT Id, Time_Window_Start__c, Time_Window_End__c, Status__c
                                                    FROM Scheduled_Batch_Executions__r WHERE Status__c != 'SKIPPED'
                                                    ORDER BY CreatedDate DESC LIMIT 1)
                                            FROM Scheduled_Batch__c 
                                            WHERE Batch_Name__c=:batchName LIMIT 1];
        if ((batches == null) || (batches.size() == 0))
        {
            errorMessage = 'Skipped Processing: There are no batch record available in Scheduled_Batch__c object for - ' + batchName;
            errorMessage += '. This could be the first run of this batch - lets silently create a new batch record and move forward';
            System.debug(LoggingLevel.ERROR, errorMessage);
            
            // Lets create a new record. This process will ensure the batch will start automatically without worrying about inserting
            // corresponding records in the batch object. Goal is to reduce as much manual intervention or process as possible.
            batch = new Scheduled_Batch__c();
            batch.Batch_Name__c = batchName;
            upsert batch Batch_Name__c;
        }
        else {
            batch = batches[0];
            System.debug('Identified the batch record - ' + batch.Id);
        }        

        config = [SELECT Processing_Time_Range__c, Data_Freshness__c, Notification_Address__c 
                  FROM Batch_Config__mdt WHERE MasterLabel=:batchName LIMIT 1];
        
        Integer timeRange = (Integer) config.Processing_Time_Range__c;
        Integer olderThan = (Integer) config.Data_Freshness__c;

        currentExecution = new Scheduled_Batch_Execution__c();
        currentExecution.Scheduled_Batch__c = batch.Id;
        currentExecution.AsyncApexJob_Id__c = bc.getJobId();
        currentExecution.Batch_Start_Time__c = Datetime.now();

        // Now that we have identified the batch, lets try to see when it was last executed and derive the time values from there
        if ((batch.Scheduled_Batch_Executions__r == null) || (batch.Scheduled_Batch_Executions__r.size() == 0) ||
            (batch.Scheduled_Batch_Executions__r[0].Time_Window_Start__c == null) || (batch.Scheduled_Batch_Executions__r[0].Time_Window_End__c == null))
        {
            System.debug(LoggingLevel.ERROR, 'There are no prior batch executions or execution times are unavailable, lets make a fresh start');
            // Lets process the records older than the current time based on data freshness and the time range configurations
            endTime = Datetime.now().addMinutes(olderThan * -1);
            startTime = endTime.addMinutes(timeRange * -1);
        }
        else 
        {
            System.debug('Previous execution Start time - ' + JSON.serialize(batch.Scheduled_Batch_Executions__r[0].Time_Window_Start__c));
            System.debug('Previous execution End time - ' + JSON.serialize(batch.Scheduled_Batch_Executions__r[0].Time_Window_End__c));

            // Previous batch execution end time is the starting point for the new execution
            startTime = batch.Scheduled_Batch_Executions__r[0].Time_Window_End__c;
            endTime = startTime.addMinutes(timeRange);
            
            // Lets make sure the end time doesn't go beyond the data freshness configuration and adjust if necessary
            if (endTime > Datetime.now().addMinutes(olderThan * -1))
            {
                System.debug('The end Time is not older than ' + (olderThan/60) + ' hours from the current time and hence will be adjusted');
                endTime = Datetime.now().addMinutes(olderThan * -1);
            }

            // Now check if the startTime is greater than endTime
            if (startTime > endTime)
            {
                // This can happen if there are more batch executions scheduled than needed or if the configurations are somehow messed up
                errorMessage = 'The execution start time - ' + JSON.serialize(startTime) + ' is greater than derived end time - ' + JSON.serialize(endTime);
                currentExecution.Status__c = 'SKIPPED';
                currentExecution.Error_Message__c = errorMessage;
                currentExecution.Batch_End_Time__c = Datetime.now();
                currentExecution.Time_Window_Start__c = startTime;
                currentExecution.Time_Window_End__c = endTime;
                insert currentExecution;
                System.debug('Created the record for the current batch execution. Id - ' + currentExecution.Id);
                skippedProcessing = true;
                System.debug(LoggingLevel.ERROR, 'Skipped Processing: ' + errorMessage);
                return null;
            }
        }

        // We are doing good so far - computed start time, end time is valid to proceed further
        System.debug('Derived Time Window: Start Time - ' + JSON.serialize(startTime) + ', End Time - ' + JSON.serialize(endTime));
        currentExecution.Time_Window_Start__c = startTime;
        currentExecution.Time_Window_End__c = endTime;
        currentExecution.Status__c = 'IN_PROGRESS';
        insert currentExecution;
        System.debug('Created the record for the current batch execution. Id - ' + currentExecution.Id);

        skippedProcessing = false;
        System.debug('PrefetchDataCleanupBatch:start End');
        
        return Database.getQueryLocator(
            'SELECT Id, Account_Number_Encrypted__c, AccountNumber ' +
            'FROM Account ' + 
            'WHERE Prefetch_Loaded_Time__c > :startTime AND Prefetch_Loaded_Time__c <= :endTime'
        );
    }

    public void execute(Database.BatchableContext bc, List<Account> scope)
    {
        System.debug('PrefetchDataCleanupBatch:execute Begin with Job Id - ' + bc.getJobId());
        noOfTransactions++;

        try
        {
            if ((scope == null) || (scope.size() == 0))
            {
                System.debug(LoggingLevel.ERROR, 'Scope passed in the execute method is either null or empty');
                return;
            }

            System.debug('Number of accounts received to process - ' + scope.size());
            totalAccountsIdentified += scope.size();

            List<Id> accountIds = new List<Id>((new Map<Id, Account>(scope)).keySet());
            System.debug('Account Ids received in the current transaction - ' + JSON.serialize(accountIds));

            List<Account> accounts = queryAllChildRecordsForAccounts(accountIds);

            if ((accounts == null) || (accounts.size() == 0))
            {
                // We have to consider this as failure since we should be able to find the same account records coming in the request 
                System.debug(LoggingLevel.ERROR, 'Skipping the current set: Zero Account records returned from queryAllChildRecordsForAccounts');
                totalAccountsFailed += scope.size();

                // There is no use in proceeding further, so just return
                return;
            }

            List<SObject> recordsToDelete = getListOfsObjectsToDeleteFromAccount(accounts);
            recordsToDelete.addAll(getListOfsObjectsToDeleteFromContact(accounts));

            System.debug('Total number of records identified for removal from Account and Contact child objects - ' + recordsToDelete.size());

            noOfRecordsIdentifiedForRemoval += recordsToDelete.size();

            if ((minDMLPerTransaction == 0) || (recordsToDelete.size() < minDMLPerTransaction))
            {
                minDMLPerTransaction = recordsToDelete.size();
            }

            if (recordsToDelete.size() > maxDMLPerTransaction)
            {
                maxDMLPerTransaction = recordsToDelete.size();
            }

            if (recordsToDelete.size() > 9900)
            {
                // 10000 is the number of DMLs allowed in an apex transaction and we are capping at 9900 to be on the safer side
                // One assumption which is valid is that these child objects is mostly acting like a cache data and hence we will
                // never implement triggers. Since the size is very close to the limit, lets trim it
                System.debug(LoggingLevel.ERROR, 'The number of records to be deleted is beyond the per-transaction apex limits - ' + recordsToDelete.size());

                List<SObject> tempList = new List<SObject>();
                for (Integer i=0; i < 9900; i++)
                {
                    tempList.add(recordsToDelete[i]);
                }
                recordsToDelete = tempList;
                System.debug(LoggingLevel.ERROR, 'Number of records to be deleted is truncated to 9900');
            }

            // Giving best attempt to delete records even if some records are not deleted successfully
            Database.DeleteResult[] drList = Database.delete(recordsToDelete, false);
            for(Database.DeleteResult dr : drList) {
                if (dr.isSuccess()) {
                    noOfRecordsRemovedSuccessfully++;
                }
                else {
                    System.debug(LoggingLevel.ERROR, 'Failed to remove the record with Id - ' + dr.getId());
                }
            }

            // The number of records in the request should match with number of records we retrieved in the query, the difference is failure
            if (scope.size() != accounts.size())
            {
                System.debug(LoggingLevel.ERROR, 'The number of accounts in scope did not match with number of accounts retrieved');
                totalAccountsFailed += scope.size() - accounts.size();
            }
        }
        catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'Exception occurred while cleaning up records - ' + e.getMessage());
            totalAccountsFailed += scope.size();
        }

        System.debug('PrefetchDataCleanupBatch:execute End');
    }

    public void finish(Database.BatchableContext bc)
    {
        System.debug('PrefetchDataCleanupBatch:finish Begin with Job Id - ' + bc.getJobId());

        if (skippedProcessing)
        {
            System.debug(LoggingLevel.ERROR, 'Batch processing is Skipped in the start, no need to do anything in finish');
        }
        else
        {
            // Lets go ahead and record the stats in the Batch Execution Object
            currentExecution.Batch_End_Time__c = Datetime.now();
            currentExecution.Processed_Record_Count__c = totalAccountsIdentified;
            currentExecution.Failed_Record_Count__c = totalAccountsFailed;
            currentExecution.Number_of_DMLs__c = noOfRecordsIdentifiedForRemoval;
            currentExecution.Number_of_DMLs_Successful__c = noOfRecordsRemovedSuccessfully;
            currentExecution.Max_DML_per_Transaction__c = maxDMLPerTransaction;
            currentExecution.Min_DML_per_Transaction__c = minDMLPerTransaction;
            currentExecution.Avg_DML_Per_Transaction__c = noOfRecordsIdentifiedForRemoval / noOfTransactions;
            currentExecution.Number_of_Apex_Transactions__c = noOfTransactions;
            currentExecution.Status__c = 'COMPLETED';
            try {
                update currentExecution;
            } catch (Exception e) {
                // Theoritically, this is a serious failure, but not serious enough to block anything since all transactions
                // already done. Lets log an error and move forward with sending an email
                System.debug(LoggingLevel.ERROR, 'Failed to update the Current Batch Execution Record with results. Exception Message - ' + e.getMessage());
            }
        }

        if ((currentExecution != null) && (String.isNotBlank(config.Notification_Address__c)))
        {
            // Time to trigger an email notification to the people who are interested in this execution
            
            try {

                EmailTemplate et=[Select Id, Name, HTMLValue, Subject, Body from EmailTemplate where developername = 'PrefetchDataCleanup_Batch_Results_1597860278509' LIMIT 1];
                
                Messaging.Singleemailmessage mail = new Messaging.Singleemailmessage();
                mail.setToAddresses(new String[] {config.Notification_Address__c});
                mail.setReplyTo(config.Notification_Address__c);
                mail.Subject = et.subject;
                mail.setTreatBodiesAsTemplate(true);
                mail.setUseSignature(false);
    
                String htmlValue = et.HtmlValue;
    
                // Compute and replace the batch execution time in the email body
                Long executionTimeInMins = 99999;
                if ((currentExecution.Batch_Start_Time__c != null) && (currentExecution.Batch_End_Time__c != null))
                {
                    executionTimeInMins = currentExecution.Batch_End_Time__c.getTime() - currentExecution.Batch_Start_Time__c.getTime();
                    executionTimeInMins /= 60000; // To convert from milliseconds to minutes
                }
                htmlValue.replace('{ExecutionTime}', executionTimeInMins.format());
    
                // Replace the domain name in the email body
                htmlValue.replace('{Domain}', URL.getSalesforceBaseUrl().getHost());
                mail.setHtmlBody(htmlValue);

                //mail.setTargetObjectId(ct.Id);
                mail.setWhatId(currentExecution.Id);

                Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
                
            } catch (Exception e) {
                System.debug(LoggingLevel.ERROR, 'Failed to send an email notification. Exception - ' + e.getMessage());
            }

        }

        System.debug('PrefetchDataCleanupBatch:finish End');
    } 

    private List<SObject> getListOfsObjectsToDeleteFromAccount(List<Account> accounts)
    {
        List<SObject> records = new List<SObject>();

        for (Account acct : accounts)
        {
            if ((acct.Account_Limitations__r != null) && (acct.Account_Limitations__r.size() > 0)){
                records.addAll(acct.Account_Limitations__r);
            }
            if ((acct.Account_Manager_Flags__r != null) && (acct.Account_Manager_Flags__r.size() > 0)){
                records.addAll(acct.Account_Manager_Flags__r);
            }
            if ((acct.Account_Notes__r != null) && (acct.Account_Notes__r.size() > 0)){
                records.addAll(acct.Account_Notes__r);
            }
            if ((acct.Account_Products__r != null) && (acct.Account_Products__r.size() > 0)){
                records.addAll(acct.Account_Products__r);
            }
            if ((acct.Account_Wallet__r != null) && (acct.Account_Wallet__r.size() > 0)){
                records.addAll(acct.Account_Wallet__r);
            }
            if ((acct.Activity_Logs__r != null) && (acct.Activity_Logs__r.size() > 0)){
                records.addAll(acct.Activity_Logs__r);
            }
            if ((acct.Business_Addresses__r != null) && (acct.Business_Addresses__r.size() > 0)){
                records.addAll(acct.Business_Addresses__r);
            }
            if ((acct.Linked_Accounts1__r != null) && (acct.Linked_Accounts1__r.size() > 0)){
                records.addAll(acct.Linked_Accounts1__r);
            }
            if ((acct.PayPal_Cases__r != null) && (acct.PayPal_Cases__r.size() > 0)){
                records.addAll(acct.PayPal_Cases__r);
            }
            if ((acct.Previous_Interactions__r != null) && (acct.Previous_Interactions__r.size() > 0)){
                records.addAll(acct.Previous_Interactions__r);
            }
            if ((acct.Transaction_Logs__r != null) && (acct.Transaction_Logs__r.size() > 0)){
                records.addAll(acct.Transaction_Logs__r);
            }
        }

        return records;
    }

    private List<SObject> getListOfsObjectsToDeleteFromContact(List<Account> accounts)
    {
        List<SObject> records = new List<SObject>();
        List<Id> accountIds = new List<Id>((new Map<Id, Account>(accounts)).keySet());
        List<Contact> contacts = queryAllChildRecordsFromContacts(accountIds);

        if ((contacts == null) || (contacts.size() == 0))
        {
            System.debug('There are no Contacts idenfied for Account Ids - ' + JSON.serialize(accountIds));
            return records;
        }

        for (Contact ct : contacts)
        {
            if ((ct.Contact_Emails__r != null) && (ct.Contact_Emails__r.size() > 0)){
                records.addAll(ct.Contact_Emails__r);
            }
            if ((ct.Contact_Phones__r != null) && (ct.Contact_Phones__r.size() > 0)){
                records.addAll(ct.Contact_Phones__r);
            }
            if ((ct.Contact_Addresses__r != null) && (ct.Contact_Addresses__r.size() > 0)){
                records.addAll(ct.Contact_Addresses__r);
            }
        }

        return records;
    }

    private List<Account> queryAllChildRecordsForAccounts(List<Id> accountIds)
    {
        return [SELECT Id, Account_Number_Encrypted__c, AccountNumber, 
                        (SELECT Id FROM Account_Limitations__r WHERE CreatedDate <= :endTime),
                        (SELECT Id FROM Account_Manager_Flags__r WHERE CreatedDate <= :endTime),
                        (SELECT Id FROM Account_Notes__r WHERE CreatedDate <= :endTime),
                        (SELECT Id FROM Account_Products__r WHERE CreatedDate <= :endTime),
                        (SELECT Id FROM Account_Wallet__r WHERE CreatedDate <= :endTime),
                        (SELECT Id FROM Activity_Logs__r WHERE CreatedDate <= :endTime),
                        (SELECT Id FROM Business_Addresses__r WHERE CreatedDate <= :endTime),
                        (SELECT Id FROM Linked_Accounts1__r WHERE CreatedDate <= :endTime),
                        (SELECT Id FROM PayPal_Cases__r WHERE CreatedDate <= :endTime),
                        (SELECT Id FROM Previous_Interactions__r WHERE CreatedDate <= :endTime),
                        (SELECT Id FROM Transaction_Logs__r WHERE CreatedDate <= :endTime)
                FROM Account
                WHERE Id IN :accountIds
                ];
    }

    private List<Contact> queryAllChildRecordsFromContacts(List<Id> accountIds)
    {
        return [SELECT Id, Party_Id__c, 
                        (SELECT Id FROM Contact_Emails__r WHERE CreatedDate <= :endTime),
                        (SELECT Id FROM Contact_Phones__r WHERE CreatedDate <= :endTime),
                        (SELECT Id FROM Contact_Addresses__r WHERE CreatedDate <= :endTime)
                FROM Contact
                WHERE Id IN (SELECT ContactId FROM AccountContactRelation WHERE AccountId IN :accountIds)
                ];
    }
    
}