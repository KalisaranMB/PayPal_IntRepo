/**
* ─────────────────────────────────────────────────────────────────┐
* Utils class for all common invocations in the app.
*
* 
* ──────────────────────────────────────────────────────────────────
* @author         Sugyan Sahu   <sugsahu@paypal.com>
* @version        1.0
* @created        2020-08-24
* ──────────────────────────────────────────────────────────────────
* @changes
* v1.0            sugsahu@paypal.com
* 2020-08-24      Created the class as part of integration to contact-contexts API.
* ─────────────────────────────────────────────────────────────────┘
*/
public class AppUtils {

	public static String getAccountNumber(String caseId) {
		List<Case> caseList = [SELECT Account.AccountNumber FROM Case WHERE Case.CaseNumber = :caseId];
		
		if(caseList!=null) {
			return caseList[0].Account.AccountNumber;
		}

		return '';
	}
}