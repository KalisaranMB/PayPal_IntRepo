/**
* ─────────────────────────────────────────────────────────────────┐
* Controller for contact-context API integration/callout.
*
* contact-contexts API callout class.
* ──────────────────────────────────────────────────────────────────
* @author         Sugyan Sahu   <sugsahu@paypal.com>
* @version        1.0
* @created        2020-08-24
* ──────────────────────────────────────────────────────────────────
* @changes
* v1.0            sugsahu@paypal.com
* 2020-08-24      Created the class as part of integration to contact-contexts API.
* ─────────────────────────────────────────────────────────────────┘
*/
public with sharing class ContactIntentController {

    public static final String endpoint = '/v1/customer-support/contexts';
    
    public ContactIntentController() {
    }
    
    @InvocableMethod(label = 'Get Intents')
    public static List<ContactIntentResponseWrapper> getIntents(List<List<String>> params) {
        List<ContactIntentResponseWrapper> wrappers = new List<ContactIntentResponseWrapper>();
        ContactIntentResponseWrapper wrapper = new ContactIntentResponseWrapper();
        ContextCollectionResponse contexts = null;
        HttpResponse response = null;
        try {
            response = getContexts(params[0][0], params[0][1]);

            // If the request is successful, parse the JSON response.
            if (response.getStatusCode() == 200) {
                System.debug('StatusCode: ' + response.getStatusCode());
                System.debug('Raw Res: ' + response.getBody());
                contexts = ContextCollectionResponse.parse(response.getBody());

                wrapper.statusCode = response.getStatusCode();
                wrapper.response = transform(contexts);

                for (Context v : contexts.items) {
                    System.debug('contextId: ' + v.context_id);
                    System.debug('updatedChannel: ' + v.updated_channel);
                    System.debug('customerIntent: ' + v.intent.customer_intent);
                    System.debug('internal_treatment: ' + v.intent.internal_treatment);
                    System.debug('priority: ' + v.intent.priority);
                    System.debug('status: ' + v.status);
                }
            } else {
                System.debug('StatusCode: ' + response.getStatusCode());
                System.debug('Raw Res: ' + response.getBody());

                Error error = (Error) Error.parse(response.getBody());
                wrapper.statusCode = response.getStatusCode();
                wrapper.error = error;
                wrapper.response = null;
            }
        }catch (Exception exc) {
            System.debug('Error in CustomerIntentController: '+exc.getMessage());
        } finally {

        } 
        
        wrappers.add(wrapper);
        
        return wrappers;
    }
    
    
    public static HttpResponse getContexts(String accNum, String channelName) {
        String url = 'callout:CSDAS_Contexts'+endpoint;
        if (accNum == null) {
            System.debug('getContexts(): Account Number is NULL');
            return null;
        } else {
            url += '?customer_id=' + accNum;
        }

        //Because channelName is Optional parameter.
        if (channelName != null) {
            url += '&channel_name=' + channelName;
        }

        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(url);
        request.setMethod('GET');
        
        return http.send(request);
    }
    
    
    private static ContactIntentResponse transform(ContextCollectionResponse response) {
        ContactIntentResponse contactIntentResponse = new ContactIntentResponse();
        List<Intent> intentList = new List<Intent>();
        
        if (response != null && response.items != null) {
            for (Context context : response.items) {
                if (context.intent != null && context.status.equalsIgnoreCase('ACTIVE')) {
                    Intent intent = new Intent();
                    intent.customerIntent = context.intent.customer_intent;
                    intent.internalIntent = context.intent.internal_treatment;
                    intent.intentPriority = context.intent.priority;
                    intentList.add(intent);
                }
            }
        }
        
        intentList.sort(); //Sorting intents based on their priority.
        
        contactIntentResponse.intents = intentList;
        return contactIntentResponse;
    }
}