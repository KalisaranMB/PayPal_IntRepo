@istest
public class MockContactIntentApi implements HttpCalloutMock {

	protected Integer statusCode;
	protected Scenario scenario;
	protected Map<String, String> responseHeaders;
	
	public enum Scenario {
		POSITIVE_SINGLE_CONTEXT,
		POSITIVE_MULTIPLE_CONTEXT_ACTIVE_STATUS,
		POSITIVE_MULTIPLE_CONTEXT_ACTIVE_AND_INCOMPLETE_STATUS
	}
	
	public MockContactIntentApi(Integer statusCode, Scenario scenario, Map<String, String> responseHeaders) {
		this.statusCode = statusCode;
		this.scenario = scenario;
		this.responseHeaders = responseHeaders;
	}
	
	public HttpResponse respond(HttpRequest req) {
		//System.assertEquals('http://example.com/example/test', req.getEndpoint());
		System.assertEquals('GET', req.getMethod());

		System.debug('Endpoint: ' + req.getEndpoint());

		// Create a fake response
		HttpResponse res = new HttpResponse();
		res.setHeader('Content-Type', 'application/json');

		ContextCollectionResponse mockObj = null;
		Error errObj = null;
		
		switch on scenario {
			when POSITIVE_SINGLE_CONTEXT {
				mockObj = ContactIntentTestUtils.getSuccessResponse();
			}
			when POSITIVE_MULTIPLE_CONTEXT_ACTIVE_STATUS {
				mockObj = ContactIntentTestUtils.getMultipleContextWithActiveStatus();
			}
			when POSITIVE_MULTIPLE_CONTEXT_ACTIVE_AND_INCOMPLETE_STATUS {
				mockObj = ContactIntentTestUtils.getMultipleContextWithActiveAndIncompleteStatus();
			}
		}
		
		res.setBody(System.JSON.serialize(mockObj));
		res.setStatusCode(this.statusCode);

		return res;
	}
}