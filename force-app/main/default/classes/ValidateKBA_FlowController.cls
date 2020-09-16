/*
    Controller to validate KBA answer in KBA auth step UP by calling CDAS API "validateStepUp"
    
*/

global with sharing class ValidateKBA_FlowController {
    @InvocableMethod
    public static List<StepUpResponse> validateKBA(List<StepUpRequest> stepUpRequests) {
        String accountNumber = stepUpRequests.get(0).accountNumber;
        String challenge_id = stepUpRequests.get(0).challenge_id;
        StepUpValidationRequest stepUpValidationRequest = new StepUpValidationRequest();
        stepUpValidationRequest.selection='kba';
        KbaValidation kbaValidation = new KbaValidation();
        kbaValidation.answer = stepUpRequests.get(0).answers;
        stepUpValidationRequest.kba = kbaValidation;

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
        @InvocableVariable
        global List<Answer> answers;
    }
    
}