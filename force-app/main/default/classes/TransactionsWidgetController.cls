public with sharing class TransactionsWidgetController {
    @AuraEnabled(cacheable=true)
    public static List<Transaction_Log__c> searchTransactions(Id contextId, DateTime startDate, DateTime endDate){
        Customer360APIRequest req = new Customer360APIRequest();
        req.setAccount([SELECT Account.Account_Number_Encrypted__c FROM Case WHERE Id = :contextId].Account);
        req.addToDataCategoriesToBeLoaded(Customer360.DataCategory.TRANSACTIONS);
        req.addToSearchCriteriaToBeLoaded(Customer360.SearchCriteria.TRANSACTIONS_START_DATE, DateTime.newInstance(startDate.date(), Time.newInstance(0,0,0,0)).formatGmt('yyyy-MM-dd\'T\'HH:mm:ss\'Z\''));
        req.addToSearchCriteriaToBeLoaded(Customer360.SearchCriteria.TRANSACTIONS_END_DATE, DateTime.newInstance(endDate.date(), Time.newInstance(0,0,0,0)).formatGmt('yyyy-MM-dd\'T\'HH:mm:ss\'Z\''));
        Customer360APIResponse resp = Customer360API.getCustomer360Data(req);
        if(resp.isAPIStatusFailure()){
            throw new TransactionAPIException('Unable to retrieve Transaction data');
        }
        Customer360SO obj = TransactionAPI.mapResponseToCustomer360SO(new Customer360SO(), req, resp);
        return obj.transactions;
    }

    private virtual class TransactionAPIException extends Exception {}
}