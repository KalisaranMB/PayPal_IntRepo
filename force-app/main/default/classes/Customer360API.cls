public class Customer360API {

    // Get Customer360 data
    public static Customer360APIResponse getCustomer360Data(Customer360APIRequest request)
    {
        Customer360APIResponse response = new Customer360APIResponse();

        // Encrypted Account number is must for the Customer360 API call
        if (String.isBlank(request.getAccountNumberEncrypted()))
        {
            System.debug(LoggingLevel.ERROR, 'Encrypted account number is missing in the Customer360 request');
            return response;
        }

        // Form the endpoint without named credentials since PayPalHTTP class will decide which
        // named credential to use based on the current context. Look at the class for more details.
        String endPoint = '/accounts/' + request.getAccountNumberEncrypted();
        endPoint += request.getURLParamsForAPICall();

        HttpRequest httpReq = new HttpRequest();
        httpReq.setMethod('GET');
        httpReq.setEndpoint(endPoint);

        // Add required header if CSDAS should retrieve fresh data instead of using its cache
        if (request.getSkipCacheDataFlag())
        {
            ExecutionContextUtil.setSkipServerSideCache(true);
        }

        HttpResponse httpRes = PayPalHTTP.send(httpReq);

        // Any Failure
        if ((httpRes == null) || ((httpRes.getStatusCode() >= 300)))
        {
            System.debug(LoggingLevel.ERROR, 'Failed to get Customer360 Data from API');
            Integer httpCode = (httpRes != null) ? httpRes.getStatusCode() : 0;
            response.setCustomer360Response(httpCode, null);
            return response;
        }

        // Great, its a Success! Parse and set the Customer 360 data to the response
        System.debug('Successfully loaded the required data from Customer360 API');
        response.setCustomer360Response(httpRes.getStatusCode(), Customer360DO.parse(httpRes.getBody()));

        return response;
    }

    public static Customer360SO mapResponseToCustomer360SO(Customer360APIRequest request, Customer360APIResponse response)
    {
        System.debug('Customer360API:mapResponseToCustomer360SO - Mapping Customer360 Information');

        // Check if the data is loaded succesfully, if not there is no point in mapping it to SO
        if ((response.isAPIStatusFailure()) || (response.getCustomer360DO() == null))
        {
            System.debug(LoggingLevel.ERROR , 'Failed to map to Customer360SO: Customer360 API status is a Failure or the response DO is null');
            return null;
        }

        Customer360SO cx360SO = new Customer360SO();

        // Profile Information
        if (request.isProfileRequested())
        {
            cx360SO = ProfileAPI.mapResponseToCustomer360SO(cx360SO, request, response);
        }

        // Business Details
        if (request.isBusinessInfoRequested())
        {
            cx360SO = BusinessDetailsAPI.mapResponseToCustomer360SO(cx360SO, request, response);
        }

        // Compliance
        if (request.isComplianceInfoRequested())
        {
            cx360SO = ComplianceInfoAPI.mapResponseToCustomer360SO(cx360SO, request, response);
        }

        // Account Info
        if (request.isAccountInfoRequested())
        {
            cx360SO = AccountInfoAPI.mapResponseToCustomer360SO(cx360SO, request, response);
        }

        // Secondary Users
        if (request.isSecondaryUsersRequested())
        {
            cx360SO = SecondaryUserAPI.mapResponseToCustomer360SO(cx360SO, request, response);
        }

        // Limitations
        if (request.isLimitationsRequested())
        {
            cx360SO = LimitationAPI.mapResponseToCustomer360SO(cx360SO, request, response);
        }

        // Wallet
        if (request.isWalletRequested())
        {
            cx360SO = WalletAPI.mapResponseToCustomer360SO(cx360SO, request, response);
        }

        // Transactions
        if (request.isTransactionsRequested())
        {
            cx360SO = TransactionAPI.mapResponseToCustomer360SO(cx360SO, request, response);
        }

        // Cases
        if (request.isCasesRequested())
        {
            cx360SO = PayPalCaseAPI.mapResponseToCustomer360SO(cx360SO, request, response);
        }

        // Activity Log
        if (request.isActivityLogsRequested())
        {
            cx360SO = ActivityLogAPI.mapResponseToCustomer360SO(cx360SO, request, response);
        }

        // Notes
        if (request.isNotesRequested())
        {
            cx360SO = ServiceLogAPI.mapResponseToCustomer360SO(cx360SO, request, response);
        }

        // Products
        if (request.isProductInfoRequested())
        {
            cx360SO = ProductAPI.mapResponseToCustomer360SO(cx360SO, request, response);
        }

        // Linked Accounts
        if (request.isLinkedAccountsRequested())
        {
            cx360SO = LinkedAccountAPI.mapResponseToCustomer360SO(cx360SO, request, response);
        }

        // Previous Interactions
        if (request.isPreviousInteractionsRequested())
        {
            cx360SO = InteractionsAPI.mapResponseToCustomer360SO(cx360SO, request, response);
        }

        return cx360SO;
    }

    public static Account storeResponseInSObject(Account acct, Customer360APIRequest request, Customer360APIResponse response)
    {
        System.debug('Customer360API:storeResponseInSObject - Storing Customer360 Information into SObject');

        // This method will be used in cases like Pre-fetch or others as we deem it appropriate. The client is expected to pass the right
        // account object as input. This method cannot do that job on behalf of the caller.
        if (acct == null)
        {
            System.debug(LoggingLevel.ERROR, 'Account object passed in the request is null, cannot proceed with storing into local objects');
            return null;
        }

        // Profile Information
        if (request.isProfileRequested())
        {
            acct = ProfileAPI.storeResponseInSObject(acct, request, response);
        }

        // Business Details
        if (request.isBusinessInfoRequested())
        {
            acct = BusinessDetailsAPI.storeResponseInSObject(acct, request, response);
        }

        // Compliance
        if (request.isComplianceInfoRequested())
        {
            acct = ComplianceInfoAPI.storeResponseInSObject(acct, request, response);
        }

        // Account Info
        if (request.isAccountInfoRequested())
        {
            acct = AccountInfoAPI.storeResponseInSObject(acct, request, response);
        }

        // Secondary Users
        if (request.isSecondaryUsersRequested())
        {
            acct = SecondaryUserAPI.storeResponseInSObject(acct, request, response);
        }

        // Limitations
        if (request.isLimitationsRequested())
        {
            acct = LimitationAPI.storeResponseInSObject(acct, request, response);
        }

        // Wallet
        if (request.isWalletRequested())
        {
            acct = WalletAPI.storeResponseInSObject(acct, request, response);
        }

        // Transactions
        if (request.isTransactionsRequested())
        {
            acct = TransactionAPI.storeResponseInSObject(acct, request, response);
        }

        // Cases
        if (request.isCasesRequested())
        {
            acct = PayPalCaseAPI.storeResponseInSObject(acct, request, response);
        }

        // Activity Log
        if (request.isActivityLogsRequested())
        {
            acct = ActivityLogAPI.storeResponseInSObject(acct, request, response);
        }

        // Notes
        if (request.isNotesRequested())
        {
            acct = ServiceLogAPI.storeResponseInSObject(acct, request, response);
        }

        // Products
        if (request.isProductInfoRequested())
        {
            acct = ProductAPI.storeResponseInSObject(acct, request, response);
        }

        // Linked Accounts
        if (request.isLinkedAccountsRequested())
        {
            acct = LinkedAccountAPI.storeResponseInSObject(acct, request, response);
        }

        // Previous Interactions
        if (request.isPreviousInteractionsRequested())
        {
            acct = InteractionsAPI.storeResponseInSObject(acct, request, response);
        }

        return acct;
    }
}