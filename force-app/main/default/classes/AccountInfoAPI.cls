public class AccountInfoAPI {

    public static Customer360SO mapResponseToCustomer360SO(Customer360SO cx360SO, Customer360APIRequest request, Customer360APIResponse response)
    {
        System.debug('AccountInfoAPI:mapResponseToCustomer360SO - mapping Account Attributes');
        
        // Check if there are any failures in loading Account Attributes
        if (response.isAccountInfoFailed() || (response.getCustomer360DO().account_attribute == null))
        {
            System.debug('Customer360 API response does not have any Account Attributes');
            return cx360SO;
        }

        // Map account manager flags
        if ((response.getCustomer360DO().account_attribute.account_flags != null) && 
            (response.getCustomer360DO().account_attribute.account_flags.size() != 0))
        {
            for (AccountManagerFlagDO flag : response.getCustomer360DO().account_attribute.account_flags)
            {
                cx360SO.accountFlags.add(mapAccountManagerFlagDOToSO(flag));
            }
        }
        else {
            System.debug('Customer360 API response does not have any Account Manager Flags');
        }

        return cx360SO;
    }

    public static Account storeResponseInSObject(Account acct, Customer360APIRequest request, Customer360APIResponse response)
    {
        System.debug('AccountInfoAPI:storeResponseInSObject - Storing Account Attributes into SObject');

        AccountInfoDO accountInfo = response.getCustomer360DO().account_attribute;
        
        // Check if there are any failures in loading Account Attributes
        if (response.isAccountInfoFailed())
        {
            System.debug('Customer360 API did not successfully load the Account Attributes');
            return acct;
        }

        // Remove all existing account manager flags associated with the account
        removeAccountManagerFlagsFromAccount(acct);

        // Map account manager flags
        if ((accountInfo != null) && (accountInfo.account_flags != null) && (accountInfo.account_flags.size() > 0))
        {
            List<Account_Manager_Flag__c> flagObjs = new List<Account_Manager_Flag__c>();

            for (AccountManagerFlagDO flag : response.getCustomer360DO().account_attribute.account_flags)
            {
                Account_Manager_Flag__c flagObj = mapAccountManagerFlagDOToSO(flag);
                flagObj.Account__c = acct.Id;
                flagObjs.add(flagObj);
            }

            insert flagObjs;
        }
        else {
            System.debug('Customer360 API response does not have any Account Manager Flags');
        }

        // If Account Manager Flags are loaded successfully (NOT a failure or partial success), let us update the cache time
        if (response.isAccountInfoSuccessfullyLoaded())
        {
            acct.Account_Manager_Flags_Loaded_Time__c = Datetime.now();
        }

        return acct;
    }

    private static void removeAccountManagerFlagsFromAccount(Account acct)
    {
        List<Account_Manager_Flag__c> flags = queryAccountManagerFlagsFromAccount(acct.Id);
        System.debug('Removing existing account manager flags from the account. Number of flags found - ' + flags.size());
        if (flags.size() > 0)
        {
            delete flags;
        }
        return;
    }

    private static Account_Manager_Flag__c mapAccountManagerFlagDOToSO(AccountManagerFlagDO flag)
    {
        Account_Manager_Flag__c amFlag = new Account_Manager_Flag__c();
        amFlag.Name = flag.name;
        amFlag.IVR_Routing_Number__c = flag.ivr_routing_number;
        amFlag.Phone_Number__c = flag.phone_number;
        amFlag.Email_Address__c = flag.email;
        amFlag.Time_Created__c = flag.create_time;
        amFlag.Description__c = flag.description;
        amFlag.Is_Managed_Account__c = flag.managed_account;
        
        return amFlag;
    }

    private static List<Account_Manager_Flag__c> queryAccountManagerFlagsFromAccount(Id accountId)
    {
        return [SELECT Id, Account__c FROM Account_Manager_Flag__c
                WHERE Account__c=:accountId];
    }
}