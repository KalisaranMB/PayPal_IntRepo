public class TriggerPrefetchHandler {
    
    public static void sendPrefetchRequestAvoidDuplicates(String encryptedAccountNumber, Boolean pushDataAfterPrefetch, Boolean considerIntentPrediction)
    {
        // Check if there is any pending ongoing pre-fetch for the account number
        // We need to lock the record so that simulataneous pre-fetch request for the same account number will wait for the lock and obtain
        // the right status instead of triggering it

        List<Prefetch_Status__c> statuses;
        Prefetch_Status__c status;

        try {
            statuses = queryPrefetchStatusByAccountNumberWithLock(encryptedAccountNumber);
        } catch (Exception e) {
            System.debug('Exception while trying to lock the prefetch status record for the encrypted account number - ' + encryptedAccountNumber + '. Message - ' + e.getMessage());

            // If there is no record in prefetch status with the account number, we will just get the empty array and there should be no exceptions
            // The exception here mostly indicates that some other transaction has obtained the lock and did not release it for more than 10 seconds
            // Though this is strange, its fine since the other transaction which obtained the lock would have triggered the pre-fetch, so we dont
            // need to worry too much here and just return
            return;
        }

        if ((statuses == null) || (statuses.size() == 0))
        {
            // Looks like the pre-fetch is not processed so far for this account number. Lets create a new record and obtain a lock.
            status = new Prefetch_Status__c();
            status.Account_Number_Encrypted__c = encryptedAccountNumber;
            status.Status__c = 'NOT_STARTED';

            try {
                insert status;
            } catch (DmlException e) {
                StatusCode code = e.getDmlType(0);
                String message = 'Exception while trying to insert the prefetch status record for account number - ' + encryptedAccountNumber;
                message += ', StatusCode - ' + code.name() + ', Message - ' + e.getMessage();
                System.debug(message);

                // Since this insert is performed after making sure there are no records existing for the encrypted account number, this mostly
                // indicates that some other concurrent transaction is trying to insert at the same time and we ended up with DUPLICATE_VALUE error
                // We dont need to worry too much since the other transaction might have successfully proceeded further - lets cut here
                return;
            }
        }
        else
        {
            status = statuses[0];
        }
        
        // If we are here, either we have successfully obtained the lock or inserted a new record by ourselves in the race condition
        // It is our responsibility to evaluate and initiate pre-fetch if it is not already done

        if (status.Status__c == 'COMPLETED')
        {
            // Status indicates that the Pre-fetch loading is Completed. We need to check when the pre-fetch was last completed and whether it is 
            // fresh enough to use
            if ((status.Last_Updated_Time__c != null) && 
                (DateTime.now().addMinutes(PrefetchUtil.getPrefetchDataValidityTime() * -1) < status.Last_Updated_Time__c))
            {
                // Pre-fetch data is loaded recently into Salesforce and is fresh enough to use, we dont need to trigger a pre-fetch
                System.debug('Skipping prefetch trigger - The data is pre-fetched recently and is fresh enough to use. Last Loaded Time - ' + status.Last_Updated_Time__c);
                return;
            }
        }
        else if (status.Status__c == 'IN_PROGRESS')
        {
            // Status indicates that the pre-fetch is already in progress. But what if either the pre-fetch trigger is already failed
            // or service failed to update us back because of some momentary issues. We need to be slightly aggressive here. Lets say if the pre-fetch
            // takes ~5 or 10 minutes at the very worst case, we should have performed an update in atleast 15 minutes
            if ((status.Last_Updated_Time__c != null) && 
                (DateTime.now().addMinutes(PrefetchUtil.getPrefetchInProgressWaitingTime() * -1) < status.Last_Updated_Time__c))
            {
                // Pre-fetch is In-Progress and triggered only recently, we need to wait and see if this will go through before
                // initiating another request
                System.debug('Skipping prefetch trigger - Prefetch is in Progress and we have not crossed the waiting time. Last Loaded Time - ' + status.Last_Updated_Time__c);
                return;
            }
        }
        else
        {
            // Status is not COMPLETED or IN_PROGRESS and hence we need to trigger pre-fetch anyway
        }

        // If we are here, we have to trigger a pre-fetch call to the service
        System.debug('Pre-fetch call has to be triggered now');

        // I would have loved to make this as a synchronous call, but unfortunately Salesforce doesn't allow us to make a callout after
        // the DML. So we are forced to use another asynchronous execution from here to make the actual API call to trigger the prefetch
        // Please note that this doubles our consumption of asynchronous operations in this scenario, but we do not have a better choice
        PrefetchAPI.triggerPrefetchAsync(encryptedAccountNumber, pushDataAfterPrefetch, ExecutionContextUtil.getContextDataAsJSON());

        System.debug('Lets update the status to IN-PROGRESS and update the timestamp for future references');
        status.Status__c = 'IN_PROGRESS';
        status.Last_Updated_Time__c = Datetime.now();
        update status;

        return;
    }

    private static List<Prefetch_Status__c> queryPrefetchStatusByAccountNumberWithLock(String encryptedAccountNumber)
    {
        return [SELECT Id, Account_Number_Encrypted__c, Status__c, Last_Updated_Time__c
                FROM Prefetch_Status__c
                WHERE Account_Number_Encrypted__c = :encryptedAccountNumber
                FOR UPDATE];
    }

}