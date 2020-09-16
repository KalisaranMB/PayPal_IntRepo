public class PayPalCaseAPI {
    
    public static Customer360SO mapResponseToCustomer360SO(Customer360SO cx360SO, Customer360APIRequest request, Customer360APIResponse response)
    {
        System.debug('PayPalCaseAPI:mapResponseToCustomer360SO - mapping Case Information');
        
        // Check if there are any failures in loading PayPal Case logs
        if (response.isCasesFailed() || (response.getCustomer360DO().cases == null) ||
            (response.getCustomer360DO().cases.size() == 0))
        {
            System.debug('No PayPal case logs available in Customer360 API response');
            return cx360SO;
        }
        
        // Map Case logs to the cx360SO object passed in the request
        for (PayPalCaseDO cs : response.getCustomer360DO().cases)
        {
            cx360SO.cases.add(mapPayPalCaseDOToSO(cs));
        }

        return cx360SO;
    }

    public static Account storeResponseInSObject(Account acct, Customer360APIRequest request, Customer360APIResponse response)
    {
        System.debug('PayPalCaseAPI:storeResponseInSObject - Storing Case Logs to SObject');
        
        // Check if there are any failures in loading PayPal Case logs
        if (response.isCasesFailed())
        {
            System.debug('Customer360 API did not successfully load PayPal case logs');
            return acct;
        }

        // Remove all PayPal cases from the account
        removePayPalCasesFromAccount(acct);

        List<PayPalCaseDO> cases = response.getCustomer360DO().cases;
        
        if ((cases != null) && (cases.size() > 0))
        {
            List<Paypal_Case__c> caseObjs = new List<Paypal_Case__c>();

            for (PayPalCaseDO cs : cases)
            {
                Paypal_Case__c caseObj = mapPayPalCaseDOToSO(cs);
                caseObj.Account__c = acct.Id;
                caseObjs.add(caseObj);
            }

            insert caseObjs;
        }

        // If Case logs are successfully loaded (NOT a failure or partial success), update the cache time
        if (response.isCasesSuccessfullyLoaded())
        {
            acct.PayPal_Cases_Loaded_Time__c = Datetime.now();
        }

        return acct;
    }

    private static void removePayPalCasesFromAccount(Account acct)
    {
        List<Paypal_Case__c> cases = queryPayPalCasesFromAccount(acct.Id);
        System.debug('Removing existing PayPal cases from the account. Number of records found - ' + cases.size());
        if (cases.size() > 0)
        {
            delete cases;
        }
        return;
    }

    private static Paypal_Case__c mapPayPalCaseDOToSO(PayPalCaseDO cs)
    {
        Paypal_Case__c ppCase = new Paypal_Case__c();
        ppCase.Case_Type__c = cs.case_type;
        ppCase.Case_Subtype__c = cs.subtype;
        ppCase.Time_Created__c = cs.create_time;
        ppCase.Transaction_Ids_JSON__c = JSON.serialize(cs.transaction_ids);
        ppCase.Case_Id__c = cs.case_id;
        ppCase.Party__c = cs.party;
        ppCase.Case_Status__c = cs.status;
        ppCase.Case_System__c = cs.case_system;
        
        return ppCase;
    }

    private static List<Paypal_Case__c> queryPayPalCasesFromAccount(Id accountId)
    {
        return [SELECT Id, Account__c FROM Paypal_Case__c
                WHERE Account__c=:accountId];
    }
}