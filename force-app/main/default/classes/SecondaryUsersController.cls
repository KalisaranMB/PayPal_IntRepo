public class SecondaryUsersController {

    /* This controller is applicable for Business accounts since personal accounts will not have
     * secondary users associated. This method returns all secondary users associated with the account
     * and hence should be used only when it is absolutely necessary. Since we don't prefetch/store
     * hundreds of parties during pre-fetch, this will be a real-time api call
     * 
     * Please note that this component can be embedded within both case record page as well as 
     * account record page since it supports querying based on both case or account.
     */

    @AuraEnabled(cacheable=true)
    public static SecondaryUsersControllerResponse getAllSecondaryUsers(Id caseId, Id accountId)
    {
        System.debug('SecondaryUsersController:getAllSecondaryUsers Start');

        // Lets set the current execution context as a first step in any transaction
        ExecutionContextUtil.initContextData(PayPalContext.Actor.TEAMMATE, caseId, accountId);
        SecondaryUsersControllerResponse response = new SecondaryUsersControllerResponse();

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

        // Since we need to fetch all secondary users which will not be cached locally, lets make an API call without
        // worrying about whether the data is available locally or not
        cx360Request.addToDataCategoriesToBeLoaded(Customer360.DataCategory.SECONDARY_USERS);
        cx360Request.addToSearchCriteriaToBeLoaded(Customer360.SearchCriteria.SECONDARY_USERS_ALL, 'true');

        response = populateResponseUsingCustomer360API(response, cx360Request);

        System.debug('SecondaryUsersController:getAllSecondaryUsers End');
        return response;
    }

    private static SecondaryUsersControllerResponse populateResponseUsingCustomer360API(SecondaryUsersControllerResponse response, Customer360APIRequest cx360Request)
    {
        // Get the required Customer360 data in real-time
        Customer360APIResponse cx360Response = Customer360API.getCustomer360Data(cx360Request);

        if (cx360Response.isAPIStatusSuccess())
        {
            response.result.setStatus(Customer360.Status.SUCCESS);

            // Go ahead and map the Customer360 API response to Secondary Users
            Customer360SO cx360SO = Customer360API.mapResponseToCustomer360SO(cx360Request, cx360Response);
            response.secondaryUsers = cx360SO.secondaryUsers;
        }
        else
        {
            // There is only one data entity we were trying to load, if it is not SUCCESS, then whole Secondary Users is not available
            // We dont need to worry about or handle partial success vs failures in this case
            response.result.setStatusAndMessage(Customer360.Status.FAILURE, 'Failed to load the Data');
            response.result.unavailableDataList.addAll(Customer360.getDescriptionForCategories(cx360Request.getDataCategoriesToBeLoaded()));
        }

        return response;
    }

    private static List<Account> queryAccountWithCaseId(Id caseId)
    {
        return [SELECT Id, Account_Number_Encrypted__c, AccountNumber, Prefetch_Loaded_Time__c
                FROM Account
                WHERE Id IN (SELECT AccountId FROM Case WHERE Id=:caseId)
               ];
    }

    private static List<Account> queryAccountWithAccountId(Id accountId)
    {
        return [SELECT Id, Account_Number_Encrypted__c, AccountNumber, Prefetch_Loaded_Time__c
                FROM Account WHERE Id=:accountId
               ];
    }
    
}