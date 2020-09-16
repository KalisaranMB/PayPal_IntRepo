public class BasicProfileAPI {

    // Map Basic Profile information to Customer360SO
    public static Customer360SO mapResponseToCustomer360SO(Customer360SO cx360SO, Customer360APIRequest request, Customer360APIResponse response)
    {
        System.debug('BasicProfileAPI:mapResponseToCustomer360SO - mapping Basic Profile Information');
        
        // Check if there are any failures in loading Basic Profile
        if (response.isBasicProfileFailed() || (response.getCustomer360DO().profile == null))
        {
            System.debug('Customer360 API response does not have any Basic Profile information');
            return cx360SO;
        }
        
        // Map Basic profile Information to the cx360SO object passed in the request
        cx360SO.acct = mapResponseToAccount(cx360SO.acct, response.getCustomer360DO().profile);
        cx360SO.primaryUser.user = mapResponseToContact(cx360SO.primaryUser.user, response.getCustomer360DO().profile);

        return cx360SO;
    }

    // Store Basic Profile information to Salesforce object - Both Account and Contact
    public static ProfileAPI.InsertToSOHelper storeResponseInSObject(ProfileAPI.InsertToSOHelper soHelper, Customer360APIRequest request, Customer360APIResponse response)
    {
        System.debug('BasicProfileAPI:storeResponseInSObject - Storing Basic Profile Information into SObject');

        ProfileDO profile = response.getCustomer360DO().profile;
        
        // Check if there basic profile is failed completetly or if the party id is blank, we cannot proceed further here
        if (response.isBasicProfileFailed() || String.isBlank(profile.party_id))
        {
            System.debug(LoggingLevel.ERROR, 'Customer360 API did not successfully load the basic profile information');
            return soHelper;
        }
        
        // Map Basic profile Information to the account object
        soHelper.acct = mapResponseToAccount(soHelper.acct, profile);

        List<Contact> contacts = queryContactAndItsRelationships(soHelper.acct.Id, profile.party_id);
        Contact ct = null;

        if (contacts.size() == 0)
        {
            // Great, looks like we got a brand new Contact to deal with, lets go ahead and set it up
            System.debug(LoggingLevel.ERROR, 'There are no existing contacts with Party Id - ' + profile.party_id);

            ct = new Contact();
            ct = mapResponseToContact(ct, profile);

            // Since this is the first time contact creation, we need to make sure the account is marked
            // as direct ownership - otherwise the private contacts will have some issues
            // Direct ownership will automatically create an entry in AccountContactRelationship table and
            // mark this relationship as "PRIMARY OWNER' by default.
            ct.AccountId = soHelper.acct.Id;

            // Check if the account is already having a PRIMARY OWNER in which case we need to remove that
            // relationship. We cannot delete that relationship record since the it could be a direct relationship
            // with that old contact which Salesforce will not allow us to remove.
            // We have mark that old relationship as NONE
            clearCurrentPrimaryOwnerForAccount(soHelper.acct.Id);

            // Lets go ahead and insert the newly created contact, this will create contact and primary owner
            // relationship with the account
            insert ct;

            soHelper.ct = ct;
            soHelper.newContact = true;
        }
        else
        {
            ct = contacts[0];
            System.debug('No of retrieved contacts - ' + contacts.size() + ', Identified Contact - ' + ct.Id);

            ct = mapResponseToContact(ct, profile);

            // We need to make sure the current account and contact is having PRIMARY OWNER relationship if not already
            // It is possible for the ownership to change at any point of time though its not frequent

            if (ct.AccountContactRelations.size() > 0)
            {
                System.debug('The Account and Contact already has some relationship');
                
                // We have located the relationship record between the Account and Contact
                // Salesforce allows only one relationship record between an account and contact, so we dont need to worry about
                // having or dealing with multiple relationship records here
                AccountContactRelation relation = ct.AccountContactRelations[0];
                if (relation.Relationship__c != 'PRIMARY_OWNER')
                {
                    System.debug('The current relationship is not PRIMARY OWNER. It is - ' + relation.Relationship__c);

                    // The curent relationship between the account and the contact is not primary
                    // We need to check and clear if the account is already having a primary relationship with some other contact
                    clearCurrentPrimaryOwnerForAccount(soHelper.acct.Id);

                    // Lets update the current relationship to PRIMARY OWNER
                    relation.Relationship__c = 'PRIMARY_OWNER';
                    update relation;
                }
                else 
                {
                    System.debug('This account and contact is already having PRIMARY OWNER relationship - no need to do anything');
                }
            }
            else 
            {
                // Contact is already existing, but the contact is not linked with the account. Now we need to link the Account and Contact.
                System.debug('The Account and Contact is existing - but does not having any relationship yet');

                // Lets clear if the Account is having PRIMARY OWNER relationship with any other Contact
                clearCurrentPrimaryOwnerForAccount(soHelper.acct.Id);

                // Just check if the contact is a Private Contact - The possibility for this is very rare since we will always associate an
                // account whenever we create a contact - either it is PRIMARY OWNER or SECONDARY USER, but lets capture that scenario here
                // to make this code more reliable
                if (ct.AccountId == null)
                {
                    System.debug('The Contact is not linked with any account yet - its a private contact.');

                    // Lets just add this as a primary account which will automatically take care of creating a new relationship between this
                    // account and the contact and mark that relationship as PRIMARY OWNER as well
                    ct.AccountId = soHelper.acct.Id;
                }
                else
                {
                    System.debug('Creating a new PRIMARY OWNER relationship between the Account and Contact');

                    // Lets go ahead and create a new PRIMARY OWNER relationship between the account and contact
                    AccountContactRelation relation = new AccountContactRelation();
                    relation.AccountId = soHelper.acct.Id;
                    relation.ContactId = ct.Id;
                    relation.Relationship__c = 'PRIMARY_OWNER';
                    insert relation;
                }
            }

            // Lot of hard work is done, lets go ahead and update the helper object with the contact
            soHelper.ct = ct;
            soHelper.newContact = false;
        }

        // If Basic profile is successfully loaded without any issue (NOT a failure or partial success), lets update the basic profile
        // loaded time in Account object
        if (response.isBasicProfileSuccessfullyLoaded())
        {
            soHelper.acct.Basic_Profile_Loaded_Time__c = DateTime.now();
        }

        return soHelper;
    }

    private static void clearCurrentPrimaryOwnerForAccount(Id accountId)
    {
        // Query the PRIMARY OWNER relationships for the account
        List<AccountContactRelation> relations = queryPrimaryOwnerOfAccount(accountId);

        if (relations.size() == 0)
        {
            System.debug('There are no existing primary owners for the account - ' + accountId);
            return;
        }

        for (AccountContactRelation relation : relations)
        {
            // Clear the relationship by marking it as NONE
            relation.Relationship__c = 'NONE';
        }

        update relations;
        System.debug('Cleared all existing primary owners for the account - ' + accountId + ', No of primary owners - ' + relations.size());
        return;
    }

    private static Account mapResponseToAccount(Account acct, ProfileDO profile)
    {
        acct.Account_Number_Encrypted__c = profile.account_id;
        acct.AccountNumber = profile.account_number;
        acct.Account_Type__c = profile.account_type;
        acct.Account_Subtype__c = profile.account_subtype;
        acct.Account_Status__c = profile.account_status;
        acct.Location__c = profile.location;
        acct.Language__c = profile.language;
        acct.Country_Code__c = profile.legal_country_code;
        acct.Country_Name__c = profile.legal_country_name;
        acct.Timezone__c = profile.timezone;
        acct.Account_Created_Time__c = profile.create_time;
        acct.Customer_Segment__c = profile.customer_segment;
        acct.Has_Secondary_Users__c = profile.has_secondary_users;

        System.debug('Account Type - ' + profile.account_type);

        // Account name should be assigned with profile name only for non-business accounts
        // For Business Accounts, we will assign the actual business name from the business details
        if (String.isNotBlank(profile.account_type) && (!profile.account_type.equalsIgnoreCase('business')))
        {
            acct.Name = profile.full_name;
        }

        // Guest/Wax account
        if (String.isNotBlank(profile.registration_type))
        {
            // Registration type 'FULL' indicates that the account is properly registered PayPal Account
            // Anything else can be treated as unregistered - which is GUEST or ANONYMOUS
            if (!profile.registration_type.equalsIgnoreCase('full'))
            {
                acct.Is_Unregistered__c = true;
                acct.Unregistered_Account_Type__c = profile.registration_type;
            }
        }

        return acct;
    }

    private static Contact mapResponseToContact(Contact ct, ProfileDO profile)
    {
        ct.Party_Id__c = profile.party_id;
        ct.Full_Name__c = profile.full_name;
        ct.FirstName = profile.first_name;
        ct.LastName = profile.last_name;
        ct.Profile_Picture__c = profile.logo_url;
        ct.Age__c = profile.age;

        return ct;
    }

    public static List<Contact> queryContactAndItsRelationships(Id accountId, String partyId)
    {
        return [SELECT Id, AccountId, Party_Id__c, Full_Name__c, FirstName, LastName, Profile_Picture__c, Age__c,
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
                        (SELECT Id, AccountId, ContactId, Relationship__c 
                        FROM AccountContactRelations WHERE AccountId = :accountId),
                Email_Loaded_Time__c, Phone_Loaded_Time__c, Address_Loaded_Time__c 
                FROM Contact WHERE Party_Id__c=:partyId
               ];
    }

    private static List<AccountContactRelation> queryPrimaryOwnerOfAccount(Id accountId)
    {
        return [SELECT Id, AccountId, ContactId, Relationship__c
                FROM AccountContactRelation 
                WHERE AccountId=:accountId AND Relationship__c = 'PRIMARY_OWNER'];
    }
}