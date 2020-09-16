public class PayPalContext {

    // Enum defined to handle two different types of actors - TEAMMATE and SYSTEM.
    // TEAMMATE - Any Apex transaction that is exexuted on behalf of a teammate. If an Apex transaction
    //            calls other asyncronous apex, even that is considered as part of the same teammate action.
    // SYSTEM   - Any non-teammate action which is happening outside of the contact. It could be inbound API calls
    //            or scheduled apex even though Salesforce technically has some user associated for those actions too.
    public enum Actor {TEAMMATE, SERVER}

    // Context variables
    public Actor actorType;
    public Id userId;
    public Id caseId;
    public Id accountId;

    // Constructor
    public PayPalContext() {
        actorType = null;
        userId = null;
        caseId = null;
        accountId = null;
    }

    // Function to deserialize the PayPal Context to JSON
    public static PayPalContext parse(String json) {
        return (PayPalContext) System.JSON.deserialize(json, PayPalContext.class);
    }
}