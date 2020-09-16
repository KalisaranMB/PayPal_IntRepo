@isTest
public class HTTPMockFactory implements HttpCalloutMock{
    protected Integer code;
    protected String status;
    protected String body;
    protected Map<String,String> responseHeader;

    public HTTPMockFactory(Integer code, String status, String body, Map<String,String> responseHeader) {
        this.code = code;
        this.status = status;
        this.body = body;
        this.responseHeader = responseHeader;
    }

    public HttpResponse respond(HttpRequest req){
        HttpResponse res = new HttpResponse();
        for(String key: this.responseHeader.keySet()){
            res.setHeader(key, this.responseHeader.get(key));
        }
        res.setBody(this.body);
        res.setStatusCode(this.code);
        res.setStatus(this.status);
        return res;
    }
}