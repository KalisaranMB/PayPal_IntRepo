@isTest
public class DeclinedTransactionsControllerTest {
   
	
	@isTest
	public static void testDeclinedTransaction_success() {
		// Set mock callout class 
		Test.setMock(HttpCalloutMock.class,
				new MockDeclinedTransactionApi(200, MockDeclinedTransactionApi.Scenario.POSITIVE_SINGLE_TRANSACTION, null));
		DeclinedTransactionsController.Requests request = new DeclinedTransactionsController.Requests();
        request.accountId='1629227783938137264';
        request.type='all';

		List<DeclinedTransactionsController.Requests> parm = new List<DeclinedTransactionsController.Requests>();
        parm.add(request);
        List<DeclinedTransactionsController.Results> res = DeclinedTransactionsController.getDeclinedTransactions(parm);

		System.assert(res!=null);
        
		
	}
    
}