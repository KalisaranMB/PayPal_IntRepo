public class QuickGlanceBizController {

    /* This controller is applicable only for business accounts and hence the name. Business
     * accounts needs some information which is unique like the contacted party, business details
     * and so on and hence needs a different QuickGlance than personal/premier accounts. 
     * 
     * Please note that this component can be embedded within both case record page as well as 
     * account record page since it supports querying based on case or account. When it is embedded
     * within Account Page, it cannot give Contacted Party details unless the controller is invoked
     * with both the case id and the account id
     */

    @AuraEnabled(cacheable=true)
    public static QuickGlanceBizControllerResponse getQuickGlanceInfo(Id caseId, Id accountId)
    {
        System.debug('QuickGlanceBizController:getQuickGlanceInfo - Start');

        // Lets set the current execution context as a first step in any transaction
        ExecutionContextUtil.initContextData(PayPalContext.Actor.TEAMMATE, caseId, accountId);
        QuickGlanceBizControllerResponse response = new QuickGlanceBizControllerResponse();

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
        Contact primaryParty = null;
        Contact contactedParty = null;
        Customer360APIRequest cx360Request = new Customer360APIRequest();
        cx360Request.setAccount(acc);
 
        // At this point of time, we have idetified the Account. We need to make sure we have both the Case Id and 
        // the Account Id to identify the contacted party from the Case Session object
        if ((caseId != null) && (acc.Id != null))
        {
            List<Contact> parties = queryContactForCaseSesstion(caseId, acc.Id);
            if ((parties == null) || (parties.size() == 0))
            {
                System.debug('Unable to identify the Contact using the Case Session. Case Id - ' + caseId + ', Account Id - ' + acc.Id);
                response.isContactedPartyAvailable = false;
            }
            else
            {
                contactedParty = parties[0];
                System.debug('Identified Contacted Party. Contact Id - ' + contactedParty.Id);
                response.isContactedPartyAvailable = true;
            }
        }

        /***************************** Profile Information *****************************/
        // Check if we have the Primary Owner associated with the account
        if ((acc.AccountContactRelations.size() == 0) || (acc.AccountContactRelations[0].ContactId == null))
        {
            // Primary owner/party record is not available for this account, so may be the profile is not loaded yet
            // Let's load the complete profile information - Basic profile, emails, phone numbers and addresses
            System.debug(LoggingLevel.ERROR, 'Primary owner/party is not available for the account, let us load the complete profile now');
            cx360Request.addToDataCategoriesToBeLoaded(Customer360.DataCategory.PROFILE);
        }
        else
        {
            // Perfect, we have located the primary user now. Let's load all the required quick glance details from the contact
            Id contactId = acc.AccountContactRelations[0].ContactId;
            System.debug('Identified Primary party from Account Contact Relationship. Contact Id - ' + contactId);
            List<Contact> contacts = queryContactWithContactId(contactId);
            
            if (contacts.size() == 0)
            {
                // This is unexpected since we just got the id from relationship object. Lets log an error message but go ahead and
                // load the whole profile data in real-time rather than failing from here
                System.debug(LoggingLevel.ERROR, 'Contact id identified in AccountContactRelations is invalid: contactId - ' + contactId);
                cx360Request.addToDataCategoriesToBeLoaded(Customer360.DataCategory.PROFILE);
            }
            else
            {
                /***************************** Basic Profile Information *****************************/
                if (Customer360Util.isDataNotAvailableLocally(Customer360.DataCategory.PROFILE_BASIC, acc.Basic_Profile_Loaded_Time__c))
                {
                    System.debug('Basic Profile Information needs to be loaded. Last loaded time - ' + acc.Basic_Profile_Loaded_Time__c);

                    // If Basic Profile information itself is not available, we cannot trust the account to contact relationship as well since
                    // it is derived only from the basic profile information. If relationship is invalid, then we cannot use that relationship
                    // to query for emails, phones or addresses and everything has to be loaded fresh since we need all of these data categories
                    cx360Request.addToDataCategoriesToBeLoaded(Customer360.DataCategory.PROFILE);
                }
                else
                {
                    System.debug('Basic Profile information is available and fresh enough to use. Last loaded time - ' + acc.Basic_Profile_Loaded_Time__c);

                    // We have located both the Account and Primary Party, lets check if the contact details are available and fresh enough to use
                    primaryParty = contacts[0];
                    cx360Request.addToDataCategoriesAvailable(Customer360.DataCategory.PROFILE_BASIC);
                    response = mapAccountInfo(response, acc);
                    response = mapPrimaryParty(response, primaryParty);

                    // Since Basic profile information is valid, we can trust this relationship to be valid and hence we can use the
                    // relationship to see if emails, phones and addresses are fresh enough to use. We can use this verified relationship as well
                    cx360Request.setContact(primaryParty);

                    /***************************** Email Information *****************************/
                    if (Customer360Util.isDataNotAvailableLocally(Customer360.DataCategory.PROFILE_EMAILS, primaryParty.Email_Loaded_Time__c))
                    {
                        System.debug('Email information needs to be loaded. Last loaded time - ' + primaryParty.Email_Loaded_Time__c);
                        cx360Request.addToDataCategoriesToBeLoaded(Customer360.DataCategory.PROFILE_EMAILS);
                    }
                    else {
                        System.debug('Email information is available and fresh enough to use. Last loaded time - ' + primaryParty.Email_Loaded_Time__c);
                        cx360Request.addToDataCategoriesAvailable(Customer360.DataCategory.PROFILE_EMAILS);
                        response.primaryParty.emails = primaryParty.Contact_Emails__r;
                    }

                    /***************************** Phone Information *****************************/
                    if (Customer360Util.isDataNotAvailableLocally(Customer360.DataCategory.PROFILE_PHONES, primaryParty.Phone_Loaded_Time__c))
                    {
                        System.debug('Phone information needs to be loaded. Last loaded time - ' + primaryParty.Phone_Loaded_Time__c);
                        cx360Request.addToDataCategoriesToBeLoaded(Customer360.DataCategory.PROFILE_PHONES);
                    }
                    else {
                        System.debug('Phone information is available and fresh enough to use. Last loaded time - ' + primaryParty.Phone_Loaded_Time__c);
                        cx360Request.addToDataCategoriesAvailable(Customer360.DataCategory.PROFILE_PHONES);
                        response.primaryParty.phones = primaryParty.Contact_Phones__r;
                    }

                    /***************************** Address Information *****************************/
                    if (Customer360Util.isDataNotAvailableLocally(Customer360.DataCategory.PROFILE_ADDRESSES, primaryParty.Address_Loaded_Time__c))
                    {
                        System.debug('Address information needs to be loaded. Last loaded time - ' + primaryParty.Address_Loaded_Time__c);
                        cx360Request.addToDataCategoriesToBeLoaded(Customer360.DataCategory.PROFILE_ADDRESSES);
                    }
                    else {
                        System.debug('Address information is available and fresh enough to use. Last loaded time - ' + primaryParty.Address_Loaded_Time__c);
                        cx360Request.addToDataCategoriesAvailable(Customer360.DataCategory.PROFILE_ADDRESSES);
                        response.primaryParty.addresses = primaryParty.Contact_Addresses__r;
                    }
                }
            }
        }

        /***************************** Limitation Information *****************************/
        if (Customer360Util.isDataNotAvailableLocally(Customer360.DataCategory.LIMITATIONS, acc.Limitation_Info_Loaded_Time__c))
        {
            System.debug('Limitation Information needs to be loaded. Last loaded time - ' + acc.Limitation_Info_Loaded_Time__c);
            cx360Request.addToDataCategoriesToBeLoaded(Customer360.DataCategory.LIMITATIONS);
        }
        else 
        {
            System.debug('Limitation information is available and fresh enough to use. Last loaded time - ' + acc.Limitation_Info_Loaded_Time__c);
            cx360Request.addToDataCategoriesAvailable(Customer360.DataCategory.LIMITATIONS);
            // We dont need to filter only open/active limitations since we already filtered in a query
            response.limitations = acc.Account_Limitations__r;
        }

        /***************************** Account Manager Information *****************************/
        if (Customer360Util.isDataNotAvailableLocally(Customer360.DataCategory.ACCOUNT_INFO, acc.Account_Manager_Flags_Loaded_Time__c))
        {
            System.debug('Account Manager Information needs to be loaded. Last loaded time - ' + acc.Account_Manager_Flags_Loaded_Time__c);
            cx360Request.addToDataCategoriesToBeLoaded(Customer360.DataCategory.ACCOUNT_INFO);
        }
        else 
        {
            System.debug('Account Manager information is available and fresh enough to use. Last loaded time - ' + acc.Account_Manager_Flags_Loaded_Time__c);
            cx360Request.addToDataCategoriesAvailable(Customer360.DataCategory.ACCOUNT_INFO);
            response.accountFlags = acc.Account_Manager_Flags__r;
        }

        /***************************** Compliance Information *****************************/
        if (Customer360Util.isDataNotAvailableLocally(Customer360.DataCategory.COMPLIANCE, acc.Compliance_Info_Loaded_Time__c))
        {
            System.debug('Compliance Information needs to be loaded. Last loaded time - ' + acc.Compliance_Info_Loaded_Time__c);
            cx360Request.addToDataCategoriesToBeLoaded(Customer360.DataCategory.COMPLIANCE);
        }
        else 
        {
            System.debug('Compliance information is available and fresh enough to use. Last loaded time - ' + acc.Compliance_Info_Loaded_Time__c);
            cx360Request.addToDataCategoriesAvailable(Customer360.DataCategory.COMPLIANCE);
            response = mapCompliance(response, acc);
        }

        /***************************** Business Information *****************************/
        if (Customer360Util.isDataNotAvailableLocally(Customer360.DataCategory.BUSINESS_INFO, acc.Business_Info_Loaded_Time__c))
        {
            System.debug('Business Information needs to be loaded. Last loaded time - ' + acc.Business_Info_Loaded_Time__c);
            cx360Request.addToDataCategoriesToBeLoaded(Customer360.DataCategory.BUSINESS_INFO);
        }
        else 
        {
            System.debug('Business information is available and fresh enough to use. Last loaded time - ' + acc.Business_Info_Loaded_Time__c);
            cx360Request.addToDataCategoriesAvailable(Customer360.DataCategory.BUSINESS_INFO);
            response = mapBusinessDetails(response, acc);
        }

        /***************************** Contacted Party Information *****************************/
        if (response.isContactedPartyAvailable)
        {
            // Primary Party details are available locally, we can use that data reliably
            if (primaryParty != null)
            {
                // Check if the primary party and contacted party are same
                if (primaryParty.Party_Id__c == contactedParty.Party_Id__c)
                {
                    // The party contacted us is the primary owner of the account, so we dont need to fill or worry about loading the contacted
                    // party details separately since it will be loaded anyway in the primary party
                    response.isContactedPartyNotPrimary = false;
                }
                else
                {
                    // The party contacted us is the secondary user, now we need to check if we have the data for the secondary user
                    // or we need to load it via API
                    response.isContactedPartyNotPrimary = true;

                    // Check if the secondary party data is available locally and is fresh enough to use
                    if (Customer360Util.isDataNotAvailableLocally(Customer360.DataCategory.SECONDARY_USERS, contactedParty.Party_Info_Loaded_Time__c))
                    {
                        System.debug('Contacted secondary user needs to be loaded. Last loaded time - ' + contactedParty.Party_Info_Loaded_Time__c);
                        cx360Request.addToDataCategoriesToBeLoaded(Customer360.DataCategory.SECONDARY_USERS);
                        cx360Request.addToSearchCriteriaToBeLoaded(Customer360.SearchCriteria.SECONDARY_USERS_PARTY_IDS, contactedParty.Party_Id__c);
                    }
                    else 
                    {
                        System.debug('Contacted secondary user is available and fresh enough to use. Last loaded time - ' + contactedParty.Party_Info_Loaded_Time__c);
                        cx360Request.addToDataCategoriesAvailable(Customer360.DataCategory.SECONDARY_USERS);
                        response = mapContactedParty(response, contactedParty);
                    }
                }
            }
            else
            {
                // We do not have the primary party data available, so we cannot reliably determine whether the contacted party is
                // the primary party or secondary party at this point of time, unless we have some other mechanism to do so in future

                // Check if the secondary party data is available locally and is fresh enough to use
                if (Customer360Util.isDataNotAvailableLocally(Customer360.DataCategory.SECONDARY_USERS, contactedParty.Party_Info_Loaded_Time__c))
                {
                    System.debug('Contacted secondary user needs to be loaded. Last loaded time - ' + contactedParty.Party_Info_Loaded_Time__c);
                    cx360Request.addToDataCategoriesToBeLoaded(Customer360.DataCategory.SECONDARY_USERS);
                    cx360Request.addToSearchCriteriaToBeLoaded(Customer360.SearchCriteria.SECONDARY_USERS_PARTY_IDS, contactedParty.Party_Id__c);
                }
                else 
                {
                    // At this point of time, we still don't know whether the contacted party is primary or secondary, but lets go ahead and map the
                    // data loaded and we can decide whether this is useful or not after the primary party is loaded.
                    System.debug('Contacted secondary user is available and fresh enough to use. Last loaded time - ' + contactedParty.Party_Info_Loaded_Time__c);
                    cx360Request.addToDataCategoriesAvailable(Customer360.DataCategory.SECONDARY_USERS);
                    response = mapContactedParty(response, contactedParty);
                }
            }
        }

        // Great, we are done with all data checks needed for QuickGlance
        // If any data has to be loaded in realtime which could be everything or partial, lets get it now
        if (cx360Request.getDataCategoriesToBeLoaded().size() > 0)
        {
            response = populateResponseUsingCustomer360API(response, cx360Request);

            // Now that we clearly know some or all the data required for this component is not available locally, lets check if we need to trigger
            // prefetch. This component is selected for this hook since it is one of the most important component that we will always have in the page.
            // There could be other places where this hook will be introduced in future, but for now just keeping it simple
            PrefetchUtil.checkAndTriggerPrefetchAsync(acc);
        }
        else {
            // Great, everything we need was retrieved from local objects itself - thanks to pre-fetch design
            // Lets mark the status as SUCCESS.
            response.result.setStatus(Customer360.Status.SUCCESS);
        }

        // Lets do some check to make sure we are covering all scenarios w.r.t primary party vs contacted party
        if ((response.isContactedPartyAvailable) && (primaryParty == null))
        {
            // We were not able to determine whether the contacted party is primary or secondary before, but now it is possible
            // But first we need to make sure the Basic Profile information is loaded successfully
            if (String.isNotBlank(response.primaryParty.user.Party_Id__c))
            {
                // The contacted party id is matching with the primary party id, so lets set the flag and clear the contacted
                // party if that is filled in any scenario
                if (response.primaryParty.user.Party_Id__c == contactedParty.Party_Id__c)
                {
                    response.isContactedPartyNotPrimary = false;
                    response.contactedParty = null;
                }
                else {
                    response.isContactedPartyNotPrimary = true;
                }
            }
        }

        System.debug('QuickGlanceBizController:getQuickGlanceInfo - End');
        return response;
    }

    /* Ths controller returns the same Quick Glance details as the above one, but without using any Cache
     * There are times where a teammate wants to see a fresh customer data (may be the customer has performed
     * some action in PayPal site/app) that we want to reflect in CS side. Each controller will provide this
     * option to get fresh data.
     * 
     * Please note that Cacheable is not set to true since this call should always get fresh data with a 
     * server roundtrip
     */

    @AuraEnabled
    public static QuickGlanceBizControllerResponse getQuickGlanceInfoWithoutCache(Id caseId, Id accountId)
    {
        System.debug('QuickGlanceBizController:getQuickGlanceInfoWithoutCache - Start');

        // Lets set the current execution context as a first step in any transaction
        ExecutionContextUtil.initContextData(PayPalContext.Actor.TEAMMATE, caseId, accountId);
        QuickGlanceBizControllerResponse response = new QuickGlanceBizControllerResponse();

        Account acc = Customer360Util.getBasicAccountDetails(caseId, accountId);
        if (acc == null)
        {
            System.debug(LoggingLevel.ERROR, 'Failed to identify the Account using account id or case id');
            response.result.setStatusAndMessage(Customer360.Status.FAILURE, 'Unexpected Error: Failed to identify the Account using Account Id or Case Id');
            return response;
        }

        Customer360APIRequest cx360Request = new Customer360APIRequest();
        cx360Request.setAccount(acc);

        // No need to check for any data loaded time here, lets go directly for prepping API call
        cx360Request.addToDataCategoriesToBeLoaded(Customer360.DataCategory.PROFILE);
        cx360Request.addToDataCategoriesToBeLoaded(Customer360.DataCategory.LIMITATIONS);
        cx360Request.addToDataCategoriesToBeLoaded(Customer360.DataCategory.ACCOUNT_INFO);
        cx360Request.addToDataCategoriesToBeLoaded(Customer360.DataCategory.COMPLIANCE);
        cx360Request.addToDataCategoriesToBeLoaded(Customer360.DataCategory.BUSINESS_INFO);

        Contact contactedParty = Customer360Util.getContactedParty(caseId, acc.Id);
        if (contactedParty != null)
        {
            response.isContactedPartyAvailable = true;
            cx360Request.addToDataCategoriesToBeLoaded(Customer360.DataCategory.SECONDARY_USERS);
            cx360Request.addToSearchCriteriaToBeLoaded(Customer360.SearchCriteria.SECONDARY_USERS_PARTY_IDS, contactedParty.Party_Id__c);
        }

        // Make sure CSDAS skips its cache and load data from domain services
        cx360Request.setSkipCacheDataFlag(true);

        response = populateResponseUsingCustomer360API(response, cx360Request);

        // TBD - We should ideally presist the fresh data into local sobjects since teammate would
        // not want to see the old data again after this stage. Lets perform an async update to Database

        // Now that the response is ready, we need to make sure whether the contacted party is a primary party or secondary and set the
        // appropriate flags or clear fields as necessary
        if (response.isContactedPartyAvailable)
        {
            // This is the best reliable way to find out if the contacted party is primary or secondary
            if (String.isNotBlank(response.primaryParty.user.Party_Id__c) && (contactedParty.Party_Id__c == response.primaryParty.user.Party_Id__c))
            {
                response.isContactedPartyNotPrimary = true;
            }
            else {
                // There is no reliable way to say whether the party contacted us is primary or secondary,
                // hence we will treat the contacted party as primary for the moment - no other option
                response.isContactedPartyNotPrimary = false;
            }
        }

        System.debug('QuickGlanceBizController:getQuickGlanceInfoWithoutCache - End');
        return response;
    }

    private static QuickGlanceBizControllerResponse populateResponseUsingCustomer360API(QuickGlanceBizControllerResponse response, Customer360APIRequest cx360Request)
    {
        // Get the required Customer360 data in real-time
        Customer360APIResponse cx360Response = Customer360API.getCustomer360Data(cx360Request);

        if (cx360Response.isAPIStatusSuccess())
        {
            response.result.setStatus(Customer360.Status.SUCCESS);

            // Go ahead and map the Customer360 API response to Quick Glance
            Customer360SO cx360SO = Customer360API.mapResponseToCustomer360SO(cx360Request, cx360Response);
            response = mapCustomer360SOToQuickGlance(response, cx360SO, cx360Request, cx360Response);
        }
        else if (cx360Response.isAPIStatusPartialSuccess())
        {
            response.result.setStatusAndMessage(Customer360.Status.PARTIAL_SUCCESS, 'Data is Partially Loaded');
            
            // Go ahead and map the Partial Customer360 API response to Quick Glance
            Customer360SO cx360SO = Customer360API.mapResponseToCustomer360SO(cx360Request, cx360Response);
            response = mapCustomer360SOToQuickGlance(response, cx360SO, cx360Request, cx360Response);

            // Fill unavailable data list array with list of datapoints failed and partially successful
            response.result.unavailableDataList.addAll(Customer360.getDescriptionForCategories(cx360Response.getFailedDataCategories()));
            response.result.unavailableDataList.addAll(Customer360.getDescriptionForCategories(cx360Response.getPartialSuccessDataCategories()));
        }
        else if (cx360Response.isAPIStatusFailure())
        {
            // Loading data in real-time failed. If there are some data categories available locally, we need to report this as partial success
            if (cx360Request.getDataCategoriesAvailable().size() == 0)
            {
                // None of the data needed for quick glance was available locally, so we had to load everything via Customer360 API but
                // the API failed, so no data is available to show in the component and this is a complete failure.
                response.result.setStatusAndMessage(Customer360.Status.FAILURE, 'Failed to load the Data');
            }
            else
            {
                // Some data was available locally, but the data loaded from API got failed. This should be considered as a partial success
                response.result.setStatusAndMessage(Customer360.Status.PARTIAL_SUCCESS, 'Data is Partially Loaded');

                // All data categories we wanted to load in real-time got failed, lets add all descriptions
                response.result.unavailableDataList.addAll(Customer360.getDescriptionForCategories(cx360Request.getDataCategoriesToBeLoaded()));
            }
        }

        return response;
    }

    private static QuickGlanceBizControllerResponse mapCustomer360SOToQuickGlance(QuickGlanceBizControllerResponse response, Customer360SO cx360SO, Customer360APIRequest cx360Request, Customer360APIResponse cx360Response)
    {
        // Profile Basic
        if (cx360Request.isBasicProfileRequested() && (!cx360Response.isBasicProfileFailed()))
        {
            response = mapAccountInfo(response, cx360SO.acct);
            response = mapPrimaryParty(response, cx360SO.primaryUser.user);
        }

        // Email
        if (cx360Request.isProfileEmailsRequested() && (!cx360Response.isProfileEmailsFailed()))
        {
            response.primaryParty.emails = cx360SO.primaryUser.emails;
        }

        // Phone
        if (cx360Request.isProfilePhonesRequested() && (!cx360Response.isProfilePhonesFailed()))
        {
            response.primaryParty.phones = cx360SO.primaryUser.phones;
        }

        // Address
        if (cx360Request.isProfileAddressesRequested() && (!cx360Response.isProfileAddressesFailed()))
        {
            response.primaryParty.addresses = cx360SO.primaryUser.addresses;
        }

        // Limitations
        if (cx360Request.isLimitationsRequested() && (!cx360Response.isLimitationsFailed()))
        {
            // TBD - we need to update this logic once the API starts returning active limitations by default 
            // In case API returns all Limitations, this will help to filter down
            response.limitations = Customer360Util.filterActiveLimitations(cx360SO.limitations);
        }

        // Account Manager Flags
        if (cx360Request.isAccountInfoRequested() && (!cx360Response.isAccountInfoFailed()))
        {
            response.accountFlags = cx360SO.accountFlags;
        }

        // Compliance
        if (cx360Request.isComplianceInfoRequested() && (!cx360Response.isComplianceInfoFailed()))
        {
            response = mapCompliance(response, cx360SO.acct);
        }

        // Business Details
        if (cx360Request.isBusinessInfoRequested() && (!cx360Response.isBusinessInfoFailed()))
        {
            response = mapBusinessDetails(response, cx360SO.acct);

            if (cx360SO.businessAddresses.size() > 0)
            {
                response.businessAddress = cx360SO.businessAddresses[0];
            }
        }

        // Secondary User
        if (cx360Request.isSecondaryUsersRequested() && (!cx360Response.isSecondaryUsersFailed()))
        {
            if (cx360SO.secondaryUsers.size() > 0)
            {
                response.contactedParty = cx360SO.secondaryUsers[0];
            }
        }

        return response;
    }

    private static QuickGlanceBizControllerResponse mapAccountInfo(QuickGlanceBizControllerResponse response, Account acc)
    {
        response.accountInfo.Account_Number_Encrypted__c = acc.Account_Number_Encrypted__c;
        response.accountInfo.AccountNumber = acc.AccountNumber;
        response.accountInfo.Account_Type__c = acc.Account_Type__c;
        response.accountInfo.Account_Subtype__c = acc.Account_Subtype__c;
        response.accountInfo.Country_Name__c = acc.Country_Name__c;
        response.accountInfo.Account_Created_Time__c = acc.Account_Created_Time__c;
        response.accountInfo.Is_Unregistered__c = acc.Is_Unregistered__c;
        response.accountInfo.Unregistered_Account_Type__c = acc.Unregistered_Account_Type__c;
        response.accountInfo.Customer_Segment__c = acc.Customer_Segment__c;
        response.accountInfo.Location__c = acc.Location__c;
        response.accountInfo.Account_Status__c = acc.Account_Status__c;
        return response;
    }

    private static QuickGlanceBizControllerResponse mapPrimaryParty(QuickGlanceBizControllerResponse response, Contact ct)
    {
        response.primaryParty.user.Party_Id__c = ct.Party_Id__c;
        response.primaryParty.user.Full_Name__c = ct.Full_Name__c;
        response.primaryParty.user.FirstName = ct.FirstName;
        response.primaryParty.user.LastName = ct.LastName;
        response.primaryParty.user.Profile_Picture__c = ct.Profile_Picture__c;
        response.primaryParty.user.Age__c = ct.Age__c;
        return response;
    }

    private static QuickGlanceBizControllerResponse mapContactedParty(QuickGlanceBizControllerResponse response, Contact ct)
    {
        response.contactedParty.user.Party_Id__c = ct.Party_Id__c;
        response.contactedParty.user.Full_Name__c = ct.Full_Name__c;
        response.contactedParty.user.FirstName = ct.FirstName;
        response.contactedParty.user.LastName = ct.LastName;
        response.contactedParty.user.Profile_Picture__c = ct.Profile_Picture__c;
        response.contactedParty.user.Age__c = ct.Age__c;
        response.contactedParty.user.CIP_Status__c = ct.CIP_Status__c;

        // Secondary user is typically loaded in a bunch and not as individual data entities, so lets map all the additional
        // details as well like emails, phones and addresses
        response.contactedParty.emails = ct.Contact_Emails__r;
        response.contactedParty.phones = ct.Contact_Phones__r;
        response.contactedParty.addresses = ct.Contact_Addresses__r;

        return response;
    }

    private static QuickGlanceBizControllerResponse mapCompliance(QuickGlanceBizControllerResponse response, Account acc)
    {
        response.accountInfo.CIP_Status__c = acc.CIP_Status__c;
        return response;
    }

    private static QuickGlanceBizControllerResponse mapBusinessDetails(QuickGlanceBizControllerResponse response, Account acc)
    {
        response.accountInfo.Industry_Name__c = acc.Industry_Name__c;
        response.accountInfo.Merchant_Category_Code__c = acc.Merchant_Category_Code__c;
        response.accountInfo.Admin_Merchant_Category_Code__c = acc.Admin_Merchant_Category_Code__c;
        response.accountInfo.Customer_Service_Email__c = acc.Customer_Service_Email__c;
        response.accountInfo.Customer_Service_Phone__c = acc.Customer_Service_Phone__c;
        response.accountInfo.Name = acc.Name;
        response.accountInfo.Average_Monthly_TPV__c = acc.Average_Monthly_TPV__c;
        response.accountInfo.Monthly_TPV_Lower_Bound_Amount__c = acc.Monthly_TPV_Lower_Bound_Amount__c;
        response.accountInfo.Monthly_TPV_Lower_Bound_Currency__c = acc.Monthly_TPV_Lower_Bound_Currency__c;
        response.accountInfo.Monthly_TPV_Upper_Bound_Amount__c = acc.Monthly_TPV_Upper_Bound_Amount__c;
        response.accountInfo.Monthly_TPV_Upper_Bound_Currency__c = acc.Monthly_TPV_Upper_Bound_Currency__c;

        if ((acc.Business_Addresses__r != null) && (acc.Business_Addresses__r.size() > 0))
        {
            response.businessAddress = acc.Business_Addresses__r[0];
        }

        return response;
    }

    private static List<Account> queryAccountWithCaseId(Id caseId)
    {
        return [SELECT Id, Name, Account_Number_Encrypted__c, AccountNumber, Account_Type__c, Account_Subtype__c, Country_Name__c, Account_Created_Time__c, 
                CIP_Status__c, Is_Unregistered__c, Unregistered_Account_Type__c, Customer_Segment__c, Location__c, Account_Status__c, Average_Monthly_TPV__c,
                Monthly_TPV_Lower_Bound_Amount__c, Monthly_TPV_Lower_Bound_Currency__c, Monthly_TPV_Upper_Bound_Amount__c, Monthly_TPV_Upper_Bound_Currency__c,
                Industry_Name__c, Merchant_Category_Code__c, Admin_Merchant_Category_Code__c, Customer_Service_Email__c, Customer_Service_Phone__c,
                        (SELECT Id, Name, Time_Created__c, Category__c, Level__c, Status__c, Is_Active__c
                        FROM Account_Limitations__r WHERE Is_Active__c = true),
                        (SELECT Id, Name, Is_Managed_Account__c, Phone_Number__c, Email_Address__c, IVR_Routing_Number__c, Description__c
                        FROM Account_Manager_Flags__r),
                        (SELECT Id, ContactId, Relationship__c FROM AccountContactRelations WHERE Relationship__c = 'PRIMARY_OWNER'),
                        (SELECT Id, Address_Id__c, Address_Line_1__c, Address_Line_2__c, Address_Line_3__c, Admin_Area_4__c, Admin_Area_3__c,
                        Admin_Area_2__c, Admin_Area_1__c, Country__c, Postal_Code__c, Type__c, Status__c, Confirmation_Status__c, Is_Primary__c,
                        Is_Active__c, Is_Confirmed__c
                        FROM Business_Addresses__r),
                Basic_Profile_Loaded_Time__c, Limitation_Info_Loaded_Time__c, Account_Manager_Flags_Loaded_Time__c, Compliance_Info_Loaded_Time__c,
                Business_Info_Loaded_Time__c, Prefetch_Loaded_Time__c
                FROM Account
                WHERE Id IN (SELECT AccountId FROM Case WHERE Id=:caseId)
               ];
    }

    private static List<Account> queryAccountWithAccountId(Id accountId)
    {
        return [SELECT Id, Name, Account_Number_Encrypted__c, AccountNumber, Account_Type__c, Account_Subtype__c, Country_Name__c, Account_Created_Time__c, 
                CIP_Status__c, Is_Unregistered__c, Unregistered_Account_Type__c, Customer_Segment__c, Location__c, Account_Status__c, Average_Monthly_TPV__c,
                Monthly_TPV_Lower_Bound_Amount__c, Monthly_TPV_Lower_Bound_Currency__c, Monthly_TPV_Upper_Bound_Amount__c, Monthly_TPV_Upper_Bound_Currency__c,
                Industry_Name__c, Merchant_Category_Code__c, Admin_Merchant_Category_Code__c, Customer_Service_Email__c, Customer_Service_Phone__c,
                        (SELECT Id, Name, Time_Created__c, Category__c, Level__c, Status__c, Is_Active__c
                        FROM Account_Limitations__r WHERE Is_Active__c = true),
                        (SELECT Id, Name, Is_Managed_Account__c, Phone_Number__c, Email_Address__c, IVR_Routing_Number__c, Description__c
                        FROM Account_Manager_Flags__r),
                        (SELECT Id, ContactId, Relationship__c FROM AccountContactRelations WHERE Relationship__c = 'PRIMARY_OWNER'),
                        (SELECT Id, Address_Id__c, Address_Line_1__c, Address_Line_2__c, Address_Line_3__c, Admin_Area_4__c, Admin_Area_3__c,
                        Admin_Area_2__c, Admin_Area_1__c, Country__c, Postal_Code__c, Type__c, Status__c, Confirmation_Status__c, Is_Primary__c,
                        Is_Active__c, Is_Confirmed__c
                        FROM Business_Addresses__r),
                Basic_Profile_Loaded_Time__c, Limitation_Info_Loaded_Time__c, Account_Manager_Flags_Loaded_Time__c, Compliance_Info_Loaded_Time__c,
                Business_Info_Loaded_Time__c, Prefetch_Loaded_Time__c
                FROM Account WHERE Id=:accountId
               ];
    }

    private static List<Contact> queryContactWithContactId(Id contactId)
    {
        return [SELECT Id, Party_Id__c, Full_Name__c, FirstName, LastName, Profile_Picture__c, Age__c, CIP_Status__c,
                        (SELECT Id, Email_Address__c, Is_Primary__c, Status__c, Confirmation_Status__c, Trust_Status__c, Is_Active__c, 
                        Is_Confirmed__c, Is_Trusted__c 
                        FROM Contact_Emails__r),
                        (SELECT Id, Country_Code__c, Phone_Number__c, Type__c, Status__c, Confirmation_Status__c, Trust_Status__c, Is_Primary__c,
                        Is_Active__c, Is_Confirmed__c, Is_Trusted__c
                        FROM Contact_Phones__r),
                        (SELECT Id, Address_Line_1__c, Address_Line_2__c, Address_Line_3__c, Admin_Area_4__c, Admin_Area_3__c,
                        Admin_Area_2__c, Admin_Area_1__c, Country__c, Postal_Code__c, Type__c, Status__c, Confirmation_Status__c, Is_Primary__c,
                        Is_Active__c, Is_Confirmed__c
                        FROM Contact_Addresses__r),
                Email_Loaded_Time__c, Phone_Loaded_Time__c, Address_Loaded_Time__c, Party_Info_Loaded_Time__c
                FROM Contact WHERE Id=:contactId
               ];
    }

    private static List<Contact> queryContactForCaseSesstion(Id caseId, Id accountId)
    {
        return [SELECT Id, Party_Id__c, Full_Name__c, FirstName, LastName, Profile_Picture__c, Age__c, CIP_Status__c,
                        (SELECT Id, Email_Address__c, Is_Primary__c, Status__c, Confirmation_Status__c, Trust_Status__c, Is_Active__c, 
                        Is_Confirmed__c, Is_Trusted__c 
                        FROM Contact_Emails__r),
                        (SELECT Id, Country_Code__c, Phone_Number__c, Type__c, Status__c, Confirmation_Status__c, Trust_Status__c, Is_Primary__c,
                        Is_Active__c, Is_Confirmed__c, Is_Trusted__c
                        FROM Contact_Phones__r),
                        (SELECT Id, Address_Line_1__c, Address_Line_2__c, Address_Line_3__c, Admin_Area_4__c, Admin_Area_3__c,
                        Admin_Area_2__c, Admin_Area_1__c, Country__c, Postal_Code__c, Type__c, Status__c, Confirmation_Status__c, Is_Primary__c,
                        Is_Active__c, Is_Confirmed__c
                        FROM Contact_Addresses__r),
                Email_Loaded_Time__c, Phone_Loaded_Time__c, Address_Loaded_Time__c, Party_Info_Loaded_Time__c
                FROM Contact WHERE Id IN (SELECT Contact__c FROM Case_Session__c WHERE Case__c=:caseId AND Account__c=:accountId)
               ];
    }
}