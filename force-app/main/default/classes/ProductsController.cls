public class ProductsController {

    /* This controller is applicable for Business accounts since personal accounts dont have
     * options to subscribe to such products atleast as of now. We are not coding anything to
     * restrict this component to load only for business accounts, so in case we need to use it
     * for personal accounts in future, we can do it too.
     * 
     * Please note that this component can be embedded within both case record page as well as 
     * account record page since it supports querying based on both case or account.
     */

    @AuraEnabled(cacheable=true)
    public static ProductsControllerResponse getProducts(Id caseId, Id accountId)
    {
        System.debug('ProductsController:getProducts Start');

        // Lets set the current execution context as a first step in any transaction
        ExecutionContextUtil.initContextData(PayPalContext.Actor.TEAMMATE, caseId, accountId);
        ProductsControllerResponse response = new ProductsControllerResponse();

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

        /***************************** Products Information *****************************/
        if (Customer360Util.isDataNotAvailableLocally(Customer360.DataCategory.PRODUCTS, acc.Product_Info_Loaded_Time__c))
        {
            System.debug('Products Information needs to be loaded. Last loaded time - ' + acc.Product_Info_Loaded_Time__c);
            cx360Request.addToDataCategoriesToBeLoaded(Customer360.DataCategory.PRODUCTS);
        }
        else 
        {
            System.debug('Products information is available and fresh enough to use. Last loaded time - ' + acc.Product_Info_Loaded_Time__c);
            cx360Request.addToDataCategoriesAvailable(Customer360.DataCategory.PRODUCTS);
            response.products = acc.Account_Products__r;
        }

        // Great, we are done with data checks needed for Products, lets see if we need to load in real time
        if (cx360Request.getDataCategoriesToBeLoaded().size() > 0)
        {
            response = populateResponseUsingCustomer360API(response, cx360Request);
        }
        else {
            // Great, everything we need was retrieved from local objects itself - thanks to pre-fetch tech
            // Lets mark the status as SUCCESS.
            response.result.setStatus(Customer360.Status.SUCCESS);
        }

        System.debug('ProductsController:getProducts End');
        return response;
    }

    /* Ths controller returns the same Products details as the above one, but without using any Cache
     * There are times where a teammate wants to see a fresh customer data (may be the customer has performed
     * some action in PayPal site/app) that we want to reflect in CS side. Each controller will provide this
     * option to get fresh data. We can decide whether hard refresh is needed or not in UI side.
     */

    @AuraEnabled
    public static ProductsControllerResponse getProductsWithoutCache(Id caseId, Id accountId)
    {
        System.debug('ProductsController:getProductsWithoutCache - Start');

        // Lets set the current execution context as a first step in any transaction
        ExecutionContextUtil.initContextData(PayPalContext.Actor.TEAMMATE, caseId, accountId);
        ProductsControllerResponse response = new ProductsControllerResponse();

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
        cx360Request.addToDataCategoriesToBeLoaded(Customer360.DataCategory.PRODUCTS);

        // Make sure CSDAS skips its cache and load data from domain services
        cx360Request.setSkipCacheDataFlag(true);

        response = populateResponseUsingCustomer360API(response, cx360Request);

        // TBD - We should ideally presist the fresh data into local sobjects since teammate would
        // not want to see the old data again after this stage. Lets perform an async update to Database

        System.debug('ProductsControllerResponse:getProductsWithoutCache - End');
        return response;
    }

    private static ProductsControllerResponse populateResponseUsingCustomer360API(ProductsControllerResponse response, Customer360APIRequest cx360Request)
    {
        // Get the required Customer360 data in real-time
        Customer360APIResponse cx360Response = Customer360API.getCustomer360Data(cx360Request);

        if (cx360Response.isAPIStatusSuccess())
        {
            response.result.setStatus(Customer360.Status.SUCCESS);

            // Go ahead and map the Customer360 API response to Products Info
            Customer360SO cx360SO = Customer360API.mapResponseToCustomer360SO(cx360Request, cx360Response);
            response = mapCustomer360SOToProductsInfo(response, cx360SO, cx360Request, cx360Response);
        }
        else
        {
            // There is only one data entity we were trying to load, if it is not SUCCESS, then whole Products information is not available
            // We dont need to worry about or handle partial success vs failures in this case
            response.result.setStatusAndMessage(Customer360.Status.FAILURE, 'Failed to load the Data');
            response.result.unavailableDataList.addAll(Customer360.getDescriptionForCategories(cx360Request.getDataCategoriesToBeLoaded()));
        }

        return response;
    }

    private static ProductsControllerResponse mapCustomer360SOToProductsInfo(ProductsControllerResponse response, Customer360SO cx360SO, Customer360APIRequest cx360Request, Customer360APIResponse cx360Response)
    {
        // Map Products Info - Simple isn't it?
        response.products = cx360SO.products;
        return response;
    }

    private static List<Account> queryAccountWithCaseId(Id caseId)
    {
        return [SELECT Id, Account_Number_Encrypted__c, AccountNumber, 
                        (SELECT Id, Name, Time_Created__c, Time_Last_Updated__c, Status__c, Time_Activated__c, Time_Deactivated__c, Product_Code__c
                        FROM Account_Products__r),
                Prefetch_Loaded_Time__c, Product_Info_Loaded_Time__c
                FROM Account
                WHERE Id IN (SELECT AccountId FROM Case WHERE Id=:caseId)
               ];
    }

    private static List<Account> queryAccountWithAccountId(Id accountId)
    {
        return [SELECT Id, Account_Number_Encrypted__c, AccountNumber, 
                        (SELECT Id, Name, Time_Created__c, Time_Last_Updated__c, Status__c, Time_Activated__c, Time_Deactivated__c, Product_Code__c
                        FROM Account_Products__r),
                Prefetch_Loaded_Time__c, Product_Info_Loaded_Time__c
                FROM Account WHERE Id=:accountId
               ];
    }
}