@isTest
private class ValidateKBA_FlowController_Test {
    @isTest
    private static void validateKBATest_SUCCESS() {
        List<ValidateKBA_FlowController.StepUpRequest> stepUpRequests = new List<ValidateKBA_FlowController.StepUpRequest>();
        ValidateKBA_FlowController.StepUpRequest stepUpRequest = prepareRequest();
        stepUpRequests.add(stepUpRequest);
        List<StepUpResponse> expectedResponse = prepareExpectedSuccessResponse();
        String responseBody = '{ "status": "PASSED", "challenge_id": "12345", "availableOptions": [], "kba": { "status": "PASSED" }}';
        HTTPMockFactory mock = new HTTPMockFactory(200, 'OK', responseBody, new Map<String, String>());
        Test.setMock(HttpCalloutMock.class, mock); 
        test.startTest();
        List<StepUpResponse> actualResponse = ValidateKBA_FlowController.validateKBA(stepUpRequests);
        System.assertEquals(expectedResponse.toString(), actualResponse.toString());
        test.stopTest();
    }

    @isTest
    private static void validateKBATest_PartialSUCCESS() {
        List<ValidateKBA_FlowController.StepUpRequest> stepUpRequests = new List<ValidateKBA_FlowController.StepUpRequest>();
        ValidateKBA_FlowController.StepUpRequest stepUpRequest = prepareRequest();
        stepUpRequests.add(stepUpRequest);
        List<StepUpResponse> expectedResponse = prepareExpectedPartialSuccessResponse();
        String responseBody = '{ "status": "IN_PROGRESS", "challenge_id": "12345", "availableOptions": ["kba"], "kba": { "status": "FAILED" ,"reason":"Partially correct KBA Answers"}}';
        HTTPMockFactory mock = new HTTPMockFactory(200, 'OK', responseBody, new Map<String, String>());
        Test.setMock(HttpCalloutMock.class, mock); 
        test.startTest();
        List<StepUpResponse> actualResponse = ValidateKBA_FlowController.validateKBA(stepUpRequests);
        System.assertEquals(expectedResponse.toString(), actualResponse.toString());
        test.stopTest();
    }

    @isTest
    private static void validateKBATest_Failed() {
        List<ValidateKBA_FlowController.StepUpRequest> stepUpRequests = new List<ValidateKBA_FlowController.StepUpRequest>();
        ValidateKBA_FlowController.StepUpRequest stepUpRequest = prepareRequest();
        stepUpRequests.add(stepUpRequest);
        List<StepUpResponse> expectedResponse = prepareExpectedFailedResponse();
        String responseBody = '{ "status": "FAILED", "challenge_id": "12345", "availableOptions": [], "kba": { "status": "FAILED" }}';
        HTTPMockFactory mock = new HTTPMockFactory(200, 'OK', responseBody, new Map<String, String>());
        Test.setMock(HttpCalloutMock.class, mock); 
        test.startTest();
        List<StepUpResponse> actualResponse = ValidateKBA_FlowController.validateKBA(stepUpRequests);
        System.assertEquals(expectedResponse.toString(), actualResponse.toString());
        test.stopTest();
    }


    @isTest
    static void validateKBATest_Error(){
        String responseBody = '{"message":"Internal Server Error"}';
        HTTPMockFactory mock = new HTTPMockFactory(500, 'OK', responseBody, new Map<String, String>());
        
        List<ValidateKBA_FlowController.StepUpRequest> stepUpRequests = new List<ValidateKBA_FlowController.StepUpRequest>();
        ValidateKBA_FlowController.StepUpRequest stepUpRequest = prepareRequest();
        stepUpRequests.add(stepUpRequest);

        Test.setMock(HttpCalloutMock.class, mock);
        test.startTest();
        List<StepUpResponse> actualResponse = ValidateKBA_FlowController.validateKBA(stepUpRequests);
        
        System.assertEquals('Internal Server Error', actualResponse.get(0).errorMsg);
        test.stopTest();
    }
    
    private static ValidateKBA_FlowController.StepUpRequest prepareRequest(){
        ValidateKBA_FlowController.StepUpRequest stepUpRequest = new ValidateKBA_FlowController.StepUpRequest();
        stepUpRequest.accountNumber = '1234';
        stepUpRequest.challenge_id = '1243432';
        return stepUpRequest;
    }
    
    private static List<StepUpResponse> prepareExpectedSuccessResponse(){
        List<StepUpResponse> stepupResponses = new List<StepUpResponse>();
        Stepup stepup = new Stepup();
        stepup.challenge_id = '12345';
        stepup.status = 'PASSED';
        Kba kba = new Kba();
        List<String> availOptions = new List<String>();
        stepup.availableOptions = availOptions;

        kba.status='PASSED';
        stepup.kba = kba;
        StepUpResponse stepupResponse = new StepUpResponse();
        stepUpResponse.status = true;
        stepUpResponse.stepup = stepup;
        stepupResponses.add(stepupResponse);
        return stepupResponses;   
    }

    private static List<StepUpResponse> prepareExpectedPartialSuccessResponse(){
        List<StepUpResponse> stepupResponses = new List<StepUpResponse>();
        Stepup stepup = new Stepup();
        stepup.challenge_id = '12345';
        stepup.status = 'IN_PROGRESS';
        Kba kba = new Kba();
        List<String> availOptions = new List<String>();
        availOptions.add('kba');
        stepup.availableOptions = availOptions;

        kba.status='FAILED';
        kba.reason='Partially correct KBA Answers';
        stepup.kba = kba;
        StepUpResponse stepupResponse = new StepUpResponse();
        stepUpResponse.status = true;
        stepUpResponse.stepup = stepup;
        stepupResponses.add(stepupResponse);
        return stepupResponses;   
    }

    private static List<StepUpResponse> prepareExpectedFailedResponse(){
        List<StepUpResponse> stepupResponses = new List<StepUpResponse>();
        Stepup stepup = new Stepup();
        stepup.challenge_id = '12345';
        stepup.status = 'FAILED';
        Kba kba = new Kba();
        List<String> availOptions = new List<String>();
        stepup.availableOptions = availOptions;

        kba.status='FAILED';
        stepup.kba = kba;
        StepUpResponse stepupResponse = new StepUpResponse();
        stepUpResponse.status = true;
        stepUpResponse.stepup = stepup;
        stepupResponses.add(stepupResponse);
        return stepupResponses;   
    }
}