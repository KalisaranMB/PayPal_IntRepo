public class ToolInterplayController {

    // This is a dummy controller method that should be removed once we implement
    // real controllers to handle all the Tool Interplay messages.

    @AuraEnabled
    public static String dummyCaseCreation(String acctNo)
    {
        Account acct;
        List<Account> accts = [SELECT Id, Account_Number_Encrypted__c, AccountNumber, Name FROM Account WHERE Account_Number_Encrypted__c = :acctNo];

        if ((accts == null) || (accts.size() == 0))
        {
            acct = new Account();
            acct.Name = 'Jennifer Lawrence';
            acct.Account_Number_Encrypted__c = acctNo;
            acct.AccountNumber = acctNo;
            upsert acct Account_Number_Encrypted__c;
            System.debug('New Account Created - ' + acct.Id);
        }
        else
        {
            acct = accts[0];
            System.debug('Account already available - ' + acct.Id);
        }

        Case cs = new Case();
        cs.Origin = 'Phone';
        cs.Status = 'Resolution';
        cs.AccountId = acct.Id;
        cs.Channel_Id__c = String.valueOf(Integer.valueof(Math.random() * 10000));
        insert cs;

        System.debug('New Case Created - ' + cs.Id);
        return cs.Id;
    }
}