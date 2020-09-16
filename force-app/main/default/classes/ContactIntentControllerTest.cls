@isTest
public class ContactIntentControllerTest {

	/*
	 * Verify single intent using Flow API.
	 */
	@isTest
	public static void testSingleIntent() {
		// Set mock callout class 
		Test.setMock(HttpCalloutMock.class,
				new MockContactIntentApi(200, MockContactIntentApi.Scenario.POSITIVE_SINGLE_CONTEXT, null));

		List<List<String>> listOfList = new List<List<String>>();

		List<String> strList = new List<String>();
		strList.add('1279734805778402069');
		strList.add('COMPASS_CS');

		listOfList.add(strList);

		List<ContactIntentResponseWrapper> res = ContactIntentController.getIntents(listOfList);

		System.assert(res!=null);
		System.assert(res.get(0)!=null);
		System.assert(res.get(0).response!=null);
		System.assert(res.get(0).response.intents!=null);
		System.assertEquals(1, res.get(0).response.intents.size());

		System.assertEquals(1, res.get(0).response.intents.get(0).intentPriority);
		System.assertEquals('Payment Decline', res.get(0).response.intents.get(0).customerIntent);
		System.assertEquals('ATO Decline', res.get(0).response.intents.get(0).internalIntent);
	}

	
	/*
	 * Verify multiple intent using Flow method with Active status.
	 */
	@isTest
	public static void testMultipleIntentsWithActiveStatus() {
		Test.setMock(HttpCalloutMock.class,
				new MockContactIntentApi(200, MockContactIntentApi.Scenario.POSITIVE_MULTIPLE_CONTEXT_ACTIVE_STATUS, null));

		List<List<String>> listOfList = new List<List<String>>();

		List<String> strList = new List<String>();
		strList.add('1279734805778402069');
		strList.add('COMPASS_CS');

		listOfList.add(strList);

		List<ContactIntentResponseWrapper> res = ContactIntentController.getIntents(listOfList);
		
		System.assert(res!=null);
		System.assert(res.get(0)!=null);
		System.assert(res.get(0).response!=null);
		System.assert(res.get(0).response.intents!=null);
		System.assert(res.get(0).response.intents.size()==2);
		System.assertEquals(1, res.get(0).response.intents.get(0).intentPriority);
		System.assertEquals('Payment Decline', res.get(0).response.intents.get(0).customerIntent);
		System.assertEquals('Merchant Decline', res.get(0).response.intents.get(0).internalIntent);

		System.assertEquals(2, res.get(0).response.intents.get(1).intentPriority);
		System.assertEquals('Payment Decline', res.get(0).response.intents.get(1).customerIntent);
		System.assertEquals('ATO Decline', res.get(0).response.intents.get(1).internalIntent);
	}



	/*
	 * Verify multiple intent using Flow method with Active status.
	 */
	@isTest
	public static void testMultipleIntentsWithActiveAndIncompleteStatus() {
		Test.setMock(HttpCalloutMock.class,
				new MockContactIntentApi(200, MockContactIntentApi.Scenario.POSITIVE_MULTIPLE_CONTEXT_ACTIVE_AND_INCOMPLETE_STATUS, null));

		List<List<String>> listOfList = new List<List<String>>();

		List<String> strList = new List<String>();
		strList.add('1279734805778402069');
		strList.add('COMPASS_CS');

		listOfList.add(strList);

		List<ContactIntentResponseWrapper> res = ContactIntentController.getIntents(listOfList);

		System.assert(res!=null);
		System.assert(res.get(0)!=null);
		System.assert(res.get(0).response!=null);
		System.assert(res.get(0).response.intents!=null);
		System.assertEquals(1, res.get(0).response.intents.size());

		System.assertEquals(2, res.get(0).response.intents.get(0).intentPriority);
		System.assertEquals('Payment Decline', res.get(0).response.intents.get(0).customerIntent);
		System.assertEquals('ATO Decline', res.get(0).response.intents.get(0).internalIntent);
	}
	
	

	/*
	 * Verify single intent using Callout method.
	 */
	@isTest
	public static void testSingleIntentWithCallOutMethod() {
		// Set mock callout class 
		Test.setMock(HttpCalloutMock.class,
				new MockContactIntentApi(200, MockContactIntentApi.Scenario.POSITIVE_SINGLE_CONTEXT, null));

		List<List<String>> listOfList = new List<List<String>>();

		List<String> strList = new List<String>();
		strList.add('1279734805778402069');
		strList.add('COMPASS_CS');

		listOfList.add(strList);

		HttpResponse res = ContactIntentController.getContexts('1279734805778402069', 'COMPASS_CS');

		ContextCollectionResponse response =
				(ContextCollectionResponse) System.JSON.deserialize(res.getBody(), ContextCollectionResponse.class);
		
		System.assertEquals(200, res.getStatusCode());
		System.assert(response.items!=null);
		System.assert(response.items.size() > 0);
		System.assert(response.items.get(0)!=null);
		System.assert(response.items.get(0).intent!=null);
		System.assertEquals('Payment Decline', response.items.get(0).intent.customer_intent);
		System.assertEquals('ATO Decline', response.items.get(0).intent.internal_treatment);


	}
}