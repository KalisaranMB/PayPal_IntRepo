public class ProfileAddressAPI {
    
    public static Customer360SO mapResponseToCustomer360SO(Customer360SO cx360SO, Customer360APIRequest request, Customer360APIResponse response)
    {
        System.debug('ProfileAddressAPI:mapResponseToCustomer360SO - Mapping Address Information');

        if (response.isProfileAddressesFailed() || (response.getCustomer360DO().profile == null) ||
           (response.getCustomer360DO().profile.addresses == null) || (response.getCustomer360DO().profile.addresses.size() == 0))
        {
            System.debug('Customer360 API response does not have any addresses');
            return cx360SO;
        }

        for (AddressDO address : response.getCustomer360DO().profile.addresses)
        {
            cx360SO.primaryUser.addresses.add(mapAddressDOToContactAddress(address));
        }

        return cx360SO;
    }

    public static ProfileAPI.InsertToSOHelper storeResponseInSObject(ProfileAPI.InsertToSOHelper soHelper, Customer360APIRequest request, Customer360APIResponse response)
    {
        System.debug('ProfileAddressAPI:storeResponseInSObject - Storing Address Information into SObject');

        if (response.isProfileAddressesFailed())
        {
            System.debug('Customer360 API did not successfully load any Addresses');
            return soHelper;
        }

        List<AddressDO> addresses = response.getCustomer360DO().profile.addresses;

        if (addresses != null)
        {
            for (AddressDO address : addresses)
            {
                Contact_Address__c addressObj = mapAddressDOToContactAddress(address);
                addressObj.Contact__c = soHelper.ct.Id;
                soHelper.recordsToInsert.add(addressObj);
            }
        }

        // If it is not the new contact that we created now, we may have some old addresses to be deleted
        if (!soHelper.newContact)
        {
            soHelper.recordsToDelete.addAll(soHelper.ct.Contact_Addresses__r);
        }

        // If addresses are successfully loaded (NOT a failure or partial success), lets update the last loaded time
        if (response.isProfileAddressesSuccessfullyLoaded())
        {
            soHelper.ct.Address_Loaded_Time__c = Datetime.now();
        }

        return soHelper;
    }

    public static Contact_Address__c mapAddressDOToContactAddress(AddressDO address)
    {
        Contact_Address__c ctAddress = new Contact_Address__c();
        ctAddress.Address_Id__c = address.address_id;
        ctAddress.Type__c = address.address_type;
        ctAddress.Tags_JSON__c = JSON.serialize(address.tags);
        ctAddress.Status__c = address.status;
        ctAddress.Confirmation_Status__c = address.confirmation_status;
        ctAddress.Is_Primary__c = address.primary;
        
        if (address.address != null)
        {
            ctAddress.Address_Line_1__c = address.address.address_line_1;
            ctAddress.Address_Line_2__c = address.address.address_line_2;
            ctAddress.Address_Line_3__c = address.address.address_line_3;
            ctAddress.Admin_Area_4__c = address.address.admin_area_4;
            ctAddress.Admin_Area_3__c = address.address.admin_area_3;
            ctAddress.Admin_Area_2__c = address.address.admin_area_2;
            ctAddress.Admin_Area_1__c = address.address.admin_area_1;
            ctAddress.Postal_Code__c = address.address.postal_code;
            ctAddress.Country__c = address.address.country_code;
        }

        ctAddress.Is_Active__c = false;
        ctAddress.Is_Confirmed__c = false;

        // TBD - Address Type, confirm if we have separate type to identify home, work, etc.,

        // Is Address Active?
        if (String.isNotBlank(address.status) && address.status.equalsIgnoreCase('active'))
        {
            ctAddress.Is_Active__c = true;
        }

        // Is Address Confirmed?
        if (String.isNotBlank(address.confirmation_status) && address.confirmation_status.equalsIgnoreCase('confirmed'))
        {
            ctAddress.Is_Confirmed__c = true;
        }

        return ctAddress;
    }

}