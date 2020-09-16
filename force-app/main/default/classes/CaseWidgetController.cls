public with sharing class CaseWidgetController {
    @AuraEnabled(cacheable=true)
    public static List<Paypal_Case__c> searchCases(Id contextId, DateTime startDate, DateTime endDate){
        Customer360APIRequest req = new Customer360APIRequest();
        req.setAccount([SELECT Account.Account_Number_Encrypted__c FROM Case WHERE Id = :contextId].Account);
        req.addToDataCategoriesToBeLoaded(Customer360.DataCategory.CASES);
        req.addToSearchCriteriaToBeLoaded(Customer360.SearchCriteria.CASES_START_DATE, DateTime.newInstance(startDate.date(), Time.newInstance(0,0,0,0)).formatGmt('yyyy-MM-dd\'T\'HH:mm:ss\'Z\''));
        req.addToSearchCriteriaToBeLoaded(Customer360.SearchCriteria.CASES_END_DATE, DateTime.newInstance(endDate.date(), Time.newInstance(0,0,0,0)).formatGmt('yyyy-MM-dd\'T\'HH:mm:ss\'Z\''));
        Customer360APIResponse resp = Customer360API.getCustomer360Data(req);
        if(resp.isAPIStatusFailure()){
            throw new TransactionAPIException('Unable to retrieve Case data');
        }
        Customer360SO obj = PayPalCaseAPI.mapResponseToCustomer360SO(new Customer360SO(), req, resp);
        return obj.cases;
    }

    private virtual class TransactionAPIException extends Exception {}
}