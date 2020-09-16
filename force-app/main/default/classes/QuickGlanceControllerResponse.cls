public class QuickGlanceControllerResponse {
    @AuraEnabled
    public Account accountInfo;

    @AuraEnabled
    public Contact userInfo;

    @AuraEnabled
    public List<Contact_Email__c> emails;

    @AuraEnabled
    public List<Contact_Phone__c> phones;

    @AuraEnabled
    public List<Contact_Address__c> addresses;

    @AuraEnabled
    public List<Account_Manager_Flag__c> accountFlags;

    @AuraEnabled
    public List<Account_Limitation__c> limitations;

    @AuraEnabled
    public Customer360StatusWO result;

    public QuickGlanceControllerResponse() {
        accountInfo = new Account();
        userInfo = new Contact();
        emails = new List<Contact_Email__c>();
        phones = new List<Contact_Phone__c>();
        addresses = new List<Contact_Address__c>();
        accountFlags = new List<Account_Manager_Flag__c>();
        limitations = new List<Account_Limitation__c>();
        result = new Customer360StatusWO();
    }
}