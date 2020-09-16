@RestResource(urlMapping='/prefetch/v1/account/*')
global class PrefetchWebService {

    @HttpPost
    global static void storePrefetchData() 
    {
        System.debug('PrefetchWebService:storePrefetchData - Start: Storing Prefetch data into local objects');

        // Lets set the current execution context as a first step in any transaction
        ExecutionContextUtil.initContextData(PayPalContext.Actor.SERVER, null, null);
        
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;

        // Log the Correlation Id passed from the client
        // We need to make sure if the service can send in this header and the case sensitivity as well as
        // the get method in map will NOT perform a case-insensitive search.
        String correlationId = req.headers.get('x-pp-corrid');
        System.debug('Correlation Id passed in the request header - ' + correlationId);
        ExecutionContextUtil.setPayPalCorrelationId(correlationId);

        // Get the Request URI        
        String uri = req.requestURI;
        System.debug('Request URI - ' + uri);

        // Extract the encrypted account number from the URI
        String[] tokens = uri.split('prefetch/v1/account/');

        if ((tokens.size() != 2) || String.isBlank(tokens[1]) || (!tokens[1].isAlphanumeric()))
        {
            System.debug(LoggingLevel.ERROR, 'Improper or Malfunctioned URI or the account number in URI is invalid - ' + JSON.serialize(tokens));
            res = handleHttpBadRequest(res, 'Improper URI - Failed to identify the encrypted account number');
            return;
        }

        String encryptedAccountNumber = tokens[1];
        System.debug('Encrypted Account Number derived from the URI - ' + encryptedAccountNumber);

        List<Account> accts = queryAccount(encryptedAccountNumber);
        Account acct;

        if ((accts == null) || (accts.size() == 0))
        {
            // Account is not available locally, perhaps the customer is contacting us for the first time
            acct = new Account();
            acct.Name = encryptedAccountNumber; // This is just a temporary assignment which will get updated anyway
            acct.Account_Number_Encrypted__c = encryptedAccountNumber;
            insert acct;
            System.debug('New Account is created in Salesforce. Account Id - ' + acct.Id);
        }
        else
        {
            // Account number is already available locally, this little searialization magic will help to make sure there are
            // no exceptions when working with Account object fields which are not queried in SOQL
            acct = (Account) JSON.deserialize(JSON.serialize(accts[0]), Account.class);
            System.debug('Account already exists in Salesforce. Id - ' + acct.Id);
        }

        String requestBody = req.requestBody.toString();
        PrefetchDataDO prefetchData;

        try {
            prefetchData = PrefetchDataDO.parse(requestBody);
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'Failed to Parse the request body to get the prefetched data. Exception - ' + e.getMessage());
            res = handleHttpBadRequest(res, 'Improper Request Body - Failed to parse the data');
            return;
        }

        if ((prefetchData == null) || (prefetchData.customer_360 == null))
        {
            System.debug(LoggingLevel.ERROR, 'Pre-fetched data is not available after parsing');
            res = handleHttpBadRequest(res, 'Improper Request Body - Failed to find Customer360 data inside the body');
            return;
        }
        
        // Great, we have the account and we have the data to store into the account. Lets get ready to store the data into Salesforce objects
        // We should do this asynchronously without letting the client to wait for us to complete the work.
        PrefetchDataHandlerAsync storePrefetchDataJob = new PrefetchDataHandlerAsync(acct, prefetchData, ExecutionContextUtil.getContextDataAsJSON());
        ID jobId = System.enqueueJob(storePrefetchDataJob);
        System.debug('Successfully queued the Prefetch data processing Job. Job Id - ' + jobId);

        // Prepare for the successful response
        res = handleHttpSuccess(res, acct.Id, jobId);

        // All Done! Well Done!
        System.debug('PrefetchWebService:storePrefetchData - End');
        return;
    }

    private static RestResponse handleHttpBadRequest(RestResponse response, String errorMessage)
    {
        StorePrefetchDataServiceResponse body = new StorePrefetchDataServiceResponse();
        body.status = false;
        body.error_message = errorMessage;

        response.statusCode = 400;
        response.addHeader('Content-Type', 'application/json');
        response.responseBody = Blob.valueof(JSON.serialize(body));
        return response;
    }

    private static RestResponse handleHttpSuccess(RestResponse response, String accountId, String jobId)
    {
        StorePrefetchDataServiceResponse body = new StorePrefetchDataServiceResponse();
        body.status = true;
        body.account_id = accountId;
        body.async_process_id = jobId;

        response.statusCode = 202; // HTTP Code for ACCEPTED - Since the request will be processed asynchronously
        response.addHeader('Content-Type', 'application/json');
        response.responseBody = Blob.valueof(JSON.serialize(body));
        return response;
    }

    private static List<Account> queryAccount(String encryptedAccountNumber)
    {
        return [SELECT Id, Account_Number_Encrypted__c, AccountNumber
                FROM Account
                WHERE Account_Number_Encrypted__c = :encryptedAccountNumber LIMIT 1];
    }

    global class StorePrefetchDataServiceResponse
    {
        public String account_id;
        public String async_process_id;
        public Boolean status;
        public String error_message;
    }

}