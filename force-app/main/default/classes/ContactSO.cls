public class ContactSO {
    
    @AuraEnabled
    public Contact user;

    @AuraEnabled
    public SecondaryUserAttrobutesSO secondaryUserAttrbutes;

    @AuraEnabled
    public List<Contact_Email__c> emails;

    @AuraEnabled
    public List<Contact_Phone__c> phones;

    @AuraEnabled
    public List<Contact_Address__c> addresses;

    // Constructor
    public ContactSO()
    {
        user = new Contact();
        secondaryUserAttrbutes = new SecondaryUserAttrobutesSO();
        emails = new List<Contact_Email__c>();
        phones = new List<Contact_Phone__c>();
        addresses = new List<Contact_Address__c>();
    }
}