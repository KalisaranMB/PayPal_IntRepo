public with sharing class DeclinedTransactions {

        @AuraEnabled
        public List<DeclinedTransaction> declined_transactions;


        public static DeclinedTransactions parse(String json) {
            return (DeclinedTransactions) System.JSON.deserialize(json, DeclinedTransactions.class);
        }
}