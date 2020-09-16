@isTest
private class OTPGenerator_FlowController_Test {
    
	@isTest
    private static void generateOtpTest(){
        List<OTPGenerator_FlowController.StepUpRequest> stepUpRequests = prepareRequest();
        List<StepUpResponse> expectedResponse = prepareExpectedResponse();
        String responseBody = '{"status": "IN_PROGRESS", "challenge_id": "12345", "availableOptions": ["sms", "kba"], "sms": {"status":"OTP_SENT"} }';
        HTTPMockFactory mock = new HTTPMockFactory(200, 'OK', responseBody, new Map<String, String>());
        Test.setMock(HttpCalloutMock.class, mock); 
        test.startTest();
        List<StepUpResponse> actualResponse = OTPGenerator_FlowController.generateOtp(stepUpRequests);
        System.assertEquals(expectedResponse.toString(), actualResponse.toString());
        test.stopTest();
    }
    
	@isTest
    private static void generateOtpTest_Error() {
        String responseBody = '{"message":"Internal Server Error"}';
        HTTPMockFactory mock = new HTTPMockFactory(500, 'OK', responseBody, new Map<String, String>());
        Test.setMock(HttpCalloutMock.class, mock);
        test.startTest();        
        List<OTPGenerator_FlowController.StepUpRequest> stepUpRequests = prepareRequest();
        List<StepUpResponse> actualResponse = OTPGenerator_FlowController.generateOtp(stepUpRequests);        
        System.assertEquals('Internal Server Error', actualResponse.get(0).errorMsg);
        test.stopTest();
    }
    
    private static List<OTPGenerator_FlowController.StepUpRequest> prepareRequest(){
        List<OTPGenerator_FlowController.StepUpRequest> stepUpRequests = new List<OTPGenerator_FlowController.StepUpRequest>();
        OTPGenerator_FlowController.StepUpRequest stepUpRequest = new OTPGenerator_FlowController.StepUpRequest();
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
        options.add('sms');
        options.add('kba');
        stepup.availableOptions = options;
        stepup.challenge_id = '12345';
        stepup.status = 'IN_PROGRESS';
        Sms sms = new Sms();
        sms.status = 'OTP_SENT';
        stepup.sms = sms;
        StepUpResponse stepupResponse = new StepUpResponse();
        stepUpResponse.status = true;
        stepUpResponse.stepup = stepup;
        stepupResponses.add(stepupResponse);
        return stepupResponses;   
    }
    
	//String otpFailureRespone = '{"status": "IN_PROGRESS", "challenge_id": "12345", "available_options": ["sms", "kba"], "sms": {"status":"OTP_SENDING_FAILED", "reason": "INTERNAL_ERROR"} }';   
}