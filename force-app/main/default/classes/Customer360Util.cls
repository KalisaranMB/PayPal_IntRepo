public class Customer360Util {
    // Utility class that provides some common methods required for Customer360 data

    // Basic Account Record will load absolute minimal data without which Account record
    // does not make any sense like Account No. This method will be required in most of the Customer360
    // controllers when we want to load fresh data for an account ignoring all cached local data
    public static Account getBasicAccountDetails(Id caseId, Id accountId)
    {
        System.debug('Customer360Util:getBasicAccountDetails: caseId - ' + caseId + ', accountId' + accountId);

        if ((caseId == null) && (accountId == null))
        {
            System.debug(LoggingLevel.ERROR, 'Both Case Id and Account Id is null - cannot proceed further');
            return null;
        }

        List<Account> accountList = new List<Account>();

        // Lets start with the Account Id if it is not null, that is the most straighforward option
        if (accountId != null)
        {
            System.debug('Loading the account with accountId -' + accountId);
            accountList = queryBasicAccountWithAccountId(accountId);
        }
        else // Use Case Id
        {
            System.debug('Loading the account with caseId -' + caseId);
            accountList = queryBasicAccountWithCaseId(caseId);
        }

        if (accountList.size() == 0)
        {
            System.debug(LoggingLevel.ERROR, 'Unable to identify the Account with either account id or case id');
            return null;
        }

        return accountList[0];
    }

    // Basic Contact Record will load absolute minimal data without which Contact record
    // does not make any sense like Party Id. This method will be required in some of the Customer360
    // controllers when we want to load fresh data for an account ignoring all cached local data
    public static Contact getContactedParty(Id caseId, Id accountId)
    {
        System.debug('Customer360Util:getContactedPartyDetails: caseId - ' + caseId + ', accountId' + accountId);

        if ((caseId == null) || (accountId == null))
        {
            System.debug(LoggingLevel.ERROR, 'Either Case Id or Account Id is null - cannot determine the Case Session');
            return null;
        }

        List<Contact> contacts = queryPartyAssociatedWithCaseSession(caseId, accountId);

        if (contacts.size() == 0)
        {
            System.debug(LoggingLevel.ERROR, 'Unable to identify the Contacted party using Case Session');
            return null;
        }

        return contacts[0];
    }

    private static List<Account> queryBasicAccountWithAccountId(Id accountId)
    {
        return [SELECT Id, Account_Number_Encrypted__c, AccountNumber
                FROM Account WHERE Id=:accountId
               ];
    }

    private static List<Account> queryBasicAccountWithCaseId(Id caseId)
    {
        return [SELECT Id, Account_Number_Encrypted__c, AccountNumber
                FROM Account
                WHERE Id IN (SELECT AccountId FROM Case WHERE Id=:caseId)
               ];
    }

    private static List<Contact> queryPartyAssociatedWithCaseSession(Id caseId, Id accountId)
    {
        return [SELECT Id, Party_Id__c
                FROM Contact 
                WHERE Id IN (SELECT Contact__c FROM Case_Session__c WHERE Case__c=:caseId AND Account__c=:accountId)
               ];
    }

    public static Boolean isDataNotAvailableLocally(Customer360.DataCategory category, Datetime lastUpdatedTime)
    {
        // If the information is not loaded into Salesforce yet or if loaded earlier than allowed cache duration, we need to load it fresh
        // As of now, all Customer360 data entities share the same expiry time and hence there is no need to consider the category passed in
        // the request in expiry time computation. When we diversify, we will assign different expiry times to each data entity based
        // on the need and use it here.
        if ((lastUpdatedTime == null) || (DateTime.now().addMinutes(ExecutionContextUtil.getPayPalAPICacheTimeDefault() * -1) > lastUpdatedTime))
        {
            return true;
        }
        return false;
    }

    public static List<Account_Limitation__c> filterActiveLimitations(List<Account_Limitation__c> limitations)
    {
        List<Account_Limitation__c> activeLimitations = new List<Account_Limitation__c>();

        if (limitations != null)
        {
            System.debug('Number of Limitations passed to the filter - ' + limitations.size());

            for (Account_Limitation__c limitation : limitations)
            {
                if (limitation.Is_Active__c)
                {
                    activeLimitations.add(limitation);
                }
            }
        }

        return activeLimitations;
    }

    public static Account_Manager_Flag__c filterManagedAccountFlag(List<Account_Manager_Flag__c> flags)
    {
        if (flags != null)
        {
            System.debug('Number of Account Manager flags passed to the filter - ' + flags.size());

            for (Account_Manager_Flag__c flag : flags)
            {
                if (flag.Is_Managed_Account__c)
                {
                    // Managed Account flag found - just return it
                    // There can be only one managed account flag set for an account
                    return flag; 
                }
            }
        }

        return null;
    }
}