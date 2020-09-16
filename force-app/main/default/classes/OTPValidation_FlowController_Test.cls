@isTest
private class OTPValidation_FlowController_Test {    
	
    @isTest
    private static void validateOtpTest(){
        List<OTPValidation_FlowController.StepUpRequest> stepUpRequests = prepareRequest();
        List<StepUpResponse> expectedResponse = prepareExpectedResponse();
        String responseBody = '{"status": "PASSED", "challenge_id": "12345", "availableOptions": ["kba"], "sms": {"status":"PASSED"} }';
        HTTPMockFactory mock = new HTTPMockFactory(200, 'OK', responseBody, new Map<String, String>());
        Test.setMock(HttpCalloutMock.class, mock); 
        test.startTest();
        List<StepUpResponse> actualResponse = OTPValidation_FlowController.validateOtp(stepUpRequests);
        System.assertEquals(expectedResponse.toString(), actualResponse.toString());
        test.stopTest();
    }
    
	@isTest
    private static void validateOtpTest_Error() {
        String responseBody = '{"message":"Internal Server Error"}';
        HTTPMockFactory mock = new HTTPMockFactory(500, 'OK', responseBody, new Map<String, String>());
        Test.setMock(HttpCalloutMock.class, mock);
        test.startTest();        
        List<OTPValidation_FlowController.StepUpRequest> stepUpRequests = prepareRequest();
        List<StepUpResponse> actualResponse = OTPValidation_FlowController.validateOtp(stepUpRequests);        
        System.assertEquals('Internal Server Error', actualResponse.get(0).errorMsg);
        test.stopTest();
    }
    
    private static List<OTPValidation_FlowController.StepUpRequest> prepareRequest(){
        List<OTPValidation_FlowController.StepUpRequest> stepUpRequests = new List<OTPValidation_FlowController.StepUpRequest>();
        OTPValidation_FlowController.StepUpRequest stepUpRequest = new OTPValidation_FlowController.StepUpRequest();
        stepUpRequest.accountNumber = '1234';
        stepUpRequest.challenge_id = '1243432';
        stepUpRequest.country_code = '1';
        stepUpRequest.phone_number = '345345667';
        stepUpRequests.add(stepUpRequest);
        return stepUpRequests;
    }
    
    private static List<StepUpResponse> prepareExpectedResponse(){
        List<StepUpResponse> stepupResponses = new List<StepUpResponse>();
        Stepup stepup = new Stepup();
        List<String> options = new List<String>();
        options.add('kba');
        stepup.availableOptions = options;
        stepup.challenge_id = '12345';
        stepup.status = 'PASSED';
        Sms sms = new Sms();
        sms.status = 'PASSED';
        stepup.sms = sms;
        StepUpResponse stepupResponse = new StepUpResponse();
        stepUpResponse.stepup = stepup;
        stepUpResponse.status = true;
        stepupResponses.add(stepupResponse);
        return stepupResponses;   
    }
}