@IsTest
public with sharing class DeclinedTransactionsTest {
    static testMethod void testParse() {
		String json = '['+
		'    {'+
		'        \"reason_code\": \"66769\",'+
		'        \"decision_code\": \"DECLINE_PMT\",'+
		'        \"counterparty_name\": \"hades_deny_careJerry\",'+
		'        \"amount\": {'+
		'            \"value\": \"1000.00\",'+
		'            \"currency_code\": \"USD\"'+
		'        },'+
		'        \"counterparty_email\": \"dottool-buyer-657592991332198@paypal.com\",'+
		'        \"is_risk_decline\": true,'+
		'        \"resolution_condition\": \"SMS or KBA\",'+
		'        \"flow_name\": \"CONSOLIDATED_FUNDING\",'+
		'        \"internal_intent\": \"Collusion Decline\",'+
		'        \"auth_flow_context_id\": \"8c687bca55514c8477b0e97e0a6af960\",'+
		'        \"attempt_time\": \"2020-07-23T16:51:10.000Z\",'+
		'        \"counterparty_accountnumber\": \"1391081759939052409\"'+
		'    },'+
		'    {'+
		'        \"counterparty_name\": \"Gary Gary\",'+
		'        \"amount\": {'+
		'            \"value\": \"123.00\",'+
		'            \"currency_code\": \"USD\"'+
		'        },'+
		'        \"counterparty_email\": \"dottool-seller-1137944619621204@paypal.com\",'+
		'        \"funding_sources_allowed\": ['+
		'            \"<Currency: USD>\"'+
		'        ],'+
		'        \"is_risk_decline\": false,'+
		'        \"funding_amounts\": ['+
		'            {'+
		'                \"value\": \"123.00\",'+
		'                \"currency_code\": \"USD\"'+
		'            }'+
		'        ],'+
		'        \"internal_intent\": \"Issuer Decline\",'+
		'        \"attempt_time\": \"2020-07-23T17:51:10.000Z\",'+
		'        \"transaction_type\": \"Mobile Express Checkout\",'+
		'        \"counterparty_accountnumber\": \"1542805703749623063\",'+
		'        \"risk_decision\": ['+
		'            \"vbase_t1 - score: 471.0000, Score(1): 672.0000, Score(2): 863.0000, Score(3): 780.0000, Segment: 0 \",'+
		'            \"RAO_ELIGIBILITY:\",'+
		'            \"<Currency: USD>\",'+
		'            \"iACH , Funding Declined\",'+
		'            \"Card , Funding Declined\",'+
		'            \"eCheck , Funding Declined\",'+
		'            \"Pluto Rules Fired: 400783,\",'+
		'            \"Payment declined \"'+
		'        ],'+
		'        \"reason_code\": \"3120\",'+
		'        \"funding_sources_denied\": ['+
		'            \"<Currency: USD>\",'+
		'            \"iACH\",'+
		'            \"Card\",'+
		'            \"eCheck\"'+
		'        ],'+
		'        \"incentive_amount\": {'+
		'            \"value\": \"0.00\",'+
		'            \"currency_code\": \"USD\"'+
		'        }'+
		'    }'+
		']';
		DeclinedTransactions obj = DeclinedTransactions.parse(json);
		System.assert(obj != null);
	}
}