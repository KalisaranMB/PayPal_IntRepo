public class WalletAPI {

    public static Customer360SO mapResponseToCustomer360SO(Customer360SO cx360SO, Customer360APIRequest request, Customer360APIResponse response)
    {
        System.debug('WalletAPI:mapResponseToCustomer360SO - mapping Wallet Information');
        
        // Check if there are any failures in loading Wallet details
        if (response.isWalletFailed() || (response.getCustomer360DO().financial_instruments == null) ||
            (response.getCustomer360DO().financial_instruments.size() == 0))
        {
            System.debug('Customer360 API response does not have Wallet details');
            return cx360SO;
        }
        
        // Map Wallet details to the cx360SO object passed in the request
        for (FinancialInstrumentDO fi : response.getCustomer360DO().financial_instruments)
        {
            cx360SO.financialInstruments.add(mapFinancialInstrumentDOToSO(fi));
        }

        return cx360SO;
    }

    public static Account storeResponseInSObject(Account acct, Customer360APIRequest request, Customer360APIResponse response)
    {
        System.debug('WalletAPI:storeResponseInSObject - Storing Wallet Information into SObject');
        
        // Check if there are any failures in loading Wallet details
        if (response.isWalletFailed())
        {
            System.debug('Customer360 API did not successfully load Wallet details');
            return acct;
        }

        // Remove all existing financial instruments from the account
        removeFinancialInstrumentsFromAccount(acct);

        List<FinancialInstrumentDO> fis = response.getCustomer360DO().financial_instruments;
        
        if ((fis != null) && (fis.size() > 0))
        {
            List<Account_Wallet__c> walletObjs = new List<Account_Wallet__c>();

            for (FinancialInstrumentDO fi : fis)
            {
                Account_Wallet__c walletObj = mapFinancialInstrumentDOToSO(fi);
                walletObj.Account__c = acct.Id;
                walletObjs.add(walletObj);
            }

            insert walletObjs;
        }

        // If Financial Instruments is successfully loaded (NOT a failure or partial success), update the cache time
        if (response.isWalletSuccessfullyLoaded())
        {
            acct.Wallet_Info_Loaded_Time__c = Datetime.now();
        }

        return acct;
    }

    private static void removeFinancialInstrumentsFromAccount(Account acct)
    {
        List<Account_Wallet__c> fis = queryFinancialInstrumentsFromAccount(acct.Id);
        System.debug('Removing existing financial instruments from the account. Number of records found - ' + fis.size());
        if (fis.size() > 0)
        {
            delete fis;
        }
        return;
    }

    public static Account_Wallet__c mapFinancialInstrumentDOToSO(FinancialInstrumentDO fi)
    {
        Account_Wallet__c aw = new Account_Wallet__c();
        aw.Wallet_Id__c = fi.wallet_id;
        aw.Logo_URL__c = fi.logo_url;
        aw.Issuer_Name__c = fi.issuer_name;
        aw.Customer_Name__c = fi.name_on_file;
        aw.Financial_Instrument_Type__c = fi.financial_instrument_type;
        aw.Financial_Instrument_Subtype__c = fi.subtype;
        aw.Last_4_digits__c = fi.last_digits;
        aw.Expiry_Date__c = fi.expiry_date;
        aw.Status__c = fi.status;
        aw.Confirmation_Status__c = fi.confirmation_status;
        
        // PayPal Credit Limit
        if (fi.paypal_credit_limit != null)
        {
            try {
                aw.Credit_Limit_Amount__c = Decimal.valueOf(fi.paypal_credit_limit.value);
                aw.Credit_Limit_Currency__c = fi.paypal_credit_limit.currency_code;
            }
            catch(Exception e) {
                System.debug('PayPal Credit Limit: ' + e.getMessage() + ', Failed to convert from String to Decimal - ' 
                                                     + JSON.serialize(fi.paypal_credit_limit));
            }
        }

        // PayPal Credit Usage
        if (fi.paypal_credit_usage != null)
        {
            try {
                aw.Credit_Usage_Amount__c = Decimal.valueOf(fi.paypal_credit_usage.value);
                aw.Credit_Usage_Currency__c = fi.paypal_credit_usage.currency_code;
            }
            catch(Exception e) {
                System.debug('PayPal Credit Usage: ' + e.getMessage() + ', Failed to convert from String to Decimal - ' 
                                                     + JSON.serialize(fi.paypal_credit_usage));
            }
        }
        
        return aw;
    }

    private static List<Account_Wallet__c> queryFinancialInstrumentsFromAccount(Id accountId)
    {
        return [SELECT Id, Account__c FROM Account_Wallet__c
                WHERE Account__c=:accountId];
    }
}