public class PrefetchUtil {
    private static Integer prefetchDataValidityTime = null;
    private static Integer prefetchInProgressWaitingTime = null;

    // Time for which the prefetched data is considered as valid
    public static Integer getPrefetchDataValidityTime()
    {
        if(prefetchDataValidityTime != null)
        {
            System.debug('Returned Prefetch validity time - ' + prefetchDataValidityTime + ' minutes');
            return prefetchDataValidityTime;
        }

        Cache_Duration__mdt cacheTime = [SELECT Cache_Time__c FROM Cache_Duration__mdt 
                                         WHERE MasterLabel='PayPalDefault' LIMIT 1];
        prefetchDataValidityTime = (Integer) cacheTime.Cache_Time__c;

        System.debug('Derived Prefetch validity time - ' + prefetchDataValidityTime + ' minutes');
        return prefetchDataValidityTime;
    }

    // Time for which we can wait for the triggered pre-fetch to Complete before we need to give up and
    // trigger a new prefetch request
    public static Integer getPrefetchInProgressWaitingTime()
    {
        if(prefetchInProgressWaitingTime != null)
        {
            System.debug('Returned In-Progress Prefetch waiting time - ' + prefetchInProgressWaitingTime + ' minutes');
            return prefetchInProgressWaitingTime;
        }

        Cache_Duration__mdt cacheTime = [SELECT Cache_Time__c FROM Cache_Duration__mdt 
                                         WHERE MasterLabel='PrefetchInProgressDuration' LIMIT 1];
        prefetchInProgressWaitingTime = (Integer) cacheTime.Cache_Time__c;

        System.debug('Derived In-Progress Prefetch waiting time - ' + prefetchInProgressWaitingTime + ' minutes');
        return prefetchInProgressWaitingTime;
    }

    // This method is a hook that can be used by other flows to trigger a prefetch in case it suspects that the
    // data is not prefetched already or is not fresh enough to use. For instance an UI component should ideally have
    // all the data required for it locally, but if it ends up calling API real-time for partial or full data, then it
    // will suspect whether the data is not pre-fetched before and call this method to investigate and act
    public static void checkAndTriggerPrefetchAsync(Account acct)
    {
        if ((acct == null) || (String.isBlank(acct.Account_Number_Encrypted__c)))
        {
            System.debug('Account object or encrypted account number passed in the request is null - cannot evaluate further or trigger prefetch');
            return;
        }

        if ((acct.Prefetch_Loaded_Time__c == null) || 
                (DateTime.now().addMinutes(PrefetchUtil.getPrefetchDataValidityTime() * -1) > acct.Prefetch_Loaded_Time__c))
        {
            // Prefetch data is not available locally, we need to trigger a pre-fetch
            TriggerPrefetchAsync prefetchTriggerJob = new TriggerPrefetchAsync(acct.Account_Number_Encrypted__c, true, true, ExecutionContextUtil.getContextDataAsJSON());
            ID jobId = System.enqueueJob(prefetchTriggerJob);
            System.debug('Successfully queued the prefetch trigger request. Job Id - ' + jobId);
        }

        System.debug('No need to trigger prefetch. Data is available locally and is fresh enough to use. Last loaded time - ' + acct.Prefetch_Loaded_Time__c);
    }
}