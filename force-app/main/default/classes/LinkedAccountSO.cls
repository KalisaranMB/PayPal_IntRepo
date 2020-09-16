public class LinkedAccountSO {
    @AuraEnabled
    public Linked_Account__c linkedAccount;

    @AuraEnabled
    public List<LinkedAccountAttributeSO> attributes;

    public LinkedAccountSO() {
        linkedAccount = new Linked_Account__c();
        attributes = new List<LinkedAccountAttributeSO>();
    }
}