public class ActivityLogAPI {
    
    public static Customer360SO mapResponseToCustomer360SO(Customer360SO cx360SO, Customer360APIRequest request, Customer360APIResponse response)
    {
        System.debug('ActivityLogAPI:mapResponseToCustomer360SO - mapping Activity Log Information');
        
        // Check if there are any failures in loading PayPal activity logs
        if (response.isActivityLogsFailed() || (response.getCustomer360DO().activities == null) ||
            (response.getCustomer360DO().activities.size() == 0))
        {
            System.debug('No Activity logs available in Customer360 API response');
            return cx360SO;
        }
        
        // Map Activity logs to the cx360SO object passed in the request
        for (ActivityLogDO activity : response.getCustomer360DO().activities)
        {
            cx360SO.activityLogs.add(mapActivityLogDOToSO(activity));
        }

        return cx360SO;
    }

    public static Account storeResponseInSObject(Account acct, Customer360APIRequest request, Customer360APIResponse response)
    {
        System.debug('ActivityLogAPI:storeResponseInSObject - Storing Activity Logs to SObject');
        
        // Check if there are any failures in loading Activity Logs
        if (response.isActivityLogsFailed())
        {
            System.debug('Customer360 API did not successfully load Activity logs');
            return acct;
        }

        // Remove all Activity Logs from the account
        removeActivityLogsFromAccount(acct);

        List<ActivityLogDO> activities = response.getCustomer360DO().activities;
        
        if ((activities != null) && (activities.size() > 0))
        {
            List<Activity_Log__c> activityObjs = new List<Activity_Log__c>();

            for (ActivityLogDO act : activities)
            {
                Activity_Log__c activityObj = mapActivityLogDOToSO(act);
                activityObj.Account__c = acct.Id;
                activityObjs.add(activityObj);
            }

            insert activityObjs;
        }

        // If Activity logs are successfully loaded (NOT a failure or partial success), update the cache time
        if (response.isActivityLogsSuccessfullyLoaded())
        {
            acct.ActivityLog_Loaded_Time__c = Datetime.now();
        }

        return acct;
    }

    private static void removeActivityLogsFromAccount(Account acct)
    {
        List<Activity_Log__c> activities = queryActivityLogsFromAccount(acct.Id);
        System.debug('Removing existing Activity Logs from the account. Number of records found - ' + activities.size());
        if (activities.size() > 0)
        {
            delete activities;
        }
        return;
    }

    private static Activity_Log__c mapActivityLogDOToSO(ActivityLogDO activity)
    {
        Activity_Log__c actLog = new Activity_Log__c();
        actLog.Activity_Log_Id__c = activity.activity_id;
        actLog.Time_Created__c = activity.create_time;
        actLog.IP_Address__c = activity.ip;
        actLog.Visitor_Id__c = activity.visitor_id;
        actLog.Actor__c = activity.actor;
        actLog.Action_Type__c = activity.action_type;
        actLog.Action_Type_Id__c = activity.action_type_id;
        actLog.Action_Data__c = activity.meta_data;
        
        return actLog;
    }

    private static List<Activity_Log__c> queryActivityLogsFromAccount(Id accountId)
    {
        return [SELECT Id, Account__c FROM Activity_Log__c
                WHERE Account__c=:accountId];
    }
}