/*
    Controller to validate OTP for Phone number for SMS stepUp Auth by calling CDAS API "validateStepUp"
    
*/

global with sharing class OTPValidation_FlowController {
    @InvocableMethod
    public static List<StepUpResponse> validateOtp(List<StepUpRequest> stepUpRequests) {
        String accountNumber = stepUpRequests.get(0).accountNumber;
        String challenge_id = stepUpRequests.get(0).challenge_id;
        StepUpValidationRequest stepUpValidationRequest = new StepUpValidationRequest();
        stepUpValidationRequest.selection='sms';
        SmsValidation smsValidation = new SmsValidation();
        smsValidation.country_code = stepUpRequests.get(0).country_code;
        smsValidation.phone_number = stepUpRequests.get(0).phone_number;
        smsValidation.answer = stepUpRequests.get(0).answer;
        stepUpValidationRequest.sms = smsValidation;

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
        global String country_code;
        @InvocableVariable
        global String phone_number;
        @InvocableVariable
        global String answer;
    }
    
}