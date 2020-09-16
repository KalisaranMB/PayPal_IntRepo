/*
 * ─────────────────────────────────────────────────────────────────┐
 * Class for housing all the fields needed for UI Components.
 * ──────────────────────────────────────────────────────────────────
 * 
 * @author Sugyan Sahu <sugsahu@paypal.com>
 * 
 * @changes v1.0 sugsahu@paypal.com
 * 2020-08-24 Created the class as part of integration to contact-contexts API.
 * ─────────────────────────────────────────────────────────────────┘
 * 
 * @created 2020-08-24
 * ──────────────────────────────────────────────────────────────────
 * 
 * @version 1.0
 */
public class Intent implements Comparable {

    @AuraEnabled
    @InvocableVariable
    public String customerIntent;

    @AuraEnabled
    @InvocableVariable
    public String internalIntent;

    @AuraEnabled
    @InvocableVariable
    public Integer intentPriority;

    public Intent() {
    }

    public Integer compareTo(Object param) {
        Intent other = (Intent)param;

        if (this.intentPriority > other.intentPriority) {
            return 1;
        } else if (this.intentPriority < other.intentPriority) {
            return -1;
        } else
            return 0;
    }
}