@isTest
private with sharing class Override_FlowController_Test {
    @isTest
    private static void riskOverride_SUCCESS() {
        List<Override_FlowController.overrideRequest> overrideRequests = new List<Override_FlowController.overrideRequest>();
        Override_FlowController.overrideRequest overrideRequest = getOverrideRequest();
        overrideRequests.add(overrideRequest);
        List<Override_FlowController.OverrideResponeWrapper> expectedResponse = prepareExpectedSuccessResponse();
        String responseBody = '{ "account_number": "2100304201585389154", "override_duration": "P0DT4H0M0S"}';
        HTTPMockFactory mock = new HTTPMockFactory(200, 'OK', responseBody, new Map<String, String>());
        Test.setMock(HttpCalloutMock.class, mock); 
        test.startTest();
        List<Override_FlowController.OverrideResponeWrapper> actualResponse = Override_FlowController.riskOverride(overrideRequests);
        System.assertEquals(expectedResponse.toString(), actualResponse.toString());
        test.stopTest();
    }

    @isTest
    private static void riskOverride_FAILURE() {
        List<Override_FlowController.overrideRequest> overrideRequests = new List<Override_FlowController.overrideRequest>();
        Override_FlowController.overrideRequest overrideRequest = getOverrideRequest();
        overrideRequests.add(overrideRequest);
        List<Override_FlowController.OverrideResponeWrapper> expectedResponse = prepareExpectedFailureResponse();
        String responseBody = '{ "account_number": "2100304201585389154", "override_duration": "P0DT0H0M0S"}';
        HTTPMockFactory mock = new HTTPMockFactory(200, 'OK', responseBody, new Map<String, String>());
        Test.setMock(HttpCalloutMock.class, mock); 
        test.startTest();
        List<Override_FlowController.OverrideResponeWrapper> actualResponse = Override_FlowController.riskOverride(overrideRequests);
        System.assertEquals(expectedResponse.toString(), actualResponse.toString());
        test.stopTest();
    }

    @isTest
    private static void riskOverride_ERROR() {
        List<Override_FlowController.overrideRequest> overrideRequests = new List<Override_FlowController.overrideRequest>();
        Override_FlowController.overrideRequest overrideRequest = getOverrideRequest();
        overrideRequests.add(overrideRequest);
        String responseBody = '{"message":"Internal Server Error"}';
        HTTPMockFactory mock = new HTTPMockFactory(500, 'OK', responseBody, new Map<String, String>());
        Test.setMock(HttpCalloutMock.class, mock); 
        test.startTest();
        List<Override_FlowController.OverrideResponeWrapper> actualResponse = Override_FlowController.riskOverride(overrideRequests);
        System.assertEquals('Internal Server Error', actualResponse.get(0).errorMsg);
        test.stopTest();
    }

    private static Override_FlowController.overrideRequest getOverrideRequest(){
        Override_FlowController.overrideRequest overrideRequest = new Override_FlowController.overrideRequest();
        overrideRequest.accountNumber = '2100304201585389154';
        overrideRequest.authFlowContextId = '195e75ad45bbe816e45bdb0f651ee90a';
        return overrideRequest;
    }

    private static List<Override_FlowController.OverrideResponeWrapper> prepareExpectedSuccessResponse(){
        List<Override_FlowController.OverrideResponeWrapper> wrappers = new List<Override_FlowController.OverrideResponeWrapper>();
        Override_FlowController.OverrideResponeWrapper wrapper  = new Override_FlowController.OverrideResponeWrapper();
        OverrideRespone overrideRespone = new OverrideRespone();
        overrideRespone.account_number = '2100304201585389154';
        overrideRespone.override_duration='P0DT4H0M0S';
        wrapper.status = true;
        wrapper.overrideRespone = overrideRespone;
        wrappers.add(wrapper);
        return wrappers;   
    }

    private static List<Override_FlowController.OverrideResponeWrapper> prepareExpectedFailureResponse(){
        List<Override_FlowController.OverrideResponeWrapper> wrappers = new List<Override_FlowController.OverrideResponeWrapper>();
        Override_FlowController.OverrideResponeWrapper wrapper  = new Override_FlowController.OverrideResponeWrapper();
        OverrideRespone overrideRespone = new OverrideRespone();
        overrideRespone.account_number = '2100304201585389154';
        overrideRespone.override_duration='P0DT0H0M0S';
        wrapper.status = true;
        wrapper.overrideRespone = overrideRespone;
        wrappers.add(wrapper);
        return wrappers;   
    }

}