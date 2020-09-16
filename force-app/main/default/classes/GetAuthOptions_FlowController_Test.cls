@isTest
private class GetAuthOptions_FlowController_Test {
    @isTest
    static void getAuthOption_AvailableOptions(){
        String responseBody = '{"challenge_id":"18094262060518187852","sms":{"phone_numbers":[{"country_code":"1","phone_number":"3129248873"},{"country_code":"1","phone_number":"7084458740"},{"country_code":"1","phone_number":"7733555072"}],"can_add_phone":true,"status":"PENDING"},"status":"PENDING","availableOptions":["sms"]}';
        HTTPMockFactory mock = new HTTPMockFactory(200, 'OK', responseBody, new Map<String, String>());
        Test.setMock(HttpCalloutMock.class, mock);
        test.startTest();
        List<GetAuthOptions_FlowController.AuthRequest> authRequests = new List<GetAuthOptions_FlowController.AuthRequest>();
        GetAuthOptions_FlowController.AuthRequest authRequest = new GetAuthOptions_FlowController.AuthRequest();
        authRequest.accountNumber = '1346586502613524019';
        authRequest.authFlowContextId = 'f4f2a7b7d55ae026e6c721ed911e1293';
        authRequests.add(authRequest);
        List<StepUpResponse> actualResponse = GetAuthOptions_FlowController.getAuthOption(authRequests);
        List<String> availOps = new List<String>();
        availOps.add('sms');
        System.assertEquals(availOps, actualResponse.get(0).stepup.availableOptions);
        test.stopTest();
    }

    @isTest
    static void getAuthOption_AvailableOptions1(){
        String responseBody = '{"challenge_id":"18094262060518187852","sms":{"phone_numbers":[{"country_code":"1","phone_number":"3129248873"},{"country_code":"1","phone_number":"7084458740"},{"country_code":"1","phone_number":"7733555072"}],"can_add_phone":true,"status":"PENDING"},"status":"PENDING","availableOptions":["sms", "kba"]}';
        HTTPMockFactory mock = new HTTPMockFactory(200, 'OK', responseBody, new Map<String, String>());
        Test.setMock(HttpCalloutMock.class, mock);
        test.startTest();
        List<GetAuthOptions_FlowController.AuthRequest> authRequests = new List<GetAuthOptions_FlowController.AuthRequest>();
        GetAuthOptions_FlowController.AuthRequest authRequest = new GetAuthOptions_FlowController.AuthRequest();
        authRequest.accountNumber = '1346586502613524019';
        authRequest.authFlowContextId = 'f4f2a7b7d55ae026e6c721ed911e1293';
        authRequests.add(authRequest);
        List<StepUpResponse> actualResponse= GetAuthOptions_FlowController.getAuthOption(authRequests);
        List<String> availOps = new List<String>();
        availOps.add('sms');
        availOps.add('kba');
        System.assertEquals(availOps, actualResponse.get(0).stepup.availableOptions);
        test.stopTest();
    }

    @isTest
    static void getAuthOption_Error(){
        String responseBody = '{"message":"Internal Server Error"}';
        HTTPMockFactory mock = new HTTPMockFactory(500, 'OK', responseBody, new Map<String, String>());
        Test.setMock(HttpCalloutMock.class, mock);
        test.startTest();
        List<GetAuthOptions_FlowController.AuthRequest> authRequests = new List<GetAuthOptions_FlowController.AuthRequest>();
        GetAuthOptions_FlowController.AuthRequest authRequest = new GetAuthOptions_FlowController.AuthRequest();
        authRequest.accountNumber = '1346586502613524019';
        authRequest.authFlowContextId = 'f4f2a7b7d55ae026e6c721ed911e1293';
        authRequests.add(authRequest);
        List<StepUpResponse> actualResponse= GetAuthOptions_FlowController.getAuthOption(authRequests);
        
        System.assertEquals('Internal Server Error', actualResponse.get(0).errorMsg);
        test.stopTest();
    }
}