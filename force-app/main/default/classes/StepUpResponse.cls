/*
    Step Up Response Wrapper for step Up API
    It contains 
    stepup - stepup response object
    errorMsg - error msg if any
    debug_id -debug id
    status - true for API success & false for API error
    
*/

public class StepUpResponse {
    @AuraEnabled
    @InvocableVariable
    public Stepup stepup;

    @AuraEnabled
    @InvocableVariable
    public string errorMsg;

    @AuraEnabled
    @InvocableVariable
    public string debug_id;

    @AuraEnabled
    @InvocableVariable
	public Boolean status;
}