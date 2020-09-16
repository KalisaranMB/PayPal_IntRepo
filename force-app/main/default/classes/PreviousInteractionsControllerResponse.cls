public class PreviousInteractionsControllerResponse {
    @AuraEnabled
    public List<PreviousInteractionSO> interactions;

    @AuraEnabled
    public Customer360StatusWO result;

    public PreviousInteractionsControllerResponse() {
        interactions = new List<PreviousInteractionSO>();
        result = new Customer360StatusWO();
    }
}