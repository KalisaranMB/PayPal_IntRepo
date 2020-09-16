public class DeclinedTransactionTestUtils {
    
    public static DeclinedTransactions getSuccessResponse() {
		DeclinedTransactions response = new DeclinedTransactions();
		
		List<DeclinedTransaction> items = new List<DeclinedTransaction>();
		
		DeclinedTransaction declinedTransaction = new DeclinedTransaction();
		declinedTransaction.resolution_condition='SMS or KBA';
        declinedTransaction.attempt_time='2020-09-01T03:31:16.000Z';
		Amount amount=new Amount();
        amount.value='1000';
		amount.currency_code='USD';
		declinedTransaction.amount=amount;
        items.add(declinedTransaction);
        response.declined_transactions=items;
		return response;
	}

}