public class LinkedAccountAttributeSO {
    @AuraEnabled
    public Linked_Account_Attributes__c attribute;

    @AuraEnabled
    public Contact_Email__c email;

    @AuraEnabled
    public Contact_Phone__c phone;

    @AuraEnabled
    public Contact_Address__c address;

    @AuraEnabled
    public Account_Wallet__c financialInstrument;

    public LinkedAccountAttributeSO() {
        attribute = new Linked_Account_Attributes__c();
        email = new Contact_Email__c();
        phone = new Contact_Phone__c();
        address = new Contact_Address__c();
        financialInstrument = new Account_Wallet__c();
    }
}