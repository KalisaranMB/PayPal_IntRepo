public class InteractionsAPI {
    
    public static Customer360SO mapResponseToCustomer360SO(Customer360SO cx360SO, Customer360APIRequest request, Customer360APIResponse response)
    {
        System.debug('InteractionsAPI:mapResponseToCustomer360SO - mapping Previous Interactions');
        
        // Check if there are any failures in loading previous interactions
        if (response.isPreviousInteractionsFailed() || (response.getCustomer360DO().previous_interactions == null) ||
            (response.getCustomer360DO().previous_interactions.size() == 0))
        {
            System.debug('Customer360 API did not load any previous interactions information');
            return cx360SO;
        }
        
        // Map Previous Interactions Information to the cx360SO object passed in the request
        for (PreviousInteractionDO interaction : response.getCustomer360DO().previous_interactions)
        {
            PreviousInteractionSO interactionSO = new PreviousInteractionSO();
            interactionSO.interaction = mapPreviousInteractionDOToSO(interaction);

            // Check if any intents are available within the interaction and map
            if ((interaction.intents != null) && (interaction.intents.size() != 0))
            {
                for (InteractionIntentDO intent : interaction.intents)
                {
                    interactionSO.intents.add(mapInteractionIntentDOToSO(intent));
                }
            }

            cx360SO.previousInteractions.add(interactionSO);
        }

        return cx360SO;
    }

    public static Account storeResponseInSObject(Account acct, Customer360APIRequest request, Customer360APIResponse response)
    {
        System.debug('InteractionsAPI:storeResponseInSObject - Storing Previous Interactions into SObject');
        
        // Check if there are any failures in loading previous interactions
        if (response.isPreviousInteractionsFailed())
        {
            System.debug('Customer360 API did not load any previous interactions information');
            return acct;
        }

        // Remove all previous interactions from the account
        removePreviousInteractionsFromAccount(acct);

        List<PreviousInteractionDO> interactionDOs = response.getCustomer360DO().previous_interactions;

        if ((interactionDOs != null) && (interactionDOs.size() > 0))
        {
            List<PreviousInteractionSO> interactionSOs = new List<PreviousInteractionSO>();
            List<Previous_Interaction__c> interactionObjsToInsert = new List<Previous_Interaction__c>();
        
            for (PreviousInteractionDO interactionDO : interactionDOs)
            {
                PreviousInteractionSO interactionSO = new PreviousInteractionSO();
                interactionSO.interaction = mapPreviousInteractionDOToSO(interactionDO);
                interactionSO.interaction.Account__c = acct.Id;

                // Check if any intents are available within the interaction and map
                if ((interactionDO.intents != null) && (interactionDO.intents.size() != 0))
                {
                    for (InteractionIntentDO intentDO : interactionDO.intents)
                    {
                        interactionSO.intents.add(mapInteractionIntentDOToSO(intentDO));
                    }
                }

                interactionObjsToInsert.add(interactionSO.interaction);
                interactionSOs.add(interactionSO);
            }

            // Insert all Previous Interactions to the database
            System.debug('Inserting Previous Interaction to the account. Number of records - ' + interactionObjsToInsert.size());
            insert interactionObjsToInsert;

            List<Interaction_Intent__c> intentObjsToInsert = new List<Interaction_Intent__c>();
            for (PreviousInteractionSO intSO : interactionSOs)
            {
                for (Interaction_Intent__c intent : intSO.intents)
                {
                    intent.Previous_Interaction__c = intSO.interaction.Id;
                    intentObjsToInsert.add(intent);
                }
            }

            System.debug('Inserting Interaction Intents to the account. Number of records - ' + intentObjsToInsert.size());
            if (intentObjsToInsert.size() > 0)
            {
                insert intentObjsToInsert;
            }
        }

        // If Previous Interactions is loaded successfully (NOT a failure or partial success), update the cache time
        if (response.isPreviousInteractionsSuccessfullyLoaded())
        {
            acct.Previous_Interactions_Loaded_Time__c = Datetime.now();
        }

        return acct;
    }

    private static Previous_Interaction__c mapPreviousInteractionDOToSO(PreviousInteractionDO interaction)
    {
        Previous_Interaction__c inter = new Previous_Interaction__c();
        inter.Case_Id__c = interaction.case_id;
        inter.Channel_Id__c = interaction.channel_id;
        inter.Channel_Name__c = interaction.channel_name;
        inter.Time_Started__c = interaction.create_time;
        inter.Time_Completed__c = interaction.end_time;
        inter.Parent_Case_Id__c = interaction.parent_case_id;
        inter.Status__c = interaction.status;
        inter.Actor__c = interaction.actor;
        inter.Contact_Reason__c = interaction.contact_reason;
        inter.Has_Followup__c = interaction.followup;
        inter.Followup_Date__c = interaction.followup_date;
        inter.Followup_Reason__c = interaction.followup_reason;

        return inter;
    }

    private static Interaction_Intent__c mapInteractionIntentDOToSO(InteractionIntentDO intent)
    {
        Interaction_Intent__c intentObj = new Interaction_Intent__c();
        intentObj.Name = intent.intent_name;
        intentObj.Time_Started__c = intent.create_time;
        intentObj.Status__c = intent.status;
        intentObj.Actor__c = intent.actor;
        
        return intentObj;
    }

    private static void removePreviousInteractionsFromAccount(Account acct)
    {
        List<Previous_Interaction__c> prevInteractions = queryPreviousInteractionsFromAccount(acct.Id);
        System.debug('Removing previous interactions from the account. Number of records found - ' + prevInteractions.size());
        if (prevInteractions.size() > 0)
        {
            delete prevInteractions;

            // Deleting the previous interactions will automatically delete all interaction intents associated with it
            // because of the Master - Detail relationship
        }
        return;
    }

    private static List<Previous_Interaction__c> queryPreviousInteractionsFromAccount(Id accountId)
    {
        return [SELECT Id, Account__c FROM Previous_Interaction__c
                WHERE Account__c=:accountId];
    }
}