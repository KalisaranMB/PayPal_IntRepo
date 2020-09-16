public class ProfileAPI {
    public static Customer360SO mapResponseToCustomer360SO(Customer360SO cx360SO, Customer360APIRequest request, Customer360APIResponse response)
    {
        System.debug('ProfileAPI:mapResponseToCustomer360SO - Mapping Profile Information');

        // Ready to map the profile response, lets make sure profile is available
        if ((response.isProfileFailed()) || (response.getCustomer360DO().profile == null))
        {
            System.debug('Customer360 API response does not have any profile information');
            return cx360SO;
        }

        if (request.isBasicProfileRequested())
        {
            cx360SO = BasicProfileAPI.mapResponseToCustomer360SO(cx360SO, request, response);
        }

        if (request.isProfileEmailsRequested())
        {
            cx360SO = ProfileEmailAPI.mapResponseToCustomer360SO(cx360SO, request, response);
        }

        if (request.isProfilePhonesRequested())
        {
            cx360SO = ProfilePhoneAPI.mapResponseToCustomer360SO(cx360SO, request, response);
        }

        if (request.isProfileAddressesRequested())
        {
            cx360SO = ProfileAddressAPI.mapResponseToCustomer360SO(cx360SO, request, response);
        }

        return cx360SO;
    }

    public static Account storeResponseInSObject(Account acct, Customer360APIRequest request, Customer360APIResponse response)
    {
        System.debug('ProfileAPI:storeResponseInSObject - Storing Profile Information into SObject');

        ProfileDO profile = response.getCustomer360DO().profile;

        // Return if the profile is failed to load. If the profile is in the request data category, it should not be null
        if ((response.isProfileFailed()) || (profile == null))
        {
            System.debug(LoggingLevel.ERROR, 'Customer360 API response does not have any profile information');
            return acct;
        }

        InsertToSOHelper soHelper = new InsertToSOHelper();
        soHelper.acct = acct;

        if (request.isBasicProfileRequested())
        {
            soHelper = BasicProfileAPI.storeResponseInSObject(soHelper, request, response);
        }

        // If contact in the soHelper is null at this stage, either the basic profile information is not requested or failed to load
        // Check if we can proceed further with Contact object is available in the Customer360 Request
        if (soHelper.ct == null)
        {
            Contact ct = request.getContact();
            if (ct == null)
            {
                System.debug('Unable to identify a contact to work with - cannot proceed with mapping emails/phones/addresses if requested');
                return acct;
            }
            else
            {
                // Ideally, if the caller who is passing the contact in the request queries for all related records and fields that we need to
                // handle here, we dont need to make another query. But let us not make that assumption at this point of time and go with clean code.
                List<Contact> contacts = BasicProfileAPI.queryContactAndItsRelationships(soHelper.acct.Id, ct.Party_Id__c);
                if (contacts.size() == 0)
                {
                    System.debug(LoggingLevel.ERROR, 'Unexpected - Failed to load contact and its relationships using the contact object. Id - ' + ct.Id);
                    return acct;
                }
                soHelper.ct = contacts[0];
            }
        }

        if (request.isProfileEmailsRequested())
        {
            soHelper = ProfileEmailAPI.storeResponseInSObject(soHelper, request, response);
        }

        if (request.isProfilePhonesRequested())
        {
            soHelper = ProfilePhoneAPI.storeResponseInSObject(soHelper, request, response);
        }

        if (request.isProfileAddressesRequested())
        {
            soHelper = ProfileAddressAPI.storeResponseInSObject(soHelper, request, response);
        }

        // Delete old records
        if (soHelper.recordsToDelete.size() > 0)
        {
            delete soHelper.recordsToDelete;
        }

        // Insert new records
        if (soHelper.recordsToInsert.size() > 0)
        {
            insert soHelper.recordsToInsert;
        }

        // Update Contact object
        update soHelper.ct;

        return acct;
    }

    // Helper Class for inserting to sObject. This can be useful in multitude of ways
    // mainly to optimize the number of DML statements in the transaction. We can 
    // optimize to the level we need using this
    public class InsertToSOHelper {
        public Account acct;
        public Contact ct;
        public Boolean newContact;
        public List<SObject> recordsToInsert;
        public List<SObject> recordsToDelete;

        public InsertToSOHelper()
        {
            acct = null;
            ct = null;
            newContact = false;
            recordsToInsert = new List<SObject>();
            recordsToDelete = new List<SObject>();
        }
    }
}