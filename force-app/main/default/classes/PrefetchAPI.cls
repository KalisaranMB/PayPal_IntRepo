public class PrefetchAPI {

    // Asynchronous / future callout
    // We could have designed another queueable apex, but using future callouts will keep the implementation simple
    // This method will directly invoke Prefetch API call without evaluating any of the reliability or concurrency
    // considerations implemented in the TriggerPrefetchAsync Queueable. So do not call this method for majority of
    // the usecases unless we have a solid reason which needs to be discussed with the leads.
    @future(callout=true)
    public static void triggerPrefetchAsync(String encryptedAccountNumber, Boolean pushDataAfterPrefetch, String contextJSON)
    {
        System.debug('PrefetchAPI:triggerPrefetchAsync - Start of triggering pre-fetch request to the service');

        // Lets set the current execution context - Please note that Async operations will have to carry the
        // context from the previous execution context so that we will have this execution as a continuation to
        // the previous one in terms of the context parameters like the security context, correlation id and so on
        ExecutionContextUtil.initContextData(contextJSON);
        triggerPrefetch(encryptedAccountNumber, pushDataAfterPrefetch);
        System.debug('PrefetchAPI:triggerPrefetchAsync - End');
        return;
    }

    // Trigger Prefetch
    public static Boolean triggerPrefetch(String encryptedAccountNumber, Boolean pushDataAfterPrefetch)
    {
        // Encrypted Account number is must for the Prefetch API call
        if (String.isBlank(encryptedAccountNumber))
        {
            System.debug(LoggingLevel.ERROR, 'Encrypted account number is null or blank in the request');
            return false;
        }

        // Form the endpoint without named credentials since PayPalHTTP class will decide which
        // named credential to use based on the current context.
        String endPoint = '/accounts/' + encryptedAccountNumber + '/prefetch';

        if (pushDataAfterPrefetch)
        {
            // We need to request CSDAS service to push data to Salesforce after pre-fetch
            // The client will not wait for the whole pre-fetch to complete since it is a long running operation
            endPoint += '?send_prefetch_data=true';
        }
        else {
            endPoint += '?send_prefetch_data=false';
        }
        
        // TBD - Is the method GET or POST?
        // What is the parameter to send / ask to push the data to salesforce?
        // Do we need to add any headers in ExecutionContextUtil to make this as asynchronous processing?
        HttpRequest httpReq = new HttpRequest();
        httpReq.setMethod('GET');
        httpReq.setEndpoint(endPoint);

        // Set timeout configured specifically for Prefetch API - Deviating from Default Timeout which is slightly higher
        // than what is needed for prefetch
        ExecutionContextUtil.setPayPalAPITimeout('PayPalPrefetchAPI');

        HttpResponse httpRes = PayPalHTTP.send(httpReq);

        // Any Failure
        if ((httpRes == null) || (httpRes.getStatusCode() >= 300))
        {
            System.debug(LoggingLevel.ERROR, 'Failed to trigger Pre-fetch, this is a serious issue');
            return false;
        }

        // Great, its a Success!
        System.debug('Successfully triggered the Pre-fetch');
        return true;
    }

}