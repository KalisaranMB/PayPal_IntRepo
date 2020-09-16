public class PreviousInteractionsController {

    /* This controller is responsible for handling Previous Interactions for the account.
     * 
     * Please note that this component can be embedded within both case record page as well as 
     * account record page since it supports querying based on both case or account.
     */

    @AuraEnabled(cacheable=true)
    public static PreviousInteractionsControllerResponse getPreviousInteractions(Id caseId, Id accountId)
    {
        System.debug('PreviousInteractionsController:getPreviousInteractions Start');

        // Lets set the current execution context as a first step in any transaction
        ExecutionContextUtil.initContextData(PayPalContext.Actor.TEAMMATE, caseId, accountId);
        PreviousInteractionsControllerResponse response = new PreviousInteractionsControllerResponse();

        // If both caseId and accountId is NULL, lets stop right here
        if ((caseId == null) && (accountId == null))
        {
            System.debug(LoggingLevel.ERROR, 'Both Case Id and Account Id is null - cannot proceed further');
            response.result.setStatusAndMessage(Customer360.Status.FAILURE, 'Unexpected Error: Both Case Id and Account Id is missing in the request');
            return response;
        }

        List<Account> accountList = new List<Account>();

        // If we have a valid accountId, lets try to load data using that rather than using the caseId
        // Ideally, we could have done this using Dynamic SOQL instead of writing two queries, but we need to 
        // use dynamic SOQL with a caution since it is vulnerable to SQL injection and hence better to avoid it
        // unless the usecase is complex enough to mandate it.
        if (accountId != null)
        {
            accountList = queryAccountWithAccountId(accountId);
            if (accountList.size() == 0)
            {
                // May be the account Id is invalid
                System.debug(LoggingLevel.ERROR, 'Invalid Account Id: accountId - ' + accountId);
                response.result.setStatusAndMessage(Customer360.Status.FAILURE, 'Unexpected Error: Failed to find the account with Account Id passed in the request');
                return response;
            }
        }
        else // query with caseId, if we are here it cannot be null
        {
            accountList = queryAccountWithCaseId(caseId);
            if (accountList.size() == 0)
            {
                // May be the case is not linked to any account, its strange but there is a possiblity
                System.debug(LoggingLevel.ERROR, 'Case Id received is not associated with any account: caseId - ' + caseId);
                response.result.setStatusAndMessage(Customer360.Status.FAILURE, 'Unexpected Error: Case Id passed in the request is not associated with any Account');
                return response;
            }
        }

        Account acc = accountList[0];
        Customer360APIRequest cx360Request = new Customer360APIRequest();
        cx360Request.setAccount(acc);

        /***************************** Previous Interactions *****************************/
        if (Customer360Util.isDataNotAvailableLocally(Customer360.DataCategory.PREVIOUS_INTERACTIONS, acc.Previous_Interactions_Loaded_Time__c))
        {
            System.debug('Previous Interactions needs to be loaded. Last loaded time - ' + acc.Previous_Interactions_Loaded_Time__c);
            cx360Request.addToDataCategoriesToBeLoaded(Customer360.DataCategory.PREVIOUS_INTERACTIONS);
        }
        else 
        {
            System.debug('Previous Interactions is available and fresh enough to use. Last loaded time - ' + acc.Previous_Interactions_Loaded_Time__c);
            cx360Request.addToDataCategoriesAvailable(Customer360.DataCategory.PREVIOUS_INTERACTIONS);
            response = mapPreviousInteractions(response, acc.Previous_Interactions__r);
        }

        // Great, we are done with data checks needed for Previous Interactions, lets see if we need to load in real time
        if (cx360Request.getDataCategoriesToBeLoaded().size() > 0)
        {
            response = populateResponseUsingCustomer360API(response, cx360Request);
        }
        else {
            // Great, everything we need was retrieved from local objects itself - thanks to pre-fetch tech
            // Lets mark the status as SUCCESS.
            response.result.setStatus(Customer360.Status.SUCCESS);
        }

        System.debug('PreviousInteractionsController:getPreviousInteractions End');
        return response;
    }

    /* Ths controller provides the ability to search for previous interactions using a time range. This will be mostly
     * useful when the component is used as a widget which will allow the teammate to search or narrow down on the data
     * 
     * Please check the PreviousInteractionSearchCriteria to understand what kind of search options are supported by this
     * controller and explanation on how to use it
     */

    @AuraEnabled
    public static PreviousInteractionsControllerResponse searchPreviousInteractions(Id caseId, Id accountId, PreviousInteractionSearchCriteria criteria)
    {
        System.debug('PreviousInteractionsController:searchPreviousInteractions - Start');

        // Lets set the current execution context as a first step in any transaction
        ExecutionContextUtil.initContextData(PayPalContext.Actor.TEAMMATE, caseId, accountId);
        PreviousInteractionsControllerResponse response = new PreviousInteractionsControllerResponse();

        Account acc = Customer360Util.getBasicAccountDetails(caseId, accountId);
        if (acc == null)
        {
            System.debug(LoggingLevel.ERROR, 'Failed to identify the Account using account id or case id');
            response.result.setStatusAndMessage(Customer360.Status.FAILURE, 'Unexpected Error: Failed to identify the Account using Account Id or Case Id');
            return response;
        }

        System.debug('Search Criteria Passed in the request - ' + JSON.serialize(criteria));

        // Ensure search criteria is valid
        // fromTime and toTime must be present since that is the only supported search criteria
        if ((criteria.fromTime == null) && (criteria.toTime == null))
        {
            System.debug('Search criteria does not have both fromTime and toTime');
            response.result.setStatusAndMessage(Customer360.Status.FAILURE, 'Both fromTime and toTime in the search request is null');
            return response;
        }

        // fromTime cannot be greater than toTime
        if (criteria.fromTime > criteria.toTime)
        {
            System.debug('Invalid search data - fromTime is greater than toTime');
            response.result.setStatusAndMessage(Customer360.Status.FAILURE, 'Invalid search criteria - fromTime is greater than toTime');
            return response;
        }

        // fromTime cannot be in future
        if (criteria.fromTime > Datetime.now())
        {
            System.debug('Invalid search data - fromTime is in future');
            response.result.setStatusAndMessage(Customer360.Status.FAILURE, 'Invalid search data - fromTime is in future');
            return response;
        }

        Customer360APIRequest cx360Request = new Customer360APIRequest();
        cx360Request.setAccount(acc);

        // Add Previous Interactions data category to the request
        cx360Request.addToDataCategoriesToBeLoaded(Customer360.DataCategory.PREVIOUS_INTERACTIONS);

        // Add the search criteria to the request
        cx360Request.addToSearchCriteriaToBeLoaded(Customer360.SearchCriteria.PREVIOUS_INTERACTIONS_START_DATE, JSON.serialize(criteria.fromTime));
        cx360Request.addToSearchCriteriaToBeLoaded(Customer360.SearchCriteria.PREVIOUS_INTERACTIONS_END_DATE, JSON.serialize(criteria.toTime));

        response = populateResponseUsingCustomer360API(response, cx360Request);

        System.debug('PreviousInteractionsController:searchPreviousInteractions - End');
        return response;
    }

    private static PreviousInteractionsControllerResponse populateResponseUsingCustomer360API(PreviousInteractionsControllerResponse response, Customer360APIRequest cx360Request)
    {
        // Get the required Customer360 data in real-time
        Customer360APIResponse cx360Response = Customer360API.getCustomer360Data(cx360Request);

        if (cx360Response.isAPIStatusSuccess())
        {
            response.result.setStatus(Customer360.Status.SUCCESS);

            // Go ahead and map the Customer360 API response to Previous Interactions
            Customer360SO cx360SO = Customer360API.mapResponseToCustomer360SO(cx360Request, cx360Response);
            response.interactions = cx360SO.previousInteractions;
        }
        else
        {
            // There is only one data entity we were trying to load, if it is not SUCCESS, then whole Previous Interactions is not available
            // We dont need to worry about or handle partial success vs failures in this case
            response.result.setStatusAndMessage(Customer360.Status.FAILURE, 'Failed to load the Data');
            response.result.unavailableDataList.addAll(Customer360.getDescriptionForCategories(cx360Request.getDataCategoriesToBeLoaded()));
        }

        return response;
    }

    private static PreviousInteractionsControllerResponse mapPreviousInteractions(PreviousInteractionsControllerResponse response, List<Previous_Interaction__c> interactions)
    {
        if ((interactions == null) || (interactions.size() == 0))
        {
            System.debug('There are no previous interactions associated with the account');
            return response;
        }

        Map<Id, PreviousInteractionSO> interactionsSOMap = new Map<Id, PreviousInteractionSO>();
        List<Id> interactionIds = new List<Id>();

        // Iterate through each interaction and create a map of SOs and collect Ids as well in the process
        for (Previous_Interaction__c interaction : interactions)
        {
            PreviousInteractionSO interactionSO = new PreviousInteractionSO();
            interactionSO.interaction = interaction;
            interactionsSOMap.put(interaction.Id, interactionSO);
            interactionIds.add(interaction.Id);
        }

        // Query all intents associated with the interaction using the interaction Ids collected above
        List<Interaction_Intent__c> intents = queryIntentsWithInteractionIds(interactionIds);
        if (intents != null)
        {
            for (Interaction_Intent__c intent : intents)
            {
                PreviousInteractionSO interactionSO = interactionsSOMap.get(intent.Previous_Interaction__c);
                if (interactionSO == null)
                {
                    // This cannot happen by any chance, but still we need to handle this scenario as a developer
                    System.debug(LoggingLevel.ERROR, 'PreviousInteractionSO object in the map is unexpectedly missing');
                    continue;
                }
                interactionSO.intents.add(intent);
            }
        }

        response.interactions = interactionsSOMap.values();
        return response;
    }

    private static List<Account> queryAccountWithCaseId(Id caseId)
    {
        return [SELECT Id, Account_Number_Encrypted__c, AccountNumber, 
                        (SELECT Id, Case_Id__c, Channel_Id__c, Channel_Name__c, Time_Started__c, Time_Completed__c, Parent_Case_Id__c,
                        Status__c, Actor__c, Contact_Reason__c, Has_Followup__c, Followup_Date__c, Followup_Reason__c
                        FROM Previous_Interactions__r),
                Prefetch_Loaded_Time__c, Previous_Interactions_Loaded_Time__c
                FROM Account
                WHERE Id IN (SELECT AccountId FROM Case WHERE Id=:caseId)
               ];
    }

    private static List<Account> queryAccountWithAccountId(Id accountId)
    {
        return [SELECT Id, Account_Number_Encrypted__c, AccountNumber, 
                        (SELECT Id, Case_Id__c, Channel_Id__c, Channel_Name__c, Time_Started__c, Time_Completed__c, Parent_Case_Id__c,
                        Status__c, Actor__c, Contact_Reason__c, Has_Followup__c, Followup_Date__c, Followup_Reason__c
                        FROM Previous_Interactions__r),
                Prefetch_Loaded_Time__c, Previous_Interactions_Loaded_Time__c
                FROM Account WHERE Id=:accountId
               ];
    }

    private static List<Interaction_Intent__c> queryIntentsWithInteractionIds(List<Id> interactionIds)
    {
        return [SELECT Id, Name, Time_Started__c, Status__c, Actor__c, Previous_Interaction__c
                FROM Interaction_Intent__c
                WHERE Previous_Interaction__c = :interactionIds
               ];
    }
}