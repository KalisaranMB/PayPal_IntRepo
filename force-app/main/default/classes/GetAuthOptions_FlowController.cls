/*
    Controller to get Auth Step Up Options by calling CDAS API
    
*/

global with sharing class GetAuthOptions_FlowController {
    @InvocableMethod
    public static List<StepUpResponse> getAuthOption(List<AuthRequest> authRequests) {

        // Request parameters
        String accountNumber = authRequests.get(0).accountNumber;
        String authFlowContextId = authRequests.get(0).authFlowContextId;

        List<StepUpResponse> StepUpResponses = new List<StepUpResponse>();
        StepUpResponse stepUpResponse = StepUpApiUtils.getAuthOptions(accountNumber, authFlowContextId);
        StepUpResponses.add(stepUpResponse);
        return StepUpResponses;
    }    
    
    
    global class AuthRequest{
        @InvocableVariable
        global String accountNumber;
        @InvocableVariable
        global String authFlowContextId;
    }
    
}