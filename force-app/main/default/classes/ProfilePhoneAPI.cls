public class ProfilePhoneAPI {
    
    public static Customer360SO mapResponseToCustomer360SO(Customer360SO cx360SO, Customer360APIRequest request, Customer360APIResponse response)
    {
        System.debug('ProfilePhoneAPI:mapResponseToCustomer360SO - Mapping Phone Information');

        if (response.isProfilePhonesFailed() || (response.getCustomer360DO().profile == null) ||
           (response.getCustomer360DO().profile.phone_numbers == null) || (response.getCustomer360DO().profile.phone_numbers.size() == 0))
        {
            System.debug('Customer360 API response does not have any phone numbers');
            return cx360SO;
        }

        for (PhoneDO phone : response.getCustomer360DO().profile.phone_numbers)
        {
            cx360SO.primaryUser.phones.add(mapPhoneDOToContactPhone(phone));
        }

        return cx360SO;
    }

    public static ProfileAPI.InsertToSOHelper storeResponseInSObject(ProfileAPI.InsertToSOHelper soHelper, Customer360APIRequest request, Customer360APIResponse response)
    {
        System.debug('ProfilePhoneAPI:storeResponseInSObject - Storing Phone Information into SObject');

        if (response.isProfilePhonesFailed())
        {
            System.debug('Customer360 API did not successfully load any phone numbers');
            return soHelper;
        }

        List<PhoneDO> phones = response.getCustomer360DO().profile.phone_numbers;

        if (phones != null)
        {
            for (PhoneDO phone : phones)
            {
                Contact_Phone__c phoneObj = mapPhoneDOToContactPhone(phone);
                phoneObj.Contact__c = soHelper.ct.Id;
                soHelper.recordsToInsert.add(phoneObj);
            }
        }

        // If it is not the new contact that we created now, we may have some old phone numbers to be deleted
        if (!soHelper.newContact)
        {
            soHelper.recordsToDelete.addAll(soHelper.ct.Contact_Phones__r);
        }

        // If Phone numbers are successfully loaded (NOT a failure or partial success), lets update the last loaded time
        if (response.isProfilePhonesSuccessfullyLoaded())
        {
            soHelper.ct.Phone_Loaded_Time__c = Datetime.now();
        }

        return soHelper;
    }

    public static Contact_Phone__c mapPhoneDOToContactPhone(PhoneDO phone)
    {
        Contact_Phone__c ctPhone = new Contact_Phone__c();
        ctPhone.Phone_Id__c = phone.phone_id;
        ctPhone.Country_Code__c = phone.country_code;
        ctPhone.Phone_Number__c = phone.phone_number;
        ctPhone.Type__c = getPhoneType(phone.tags);
        ctPhone.Tags_JSON__c = JSON.serialize(phone.tags);
        ctPhone.Status__c = phone.status;
        ctPhone.Confirmation_Status__c = phone.confirmation_status;
        ctPhone.Trust_Status__c = phone.trust_status;
        ctPhone.Is_Primary__c = phone.primary;

        ctPhone.Is_Active__c = false;
        ctPhone.Is_Confirmed__c = false;
        ctPhone.Is_Trusted__c = false;
                
        // Is Phone Active?
        if (String.isNotBlank(phone.status) && phone.status.equalsIgnoreCase('active'))
        {
            ctPhone.Is_Active__c = true;
        }

        // Is Phone Confirmed?
        if (String.isNotBlank(phone.confirmation_status) && phone.confirmation_status.equalsIgnoreCase('confirmed'))
        {
            ctPhone.Is_Confirmed__c = true;
        }

        // Is Phone Trusted?
        if (String.isNotBlank(phone.trust_status) && phone.trust_status.equalsIgnoreCase('trusted'))
        {
            ctPhone.Is_Trusted__c = true;
        }

        return ctPhone;
    }

    private static String getPhoneType(List<String> tags)
    {
        if (tags == null) {
            return 'OTHER';
        }
        else if (tags.contains('MOBILE')) {
            return 'MOBILE';
        }
        else if (tags.contains('HOME')) {
            return 'HOME';
        }
        else if (tags.contains('WORK')) {
            return 'WORK';
        }
        else if (tags.contains('FAX')) {
            return 'FAX';
        }
        else {
            return 'OTHER';
        }
    }
}