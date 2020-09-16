public class MerchantProfileControllerResponse {

    @AuraEnabled
    public Boolean hasSecondaryUsers;

    @AuraEnabled
    public List<Contact_Email__c> emails;

    @AuraEnabled
    public List<Contact_Phone__c> phones;

    @AuraEnabled
    public Customer360StatusWO result;

    public MerchantProfileControllerResponse() {
        hasSecondaryUsers = false;
        emails = new List<Contact_Email__c>();
        phones = new List<Contact_Phone__c>();
        result = new Customer360StatusWO();
    }
}