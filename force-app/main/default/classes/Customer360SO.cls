public class Customer360SO {
    public Account acct;
    public ContactSO primaryUser;
    public List<ContactSO> secondaryUsers;
    public List<Business_Address__c> businessAddresses;
    public List<Account_Manager_Flag__c> accountFlags;
    public List<Account_Limitation__c> limitations;
    public List<Account_Wallet__c> financialInstruments;
    public List<Transaction_Log__c> transactions;
    public List<PayPal_Case__c> cases;
    public List<Activity_Log__c> activityLogs;
    public List<Account_Note__c> notes;
    public List<Account_Product__c> products;
    public List<LinkedAccountSO> linkedAccounts;
    public List<PreviousInteractionSO> previousInteractions;

    // Constructor
    public Customer360SO()
    {
        acct = new Account();
        primaryUser = new ContactSO();
        secondaryUsers = new List<ContactSO>();
        businessAddresses = new List<Business_Address__c>();
        accountFlags = new List<Account_Manager_Flag__c>();
        limitations = new List<Account_Limitation__c>();
        financialInstruments = new List<Account_Wallet__c>();
        transactions = new List<Transaction_Log__c>();
        cases = new List<PayPal_Case__c>();
        activityLogs = new List<Activity_Log__c>();
        notes = new List<Account_Note__c>();
        products = new List<Account_Product__c>();
        linkedAccounts = new List<LinkedAccountSO>();
        previousInteractions = new List<PreviousInteractionSO>();
    }
}