public class FlowRouterController {
    @AuraEnabled
    public static String getCurrentFlowName(String caseId) {
        //Q4
        //Get Primary Intent, By api call
        //Get SubIntent, By api call
        //Return the Flow API Name from Custom Metadata Table
        //Q1
        //Get Case Status
        //Depending on the Case Status Route to
        //New: Confirm Intent
        //Closed: Wrap Up
        //Working: Look up the lastest Task and get the flow name from the task
        /*String result; 
        List<Case> aListOfCases = [SELECT Current_Status__c, Status FROM Case WHERE Id =: caseId];
        if(!aListOfCases.isEmpty()) {
            Case aCase = aListOfCases[0];
            if(String.isEmpty(aCase.Current_Status__c) || aCase.Current_Status__c == 'New') {
                result = 'Confirm_Intent_Flow';
            } else if(aCase.Current_Status__c == 'Working') {
                result = 'Intent_Payment_Decline_ATO_Decline';
            } else if(aCase.Current_Status__c == 'Closed') {
                
            }
        }
        return result; 
        */
        //Payment Decline
        //Internal Sub-Intent
        //Fetch the actual flow name from Custom metadata
        //return ABC
        return 'Intent_Payment_Decline_ATO_Decline';
    }
}