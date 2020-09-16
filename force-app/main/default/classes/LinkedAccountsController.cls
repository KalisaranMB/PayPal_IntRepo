public class LinkedAccountsController {

    /* This controller is applicable for personal, premier and business accounts.
     * The business accounts has even more nuances link MUMA which are not handled in the
     * current implementation, but eventually we will end up dealing with all linked accounts - 
     * either the direct links which is mostly common among business accounts or the indirect relationships
     * which are mostly common among consumer accounts but somtimes applicable even for business accounts.
     * 
     * Please note that this component can be embedded within both case record page as well as 
     * account record page since it supports querying based on both case or account.
     */

    @AuraEnabled(cacheable=true)
    public static LinkedAccountsControllerResponse getLinkedAccounts(Id caseId, Id accountId)
    {
        System.debug('LinkedAccountsController:getLinkedAccounts Start');

        // Lets set the current execution context as a first step in any transaction
        ExecutionContextUtil.initContextData(PayPalContext.Actor.TEAMMATE, caseId, accountId);
        LinkedAccountsControllerResponse response = new LinkedAccountsControllerResponse();

        // If both caseId and accountId is NULL, lets stop right here
        if ((caseId == null) && (accountId == null))
        {
            System.debug(LoggingLevel.ERROR, 'Both Case Id and Account Id is null - cannot proceed further');
            response.result.setStatusAndMessage(Customer360.Status.FAILURE, 'Unexpected Error: Both Case Id and Account Id is missing in the request');
            return response;
        }

        List<Account> accountList = new List<Account>();

        // If we have a valid accountId, lets try to load data using that rather than using the caseId
        // Ideally, we could have done this using Dynamic SOQL instead of writing two queries, but we need to 
        // use dynamic SOQL with a caution since it is vulnerable to SQL injection and hence better to avoid it
        // unless the usecase is complex enough to mandate it.
        if (accountId != null)
        {
            accountList = queryAccountWithAccountId(accountId);
            if (accountList.size() == 0)
            {
                // May be the account Id is invalid
                System.debug(LoggingLevel.ERROR, 'Invalid Account Id: accountId - ' + accountId);
                response.result.setStatusAndMessage(Customer360.Status.FAILURE, 'Unexpected Error: Failed to find the account with Account Id passed in the request');
                return response;
            }
        }
        else // query with caseId, if we are here it cannot be null
        {
            accountList = queryAccountWithCaseId(caseId);
            if (accountList.size() == 0)
            {
                // May be the case is not linked to any account, its strange but there is a possiblity
                System.debug(LoggingLevel.ERROR, 'Case Id received is not associated with any account: caseId - ' + caseId);
                response.result.setStatusAndMessage(Customer360.Status.FAILURE, 'Unexpected Error: Case Id passed in the request is not associated with any Account');
                return response;
            }
        }

        Account acc = accountList[0];
        Customer360APIRequest cx360Request = new Customer360APIRequest();
        cx360Request.setAccount(acc);

        /***************************** Linked Accounts *****************************/
        if (Customer360Util.isDataNotAvailableLocally(Customer360.DataCategory.LINKED_ACCOUNTS, acc.Linked_Accounts_Loaded_Time__c))
        {
            System.debug('Linked Accounts needs to be loaded. Last loaded time - ' + acc.Linked_Accounts_Loaded_Time__c);
            cx360Request.addToDataCategoriesToBeLoaded(Customer360.DataCategory.LINKED_ACCOUNTS);
        }
        else 
        {
            System.debug('Linked Accounts is available and fresh enough to use. Last loaded time - ' + acc.Linked_Accounts_Loaded_Time__c);
            cx360Request.addToDataCategoriesAvailable(Customer360.DataCategory.LINKED_ACCOUNTS);
            response = mapLinkedAccounts(response, acc.Linked_Accounts1__r);
        }

        // Great, we are done with data checks needed for Linked Accounts, lets see if we need to load in real time
        if (cx360Request.getDataCategoriesToBeLoaded().size() > 0)
        {
            response = populateResponseUsingCustomer360API(response, cx360Request);
        }
        else {
            // Great, everything we need was retrieved from local objects itself - thanks to pre-fetch tech
            // Lets mark the status as SUCCESS.
            response.result.setStatus(Customer360.Status.SUCCESS);
        }

        System.debug('LinkedAccountsController:getLinkedAccounts End');
        return response;
    }

    /* Ths controller returns the same Linked Accounts as the above one, but without using any Cache
     * There are times where a teammate wants to see a fresh customer data (may be the customer has performed
     * some action in PayPal site/app) that we want to reflect in CS side. Each controller will provide this
     * option to get fresh data. We can decide whether hard refresh is needed or not in UI side.
     */

    @AuraEnabled
    public static LinkedAccountsControllerResponse getLinkedAccountsWithoutCache(Id caseId, Id accountId)
    {
        System.debug('LinkedAccountsController:getLinkedAccountsWithoutCache - Start');

        // Lets set the current execution context as a first step in any transaction
        ExecutionContextUtil.initContextData(PayPalContext.Actor.TEAMMATE, caseId, accountId);
        LinkedAccountsControllerResponse response = new LinkedAccountsControllerResponse();

        Account acc = Customer360Util.getBasicAccountDetails(caseId, accountId);
        if (acc == null)
        {
            System.debug(LoggingLevel.ERROR, 'Failed to identify the Account using account id or case id');
            response.result.setStatusAndMessage(Customer360.Status.FAILURE, 'Unexpected Error: Failed to identify the Account using Account Id or Case Id');
            return response;
        }

        Customer360APIRequest cx360Request = new Customer360APIRequest();
        cx360Request.setAccount(acc);

        // No need to check for any data loaded time here, lets go directly for prepping API call
        cx360Request.addToDataCategoriesToBeLoaded(Customer360.DataCategory.LINKED_ACCOUNTS);

        // Make sure CSDAS skips its cache and load data from domain services
        cx360Request.setSkipCacheDataFlag(true);

        response = populateResponseUsingCustomer360API(response, cx360Request);

        // TBD - We should ideally presist the fresh data into local sobjects since teammate would
        // not want to see the old data again after this stage. Lets perform an async update to Database

        System.debug('LinkedAccountsController:getLinkedAccountsWithoutCache - End');
        return response;
    }

    private static LinkedAccountsControllerResponse populateResponseUsingCustomer360API(LinkedAccountsControllerResponse response, Customer360APIRequest cx360Request)
    {
        // Get the required Customer360 data in real-time
        Customer360APIResponse cx360Response = Customer360API.getCustomer360Data(cx360Request);

        if (cx360Response.isAPIStatusSuccess())
        {
            response.result.setStatus(Customer360.Status.SUCCESS);

            // Go ahead and map the Customer360 API response to Linked Accounts
            Customer360SO cx360SO = Customer360API.mapResponseToCustomer360SO(cx360Request, cx360Response);
            response.linkedAccounts = cx360SO.linkedAccounts;
        }
        else
        {
            // There is only one data entity we were trying to load, if it is not SUCCESS, then whole Linked Accounts is not available
            // We dont need to worry about or handle partial success vs failures in this case
            response.result.setStatusAndMessage(Customer360.Status.FAILURE, 'Failed to load the Data');
            response.result.unavailableDataList.addAll(Customer360.getDescriptionForCategories(cx360Request.getDataCategoriesToBeLoaded()));
        }

        return response;
    }

    private static LinkedAccountsControllerResponse mapLinkedAccounts(LinkedAccountsControllerResponse response, List<Linked_Account__c> linkedAccounts)
    {
        if ((linkedAccounts == null) || (linkedAccounts.size() == 0))
        {
            System.debug('There are no linked accounts associated with the account');
            return response;
        }

        Map<Id, LinkedAccountSO> linkedAccountsSOMap = new Map<Id, LinkedAccountSO>();
        List<Id> linkedAccountIds = new List<Id>();

        // Iterate through each linked account and create a map of SOs and collect Ids as well in the process
        for (Linked_Account__c lacct : linkedAccounts)
        {
            LinkedAccountSO lacctSO = new LinkedAccountSO();
            lacctSO.linkedAccount = lacct;
            linkedAccountsSOMap.put(lacct.Id, lacctSO);
            linkedAccountIds.add(lacct.Id);
        }

        // Query all linked account attributes using the linked account Ids collected above
        List<Linked_Account_Attributes__c> lacctAttributes = queryLinkedAccountAttributesWithIds(linkedAccountIds);
        if (lacctAttributes != null)
        {
            for (Linked_Account_Attributes__c attribute : lacctAttributes)
            {
                LinkedAccountSO lacctSO = linkedAccountsSOMap.get(attribute.Linked_Account__c);
                if (lacctSO == null)
                {
                    // This cannot happen by any chance, but still we need to handle this scenario as a developer
                    System.debug(LoggingLevel.ERROR, 'LinkedAccountSO object in the map is unexpectedly missing');
                    continue;
                }
                lacctSO.attributes.add(LinkedAccountAPI.mapLinkedAccountAttributeObjToSO(attribute));
            }
        }

        response.linkedAccounts = linkedAccountsSOMap.values();
        return response;
    }

    private static List<Account> queryAccountWithCaseId(Id caseId)
    {
        return [SELECT Id, Account_Number_Encrypted__c, AccountNumber, 
                        (SELECT Id, Full_Name__c, Account_Number__c, Account_Number_Encrypted__c, Account_Type__c, Account_Created_Time__c, 
                        Account_Status__c, Has_Strong_Link__c, Is_Unregistered__c, Unregistered_Account_Type__c
                        FROM Linked_Accounts1__r),
                Prefetch_Loaded_Time__c, Linked_Accounts_Loaded_Time__c
                FROM Account
                WHERE Id IN (SELECT AccountId FROM Case WHERE Id=:caseId)
               ];
    }

    private static List<Account> queryAccountWithAccountId(Id accountId)
    {
        return [SELECT Id, Account_Number_Encrypted__c, AccountNumber, 
                        (SELECT Id, Full_Name__c, Account_Number__c, Account_Number_Encrypted__c, Account_Type__c, Account_Created_Time__c, 
                        Account_Status__c, Has_Strong_Link__c, Is_Unregistered__c, Unregistered_Account_Type__c
                        FROM Linked_Accounts1__r),
                Prefetch_Loaded_Time__c, Linked_Accounts_Loaded_Time__c
                FROM Account WHERE Id=:accountId
               ];
    }

    private static List<Linked_Account_Attributes__c> queryLinkedAccountAttributesWithIds(List<Id> linkedAccountIds)
    {
        return [SELECT Id, Name, Attribute_Value__c, Has_Strong_Link__c, Response_JSON__c, Linked_Account__c
                FROM Linked_Account_Attributes__c
                WHERE Linked_Account__c = :linkedAccountIds
               ];
    }
}