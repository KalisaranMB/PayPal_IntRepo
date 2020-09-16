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
public with sharing class ContextIntent {
    /**
     * Intent Code.
     * @return code
     */
    @AuraEnabled
    @InvocableVariable
    public String code;

    /**
     * For the intent structure, we may have multiple internal treatments for different customer intent.
     * @return internalTreatment
     */
    @AuraEnabled
    @InvocableVariable
    public String internal_treatment;

    /**
     * Customer Intent for. Eg. Add Bank, Add Card, Verify Bank, Update Bank, Gift Card.
     * @return customerIntent
     */
    @AuraEnabled
    @InvocableVariable
    public String customer_intent;

    /**
     * Category of the intent.
     * @return category
     */
    @AuraEnabled
    @InvocableVariable
    public String category;

    /**
     * Sub category of the intent.
     * @return subCategory
     */
    @AuraEnabled
    @InvocableVariable
    public String sub_category;

    /**
     * Priority of the intent.
     * minimum: 0
     * maximum: 2147483647
     * @return priority
     */
    @AuraEnabled
    @InvocableVariable
    public Integer priority;

    /**
     * The confidence of the intent that was predicted.
     * minimum: 0.0
     * maximum: 100.0
     * @return score
     */
    @AuraEnabled
    @InvocableVariable
    public Double score;
    
}