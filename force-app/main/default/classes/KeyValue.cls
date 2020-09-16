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
public with sharing class KeyValue {
    /**
     * A key, for example <code>reference_id</code>.
     * @return key
     */
    @AuraEnabled
    public String key { get; set; }

    /**
     * The value of the key.
     * @return value
     */
    @AuraEnabled
    public String value { get; set; }
    
}