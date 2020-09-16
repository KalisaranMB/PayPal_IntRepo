public class ComplianceInfoAPI {

    public static Customer360SO mapResponseToCustomer360SO(Customer360SO cx360SO, Customer360APIRequest request, Customer360APIResponse response)
    {
        System.debug('ComplianceInfoAPI:mapResponseToCustomer360SO - mapping Compliance Information');
        
        // Check if there are any failures in loading Compliance Info
        if (response.isComplianceInfoFailed())
        {
            System.debug('Customer360 API response does not have any Compliance information');
            return cx360SO;
        }
        
        // Map Compliance Information to the cx360SO object passed in the request
        cx360SO.acct = mapComplianceDOToAccount(cx360SO.acct, response.getCustomer360DO().compliance);

        return cx360SO;
    }

    public static Account storeResponseInSObject(Account acct, Customer360APIRequest request, Customer360APIResponse response)
    {
        System.debug('ComplianceInfoAPI:storeResponseInSObject - Storing Compliance Information into SObject');
        
        // Check if there are any failures in loading Compliance Info
        if (response.isComplianceInfoFailed() || (response.getCustomer360DO().compliance == null))
        {
            System.debug('Customer360 API response did not successfully load Compliance Information');
            return acct;
        }
        
        // Map Compliance Information to the cx360SO object passed in the request
        acct = mapComplianceDOToAccount(acct, response.getCustomer360DO().compliance);

        // If Compliance Information is loaded successfully (NOT a failure or partial success), lets update the cache time
        if (response.isComplianceInfoSuccessfullyLoaded())
        {
            acct.Compliance_Info_Loaded_Time__c = Datetime.now();
        }

        return acct;
    }

    private static Account mapComplianceDOToAccount(Account acct, ComplianceDO compliance)
    {
        if (compliance == null)
        {
            return acct;
        }

        // TBD - We need to check how / where we will get KYC status for business accounts
        
        acct.CIP_Status__c = compliance.cip_status;
        return acct;
    }
}