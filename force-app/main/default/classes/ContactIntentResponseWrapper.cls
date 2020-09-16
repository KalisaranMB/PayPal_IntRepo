/**
* ─────────────────────────────────────────────────────────────────┐
* Wrapper class for contact-context API responses.
*
* contact-contexts API response wrapper class hosting error & response objects.
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
public with sharing class ContactIntentResponseWrapper {

    @AuraEnabled
    @InvocableVariable
    public Integer statusCode;

    //UI Specific Container
    @AuraEnabled
    @InvocableVariable
    public ContactIntentResponse response;

    @AuraEnabled
    @InvocableVariable
    public Error error;

}