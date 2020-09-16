@isTest
private class GetKBAQuestions_FlowController_Test {
    @isTest
    private static void getKbaQuestionsTest() {
        List<GetKBAQuestions_FlowController.StepUpRequest> stepUpRequests = new List<GetKBAQuestions_FlowController.StepUpRequest>();
        GetKBAQuestions_FlowController.StepUpRequest stepUpRequest = prepareRequest();
        stepUpRequests.add(stepUpRequest);
        List<StepUpResponse> expectedResponse = prepareExpectedResponse();
        String responseBody = '{ "status":"IN_PROGRESS", "challenge_id":"12345", "availableOptions":[ "kba" ], "kba":{ "questions":[ { "question_id":"KBA_2", "question":"What month were you born?", "options":[ { "value":"January" } ] } ], "status":"PENDING" }}';
        HTTPMockFactory mock = new HTTPMockFactory(200, 'OK', responseBody, new Map<String, String>());
        Test.setMock(HttpCalloutMock.class, mock); 
        test.startTest();
        List<StepUpResponse> actualResponse = GetKBAQuestions_FlowController.getKBAQuestions(stepUpRequests);
        System.assertEquals(expectedResponse.toString(), actualResponse.toString());
        test.stopTest();
    }

    @isTest
    static void getKbaQuestionsTest_Error(){
        String responseBody = '{"message":"Internal Server Error"}';
        HTTPMockFactory mock = new HTTPMockFactory(500, 'OK', responseBody, new Map<String, String>());
        
        List<GetKBAQuestions_FlowController.StepUpRequest> stepUpRequests = new List<GetKBAQuestions_FlowController.StepUpRequest>();
        GetKBAQuestions_FlowController.StepUpRequest stepUpRequest = prepareRequest();
        stepUpRequests.add(stepUpRequest);

        Test.setMock(HttpCalloutMock.class, mock);
        test.startTest();
        List<StepUpResponse> actualResponse = GetKBAQuestions_FlowController.getKBAQuestions(stepUpRequests);
        
        System.assertEquals('Internal Server Error', actualResponse.get(0).errorMsg);
        test.stopTest();
    }
    
    private static GetKBAQuestions_FlowController.StepUpRequest prepareRequest(){
        GetKBAQuestions_FlowController.StepUpRequest stepUpRequest = new GetKBAQuestions_FlowController.StepUpRequest();
        stepUpRequest.accountNumber = '1234';
        stepUpRequest.challenge_id = '1243432';
        return stepUpRequest;
    }
    
    private static List<StepUpResponse> prepareExpectedResponse(){
        List<StepUpResponse> stepupResponses = new List<StepUpResponse>();
        Stepup stepup = new Stepup();
        List<String> availOptions = new List<String>();
        availOptions.add('kba');
        stepup.availableOptions = availOptions;
        stepup.challenge_id = '12345';
        stepup.status = 'IN_PROGRESS';
        Kba kba = new Kba();
        Questions questions = new Questions();
        questions.question = 'What month were you born?';
        questions.question_id='KBA_2';

        List<Options> opts = new List<Options>();
        Options options = new Options();
        options.value = 'January';
        opts.add(options);  
        questions.options =  opts;
        
        List<Questions> questionsList =  new List<Questions>();
        questionsList.add(questions);
        kba.questions = questionsList;
        kba.status='PENDING';
        stepup.kba = kba;
        StepUpResponse stepupResponse = new StepUpResponse();
        stepUpResponse.status = true;
        stepUpResponse.stepup = stepup;
        stepupResponses.add(stepupResponse);
        return stepupResponses;   
    }
}