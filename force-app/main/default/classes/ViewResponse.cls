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
public virtual class ViewResponse {

	@AuraEnabled
	@InvocableVariable
	public Integer statusCode;

	@AuraEnabled
	@InvocableVariable
	public String debugId;

	@AuraEnabled
	@InvocableVariable
	public ViewError viewError;

	@AuraEnabled
	@InvocableVariable
	public String serializedResponse;

}