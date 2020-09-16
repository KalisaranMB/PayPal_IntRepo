global with sharing class DeclinedTransactionsController {

    @InvocableMethod
    public static List<Results> getDeclinedTransactions(List<Requests> params) 
    {
        List<Results> resultsList = null;
        DeclinedTransactions response= null;

        String account_id = params.get(0).accountId;        
        if(account_id ==  null){
            return resultsList;
        }
        
        HttpRequest httpReq = new HttpRequest();
        httpReq.setMethod('GET');
        String endPoint = formEndPoint(account_id, params.get(0));
        
        System.debug('endpoint :  '+endPoint);
        
        try {
            httpReq.setEndpoint(endPoint);
            HttpResponse httpRes = new Http().send(httpReq);
            
            System.debug('Body : '+httpRes.getBody());

            if (httpRes.getStatusCode() == 200)
            {
                response=DeclinedTransactions.parse(httpRes.getBody());
                System.debug('Response is '+response);
                Results results = new Results();
                results.declinedTransactions = response;
                resultsList = new List<Results>();
                resultsList.add(results);
                System.debug(resultsList);
                return resultsList;
            }
        } catch (Exception e) {
            System.debug('Exception : '+e.getMessage());
            System.debug('Cause : '+e.getCause());
            throw e;
        }
        
        return resultsList;
    }
    
    public static String formEndPoint(String account_id, Requests queryParam){
        //String service = 'https://api.salesforce.csi.stage.paypal.com';
        String service = 'callout:CSDAS_Contexts';
        String api = '/v1/customer-support/'+account_id+'/declined-transactions';
        
        String endPoint = service + api;
        
        if(queryParam.type!=null){
            endPoint = endPoint+'?type='+queryParam.type;
        }

        if(queryParam.start_date!=null){
            endPoint = endPoint+'&start_date='+queryParam.start_date;
        }
        if(queryParam.end_date!=null){
            endPoint = endPoint+'&end_date='+queryParam.end_date;
        }
        if(queryParam.gsid!=null){
            endPoint = endPoint+'&gsid='+queryParam.gsid;
        }
        if(queryParam.correlating_id!=null){
            endPoint = endPoint+'&correlatingid='+queryParam.correlating_id;
        }
        return endPoint;
    }

    global class Results {
        @InvocableVariable
        global DeclinedTransactions declinedTransactions;
    }
     global class Requests {
        @InvocableVariable
        global String accountId;
        @InvocableVariable
        global String type;
        @InvocableVariable
        global String start_date;
        @InvocableVariable
        global String end_date;
        @InvocableVariable
        global String gsid;
        @InvocableVariable
        global String correlating_id;
    }

}