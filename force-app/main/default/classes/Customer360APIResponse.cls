public class Customer360APIResponse {

    public static final String partialSuccessCode='206';
    // TBD Confirm if service team will be sending 404 for data entities in case of failure
    public static final String failureCode='404';

    private Integer httpResponseCode;
    private Customer360.Status apiResult; 
    private Customer360DO cx360Data;
    private Map<Customer360.DataCategory, PayPalAPIErrorDetailDO> errorCategoriesMap;
    private Map<Customer360.DataCategory, Boolean> failedCategories;
    private Map<Customer360.DataCategory, Boolean> partialSuccessCategories;

    // Constructor
    public Customer360APIResponse()
    {
        cx360Data = null;
        errorCategoriesMap = new Map<Customer360.DataCategory, PayPalAPIErrorDetailDO>();
        failedCategories = new Map<Customer360.DataCategory, Boolean>();
        partialSuccessCategories = new Map<Customer360.DataCategory, Boolean>();
        httpResponseCode = 0;
        apiResult = Customer360.Status.FAILURE;
    }

    public void setCustomer360Response(Integer httpCode, Customer360DO data)
    {
        httpResponseCode = httpCode;
        
        if ((httpCode >= 200) && (httpCode < 300) && (httpCode != 206))
        {
            // Success - Any 2XX except Partial content is considered as success
            apiResult = Customer360.Status.SUCCESS;
            cx360Data = data;
        }
        else if (httpCode == 206)
        {
            // Partial Success - 206
            apiResult = Customer360.Status.PARTIAL_SUCCESS;
            cx360Data = data;

            // Lets fill all unsuccessful categories into errorCategoriesMap
            deriveErrorDataCategories();
        }
        else
        {
            // Anything else is a failure
            apiResult = Customer360.Status.FAILURE;
            cx360Data = null;
        }
    }

    private void deriveErrorDataCategories()
    {
        if ((cx360Data == null) || (cx360Data.error_object == null) ||
            (cx360Data.error_object.details == null) || (cx360Data.error_object.details.size() == 0))
        {
            System.debug(LoggingLevel.ERROR, 'Couldnt find error details in the response to map to failed data attributes');
            return;
        }

        for (PayPalAPIErrorDetailDO detail : cx360Data.error_object.details)
        {
            // TBD - Make sure the field's values is 'fields' from the service side
            if (detail.field == 'fields')
            {
                // Even if service is giving error at the detailed level, this will filter only the data
                // categories we defined in the system
                Customer360.DataCategory category = Customer360.getDataCategoryByFieldName(detail.value);
                if (category != null)
                {
                    errorCategoriesMap.put(category, detail);
                    if (detail.value == partialSuccessCode)
                    {
                        partialSuccessCategories.put(category, true);
                    }
                    else if (detail.value == failureCode)
                    {
                        failedCategories.put(category, true);
                    }
                }
            }
        }
    }

    public Customer360DO getCustomer360DO()
    {
        return cx360Data;
    }

    public Boolean isAPIStatusSuccess()
    {
        return (apiResult == Customer360.Status.SUCCESS) ? true : false;
    }

    public Boolean isAPIStatusFailure()
    {
        return (apiResult == Customer360.Status.FAILURE) ? true : false;
    }

    public Boolean isAPIStatusPartialSuccess()
    {
        return (apiResult == Customer360.Status.PARTIAL_SUCCESS) ? true : false;
    }

    // TBD - Understand how Service handles top level entity failures / partial success
    public List<Customer360.DataCategory> getFailedDataCategories()
    {
        List<Customer360.DataCategory> categoryList = new List<Customer360.DataCategory>();
        categoryList.addAll(failedCategories.keySet());
        return categoryList;
    }

    public List<Customer360.DataCategory> getPartialSuccessDataCategories()
    {
        List<Customer360.DataCategory> categoryList = new List<Customer360.DataCategory>();
        categoryList.addAll(partialSuccessCategories.keySet());
        return categoryList;
    }

    /*********************************************************************** 
      Set of Methods to determine whether a data entity is failed to load 
    ************************************************************************/

    public Boolean isProfileFailed()
    {
        if (failedCategories.containsKey(Customer360.DataCategory.PROFILE))
        {
            return true;
        }
        return false;
    }

    public Boolean isBasicProfileFailed()
    {
        if (failedCategories.containsKey(Customer360.DataCategory.PROFILE)      ||
            failedCategories.containsKey(Customer360.DataCategory.PROFILE_BASIC))
        {
            return true;
        }
        return false;
    }

    public Boolean isProfileEmailsFailed()
    {
        if (failedCategories.containsKey(Customer360.DataCategory.PROFILE)       ||
            failedCategories.containsKey(Customer360.DataCategory.PROFILE_EMAILS))
        {
            return true;
        }
        return false;
    }

    public Boolean isProfilePhonesFailed()
    {
        if (failedCategories.containsKey(Customer360.DataCategory.PROFILE)       ||
            failedCategories.containsKey(Customer360.DataCategory.PROFILE_PHONES))
        {
            return true;
        }
        return false;
    }

    public Boolean isProfileAddressesFailed()
    {
        if (failedCategories.containsKey(Customer360.DataCategory.PROFILE)          ||
            failedCategories.containsKey(Customer360.DataCategory.PROFILE_ADDRESSES))
        {
            return true;
        }
        return false;
    }

    public Boolean isBusinessInfoFailed()
    {
        if (failedCategories.containsKey(Customer360.DataCategory.BUSINESS_INFO))
        {
            return true;
        }
        return false;
    }

    public Boolean isComplianceInfoFailed()
    {
        if (failedCategories.containsKey(Customer360.DataCategory.COMPLIANCE))
        {
            return true;
        }
        return false;
    }

    public Boolean isAccountInfoFailed()
    {
        if (failedCategories.containsKey(Customer360.DataCategory.ACCOUNT_INFO))
        {
            return true;
        }
        return false;
    }

    public Boolean isSecondaryUsersFailed()
    {
        if (failedCategories.containsKey(Customer360.DataCategory.SECONDARY_USERS))
        {
            return true;
        }
        return false;
    }

    public Boolean isLimitationsFailed()
    {
        if (failedCategories.containsKey(Customer360.DataCategory.LIMITATIONS))
        {
            return true;
        }
        return false;
    }

    public Boolean isWalletFailed()
    {
        if (failedCategories.containsKey(Customer360.DataCategory.WALLET))
        {
            return true;
        }
        return false;
    }

    public Boolean isTransactionsFailed()
    {
        if (failedCategories.containsKey(Customer360.DataCategory.TRANSACTIONS))
        {
            return true;
        }
        return false;
    }

    public Boolean isCasesFailed()
    {
        if (failedCategories.containsKey(Customer360.DataCategory.CASES))
        {
            return true;
        }
        return false;
    }

    public Boolean isActivityLogsFailed()
    {
        if (failedCategories.containsKey(Customer360.DataCategory.ACTIVITIES))
        {
            return true;
        }
        return false;
    }

    public Boolean isNotesFailed()
    {
        if (failedCategories.containsKey(Customer360.DataCategory.NOTES))
        {
            return true;
        }
        return false;
    }

    public Boolean isProductInfoFailed()
    {
        if (failedCategories.containsKey(Customer360.DataCategory.PRODUCTS))
        {
            return true;
        }
        return false;
    }

    public Boolean isLinkedAccountsFailed()
    {
        if (failedCategories.containsKey(Customer360.DataCategory.LINKED_ACCOUNTS))
        {
            return true;
        }
        return false;
    }
    
    public Boolean isPreviousInteractionsFailed()
    {
        if (failedCategories.containsKey(Customer360.DataCategory.PREVIOUS_INTERACTIONS))
        {
            return true;
        }
        return false;
    }

    /*********************************************************************** 
      Set of Methods to determine whether a data entity is successfully
      loaded without any issue. An entity is considered as loaded if that
      data category is not present in the errorCategoriesMap
    ************************************************************************/

    public Boolean isBasicProfileSuccessfullyLoaded()
    {
        if (!errorCategoriesMap.containsKey(Customer360.DataCategory.PROFILE_BASIC))
        {
            return true;
        }
        return false;
    }

    public Boolean isProfileEmailsSuccessfullyLoaded()
    {
        if (!errorCategoriesMap.containsKey(Customer360.DataCategory.PROFILE_EMAILS))
        {
            return true;
        }
        return false;
    }

    public Boolean isProfilePhonesSuccessfullyLoaded()
    {
        if (!errorCategoriesMap.containsKey(Customer360.DataCategory.PROFILE_PHONES))
        {
            return true;
        }
        return false;
    }

    public Boolean isProfileAddressesSuccessfullyLoaded()
    {
        if (!errorCategoriesMap.containsKey(Customer360.DataCategory.PROFILE_ADDRESSES))
        {
            return true;
        }
        return false;
    }

    public Boolean isBusinessInfoSuccessfullyLoaded()
    {
        if (!errorCategoriesMap.containsKey(Customer360.DataCategory.BUSINESS_INFO))
        {
            return true;
        }
        return false;
    }

    public Boolean isComplianceInfoSuccessfullyLoaded()
    {
        if (!errorCategoriesMap.containsKey(Customer360.DataCategory.COMPLIANCE))
        {
            return true;
        }
        return false;
    }

    public Boolean isAccountInfoSuccessfullyLoaded()
    {
        if (!errorCategoriesMap.containsKey(Customer360.DataCategory.ACCOUNT_INFO))
        {
            return true;
        }
        return false;
    }

    public Boolean isSecondaryUsersSuccessfullyLoaded()
    {
        if (!errorCategoriesMap.containsKey(Customer360.DataCategory.SECONDARY_USERS))
        {
            return true;
        }
        return false;
    }

    public Boolean isLimitationsSuccessfullyLoaded()
    {
        if (!errorCategoriesMap.containsKey(Customer360.DataCategory.LIMITATIONS))
        {
            return true;
        }
        return false;
    }

    public Boolean isWalletSuccessfullyLoaded()
    {
        if (!errorCategoriesMap.containsKey(Customer360.DataCategory.WALLET))
        {
            return true;
        }
        return false;
    }

    public Boolean isTransactionsSuccessfullyLoaded()
    {
        if (!errorCategoriesMap.containsKey(Customer360.DataCategory.TRANSACTIONS))
        {
            return true;
        }
        return false;
    }

    public Boolean isCasesSuccessfullyLoaded()
    {
        if (!errorCategoriesMap.containsKey(Customer360.DataCategory.CASES))
        {
            return true;
        }
        return false;
    }

    public Boolean isActivityLogsSuccessfullyLoaded()
    {
        if (!errorCategoriesMap.containsKey(Customer360.DataCategory.ACTIVITIES))
        {
            return true;
        }
        return false;
    }

    public Boolean isNotesSuccessfullyLoaded()
    {
        if (!errorCategoriesMap.containsKey(Customer360.DataCategory.NOTES))
        {
            return true;
        }
        return false;
    }

    public Boolean isProductInfoSuccessfullyLoaded()
    {
        if (!errorCategoriesMap.containsKey(Customer360.DataCategory.PRODUCTS))
        {
            return true;
        }
        return false;
    }

    public Boolean isLinkedAccountsSuccessfullyLoaded()
    {
        if (!errorCategoriesMap.containsKey(Customer360.DataCategory.LINKED_ACCOUNTS))
        {
            return true;
        }
        return false;
    }
    
    public Boolean isPreviousInteractionsSuccessfullyLoaded()
    {
        if (!errorCategoriesMap.containsKey(Customer360.DataCategory.PREVIOUS_INTERACTIONS))
        {
            return true;
        }
        return false;
    }
}