public class QuickGlanceBizControllerResponse {
    @AuraEnabled
    public Account accountInfo;

    @AuraEnabled
    public ContactSO primaryParty;

    @AuraEnabled
    public Boolean isContactedPartyAvailable;

    @AuraEnabled
    public Boolean isContactedPartyNotPrimary;

    @AuraEnabled
    public ContactSO contactedParty;

    @AuraEnabled
    public List<Account_Manager_Flag__c> accountFlags;

    @AuraEnabled
    public List<Account_Limitation__c> limitations;

    @AuraEnabled
    public Business_Address__c businessAddress;

    @AuraEnabled
    public Customer360StatusWO result;

    public QuickGlanceBizControllerResponse() {
        accountInfo = new Account();
        primaryParty = new ContactSO();
        contactedParty = new ContactSO();
        accountFlags = new List<Account_Manager_Flag__c>();
        limitations = new List<Account_Limitation__c>();
        businessAddress = new Business_Address__c();
        result = new Customer360StatusWO();
        isContactedPartyAvailable = false;
        isContactedPartyNotPrimary = false;
    }
}