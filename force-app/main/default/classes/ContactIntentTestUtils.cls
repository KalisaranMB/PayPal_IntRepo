public class ContactIntentTestUtils {

	/*
	 * returns single context info for success case.
	 */
	public static ContextCollectionResponse getSuccessResponse() {
		ContextCollectionResponse response = new ContextCollectionResponse();
		response.total_items = 1;
		response.total_pages = 1;
		
		List<Context> items = new List<Context>();
		
		Context context1 = new Context();
		ContextIntent intent = new ContextIntent();
		intent.priority = 1;
		intent.internal_treatment = 'ATO Decline';
		intent.customer_intent = 'Payment Decline';
		intent.code = 'FIPAYLN026';
		context1.intent = intent;
		context1.status = 'ACTIVE';
		context1.channel = 'COMPASS_CS';
		context1.customer_type = 'CONSUMER';
		
		items.add(context1);
		response.items = items;

		List<LinkDescription> links = new List<LinkDescription>();

		LinkDescription linkDescription = new LinkDescription();
		linkDescription.method = 'GET';
		linkDescription.rel = 'self';
		linkDescription.href = 'https://te-alm-18548962012353995619396.qa.paypal.com:21014/v1/customer-support/contexts?channel_name=IVR&customer_id=1279734805778402069&page_size=10&page=1';
		links.add(linkDescription);
		
		response.links = links;
		
		return response;
	}


	/*
	 * returns multiple contexts info with all ACTIVE status.
	 */
	public static ContextCollectionResponse getMultipleContextWithActiveStatus() {
		ContextCollectionResponse response = new ContextCollectionResponse();
		response.total_items = 2;
		response.total_pages = 1;

		List<Context> items = new List<Context>();

		Context context1 = new Context();
		ContextIntent intent = new ContextIntent();
		intent.priority = 2;
		intent.internal_treatment = 'ATO Decline';
		intent.customer_intent = 'Payment Decline';
		intent.code = 'FIPAYLN026';
		context1.intent = intent;
		context1.status = 'ACTIVE';
		context1.channel = 'COMPASS_CS';
		context1.customer_type = 'CONSUMER';

		items.add(context1);
		
		Context context2 = new Context();
		ContextIntent intent2 = new ContextIntent();
		intent2.priority = 1;
		intent2.internal_treatment = 'Merchant Decline';
		intent2.customer_intent = 'Payment Decline';
		intent2.code = 'FIPAYLN027';
		context2.intent = intent2;
		context2.status = 'ACTIVE';
		context2.channel = 'COMPASS_CS';
		context2.customer_type = 'CONSUMER';

		items.add(context2);
		response.items = items;

		List<LinkDescription> links = new List<LinkDescription>();

		LinkDescription linkDescription = new LinkDescription();
		linkDescription.method = 'GET';
		linkDescription.rel = 'self';
		linkDescription.href = 'https://te-alm-18548962012353995619396.qa.paypal.com:21014/v1/customer-support/contexts?channel_name=IVR&customer_id=1279734805778402069&page_size=10&page=1';
		links.add(linkDescription);

		response.links = links;

		return response;
	}

	/*
	 * returns multiple contexts info with  ACTIVE & INCOMPLETE status.
	 */
	public static ContextCollectionResponse getMultipleContextWithActiveAndIncompleteStatus() {
		ContextCollectionResponse response = new ContextCollectionResponse();
		response.total_items = 3;
		response.total_pages = 1;

		List<Context> items = new List<Context>();

		Context context1 = new Context();
		ContextIntent intent = new ContextIntent();
		intent.priority = 2;
		intent.internal_treatment = 'ATO Decline';
		intent.customer_intent = 'Payment Decline';
		intent.code = 'FIPAYLN026';
		context1.intent = intent;
		context1.status = 'ACTIVE';
		context1.channel = 'COMPASS_CS';
		context1.customer_type = 'CONSUMER';

		items.add(context1);
		
		Context context2 = new Context();
		ContextIntent intent2 = new ContextIntent();
		intent2.priority = 1;
		intent2.internal_treatment = 'Merchant Decline';
		intent2.customer_intent = 'Payment Decline';
		intent2.code = 'FIPAYLN027';
		context2.intent = intent2;
		context2.status = 'INCOMPLETE';
		context2.channel = 'COMPASS_CS';
		context2.customer_type = 'CONSUMER';

		items.add(context2);


		Context context3 = new Context();
		ContextIntent intent3 = new ContextIntent();
		intent3.priority = 3;
		intent3.internal_treatment = 'Add Bank';
		intent3.customer_intent = 'Add Bank';
		intent3.code = 'FIPAYLN028';
		context3.intent = intent3;
		context3.status = 'INCOMPLETE';
		context3.channel = 'COMPASS_CS';
		context3.customer_type = 'CONSUMER';

		items.add(context3);
		
		response.items = items;

		List<LinkDescription> links = new List<LinkDescription>();

		LinkDescription linkDescription = new LinkDescription();
		linkDescription.method = 'GET';
		linkDescription.rel = 'self';
		linkDescription.href = 'https://te-alm-18548962012353995619396.qa.paypal.com:21014/v1/customer-support/contexts?channel_name=IVR&customer_id=1279734805778402069&page_size=10&page=1';
		links.add(linkDescription);

		response.links = links;

		return response;
	}

}