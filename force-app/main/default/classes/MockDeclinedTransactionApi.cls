@istest
public class MockDeclinedTransactionApi implements HttpCalloutMock{
 
    protected Integer statusCode;
	protected Scenario scenario;
	protected Map<String, String> responseHeaders;
	
	public enum Scenario {
		POSITIVE_SINGLE_TRANSACTION
	}
	
	public MockDeclinedTransactionApi(Integer statusCode, Scenario scenario, Map<String, String> responseHeaders) {
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

		DeclinedTransactions mockObj = null;
		Error errObj = null;
		
		switch on scenario {
			when POSITIVE_SINGLE_TRANSACTION {
				mockObj = DeclinedTransactionTestUtils.getSuccessResponse();
			}
			
		}
		
		res.setBody(System.JSON.serialize(mockObj));
		res.setStatusCode(this.statusCode);

		return res;
	}
}