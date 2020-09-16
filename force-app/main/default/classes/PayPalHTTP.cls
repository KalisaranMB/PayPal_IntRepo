/* PayPalHTTP Class should be used to make any API callout to PayPal. Apart from making HTTP requests which can
 * be handled without this class too, this class adds some functionalities on top like generating a correlation id
 * for tracking API calls across multiple components, using the right named credentials depending on whether the
 * current user is a System or Teammate and so on. It also takes care of logging appropriate failures. Having this
 * centralized control will help us to add more such capabilities in future without modifying the code in multiple places.
 */
public class PayPalHTTP {
    public static HttpResponse send(HttpRequest request)
    {
        // Some basic checks to see if we can move forward
        if (request == null || String.isBlank(request.getEndpoint()))
        {
            System.debug('HttpRequest object is not in good shape to make an API call - returning');
            return null;
        }

        // Create a full endpoint from the path, the consumers of PayPalHTTP class must only add path when they
        // set endpoint in the HttpRequest Class. PayPalHTTP will do the extra necessary work.
        String endPoint =  'callout:' + ExecutionContextUtil.getPayPalNamedCredential();
        if (!request.getEndpoint().startsWith('/'))
        {
            endPoint += '/';
        }
        endPoint += request.getEndpoint();
        request.setEndpoint(endpoint);

        // Set Correlation Id header
        String correlationId = ExecutionContextUtil.getPayPalCorrelationId();
        if (ExecutionContextUtil.isCorrelationIdEnabled() && String.isNotBlank(correlationId))
        {
            request.setHeader('HTTP_X_PP_CORRID', correlationId);
            request.setHeader('X-PP-CORRID', correlationId);
        }

        // Set Security Context header if we have a valid security context
        String securityContext = ExecutionContextUtil.getPayPalSecurityContextJSON();
        if (String.isNotBlank(securityContext))
        {
            request.setHeader('Admin-App-Security-Context', securityContext);
        }

        // Add required header if CSDAS should retrieve fresh data instead of using its cache
        if (ExecutionContextUtil.getSkipServerSideCache())
        {
            request.setHeader('Prefer', 'read-consistent');
        }

        // Set the Paypal API timeout value
        request.setTimeout(ExecutionContextUtil.getPayPalAPITimeout());

        try
        {
            // Enough! Lets make an API call
            System.debug('Making an API Callout to PayPal: HTTP Method - ' + request.getMethod() + ', EndPoint - ' + request.getEndpoint());
            HttpResponse response = new Http().send(request);
            System.debug('PayPal API Callout completed : HTTP Response Code - ' + response.getStatusCode());

            // 2XX - Success
            if ((response.getStatusCode() >= 200) && (response.getStatusCode() < 300))
            {
                // Great
                System.debug('PayPal API Callout successfully completed: HTTP Code - ' + response.getStatusCode());
            }
            else if (response.getStatusCode() == 401)
            {
                // Unauthorized. This should never happen unless there is some issue with the auth credentials itself that we use
                // to connect with PayPal APIs. Named Credentials will internally manage the expiry and refresh of tokens.
                System.debug(LoggingLevel.ERROR, 'PayPal API Callout failed with Unauthorized error: Response body - ' + response.getBody());
            }
            else if ((response.getStatusCode() == 400) || (response.getStatusCode() == 403) ||
                     (response.getStatusCode() == 404) || (response.getStatusCode() == 500))
            {
                // Just log some error details into the log. It is caller's responsibility to decide on how they want to handle this scenario
                if (String.isNotBlank(response.getBody()))
                {
                    PayPalAPIErrorDO errorObj = PayPalAPIErrorDO.parse(response.getBody());
                    String errorMessage = ' Name - ' + errorObj.name + ', Message - ' + errorObj.message + ', Debug Id - ' + errorObj.debug_id;
                    System.debug(LoggingLevel.ERROR, 'PayPal API Callout failed: HTTP Code - ' + response.getStatusCode() + ', Details - ' + errorMessage);
                }
            }
            else {
                // Unexpected error code, but thats fine
                System.debug(LoggingLevel.ERROR, 'PayPal API Callout failed: Response body - ' + response.getBody());
            }

            return response;
        }
        catch (Exception e)
        {
            System.debug(LoggingLevel.ERROR, 'Exception occurred while making PayPal API Callout: Exception Type - ' + e.getTypeName()
                                                                                        + ', Exception Message - ' + e.getMessage());
        }

        return null;
    }
}