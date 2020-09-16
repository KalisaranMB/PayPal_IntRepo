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
public with sharing class SuggestedSolution {

	@AuraEnabled
	public 	String target_flow {get; set;}

	@AuraEnabled
	public  String prompt_id {get; set;}

	@AuraEnabled
	public  String faq_id {get; set;}

	@AuraEnabled
	public  String interactive_content_flow_id {get; set;}
	
	public SuggestedSolution(){}
	
}