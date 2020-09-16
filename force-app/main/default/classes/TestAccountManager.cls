@isTest(SeeAllData=true)

public class TestAccountManager {
   
    public static String generateRandomNumber() {
        String randomNumber = generate();
        if (randomNumber.length() < 3) {
            String randomNumber2 = generate();
            randomNumber = randomNumber + randomNumber2.substring(0, 10 - randomNumber.length());
        }
        return randomNumber;
    }
    public static String generateIdentifier(String prefix) {
        return prefix + '-' + generateRandomNumber();
    }
    private static String generate() {
        return String.valueOf(Math.abs(Crypto.getRandomInteger()));
    }
    
    private static Account cloneAccount(){
         // Query an existing account in the organization. 
        Account a = [SELECT Id, Name FROM Account WHERE AccountNumber='1334781826176083629' LIMIT 1];
        System.assert(a != null);
        System.debug('a.id'+a.Id);
        // Create a test account based on the queried account.
        Account testAccount = a.clone();
        testAccount.Name = 'Acme Test';
        testAccount.Account_Number_Encrypted__c = '133478182617600'+generateIdentifier('t');
        insert testAccount;
        return testAccount;
    }
  
private static Account createAccount(String Name, String AccountNumber){
        
        Account acct = new Account();
acct.Name = Name;
acct.Account_Number_Encrypted__c = AccountNumber;
acct.AccountNumber = AccountNumber;
acct.Account_Type__c = 'Personal';
acct.Account_Subtype__c = 'PayPal Cash Plus';
acct.Account_Status__c = 'Open';
acct.Location__c = 'San Jose';
acct.Country_Code__c = 'US';
acct.Country_Name__c = 'United States';
acct.Timezone__c = 'PST';
acct.Account_Created_Time__c = DateTime.newInstance(2015, 03, 01, 09, 00, 00);
acct.Customer_Segment__c = 'Likely To Churn';
acct.No_of_Secondary_Users__c = 0;
acct.CIP_Status__c = 'In-Progress';
acct.Is_Unregistered__c = false;
acct.Unregistered_Account_Type__c = '';
        

acct.ActivityLog_Loaded_Time__c = DateTime.newInstance(2021, 03, 01, 09, 00, 00);
acct.Basic_Profile_Loaded_Time__c = DateTime.newInstance(2021, 03, 01, 09, 00, 00);
acct.Compliance_Info_Loaded_Time__c = DateTime.newInstance(2021, 03, 01, 09, 00, 00);
acct.Limitation_Info_Loaded_Time__c = DateTime.newInstance(2021, 03, 01, 09, 00, 00);
acct.Business_Info_Loaded_Time__c = DateTime.newInstance(2021, 03, 01, 09, 00, 00);
acct.Linked_Accounts_Loaded_Time__c = DateTime.newInstance(2021, 03, 01, 09, 00, 00);
acct.PayPal_Cases_Loaded_Time__c = DateTime.newInstance(2021, 03, 01, 09, 00, 00);
acct.Previous_Interactions_Loaded_Time__c = DateTime.newInstance(2021, 03, 01, 09, 00, 00);
acct.Product_Info_Loaded_Time__c = DateTime.newInstance(2021, 03, 01, 09, 00, 00);
acct.Secondary_User_Loaded_Time__c = DateTime.newInstance(2021, 03, 01, 09, 00, 00);
acct.ServiceLog_Notes_Loaded_Time__c = DateTime.newInstance(2021, 03, 01, 09, 00, 00);
acct.TransactionLog_Loaded_Time__c = DateTime.newInstance(2021, 03, 01, 09, 00, 00);
acct.Wallet_Info_Loaded_Time__c = DateTime.newInstance(2021, 03, 01, 09, 00, 00);
acct.Prefetch_Loaded_Time__c = DateTime.newInstance(2021, 03, 01, 09, 00, 00);

insert acct;
System.debug(JSON.serialize(acct.Id));
       return acct; 
    }
   @isTest
    public static void verifyCloneTest(){
        // Creating Request
        Customer360APIRequest cx360Request = new Customer360APIRequest();
        Account a = [SELECT Id, Name FROM Account WHERE AccountNumber='1334781826176083629' LIMIT 1];
        //cx360Request.setAccount(a);
        cx360Request.setAccount(cloneAccount());
        cx360Request.addToDataCategoriesToBeLoaded(Customer360.DataCategory.ACCOUNT_INFO);
        test.startTest();
         
        // Create the mock response based on a static resource
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('AccountManagerValidResponse');
        mock.setStatusCode(500);
        mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
        // Associate the callout with a mock response
        Test.setMock(HttpCalloutMock.class, mock);
        // Call method to test
        Customer360APIResponse result = Customer360API.getCustomer360Data(cx360Request);
        Customer360DO customer360do = result.getCustomer360DO();
         System.debug('Success1'+result.isAPIStatusSuccess());
         System.debug('Success2'+result.isAPIStatusPartialSuccess());
         System.debug('Success3'+result.isAPIStatusFailure());
        test.stopTest();
    }
    
     @isTest
    public static void verifyAccManagerTest(){
        test.startTest();
        // Creating Request
        //Customer360APIRequest cx360Request = new Customer360APIRequest();
             
        //cx360Request.addToDataCategoriesToBeLoaded(Customer360.DataCategory.ACCOUNT_INFO);
                 
        // Create the mock response based on a static resource
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('AccountManagerValidResponse');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
        // Associate the callout with a mock response
        Test.setMock(HttpCalloutMock.class, mock);
        // Call method to test
        //Customer360APIResponse mockResult = new Customer360APIResponse();
        //result.apiResult="";
        /*
         * result  values
         */
        //Test.setMock(Customer360API.class, mockResult)
        CustomerTagsControllerResponse response =  CustomerTagsController.getCustomerTags(null,cloneAccount().Id);
        //Customer360DO customer360do = result.getCustomer360DO();
         System.debug('Success1'+response.result);
         //System.debug('Success2'+response.result.isAPIStatusPartialSuccess());
         //System.debug('Success3'+response.result.isAPIStatusFailure());
        test.stopTest();
    }

}