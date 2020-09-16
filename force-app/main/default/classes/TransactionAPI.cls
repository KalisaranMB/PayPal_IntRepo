public class TransactionAPI {
    
    public static Customer360SO mapResponseToCustomer360SO(Customer360SO cx360SO, Customer360APIRequest request, Customer360APIResponse response)
    {
        System.debug('TransactionAPI:mapResponseToCustomer360SO - mapping Transaction Information');
        
        // Check if there are any failures in loading Transaction logs
        if (response.isTransactionsFailed() || (response.getCustomer360DO().transactions == null) ||
            (response.getCustomer360DO().transactions.size() == 0))
        {
            System.debug('Customer360 API response does not have any Transactions');
            return cx360SO;
        }
        
        // Map Transaction logs to the cx360SO object passed in the request
        for (TransactionDO txn : response.getCustomer360DO().transactions)
        {
            cx360SO.transactions.add(mapTransactionDOToSO(txn));
        }

        return cx360SO;
    }

    public static Account storeResponseInSObject(Account acct, Customer360APIRequest request, Customer360APIResponse response)
    {
        System.debug('TransactionAPI:storeResponseInSObject - Storing Transactions into SObject');
        
        // Check if there are any failures in loading Transaction Logs
        if (response.isTransactionsFailed())
        {
            System.debug('Customer360 API did not successfully load Transaction Logs');
            return acct;
        }

        // Remove all existing transactions from the account
        removeTransactionsFromAccount(acct);

        List<TransactionDO> txns = response.getCustomer360DO().transactions;
        
        if ((txns != null) && (txns.size() > 0))
        {
            List<Transaction_Log__c> txnObjs = new List<Transaction_Log__c>();

            for (TransactionDO txn : txns)
            {
                Transaction_Log__c txnObj = mapTransactionDOToSO(txn);
                txnObj.Account__c = acct.Id;
                txnObjs.add(txnObj);
            }

            insert txnObjs;
        }

        // If Transaction logs are successfully loaded (NOT a failure or partial success), update the cache time
        if (response.isTransactionsSuccessfullyLoaded())
        {
            acct.TransactionLog_Loaded_Time__c = Datetime.now();
        }

        return acct;
    }

    private static void removeTransactionsFromAccount(Account acct)
    {
        List<Transaction_Log__c> transactions = queryTransactionsFromAccount(acct.Id);
        System.debug('Removing existing transactions from the account. Number of records found - ' + transactions.size());
        if (transactions.size() > 0)
        {
            delete transactions;
        }
        return;
    }

    private static Transaction_Log__c mapTransactionDOToSO(TransactionDO txn)
    {
        Transaction_Log__c trans = new Transaction_Log__c();
        trans.Transaction_Type__c = txn.transaction_type;
        trans.Transaction_Time__c = txn.create_time;
        trans.Transaction_Id__c = txn.transaction_id;
        trans.Transaction_Id_Encrypted__c = txn.encrypted_transaction_id;
        trans.Transaction_Status__c = txn.status;
        trans.Last_4_digits__c = txn.last_digits;
        trans.ToFrom__c = txn.to_and_from;
        trans.Counterparty_Name__c = txn.counterparty_name;
        trans.Counterparty_Email__c = txn.counterparty_email;
        trans.Is_Parent__c = txn.parent;
        trans.Has_Dispute__c = txn.disputed;
        
        // Gross Amount
        if (txn.gross_amount != null)
        {
            try {
                trans.Gross_Amount__c = Decimal.valueOf(txn.gross_amount.value);
                trans.Gross_Amount_Currency_Code__c = txn.gross_amount.currency_code;
            }
            catch(Exception e) {
                System.debug('Gross Amount: ' + e.getMessage() + ', Failed to convert from String to Decimal - ' 
                                            + JSON.serialize(txn.gross_amount));
            }
        }

        // Net Amount
        if (txn.net_amount != null)
        {
            try {
                trans.Net_Amount__c = Decimal.valueOf(txn.net_amount.value);
                trans.Net_Amount_Currency_Code__c = txn.net_amount.currency_code;
            }
            catch(Exception e) {
                System.debug('Net Amount: ' + e.getMessage() + ', Failed to convert from String to Decimal - ' 
                                            + JSON.serialize(txn.net_amount));
            }
        }

        // Fee Amount
        if (txn.fee_amount != null)
        {
            try {
                trans.Fee_Amount__c = Decimal.valueOf(txn.fee_amount.value);
                trans.Fee_Amount_Currency_Code__c = txn.fee_amount.currency_code;
            }
            catch(Exception e) {
                System.debug('Fee Amount: ' + e.getMessage() + ', Failed to convert from String to Decimal - ' 
                                            + JSON.serialize(txn.fee_amount));
            }
        }

        // Running Balance Amount
        if (txn.running_balance_amount != null)
        {
            try {
                trans.Running_Balance_Amount__c = Decimal.valueOf(txn.running_balance_amount.value);
                trans.Running_Balance_Amount_Currency_Code__c = txn.running_balance_amount.currency_code;
            }
            catch(Exception e) {
                System.debug('Running Balance Amount: ' + e.getMessage() + ', Failed to convert from String to Decimal - ' 
                                                        + JSON.serialize(txn.running_balance_amount));
            }
        }
        
        return trans;
    }

    private static List<Transaction_Log__c> queryTransactionsFromAccount(Id accountId)
    {
        return [SELECT Id, Account__c FROM Transaction_Log__c
                WHERE Account__c=:accountId];
    }
}