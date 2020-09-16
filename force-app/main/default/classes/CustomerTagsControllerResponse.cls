public class CustomerTagsControllerResponse {
    @AuraEnabled
    public Account accountInfo;

    @AuraEnabled
    public Contact userInfo;

    @AuraEnabled
    public Boolean isManagedAccount;

    @AuraEnabled
    public Boolean hasOpenLimitations;

    @AuraEnabled
    public Account_Manager_Flag__c amFlagDetails;

    @AuraEnabled
    public List<Account_Limitation__c> openLimitations;

    @AuraEnabled
    public Customer360StatusWO result;

    public CustomerTagsControllerResponse() {
        accountInfo = new Account();
        userInfo = new Contact();
        amFlagDetails = null;
        openLimitations = new List<Account_Limitation__c>();
        result = new Customer360StatusWO();
    }
}