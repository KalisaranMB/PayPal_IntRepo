public class PrefetchDataCleanupSchedule implements Schedulable {
    public void execute(SchedulableContext sc) {
        System.debug('PrefetchDataCleanupSchedule:execute Begin called with CronTrigger Id - ' + sc.getTriggerId());

        // Lets get the scope or number of records per execute transaction from the configuration
        String batchName = 'CUSTOMER360_DATA_CLEANUP';
        Batch_Config__mdt config = [SELECT Scope__c FROM Batch_Config__mdt 
                                    WHERE MasterLabel=:batchName LIMIT 1];
        
        Integer scope = (Integer) config.Scope__c;
        System.debug('Identified batch size / scope value - ' + scope);

        // Lets go ahead and run the batch
        PrefetchDataCleanupBatch batch = new PrefetchDataCleanupBatch();
        String jobId = Database.executeBatch(batch, scope);

        // If executeBatch fails, it will return 000000000000000, otherwise we are expected to receive 707xxxxxxxxxxxx
        // Refer - https://trailblazer.salesforce.com/issues_view?id=a1p3A0000008geqQAA
        
        if(jobId.startsWith('707')) { 
            System.debug('Batch Job Queued successfully. Job Id - ' + jobId);
        } else {
            System.debug(LoggingLevel.ERROR, 'Failed to queue the Batch Job. Returned Job Id - ' + jobId);
        }

        System.debug('PrefetchDataCleanupSchedule:execute End');
    }
}