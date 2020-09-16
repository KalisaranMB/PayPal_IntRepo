/*
    Class to call step Up APIs
    
*/

global with sharing class StepUpApiUtils {

    // Post API call for stepUp
    public static StepUpResponse callStepUp(String accountNumber, String challenge_id, StepUpValidationRequest stepUpValidationRequest){
        StepUpResponse stepUpResponse = new StepUpResponse();
        String entryPoint = 'callout:CSDAS_EntryPoint';
        String url = 'callout:CSDAS_Contexts/v1/customer-support/'+accountNumber+'/stepup/'+challenge_id+'?entry_point='+entryPoint;

        try{
            Http http = new Http();
            HttpRequest request = new HttpRequest();
        
            request.setEndpoint(url);
            request.setMethod('POST');
            request.setHeader('Content-Type', 'application/json;charset=UTF-8');
            String body = JSON.serialize(stepUpValidationRequest);
            request.setBody(body);
            // time out
            HttpResponse response = http.send(request);
            if (response.getStatusCode() == 200) {
                 
                Stepup stepUp = Stepup.parse(response.getBody());
                stepUpResponse.Stepup = stepUp;
                stepUpResponse.status = true;
                
                System.debug('API successfully completed Raw Res: '+stepUp);
                
            } else {
                System.debug('StatusCode: ' + response.getStatusCode());
                System.debug('Raw Res: ' + response.getBody());

                Error error = (Error) Error.parse(response.getBody());
                stepUpResponse.status = false;
                stepUpResponse.debug_id = error.debug_id;
                stepUpResponse.errorMsg = error.message;
                stepUpResponse.stepup = null;
            }
        }catch (Exception exc) {
            System.debug('Error in AuthStepUp_FlowController: '+exc.getMessage());
        } finally {

        } 
        return stepUpResponse;
    }

    // Get API call for getting auth step Up options
    public static StepUpResponse getAuthOptions(String accountNumber, String authFlowContextId){

        String entryPoint = 'callout:CSDAS_EntryPoint'; 
        String url = 'callout:CSDAS_Contexts/v1/customer-support/'+accountNumber+'/stepup?entry_point='+entryPoint+'&auth_flow_context_id='+authFlowContextId;

        StepUpResponse stepUpResponse = new StepUpResponse();
        try{
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint(url);
            request.setMethod('GET');
            // connection timeout 
            HttpResponse response = http.send(request);
            if (response.getStatusCode() == 200) {
                
                Stepup stepUp = Stepup.parse(response.getBody());
                stepUpResponse.Stepup = stepUp;
                stepUpResponse.status = true;
                
                System.debug('API successfully completed Raw Res: '+stepUp);
                
            }  else {
                System.debug('StatusCode: ' + response.getStatusCode());
                System.debug('Raw Res: ' + response.getBody());
                Error error = (Error) Error.parse(response.getBody());
                stepUpResponse.status = false;
                stepUpResponse.errorMsg = error.message;
                stepUpResponse.debug_id = error.debug_id;
                stepUpResponse.stepup = null;
            }
        }catch (Exception exc) {
            System.debug('Error in GetAuthOptions_FlowController: '+exc.getMessage());
        } finally {

        } 

        return stepUpResponse;
    }
}