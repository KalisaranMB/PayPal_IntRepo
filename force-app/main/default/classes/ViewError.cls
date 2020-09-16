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
* 2020-08-24      Created the class as part of integration to Apex Design Patterns.
* ─────────────────────────────────────────────────────────────────┘
*/
public virtual class ViewError {
	
	@AuraEnabled
	@InvocableVariable
	public String errorMessage;

}