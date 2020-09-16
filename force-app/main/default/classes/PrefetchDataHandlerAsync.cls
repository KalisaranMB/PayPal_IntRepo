public class PrefetchDataHandlerAsync implements Queueable, Database.AllowsCallouts
{
    private String contextJSON;
    private Account acct;
    private PrefetchDataDO prefetchData;

    public PrefetchDataHandlerAsync(Account acc, PrefetchDataDO data, String serializedContext) 
    {
        this.acct = acc;
        this.prefetchData = data;
        this.contextJSON = serializedContext;
    }

    public void execute(QueueableContext context) {
        System.debug('PrefetchDataHandlerAsync:execute - Start of storing prefetched data into Salesforce');

        // Lets set the current execution context - Please note that Async operations will have to carry the
        // context from the previous execution context so that we will have this execution as a continuation to
        // the previous one in terms of the context parameters like the security context, correlation id and so on
        ExecutionContextUtil.initContextData(contextJSON);

        // Check if we have the valid account object
        if ((acct == null) || (String.isBlank(acct.Account_Number_Encrypted__c)))
        {
            System.debug(LoggingLevel.ERROR, 'Account Object passed is either null or it does not contain encrypted account number');
            return;
        }

        // Check if we have the valid Data object
        if (prefetchData == null)
        {
            System.debug(LoggingLevel.ERROR, 'Prefetch data Object passed is null');
            return;
        }

        // Lets get the lock for pre-fetch status object so that no other concurrent request can mess with it
        Prefetch_Status__c status = locateAndLockPrefetchStatusRecord(acct.Account_Number_Encrypted__c);
        if (status == null)
        {
            System.debug(LoggingLevel.ERROR, 'Unfortunately we are not able to get the prefetch status record to deal with - lets return');
            return;
        }

        if (!canProceedWithStoringPrefetchData(status))
        {
            System.debug('Skipping prefetch storage since the data is loaded recently and is fresh enough to use');
            return;
        }

        // If Customer360 data is available in the prefetched data, lets go ahead and proceed with storing it into local objects
        // Please note that, we may handle more data categories in future which sits outside of Customer360 as well, this will help
        // this code reliable for future needs as well
        if (prefetchData.customer_360 != null)
        {
            // Lets go ahead and parse the Customer360 data, but before that we need to form the request and response objects properly
            // for the Customer360API to re-use all their existing code
            Customer360APIRequest request = new Customer360APIRequest();
            request.addToDataCategoriesToBeLoaded(Customer360.getPrefetchDataCategories());
            request.setAccount(acct);

            // For response, we will not know whether it is a partial success or full success at this point of time
            // So lets call it as partial success as a cautious approach, anyway individual classes will check for its own failure before storing
            // the data into corresponding objects
            Customer360APIResponse response = new Customer360APIResponse();
            response.setCustomer360Response(Integer.valueOf(Customer360APIResponse.partialSuccessCode), prefetchData.customer_360);

            // Now that everything is ready, lets go ahead and store it in the sobject
            acct = Customer360API.storeResponseInSObject(acct, request, response);
        }

        // Update the Prefetched time
        acct.Prefetch_Loaded_Time__c = Datetime.now();

        // Finally preserve all the hard work went into this, update the Account Object
        update acct;

        // Update the prefetch status record and mark its status as COMPLETED to avoid further unnecessary updates
        status.Status__c = 'COMPLETED';
        status.Last_Updated_Time__c = Datetime.now();
        update status;

        System.debug('PrefetchDataHandlerAsync:execute - End');
        return;
    }

    private static Boolean canProceedWithStoringPrefetchData(Prefetch_Status__c status)
    {
        if (status.Status__c == 'COMPLETED')
        {
            // Status indicates that the Pre-fetch loading is Completed. We need to check when the pre-fetch was last completed and whether it is 
            // fresh enough to use
            if ((status.Last_Updated_Time__c != null) && 
                (DateTime.now().addMinutes(PrefetchUtil.getPrefetchDataValidityTime() * -1) < status.Last_Updated_Time__c))
            {
                // Pre-fetch data is loaded recently into Salesforce and is fresh enough to use, we dont need to store the pre-fetched data again
                System.debug('Skipping Prefetch storage - The data is pre-fetched recently and is fresh enough to use. Last Loaded Time - ' + status.Last_Updated_Time__c);
                return false;
            }
        }

        // If we are here, we can proceed further with storing the data
        System.debug('The prefetch status is not COMPLETED or it is not loaded recently to consider as fresh - ' + JSON.serialize(status));
        return true;
    }

    private static Prefetch_Status__c locateAndLockPrefetchStatusRecord(String encAcctNo)
    {
        // At this point of time, the prefetch data will not be pushed to Salesforce without we asking for it
        // When we ask for pre-fetch data, we ensure that we create a record to track the prefetch status before even triggering it
        // We can straight away get into the business of obtaining the record lock without worrying about whether the
        // record will be present or not

        for (Integer i = 0; i < 2; i++)
        {
            System.debug('Trying to gett lock on pre-fetch status record for the encrypted account number - ' + encAcctNo + ', Attempt ' + i+1);

            try {
                List<Prefetch_Status__c> statuses = queryPrefetchStatusByAccountNumberWithLock(encAcctNo);
                if ((statuses == null) || (statuses.size() == 0))
                {
                    System.debug(LoggingLevel.ERROR, 'There is no record in Prefetch Status object - returning without proceesing further');

                    // In future, we can think about expanding this into record insertion and so on, but right now we do not have usecases
                    // for that and we can keep it simple here
                    return null;
                }

                System.debug('Successfully obtained the lock for prefetch status record');
                return statuses[0];
                
            } catch (Exception e) {
                System.debug('Exception occurred while trying to lock prefetch status row. Message - ' + e.getMessage());

                // There are two possibilities here, either some process is triggering a new request or updating prefetch data for the already triggered
                // request. Since the lock will typically wait for 5 to 10 seconds, it is most likely the later case. In either case, we can give couple
                // of retries before giving up
                continue;
            }
        }
        
        // If we are here, unfortunately we have exhausted all reties without successfully getting a lock
        System.debug(LoggingLevel.ERROR, 'Failed to obtain lock even after multiple retries - really unfortunate');
        return null;
    }

    private static List<Prefetch_Status__c> queryPrefetchStatusByAccountNumberWithLock(String encryptedAccountNumber)
    {
        return [SELECT Id, Account_Number_Encrypted__c, Status__c, Last_Updated_Time__c
                FROM Prefetch_Status__c
                WHERE Account_Number_Encrypted__c = :encryptedAccountNumber
                FOR UPDATE];
    }

}