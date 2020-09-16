public class LimitationAPI {

    public static Customer360SO mapResponseToCustomer360SO(Customer360SO cx360SO, Customer360APIRequest request, Customer360APIResponse response)
    {
        System.debug('LimitationAPI:mapResponseToCustomer360SO - mapping Limitations Information');
        
        // Check if there are any failures in loading Limitations Info
        if (response.isLimitationsFailed() || (response.getCustomer360DO().limitations == null) ||
            (response.getCustomer360DO().limitations.size() == 0))
        {
            System.debug('Customer360 API response does not have Limitations information');
            return cx360SO;
        }
        
        // Map Limitations Information to the cx360SO object passed in the request
        for (LimitationDO limitation : response.getCustomer360DO().limitations)
        {
            cx360SO.limitations.add(mapLimitationDOToSO(limitation));
        }

        return cx360SO;
    }

    public static Account storeResponseInSObject(Account acct, Customer360APIRequest request, Customer360APIResponse response)
    {
        System.debug('LimitationAPI:storeResponseInSObject - Storing Limitations Information into SObject');
        
        // Check if there are any failures in loading Limitations Info
        if (response.isLimitationsFailed())
        {
            System.debug('Customer360 API did not successfully load Limitations information');
            return acct;
        }

        // Remove all existing limitations associated with the account
        removeLimitationsFromAccount(acct);

        List<LimitationDO> limitations = response.getCustomer360DO().limitations;
        
        if ((limitations != null) && (limitations.size() > 0))
        {
            List<Account_Limitation__c> limObjs = new List<Account_Limitation__c>();

            for (LimitationDO limitation : limitations)
            {
                Account_Limitation__c limObj = mapLimitationDOToSO(limitation);
                limObj.Account__c = acct.Id;
                limObjs.add(limObj);
            }

            insert limObjs;
        }

        // If limitations is successfully loaded (NOT a failure or partial success), update the cache time
        if (response.isLimitationsSuccessfullyLoaded())
        {
            acct.Limitation_Info_Loaded_Time__c = Datetime.now();
        }

        return acct;
    }

    private static void removeLimitationsFromAccount(Account acct)
    {
        List<Account_Limitation__c> limitations = queryLimitationsFromAccount(acct.Id);
        System.debug('Removing existing limitations from the account. Number of records found - ' + limitations.size());
        if (limitations.size() > 0)
        {
            delete limitations;
        }
        return;
    }

    private static Account_Limitation__c mapLimitationDOToSO(LimitationDO limitation)
    {
        Account_Limitation__c lim = new Account_Limitation__c();
        lim.Name = limitation.name;
        lim.Category__c = limitation.category;
        lim.Level__c = limitation.level;
        lim.Time_Created__c = limitation.limited_time;
        lim.Status__c = limitation.status;
        lim.Cases_JSON__c = JSON.serialize(limitation.cases);
        lim.Subtypes_JSON__c = JSON.serialize(limitation.subtypes);
        lim.Is_Active__c = isLimitationActive(limitation.status);
        
        return lim;
    }

    // Is this Limitation still open on the account?
    private static Boolean isLimitationActive(String status)
    {        
        if (String.isBlank(status))
        {
            return false;
        }

        if (status.equalsIgnoreCase('active') || (status.equalsIgnoreCase('appeal_denied')))
        {
            return true;
        }
        
        return false;
    }

    private static Limitation_Access_Change__c mapLimitationAccessChangeDOToSO(LimitationAccessChangeDO accessChange)
    {
        Limitation_Access_Change__c aCh = new Limitation_Access_Change__c();
        aCh.Name = accessChange.name;
        aCh.Time_Created__c = accessChange.create_time;
        
        return aCh;
    }

    private static List<Account_Limitation__c> queryLimitationsFromAccount(Id accountId)
    {
        return [SELECT Id, Account__c FROM Account_Limitation__c
                WHERE Account__c=:accountId];
    }
}