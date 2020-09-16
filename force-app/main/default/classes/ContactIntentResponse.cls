/**
* ─────────────────────────────────────────────────────────────────┐
* Class for housing all the fields needed for UI Components.
*
* 
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
public class ContactIntentResponse {
	
	@AuraEnabled
	@InvocableVariable
	public List<Intent> intents;
	
	public ContactIntentResponse(){}

}