public class PreviousInteractionSO {
    public Previous_Interaction__c interaction;
    public List<Interaction_Intent__c> intents;

    public PreviousInteractionSO() {
        interaction = new Previous_Interaction__c();
        intents = new List<Interaction_Intent__c>();
    }
}