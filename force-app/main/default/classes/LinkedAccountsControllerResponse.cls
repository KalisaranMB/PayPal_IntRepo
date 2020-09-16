public class LinkedAccountsControllerResponse {
    @AuraEnabled
    public List<LinkedAccountSO> linkedAccounts;

    @AuraEnabled
    public Customer360StatusWO result;

    public LinkedAccountsControllerResponse() {
        linkedAccounts = new List<LinkedAccountSO>();
        result = new Customer360StatusWO();
    }
}