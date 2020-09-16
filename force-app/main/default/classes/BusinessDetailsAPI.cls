public class BusinessDetailsAPI {
    
    public static Customer360SO mapResponseToCustomer360SO(Customer360SO cx360SO, Customer360APIRequest request, Customer360APIResponse response)
    {
        System.debug('BusinessDetailsAPI:mapResponseToCustomer360SO - Mapping Business Information');

        if (response.isBusinessInfoFailed() || (response.getCustomer360DO().business_details == null))
        {
            System.debug('Customer360 API response does not have any Business details');
            return cx360SO;
        }

        cx360SO.acct = mapBusinessDetailsDOToAccount(cx360SO.acct, response.getCustomer360DO().business_details);

        if (response.getCustomer360DO().business_details.business_address != null)
        {
            cx360SO.businessAddresses.add(mapAddressDOToBusinessAddress(response.getCustomer360DO().business_details.business_address));
        }
        else
        {
            System.debug('Business Address is missing in the Business Details - so ignoring the mapping');
        }

        return cx360SO;
    }

    public static Account storeResponseInSObject(Account acct, Customer360APIRequest request, Customer360APIResponse response)
    {
        System.debug('BusinessDetailsAPI:storeResponseInSObject - Storing Business Information into SObject');

        BusinessDetailsDO businessDetails = response.getCustomer360DO().business_details;

        if (response.isBusinessInfoFailed())
        {
            System.debug('Customer360 API response did not successfully load the Business details');
            return acct;
        }

        // Remove old business addresses associated with the account
        removeBusinessAddressesFromAccount(acct);

        if (businessDetails != null)
        {
            acct = mapBusinessDetailsDOToAccount(acct, businessDetails);

            if (businessDetails.business_address != null)
            {
                Business_Address__c address = mapAddressDOToBusinessAddress(businessDetails.business_address);
                address.Account__c = acct.Id;
                insert address;
            }
            else
            {
                System.debug('Business Address is missing in the Business Details - so ignoring the mapping');
            }
        }

        // If Business information is loaded successfully (NOT a failure or partial success), let us update the cache time
        if (response.isBusinessInfoSuccessfullyLoaded())
        {
            acct.Business_Info_Loaded_Time__c = Datetime.now();
        }

        return acct;
    }

    private static void removeBusinessAddressesFromAccount(Account acct)
    {
        List<Business_Address__c> addresses = queryBusinessAddressesFromAccount(acct.Id);
        System.debug('Removing existing business addresses from the account. Number of business addresses found - ' + addresses.size());
        if (addresses.size() > 0)
        {
            delete addresses;
        }
        return;
    }

    private static Account mapBusinessDetailsDOToAccount(Account acct, BusinessDetailsDO businessDetails)
    {
        acct.Industry_Name__c = businessDetails.industry_name;
        acct.Merchant_Category_Code__c = businessDetails.merchant_category_code;
        acct.Admin_Merchant_Category_Code__c = businessDetails.admin_merchant_category_code;
        acct.Customer_Service_Email__c = businessDetails.customer_service_email;
        acct.Customer_Service_Phone__c = businessDetails.customer_service_phone;

        // This is just for safety purposes, no harm in doing so too
        if (String.isNotBlank(businessDetails.business_name))
        {
            acct.Name = businessDetails.business_name;
        }

        // Map Monthly TPV related values
        if (businessDetails.average_monthly_volume != null)
        {
            // TBD - Get the final decision around service passing this value in fomatted String
            acct.Average_Monthly_TPV__c = businessDetails.average_monthly_volume.average_monthly_volume_str;

            // TPV Lower Bound
            if (businessDetails.average_monthly_volume.lower_bound != null)
            {
                try {
                    acct.Monthly_TPV_Lower_Bound_Amount__c = Decimal.valueOf(businessDetails.average_monthly_volume.lower_bound.value);
                    acct.Monthly_TPV_Lower_Bound_Currency__c = businessDetails.average_monthly_volume.lower_bound.currency_code;
                }
                catch(Exception e) {
                    System.debug('Monthly TPV Lower Bound Exception: ' + e.getMessage() + ', Failed to convert from String to Decimal - ' 
                                                                       + JSON.serialize(businessDetails.average_monthly_volume.lower_bound));
                }
            }

            // TPV Upper Bound
            if (businessDetails.average_monthly_volume.upper_bound != null)
            {
                try {
                    acct.Monthly_TPV_Upper_Bound_Amount__c = Decimal.valueOf(businessDetails.average_monthly_volume.upper_bound.value);
                    acct.Monthly_TPV_Upper_Bound_Currency__c = businessDetails.average_monthly_volume.upper_bound.currency_code;
                }
                catch(Exception e) {
                    System.debug('Monthly TPV Upper Bound Exception: ' + e.getMessage() + ', Failed to convert from String to Decimal - ' 
                                                                       + JSON.serialize(businessDetails.average_monthly_volume.upper_bound));
                }
            }
        }

        return acct;
    }

    private static Business_Address__c mapAddressDOToBusinessAddress(AddressDO address)
    {
        Business_Address__c bAddress = new Business_Address__c();
        bAddress.Address_Id__c = address.address_id;
        bAddress.Type__c = address.address_type;
        bAddress.Tags_JSON__c = JSON.serialize(address.tags);
        bAddress.Status__c = address.status;
        bAddress.Confirmation_Status__c = address.confirmation_status;
        bAddress.Is_Primary__c = address.primary;
        
        if (address.address != null)
        {
            bAddress.Address_Line_1__c = address.address.address_line_1;
            bAddress.Address_Line_2__c = address.address.address_line_2;
            bAddress.Address_Line_3__c = address.address.address_line_3;
            bAddress.Admin_Area_4__c = address.address.admin_area_4;
            bAddress.Admin_Area_3__c = address.address.admin_area_3;
            bAddress.Admin_Area_2__c = address.address.admin_area_2;
            bAddress.Admin_Area_1__c = address.address.admin_area_1;
            bAddress.Postal_Code__c = address.address.postal_code;
            bAddress.Country__c = address.address.country_code;
        }

        // TBD - Address Type, confirm if we have separate type to identify home, work, etc.,

        // Is Address Active?
        if (String.isNotBlank(address.status) && address.status.equalsIgnoreCase('active'))
        {
            bAddress.Is_Active__c = true;
        }

        // Is Address Confirmed?
        if (String.isNotBlank(address.confirmation_status) && address.confirmation_status.equalsIgnoreCase('confirmed'))
        {
            bAddress.Is_Confirmed__c = true;
        }

        return bAddress;
    }

    private static List<Business_Address__c> queryBusinessAddressesFromAccount(Id accountId)
    {
        return [SELECT Id, Account__c FROM Business_Address__c
                WHERE Account__c=:accountId];
    }
}