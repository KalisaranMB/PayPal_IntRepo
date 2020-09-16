/*
    Controller to Get KBA questions by calling CDAS API "validateStepUp"
    
*/

global with sharing class GetKBAQuestions_FlowController {
    @InvocableMethod
    public static List<StepUpResponse> getKBAQuestions(List<StepUpRequest> stepUpRequests) {

        // Request creation
        String accountNumber = stepUpRequests.get(0).accountNumber;
        String challenge_id = stepUpRequests.get(0).challenge_id;
        StepUpValidationRequest stepUpValidationRequest = new StepUpValidationRequest();
        stepUpValidationRequest.selection='kba';

        List<StepUpResponse> StepUpResponses = new List<StepUpResponse>();
        StepUpResponse stepUpResponse =  StepUpApiUtils.callStepUp(accountNumber, challenge_id, stepUpValidationRequest);
        StepUpResponses.add(stepUpResponse);

        return StepUpResponses;
    }    
    
    global class StepUpRequest{
        @InvocableVariable
        global String accountNumber;
        @InvocableVariable
        global String challenge_id;
    }
    
}