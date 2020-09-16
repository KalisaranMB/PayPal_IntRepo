public with sharing class DeclinedTransaction {

        @AuraEnabled
        public String reason_code;

        @AuraEnabled
        public String decision_code;

        @AuraEnabled
        public String counterparty_name;

        @AuraEnabled
        public Amount amount;

        @AuraEnabled
        public String counterparty_email;

        @AuraEnabled
        public Boolean is_risk_decline;

        @AuraEnabled
        public String resolution_condition;

        @AuraEnabled
        public String flow_name;

        @AuraEnabled
        public String internal_intent;

        @AuraEnabled
        public String auth_flow_context_id;

        @AuraEnabled
        public String attempt_time;

        @AuraEnabled
        public String counterparty_accountnumber;

        @AuraEnabled
        public List<String> funding_sources_allowed;

        @AuraEnabled
        public List<Amount> funding_amounts;

        @AuraEnabled
        public String transaction_type;

        @AuraEnabled
        public List<String> risk_decision;

        @AuraEnabled
        public List<String> funding_sources_denied;

        @AuraEnabled
        public Amount incentive_amount;


        public static List<DeclinedTransaction> parse(String json) {
            return (List<DeclinedTransaction>) System.JSON.deserialize(json, List<DeclinedTransaction>.class);
        }
}