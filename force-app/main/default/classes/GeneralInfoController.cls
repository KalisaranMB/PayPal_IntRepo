public class GeneralInfoController {

	public GeneralInfoController() {
	}

	
	/*
	 * Get Account Number from the CaseId.
	 */
	@InvocableMethod(label = 'Get Account Number')
	public static List<GeneralInfoResponse> getContexts(List<String> params) {
		List<GeneralInfoResponse> responseList = new List<GeneralInfoResponse>();
		GeneralInfoResponse response = new GeneralInfoResponse();

		if (params != null) {
			response.accountNumber = AppUtils.getAccountNumber(params[0]);
		}
		
		responseList.add(response);
		
		return responseList;
	}
}