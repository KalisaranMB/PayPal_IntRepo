/**
* ──────────────────────────────────────────────────────────────────────────────────────┐
* Swagger codegen generated Apex class of getContext API response model.
*
* Part of contact-contexts API response model class.
* ──────────────────────────────────────────────────────────────────
* @author         Sugyan Sahu   <sugsahu@paypal.com>
* @version        1.0
* @created        2020-08-24
* ──────────────────────────────────────────────────────────────────
* @changes
* v1.0            sugsahu@paypal.com
* 2020-08-24      Created the class as part of integration to contact-contexts API.
* ──────────────────────────────────────────────────────────────────────────────────────┘
**/
public with sharing class Context {
    /**
     * Context Timed UUID.
     * @return contextId
     */
    @AuraEnabled
    public String context_id { get; set; }

    /**
     * Calling channel.
     * @return channel
     */
    @AuraEnabled
    public String channel { get; set; }

    /**
     * Context initiated channel for. Eg. IVR, Help Center, Info Center, Live Chat, Email.
     * @return initiatedChannel
     */
    @AuraEnabled
    public String initiated_channel { get; set; }

    /**
     * Context updated channel for. Eg. IVR, Help Center, Info Center, Live Chat, Email.
     * @return updatedChannel
     */
    @AuraEnabled
    public String updated_channel { get; set; }

    /**
     * A lifecycle that involves a resource which could have many states.
     * @return status
     */
    @AuraEnabled 
    @InvocableVariable
    public String status;

    /**
     * Customer identifier number.
     * @return customerId
     */
    @AuraEnabled
    @InvocableVariable
    public String customer_id;

    /**
     * The standard PayPal Customer Account Number.
     * @return customerAccountNumber
     */
    @AuraEnabled
    public String customer_account_number { get; set; }

    /**
     * Customer Party Id.
     * @return partyId
     */
    @AuraEnabled
    public String party_id { get; set; }

    /**
     * Type of the customer associated with this context.
     * @return customerType
     */
    @AuraEnabled
    public String customer_type { get; set; }

    /**
     * Tenant ID for. Eg. PayPal, Venmo.
     * @return tenantId
     */
    @AuraEnabled
    public String tenant_id { get; set; }

    /**
     * Message details for Context.
     * @return contextMessage
     */
    @AuraEnabled 
    @InvocableVariable
    public String context_message;

    /**
     * System source where the intent originated from.
     * @return intentSource
     */
    @AuraEnabled
    public String intent_source { get; set; }

    /**
     * The field identifies if customer confirmed the presented context.
     * @return customerConfirmed
     */
    @AuraEnabled
    public Boolean customer_confirmed { get; set; }

    /**
     * The action Id unique to a predicted intent.
     * @return predictedActionId
     */
    @AuraEnabled
    public String predicted_action_id { get; set; }

    /**
     * The action name unique to a predicted intent.
     * @return predictedActionName
     */
    @AuraEnabled
    public String predicted_action_name { get; set; }

    /**
     * The action list Id unique to predicted intents.
     * @return predictedActionListId
     */
    @AuraEnabled
    public String predicted_action_list_id { get; set; }

    /**
     * Intent for a context.
     * @return intent
     */
    @AuraEnabled
    @InvocableVariable
    public ContextIntent intent;

    /**
     * Authentication details for customer.
     * @return authentication
     */
    @AuraEnabled
    public ContextAuthentication authentication { get; set; }

    /**
     * Payload Details.
     * @return payload
     */
    @AuraEnabled
    public List<KeyValue> payload { get; set; }

    /**
     * Suggested solutions.
     * @return suggestedSolutions
     */
    @AuraEnabled
    public SuggestedSolution suggested_solutions { get; set; }

    /**
     * Language of the utterance being passed.
     * @return locale
     */
    @AuraEnabled
    public String locale { get; set; }

    /**
     * Country of the account making the request.
     * @return countryCode
     */
    @AuraEnabled
    public String country_code { get; set; }

    public Context() {
        payload = new List<KeyValue>();
    }
    
}