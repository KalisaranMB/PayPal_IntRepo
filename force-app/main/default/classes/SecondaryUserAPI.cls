public class SecondaryUserAPI {

    public static Customer360SO mapResponseToCustomer360SO(Customer360SO cx360SO, Customer360APIRequest request, Customer360APIResponse response)
    {
        System.debug('SecondaryUserAPI:mapResponseToCustomer360SO - mapping Secondary Users');
        
        // Check if there are any failures in loading Secondary Users
        if (response.isSecondaryUsersFailed() || (response.getCustomer360DO().secondary_users == null) ||
            (response.getCustomer360DO().secondary_users.size() == 0))
        {
            System.debug('Customer360 API response does not have any Secondary Users');
            return cx360SO;
        }

        // Map details per secondary user
        for (SecondaryUserDO secUser : response.getCustomer360DO().secondary_users)
        {
            cx360SO.secondaryUsers.add(mapSecondaryUserDOToSO(secUser));
        }

        return cx360SO;
    }

    public static Account storeResponseInSObject(Account acct, Customer360APIRequest request, Customer360APIResponse response)
    {
        System.debug('SecondaryUserAPI:mapResponseToCustomer360SO - Storing Secondary Users to SObject');
        
        // Check if there are any failures in loading Secondary Users
        if (response.isSecondaryUsersFailed())
        {
            System.debug('Customer360 API did not successfully load any Secondary Users');
            return acct;
        }

        // Clear all Secondary user relationships for the account
        // Even if there are no secondary users currently associated with the customer, there is a chance that the
        // acount may have had a secondary users assigned before and that relationship has to be cleared in SF.
        removeAllSecondaryUserRelationships(acct);

        List<SecondaryUserDO> users = response.getCustomer360DO().secondary_users;

        if ((users != null) && (users.size() > 0))
        {
            System.debug('Number of secondary users in the response - ' + users.size());

            // Lets get all party ids from the secondary users list
            List<String> partyIds = new List<String>();
            Map<String, SecondaryUserDO> partyIdToSecondaryUserMap = new Map<String, SecondaryUserDO>();

            for (SecondaryUserDO user : users)
            {
                if (String.isNotBlank(user.party_id) && (user.has_permission_to_speak))
                {
                    partyIds.add(user.party_id);
                    partyIdToSecondaryUserMap.put(user.party_id, user);
                }
            }

            // Query all contact records for the party ids received in the response
            List<Contact> contacts = queryContactAndItsRelationships(acct.Id, partyIds);
            System.debug('Number of contacts loaded from salesforce - ' + contacts.size());

            Map<String, Contact> partyIdToContactMap = new Map<String, Contact>();
            List<Contact> contactsToUpsert = new List<Contact>();
            List<SObject> recordsToDelete = new List<SObject>();
            List<SObject> recordsToInsert  = new List<SObject>();

            // Create a map between party id and the contact
            for (Contact ct : contacts)
            {
                partyIdToContactMap.put(ct.Party_Id__c, ct);
            }

            for (SecondaryUserDO user : users)
            {
                if (String.isBlank(user.party_id))
                {
                    System.debug(LoggingLevel.ERROR, 'Party Id is blank in the Customer360 data, let us continue with others');
                    continue;
                }

                if (!user.has_permission_to_speak)
                {
                    System.debug('Skipping the user since the Party does not have the permission to contact CS. Party ID - ' + user.party_id);
                    continue;
                }

                Contact ct = partyIdToContactMap.get(user.party_id);
                
                if (ct != null)
                {
                    // Contact record is alreay available for the party id, let us update the contact object with fresh values
                    ct = mapSecondaryUserToContact(ct, user);

                    if (response.isSecondaryUsersSuccessfullyLoaded()) {
                        ct.Party_Info_Loaded_Time__c = Datetime.now();
                    }

                    // Add all child records to be deleted - Phones, emails addresses
                    recordsToDelete.addAll(ct.Contact_Emails__r);
                    recordsToDelete.addAll(ct.Contact_Phones__r);
                    recordsToDelete.addAll(ct.Contact_Addresses__r);

                    // Relationship Handling
                    if (ct.AccountId == null)
                    {
                        // May be the party is not associated with any account yet, its a rare case
                        // This assignment will automatically create a new relationship and mark that relationship as 'PRIMARY OWNER',
                        // we can update it to 'SECONDARY USER' later.
                        ct.AccountId = acct.Id;
                    }
                    else
                    {
                        // Check if the current Account and Contact is already having a relationship, please note that we already filtered
                        // the account id in the query and hence the relationship retrieved will only be between this Account and Contact
                        if (ct.AccountContactRelations.size() == 0)
                        {
                            System.debug('This Account has no existing relationship with the Contact - ' + ct.Id + ', lets create a new one');
                            AccountContactRelation relation = new AccountContactRelation();
                            relation.AccountId = acct.Id;
                            relation.ContactId = ct.Id;
                            relation.Relationship__c = 'SECONDARY_USER';
                            
                            recordsToInsert.add(relation);
                        }
                        else
                        {
                            // There is already some relationship exist between this account and contact, let us not worry about
                            // what that relationship is since we will do a mass update of all relationships to 'SECONDARY USER' later
                        }
                    }

                    contactsToUpsert.add(ct);
                }
                else
                {
                    // Contact object is not available for the party yet, so we need to create a new one
                    ct = new Contact();
                    ct = mapSecondaryUserToContact(ct, user);

                    if (response.isSecondaryUsersSuccessfullyLoaded()) {
                        ct.Party_Info_Loaded_Time__c = Datetime.now();
                    }

                    // Since this is a fresh contact, we can straight away assign the account as primary which will automatically create
                    // a new relationship record as well. We will just need to update that relationship to SECONDARY USER - same mass update
                    ct.AccountId = acct.Id;
                    contactsToUpsert.add(ct);
                }
            }

            // Upsert Contacts - Existing contacts will be updated and new contacts will be inserted. We dont need to upsert using Party Id
            // here since we already loaded the contact records for existing ones and only the new ones has to be inserted
            if (contactsToUpsert.size() > 0)
            {
                System.debug('We got some contacts to upsert. Number of records - ' + contactsToUpsert.size());
                upsert contactsToUpsert;
            }

            List<Id> contactIdsToUpdateRelationship = new List<Id>();

            // Now that the required contacts are all updated or created, lets get to the business of adding emails, phones and addresses
            for (Contact ct : contactsToUpsert)
            {
                if (ct.Id == null)
                {
                    System.debug(LoggingLevel.ERROR, 'Id is not available after upsert for the Party Id - ' + ct.Party_Id__c);
                    continue;
                }

                SecondaryUserDO user = partyIdToSecondaryUserMap.get(ct.Party_Id__c);
                if (user == null)
                {
                    // This is extremely rare, but need to handle every scenario as a developer
                    System.debug(LoggingLevel.ERROR, 'User object retrieved from the map is null - this should never happen');
                    continue;
                }

                contactIdsToUpdateRelationship.add(ct.Id);

                // Add emails to insert list
                if ((user.emails != null) && (user.emails.size() > 0))
                {
                    for (EmailDO email : user.emails)
                    {
                        Contact_Email__c emailObj = ProfileEmailAPI.mapEmailDOToContactEmail(email);
                        emailObj.Contact__c = ct.Id;
                        recordsToInsert.add(emailObj);
                    }
                }

                // Add Phones to insert list
                if ((user.phone_numbers != null) && (user.phone_numbers.size() > 0))
                {
                    for (PhoneDO phone : user.phone_numbers)
                    {
                        Contact_Phone__c phoneObj = ProfilePhoneAPI.mapPhoneDOToContactPhone(phone);
                        phoneObj.Contact__c = ct.Id;
                        recordsToInsert.add(phoneObj);
                    }
                }

                // Add Addresses to insert list
                if ((user.addresses != null) && (user.addresses.size() > 0))
                {
                    for (AddressDO address : user.addresses)
                    {
                        Contact_Address__c addressObj = ProfileAddressAPI.mapAddressDOToContactAddress(address);
                        addressObj.Contact__c = ct.Id;
                        recordsToInsert.add(addressObj);
                    }
                }
            }

            // Delete all records that are marked for deletion
            if (recordsToDelete.size() > 0)
            {
                System.debug('We got some records to delete. Number of records - ' + recordsToDelete.size());
                delete recordsToDelete;
            }

            // Insert all records that are marked for insertion
            if (recordsToInsert.size() > 0)
            {
                System.debug('We got some records to insert. Number of records - ' + recordsToDelete.size());
                insert recordsToInsert;
            }

            // Now that we have made sure all the contacts are available and all relationships too - even though it
            // might all be in different statuses, we can just go ahead and update the relationship type like cake walk
            // Update all relationsips between this account and created/updated account ids to SECONDARY USERS
            updateAllRelationshipsToSecondaryUsers(acct, contactIdsToUpdateRelationship);
        }

        // If Secondary users info is successfully loaded (NOT a failure or partial success), update the cache time
        if (response.isSecondaryUsersSuccessfullyLoaded())
        {
            acct.Secondary_User_Loaded_Time__c = Datetime.now();
        }

        return acct;
    }

    private static void removeAllSecondaryUserRelationships(Account acct)
    {
        List<AccountContactRelation> relations = querySecondaryUsersForAccount(acct.Id);

        if (relations.size() == 0)
        {
            System.debug('There are no existing secondary users for the account - ' + acct.Id);
            return;
        }
        
        for (AccountContactRelation relation : relations)
        {
            // Clear the relationship by marking it as NONE
            relation.Relationship__c = 'NONE';
        }

        update relations;
        System.debug('Cleared all existing secondary users for the account - ' + acct.Id + ', No of secondary users - ' + relations.size());
        return;
    }

    private static void updateAllRelationshipsToSecondaryUsers(Account acct, List<Id> contactIds)
    {
        if (contactIds.size() == 0)
        {
            System.debug('Number of contact ids to update the relationship is zero');
            return;
        }

        List<AccountContactRelation> relations = queryRelationshipBetweenAccountAndContacts(acct.Id, contactIds);
        if (relations.size() == 0)
        {
            System.debug(LoggingLevel.ERROR, 'Number of relationships identified is zero');
            return;
        }

        for (AccountContactRelation relation : relations)
        {
            // Prefetch deals with only secondary users who has permission to speak with customer service. Only those
            // parties will be recorded in Salesforce and everything else has to be dealt in real time. Since we deal
            // with only the parties who has the permissions to speak, we are blindly assigning here. We also have a 
            // mechanism to filter out other parties when coming to storing it. So we are good here.
            relation.Can_Contact_CS__c = true;
            relation.Relationship__c = 'SECONDARY_USER';
        }

        update relations;
        System.debug('Updated all relationships for the Account as SECONDARY USER. Number of records updated - ' + relations.size());
        return;
    }

    private static ContactSO mapSecondaryUserDOToSO(SecondaryUserDO secUser)
    {
        ContactSO ctSo = new ContactSO();

        // Map the user details to Contact Object
        ctSo.user = mapSecondaryUserToContact(ctSo.user, secUser);

        // Map the secondary user attributes like login id, permissions and so on to SO Object
        ctSo.secondaryUserAttrbutes = mapSecondaryUserAttributesToSO(ctSo.secondaryUserAttrbutes, secUser);

        // Add emails
        if ((secUser.emails != null) && (secUser.emails.size() > 0))
        {
            for (EmailDO email : secUser.emails)
            {
                ctSo.emails.add(ProfileEmailAPI.mapEmailDOToContactEmail(email));
            }
        }

        // Add Phones
        if ((secUser.phone_numbers != null) && (secUser.phone_numbers.size() > 0))
        {
            for (PhoneDO phone : secUser.phone_numbers)
            {
                ctSo.phones.add(ProfilePhoneAPI.mapPhoneDOToContactPhone(phone));
            }
        }

        // Add Addresses
        if ((secUser.addresses != null) && (secUser.addresses.size() > 0))
        {
            for (AddressDO address : secUser.addresses)
            {
                ctSo.addresses.add(ProfileAddressAPI.mapAddressDOToContactAddress(address));
            }
        }

        return ctSo;
    }

    private static Contact mapSecondaryUserToContact(Contact ct, SecondaryUserDO secUser)
    {
        ct.Full_Name__c = secUser.full_name;
        ct.FirstName = secUser.first_name;
        ct.LastName = secUser.last_name;
        ct.Party_Id__c = secUser.party_id;
        ct.Profile_Picture__c = secUser.logo_url;
        ct.Age__c = secUser.age;

        if (secUser.compliance != null)
        {
            ct.CIP_Status__c = secUser.compliance.cip_status;
        }

        return ct;
    }

    private static SecondaryUserAttrobutesSO mapSecondaryUserAttributesToSO(SecondaryUserAttrobutesSO attr, SecondaryUserDO secUser)
    {
        attr.loginId = secUser.login_id;
        attr.canContactCS = secUser.has_permission_to_speak;
        return attr;
    }

    public static List<Contact> queryContactAndItsRelationships(Id accountId, List<String> partyIds)
    {
        return [SELECT Id, AccountId, Party_Id__c, Full_Name__c, FirstName, LastName, Profile_Picture__c, Age__c, CIP_Status__c,
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
                        (SELECT Id, AccountId, ContactId, Relationship__c, Can_Contact_CS__c 
                        FROM AccountContactRelations WHERE AccountId = :accountId),
                Email_Loaded_Time__c, Phone_Loaded_Time__c, Address_Loaded_Time__c 
                FROM Contact WHERE Party_Id__c IN :partyIds
               ];
    }

    private static List<AccountContactRelation> querySecondaryUsersForAccount(Id accountId)
    {
        return [SELECT Id, AccountId, ContactId, Relationship__c
                FROM AccountContactRelation 
                WHERE AccountId=:accountId AND Relationship__c = 'SECONDARY_USER' AND Can_Contact_CS__c = true];
    }

    private static List<AccountContactRelation> queryRelationshipBetweenAccountAndContacts(Id accountId, List<Id> contactIds)
    {
        return [SELECT Id, AccountId, ContactId, Relationship__c
                FROM AccountContactRelation 
                WHERE AccountId=:accountId AND ContactId IN :contactIds];
    }
}