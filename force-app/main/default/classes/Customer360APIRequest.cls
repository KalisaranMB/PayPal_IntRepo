public class Customer360APIRequest {

    // Customer360 Data that are available locally and fresh enough to use - no need to call API
    private Map<Customer360.DataCategory, Boolean> dataCategoriesAvailable;

    // Customer360 Data that needs to be loaded via API - either it is not available or not fresh enough to use
    private Map<Customer360.DataCategory, Boolean> dataCategoriesToBeLoaded;

    // Search Criteria (key value pairs), will be populated by the corresponding controllers who needs the data
    private Map<Customer360.SearchCriteria, String> searchCriteriaToBeLoaded;

    // In some instances, we will need to retrieve fresh data instead of using cache - in Salesforce or CSDAS
    // By default, this field will be false and we will always use the cached data unless the situation demands it
    private Boolean skipCacheData;

    // Account
    private Account acct;

    // Contact
    private Contact ct;

    // Constructor
    public Customer360APIRequest() {
        dataCategoriesAvailable = new Map<Customer360.DataCategory, Boolean>();
        dataCategoriesToBeLoaded = new Map<Customer360.DataCategory, Boolean>();
        searchCriteriaToBeLoaded = new Map<Customer360.SearchCriteria, String>();
        acct = null;
        ct = null;
        skipCacheData = false;
    }

    public void addToDataCategoriesAvailable(Customer360.DataCategory category)
    {
        if (category != null)
        {
            dataCategoriesAvailable.put(category, true);
        }
    }

    public List<Customer360.DataCategory> getDataCategoriesAvailable()
    {
        List<Customer360.DataCategory> categoryList = new List<Customer360.DataCategory>();
        categoryList.addAll(dataCategoriesAvailable.keySet());
        return categoryList;
    }

    public void addToDataCategoriesToBeLoaded(Customer360.DataCategory category)
    {
        if (category != null)
        {
            dataCategoriesToBeLoaded.put(category, true);
        }
    }

    public void addToDataCategoriesToBeLoaded(List<Customer360.DataCategory> categories)
    {
        if ((categories != null) && (categories.size() > 0))
        {
            for (Customer360.DataCategory category : categories)
            {
                dataCategoriesToBeLoaded.put(category, true);
            }
        }
    }

    public List<Customer360.DataCategory> getDataCategoriesToBeLoaded()
    {
        List<Customer360.DataCategory> categoryList = new List<Customer360.DataCategory>();
        categoryList.addAll(dataCategoriesToBeLoaded.keySet());
        return categoryList;
    }

    public void addToSearchCriteriaToBeLoaded(Customer360.SearchCriteria criteria, String value)
    {
        searchCriteriaToBeLoaded.put(criteria, value);
    }

    // This method will consolidate all the data to be loaded and search criteria to return the URI
    // parameters that match the expectations of API specification
    public String getURLParamsForAPICall()
    {
        // If all Customer 360 data is required or none, we dont need to populate any key value params in the URL
        if (dataCategoriesToBeLoaded.isEmpty() || dataCategoriesToBeLoaded.containsKey(Customer360.DataCategory.ALL))
        {
            System.debug('URL parameters for the Customer360 API call - None');
            return '';
        }

        String urlParams = '?fields=';

        // Put all data categories we need to load as the comma separated values
        for (Customer360.DataCategory category : dataCategoriesToBeLoaded.keySet())
        {
            urlParams += Customer360.getFieldNameFromDataCategory(category);
            urlParams += ',';
        }

        // We need to remove the last comma, happy to see Salesforce providing a native method to do :)
        urlParams = urlParams.removeEnd(',');

        // Put all the search criteria as key value params in the URL Please note that we allow
        // search criterias to be filled only if we need specific data categories and not for ALL
        // If we have a usecases where we need to get all data points but with speicifc search criteria,
        // we will need to enhance this function a bit.
        for(Customer360.SearchCriteria criteria : searchCriteriaToBeLoaded.keySet())
        {
            urlParams += '&';
            urlParams += Customer360.getFieldNameFromSearchCriteria(criteria);
            urlParams += '=';
            urlParams += EncodingUtil.urlEncode(searchCriteriaToBeLoaded.get(criteria), 'UTF-8');
        }

        // All Done!
        System.debug('URL parameters for the Customer360 API call - ' + urlParams);
        return urlParams;
    }

    public void setAccount(Account curAcct)
    {
        acct = curAcct;
    }

    public Account getAccount()
    {
        return acct;
    }

    public void setContact(Contact curCt)
    {
        ct = curCt;
    }

    public Contact getContact()
    {
        return ct;
    }

    public String getAccountNumberEncrypted()
    {
        return (acct != null) ? acct.Account_Number_Encrypted__c : '';
    }

    public String getPrimaryPartyId()
    {
        return (ct != null) ? ct.Party_Id__c : '';
    }

    public void setSkipCacheDataFlag(Boolean flag)
    {
        skipCacheData = flag;
    }

    public Boolean getSkipCacheDataFlag()
    {
        return skipCacheData;
    }

    public Boolean isProfileRequested()
    {
        if (dataCategoriesToBeLoaded.containsKey(Customer360.DataCategory.ALL)            ||
            dataCategoriesToBeLoaded.containsKey(Customer360.DataCategory.PROFILE)        ||
            dataCategoriesToBeLoaded.containsKey(Customer360.DataCategory.PROFILE_BASIC)  ||
            dataCategoriesToBeLoaded.containsKey(Customer360.DataCategory.PROFILE_EMAILS) ||
            dataCategoriesToBeLoaded.containsKey(Customer360.DataCategory.PROFILE_PHONES) ||
            dataCategoriesToBeLoaded.containsKey(Customer360.DataCategory.PROFILE_ADDRESSES))
        {
            return true;
        }

        return false;
    }

    public Boolean isBasicProfileRequested()
    {
        if (dataCategoriesToBeLoaded.containsKey(Customer360.DataCategory.ALL)            ||
            dataCategoriesToBeLoaded.containsKey(Customer360.DataCategory.PROFILE)        ||
            dataCategoriesToBeLoaded.containsKey(Customer360.DataCategory.PROFILE_BASIC))
        {
            return true;
        }

        return false;
    }

    public Boolean isProfileEmailsRequested()
    {
        if (dataCategoriesToBeLoaded.containsKey(Customer360.DataCategory.ALL)            ||
            dataCategoriesToBeLoaded.containsKey(Customer360.DataCategory.PROFILE)        ||
            dataCategoriesToBeLoaded.containsKey(Customer360.DataCategory.PROFILE_EMAILS))
        {
            return true;
        }

        return false;
    }

    public Boolean isProfilePhonesRequested()
    {
        if (dataCategoriesToBeLoaded.containsKey(Customer360.DataCategory.ALL)            ||
            dataCategoriesToBeLoaded.containsKey(Customer360.DataCategory.PROFILE)        ||
            dataCategoriesToBeLoaded.containsKey(Customer360.DataCategory.PROFILE_PHONES))
        {
            return true;
        }

        return false;
    }

    public Boolean isProfileAddressesRequested()
    {
        if (dataCategoriesToBeLoaded.containsKey(Customer360.DataCategory.ALL)            ||
            dataCategoriesToBeLoaded.containsKey(Customer360.DataCategory.PROFILE)        ||
            dataCategoriesToBeLoaded.containsKey(Customer360.DataCategory.PROFILE_ADDRESSES))
        {
            return true;
        }

        return false;
    }

    public Boolean isBusinessInfoRequested()
    {
        if (dataCategoriesToBeLoaded.containsKey(Customer360.DataCategory.ALL)            ||
            dataCategoriesToBeLoaded.containsKey(Customer360.DataCategory.BUSINESS_INFO))
        {
            return true;
        }

        return false;
    }

    public Boolean isComplianceInfoRequested()
    {
        if (dataCategoriesToBeLoaded.containsKey(Customer360.DataCategory.ALL)            ||
            dataCategoriesToBeLoaded.containsKey(Customer360.DataCategory.COMPLIANCE))
        {
            return true;
        }

        return false;
    }

    public Boolean isAccountInfoRequested()
    {
        if (dataCategoriesToBeLoaded.containsKey(Customer360.DataCategory.ALL)            ||
            dataCategoriesToBeLoaded.containsKey(Customer360.DataCategory.ACCOUNT_INFO))
        {
            return true;
        }

        return false;
    }

    public Boolean isSecondaryUsersRequested()
    {
        if (dataCategoriesToBeLoaded.containsKey(Customer360.DataCategory.ALL)            ||
            dataCategoriesToBeLoaded.containsKey(Customer360.DataCategory.SECONDARY_USERS))
        {
            return true;
        }

        return false;
    }

    public Boolean isLimitationsRequested()
    {
        if (dataCategoriesToBeLoaded.containsKey(Customer360.DataCategory.ALL)            ||
            dataCategoriesToBeLoaded.containsKey(Customer360.DataCategory.LIMITATIONS))
        {
            return true;
        }

        return false;
    }

    public Boolean isWalletRequested()
    {
        if (dataCategoriesToBeLoaded.containsKey(Customer360.DataCategory.ALL)            ||
            dataCategoriesToBeLoaded.containsKey(Customer360.DataCategory.WALLET))
        {
            return true;
        }

        return false;
    }

    public Boolean isTransactionsRequested()
    {
        if (dataCategoriesToBeLoaded.containsKey(Customer360.DataCategory.ALL)            ||
            dataCategoriesToBeLoaded.containsKey(Customer360.DataCategory.TRANSACTIONS))
        {
            return true;
        }

        return false;
    }

    public Boolean isCasesRequested()
    {
        if (dataCategoriesToBeLoaded.containsKey(Customer360.DataCategory.ALL)            ||
            dataCategoriesToBeLoaded.containsKey(Customer360.DataCategory.CASES))
        {
            return true;
        }

        return false;
    }

    public Boolean isActivityLogsRequested()
    {
        if (dataCategoriesToBeLoaded.containsKey(Customer360.DataCategory.ALL)            ||
            dataCategoriesToBeLoaded.containsKey(Customer360.DataCategory.ACTIVITIES))
        {
            return true;
        }

        return false;
    }

    public Boolean isNotesRequested()
    {
        if (dataCategoriesToBeLoaded.containsKey(Customer360.DataCategory.ALL)            ||
            dataCategoriesToBeLoaded.containsKey(Customer360.DataCategory.NOTES))
        {
            return true;
        }

        return false;
    }

    public Boolean isProductInfoRequested()
    {
        if (dataCategoriesToBeLoaded.containsKey(Customer360.DataCategory.ALL)            ||
            dataCategoriesToBeLoaded.containsKey(Customer360.DataCategory.PRODUCTS))
        {
            return true;
        }

        return false;
    }

    public Boolean isLinkedAccountsRequested()
    {
        if (dataCategoriesToBeLoaded.containsKey(Customer360.DataCategory.ALL)            ||
            dataCategoriesToBeLoaded.containsKey(Customer360.DataCategory.LINKED_ACCOUNTS))
        {
            return true;
        }

        return false;
    }

    public Boolean isPreviousInteractionsRequested()
    {
        if (dataCategoriesToBeLoaded.containsKey(Customer360.DataCategory.ALL)            ||
            dataCategoriesToBeLoaded.containsKey(Customer360.DataCategory.PREVIOUS_INTERACTIONS))
        {
            return true;
        }

        return false;
    }

}