public class TriggerPrefetchAsync implements Queueable, Database.AllowsCallouts
{
    // Serialized Execution Context from the previous context
    private String contextJSON;

    // Account to trigger the pre-fetch
    private String encryptedAccountNumber;

    // Boolean flag that controls whether the pre-fetched data should be pushed to Salesforce or not
    // We will always prefer the data to be available locally, but during Pilot, we need to be cautious of
    // the resource consumption (storage and other limits) since we may have limited license which will
    // allocate only less resources to play with
    private Boolean pushDataToSalesforce;

    // This is futuristic at this point of time. Considering intent prediction for pre-fetch
    // will help to load the most relevant information required for handling this contact as long
    // as the intent prediction accuracy is high.
    // We will always load the critical Customer360 data irrespective of the intent + any data required
    // for one or more predicted intents. Since we will be handling only one intent for the Pilot, this
    // is not much useful at this point of time.
    private Boolean considerIntentPrediction;

    public TriggerPrefetchAsync(String acctNo, Boolean pushData, Boolean considerIntent, String serializedContext) 
    {
        this.encryptedAccountNumber = acctNo;
        this.pushDataToSalesforce = pushData;
        this.considerIntentPrediction = considerIntent;
        this.contextJSON = serializedContext;
    }

    public void execute(QueueableContext context) {
        System.debug('TriggerPrefetchAsync:execute - Start of triggering pre-fetch request to the service');

        // Lets set the current execution context - Please note that Async operations will have to carry the
        // context from the previous execution context so that we will have this execution as a continuation to
        // the previous one in terms of the context parameters like the security context, correlation id and so on
        ExecutionContextUtil.initContextData(contextJSON);
        TriggerPrefetchHandler.sendPrefetchRequestAvoidDuplicates(encryptedAccountNumber, pushDataToSalesforce, considerIntentPrediction);
        System.debug('TriggerPrefetchAsync:execute - End');
        return;
    }
}