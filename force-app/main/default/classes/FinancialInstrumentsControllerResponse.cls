public class FinancialInstrumentsControllerResponse {
    @AuraEnabled
    public List<Account_Wallet__c> financialInstruments;

    @AuraEnabled
    public Customer360StatusWO result;

    public FinancialInstrumentsControllerResponse() {
        financialInstruments = new List<Account_Wallet__c>();
        result = new Customer360StatusWO();
    }
}