/*
    Controller to risk override after successfule auth step Up by calling CDAS API "evaluateRiskCheckOverride"
    
*/

global with sharing class Override_FlowController {
    @InvocableMethod
    public static List<OverrideResponeWrapper> riskOverride(List<overrideRequest> overrideRequests) {
        String accountNumber = overrideRequests.get(0).accountNumber;
        String authFlowContextId = overrideRequests.get(0).authFlowContextId;
        
        List<OverrideResponeWrapper> OverrideResponeWrapperList = new List<OverrideResponeWrapper>();
        String entryPoint = 'callout:CSDAS_EntryPoint';  
        String url = 'callout:CSDAS_Contexts/v1/customer-support/'+accountNumber+'/evaluate-riskcheck-overrides';

        OverrideResponeWrapper overrideResponeWrapper = new OverrideResponeWrapper();
        try{
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint(url);
            request.setMethod('POST');
            request.setHeader('Content-Type', 'application/json;charset=UTF-8');
            request.setBody('{ "id": '+authFlowContextId+'}');
            // time out
            HttpResponse response = http.send(request);
            if (response.getStatusCode() == 200) {
                
                OverrideRespone overrideRespone = OverrideRespone.parse(response.getBody());
                overrideResponeWrapper.overrideRespone = overrideRespone;
                overrideResponeWrapper.status = true;
                
                System.debug(overrideRespone);
                
            }  else {
                System.debug('StatusCode: ' + response.getStatusCode());
                System.debug('Raw Res: ' + response.getBody());

                Error error = (Error) Error.parse(response.getBody());
                overrideResponeWrapper.status = false;
                overrideResponeWrapper.errorMsg = error.message;
                overrideResponeWrapper.debug_id = error.debug_id;
                overrideResponeWrapper.overrideRespone = null;
            }
        }catch (Exception exc) {
            System.debug('Error in Override_FlowController: '+exc.getMessage());
        } finally {

        } 
        OverrideResponeWrapperList.add(overrideResponeWrapper);
        return OverrideResponeWrapperList;
    }    
    
    
    global class overrideRequest{
        @InvocableVariable
        global String accountNumber;
        @InvocableVariable
        global String authFlowContextId;
    }
    global class OverrideResponeWrapper { 
        @InvocableVariable
        global OverrideRespone overrideRespone;
        
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
    
}