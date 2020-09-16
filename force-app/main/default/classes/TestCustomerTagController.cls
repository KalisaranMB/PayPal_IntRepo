@isTest(SeeAllData=true)
private class TestCustomerTagController {
    private static Account createAccount(String Name, String AccountNumber){
        
        Account acct = new Account();
acct.Name = Name;
acct.Account_Number_Encrypted__c = 'AccountNumber';
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
acct.Account_Manager_Flags_Loaded_Time__c = DateTime.newInstance(2021, 03, 01, 09, 00, 00);
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
//clone data
    /*private static Account cloneAccount(String Name, String AccountNumber){
    
       // Query an existing account in the organization. 
        Account a = [SELECT Id, Name FROM Account WHERE Id='0015B000019pIgjQAE' LIMIT 1];
        System.assert(a != null);
        
        // Create a test account based on the queried account.
        Account testAccount = a.clone();
        testAccount.Name = 'Clone Account';
        testAccount.Account_Number_Encrypted__c= 'AccountNumber;
        testAccount.AccountNumber = AccountNumber;
        insert testAccount;
        return testAccount;
    }*/
    
    private static Case createCaseid(String Name, String AccountNumber){
        
        Account acct = new Account();
acct.Name = Name;
acct.Account_Number_Encrypted__c = 'AccountNumber';
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
acct.Account_Manager_Flags_Loaded_Time__c = DateTime.newInstance(2021, 03, 01, 09, 00, 00);
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

Case cs = new Case();
cs.Origin = 'Phone';
cs.Channel_Id__c = '10002';
cs.Status = 'Resolution';
cs.AccountId = acct.id;
insert cs;
System.debug(JSON.serialize(cs.Id));       
       return cs;
    }
    
private static Case createCaseIdWoAccount(){
Case cs = new Case();
cs.Origin = 'Phone';
cs.Channel_Id__c = '10002';
cs.Status = 'Resolution';
insert cs;
System.debug(JSON.serialize(cs.Id));       
       return cs;
    }    
  
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
    
    
private static Account createNoLimitAccountFlag(String Name, String AccountNumber){
        
Account acct = new Account();
acct.Name = Name;
acct.Account_Number_Encrypted__c = 'AccountNumber';
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


    
   private static Contact createContactRelationId(String Name, String AccountNumber){
        
        Account acct = new Account();
acct.Name = Name;
acct.Account_Number_Encrypted__c = 'AccountNumber';
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
acct.Account_Manager_Flags_Loaded_Time__c = DateTime.newInstance(2021, 03, 01, 09, 00, 00);
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

       
Contact ct = new Contact();
ct.Party_Id__c = '1334781826176083630';
ct.Full_Name__c = 'Jennifer Lawrence';
ct.FirstName = 'Jennifer';
ct.LastName = 'Lawrence';
ct.Profile_Picture__c = 'https://msmaster.qa.paypal.com:14870/v1/content/media-containers/PICS/cdn-assets/00/p/OGY0MmMyZDAtMmY5Zi00YTIyLWJkNzUtYTE1YTQwYjEwOWYx/image_2.JPG';
ct.Age__c = 27;
ct.AccountId = acct.Id;

ct.Address_Loaded_Time__c = DateTime.newInstance(2021, 03, 01, 09, 00, 00);
ct.Email_Loaded_Time__c = DateTime.newInstance(2021, 03, 01, 09, 00, 00);
ct.Phone_Loaded_Time__c = DateTime.newInstance(2021, 03, 01, 09, 00, 00);

insert ct;
System.debug(JSON.serialize(ct.Id));
       return ct;
   }
    
    
    //Both Case and account id is NULL
    @isTest static void testNullAccountidAndCaseid()
    {
         CustomerTagsControllerResponse response =  CustomerTagsController.getCustomerTags(null,null);
         //System.debug('Result'+response.result.message);
         System.assertEquals('Unexpected Error: Both Case Id and Account Id is missing in the request', response.result.message); 
    }

    //Case id Null and provide value for Account id
    public static testMethod void testWithAccountId(){
        CustomerTagsControllerResponse response =  CustomerTagsController.getCustomerTags(null,createAccount('Eazhil', '1293589840714216965').Id);
        System.debug('Eazhil Here'+ response.result);
        System.assertEquals('Data is Partially Loaded', response.result.message);
    }
    
     //Account with limitation , Account Manager and complienace info
     public static testMethod void limitationTestMethod(){
        Account acct = createAccount('Eazhil', '1293589840714216966');
        CustomerTagsControllerResponse response =  CustomerTagsController.getCustomerTags(null,acct.Id);
        System.debug('Eazhil Here'+ response.result);
        System.assertEquals('Data is Partially Loaded', response.result.message);
    }
    
     //Account with account manager info
     public static testMethod void accountManagerTestMethod(){
        Account acct = createAccount('Eazhil', '1293589840714216968');
        CustomerTagsControllerResponse response =  CustomerTagsController.getCustomerTags(null,acct.Id);
        System.debug('Eazhil Here'+ response.result);
        System.assertEquals('Data is Partially Loaded', response.result.message);
    }
    
     //Account with no Limitation info
     public static testMethod void nolimitationTestMethod(){
        Account acct = createNoLimitAccountFlag('Eazhil', '1293589840714216969');
        //acct.Limitation_Info_Loaded_Time__c = null;
        CustomerTagsControllerResponse response =  CustomerTagsController.getCustomerTags(null,acct.Id);
        System.debug('Eazhil Here'+ response.result.message);
        System.assertEquals('Failed to load the Data', response.result.message);
    }
     
    //Account with no account manager info
     public static testMethod void noaccountManagerTestMethod(){
        Account acct = createNoLimitAccountFlag('Eazhil', '1293589840714216970');
        //acct.Account_Manager_Flags_Loaded_Time__c = null;
        CustomerTagsControllerResponse response =  CustomerTagsController.getCustomerTags(null,acct.Id);
        System.debug('Eazhil Here'+ response.result.message);
        System.assertEquals('Failed to load the Data', response.result.message);
    }
    
    //Case id associated with account
    public static testMethod void testCaseId(){
        CustomerTagsControllerResponse response =  CustomerTagsController.getCustomerTags(createCaseid('Eazhil', '1293589840714216988').Id,null);
        System.debug('Eazhil Here'+ response.result);
        System.assertEquals('Data is Partially Loaded', response.result.message);
    }
    
     //Contact id associated with account
     public static testMethod void testContactRelationId(){
        Contact ct = createContactRelationId('Eazhil', '1293589840714216991');
        CustomerTagsControllerResponse response =  CustomerTagsController.getCustomerTags(null,ct.AccountId);
        System.debug('Eazhil Here'+ response.result);
        System.assertEquals('SUCCESS', response.result.message);
    }
    //Case id not associated with account
     public static testMethod void testCaseIdWoAccount(){
        CustomerTagsControllerResponse response =  CustomerTagsController.getCustomerTags(createCaseIdWoAccount().Id,null);
        System.debug('Eazhil Here'+ response.result);
        System.assertEquals('Unexpected Error: Case Id passed in the request is not associated with any Account', response.result.message);
    }
    //Account without Cache
     public static testMethod void testCustomerTagWoCache(){
        Case caseObj = createCaseid('Eazhil', '1293589840714216988');
        CustomerTagsControllerResponse response =  CustomerTagsController.getCustomerTagsWithoutCache(caseObj.Id,caseObj.AccountId);
        System.debug('Eazhil Here'+ response.result);
        System.assertEquals('Failed to load the Data', response.result.message);
    }
    //Account info is Null
     public static testMethod void testAccountNumberNull(){
        Case caseObj = createCaseid('Eazhil', '1293589840714216988');
        CustomerTagsControllerResponse response =  CustomerTagsController.getCustomerTagsWithoutCache(caseObj.Id,caseObj.Id);
        System.debug('Eazhil Here'+ response.result);
        System.assertEquals('Unexpected Error: Failed to identify the Account using Account Id or Case Id', response.result.message);
    }

    public static testMethod void testCustTagsWoCacheAccountNull(){
        Case caseObj = createCaseid('Eazhil', '1293589840714216988');
        CustomerTagsControllerResponse response =  CustomerTagsController.getCustomerTags(caseObj.Id,caseObj.Id);
        System.debug('Eazhil Here'+ response.result);
        System.assertEquals('Unexpected Error: Failed to find the account with Account Id passed in the request', response.result.message);
    }
    
     public static testMethod void testpopulateResponseUsingCustomer360APITestMethod(){
        Customer360APIResponse cx360Response = new Customer360APIResponse();
        cx360Response.setCustomer360Response(200, null);
        CustomerTagsControllerResponse response =  CustomerTagsController.getCustomerTags(null,createAccount('Eazhil', '1293589840714216965').Id);
        System.debug('Eazhil Here'+ response.result);
        System.assertEquals('Data is Partially Loaded', response.result.message);
    }
    
    @isTest
    public static void verifyApiSuccess200Test(){
        // Creating Request
        Customer360APIRequest cx360Request = new Customer360APIRequest();
        Account a = [SELECT Id, Name FROM Account WHERE AccountNumber='1334781826176083629' LIMIT 1];
        cx360Request.setAccount(a);
        cx360Request.setAccount(cloneAccount());
        cx360Request.addToDataCategoriesToBeLoaded(Customer360.DataCategory.ACCOUNT_INFO);
        test.startTest();
         
        // Create the mock response based on a static resource
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('AccountManagerValidResponse');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
        // Associate the callout with a mock response
        Test.setMock(HttpCalloutMock.class, mock);
        // Call method to test
        Customer360APIResponse result = Customer360API.getCustomer360Data(cx360Request);
        Customer360DO customer360do = result.getCustomer360DO();
         System.debug('Success1'+result.isAPIStatusSuccess());
         System.debug('Success2'+result.isAPIStatusPartialSuccess());
         System.debug('Success3'+result.isAPIStatusFailure());
        CustomerTagsControllerResponse response =  CustomerTagsController.getCustomerTags(null,a.Id);
        System.debug('Eazhil Here'+ response.result);
        //System.assertEquals('SUCCESS', response.result.message);
        test.stopTest();
    }
    
     @isTest
    public static void verifyApiPartial206Test(){
        // Creating Request
        Customer360APIRequest cx360Request = new Customer360APIRequest();
        Account a = [SELECT Id, Name FROM Account WHERE AccountNumber='1334781826176083629' LIMIT 1];
        cx360Request.setAccount(a);
        cx360Request.setAccount(cloneAccount());
        cx360Request.addToDataCategoriesToBeLoaded(Customer360.DataCategory.ACCOUNT_INFO);
        test.startTest();
        // Create the mock response based on a static resource
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('AccountManagerValidResponse');
        mock.setStatusCode(206);
        mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
        // Associate the callout with a mock response
        Test.setMock(HttpCalloutMock.class, mock);
        // Call method to test
        Customer360APIResponse result = Customer360API.getCustomer360Data(cx360Request);
        Customer360DO customer360do = result.getCustomer360DO();
         System.debug('Success1'+result.isAPIStatusSuccess());
         System.debug('Success2'+result.isAPIStatusPartialSuccess());
         System.debug('Success3'+result.isAPIStatusFailure());
        CustomerTagsControllerResponse response =  CustomerTagsController.getCustomerTags(null,a.Id);
        System.debug('Eazhil Here'+ response.result);
        //System.assertEquals('SUCCESS', response.result.message);
        test.stopTest();
    }
   }