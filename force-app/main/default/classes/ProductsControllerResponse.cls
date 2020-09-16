public class ProductsControllerResponse {
    @AuraEnabled
    public List<Account_Product__c> products;

    @AuraEnabled
    public Customer360StatusWO result;

    public ProductsControllerResponse() {
        products = new List<Account_Product__c>();
        result = new Customer360StatusWO();
    }
}