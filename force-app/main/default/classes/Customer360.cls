public class Customer360 {

    // Class that holds all the constants and maps that are core to the Customer360 data like
    // Data Categories supported, search criteria, error message map and so on. If a new data
    // is introduced in Customer360 or if we are improving search options for existing categories,
    // this is the best place to start the plan

    // Different data categories available within Customer360
    public enum DataCategory {
                                    ALL,
                                    PROFILE,
                                    PROFILE_BASIC,
                                    PROFILE_EMAILS,
                                    PROFILE_PHONES,
                                    PROFILE_ADDRESSES,
                                    COMPLIANCE,
                                    SECONDARY_USERS,
                                    BUSINESS_INFO,
                                    ACCOUNT_INFO,
                                    LIMITATIONS,
                                    TRANSACTIONS,
                                    CASES,
                                    ACTIVITIES,
                                    NOTES,
                                    PRODUCTS,
                                    WALLET,
                                    LINKED_ACCOUNTS,
                                    PREVIOUS_INTERACTIONS
                                }
    
    // Search criteria that we can use to filter different data categories
    public enum SearchCriteria {
                                    SECONDARY_USERS_PERMISSION_TO_SPEAK,    // Secondar users
                                    SECONDARY_USERS_PARTY_IDS,
                                    SECONDARY_USERS_ALL,
                                    TRANSACTIONS_START_DATE,                // Transactions
                                    TRANSACTIONS_END_DATE,
                                    TRANSACTIONS_LOAD_SUMMARY,
                                    TRANSACTIONS_TRANSACTION_ID,
                                    CASES_START_DATE,                       // Cases
                                    CASES_END_DATE,
                                    CASES_TRANSACTION_ID,
                                    ACTIVITIES_START_DATE,                  // Activity Logs
                                    ACTIVITIES_END_DATE,
                                    ACTIVITIES_FILTER_GROUP,
                                    ACTIVITIES_INCLUDE_ERROR_MESSAGES,
                                    NOTES_START_DATE,                       // Notes
                                    NOTES_END_DATE,
                                    PREVIOUS_INTERACTIONS_START_DATE,       // Previous Interactions
                                    PREVIOUS_INTERACTIONS_END_DATE
                                }
    
    // Status of the Customer360 data handling - this can be used in API or even controller response
    public enum Status  {
                                    SUCCESS,
                                    PARTIAL_SUCCESS,
                                    FAILURE
                        }

    // Map between the actual data category enum to the string that needs to passed to API as per the contract
    static Map<DataCategory, String> dataCategoryToFieldName = new Map<DataCategory, String>();

    // Reverse map between the field name to actual data category enum that we can use
    static Map<String, DataCategory> fieldNameToDataCategory = new Map<String, DataCategory>();

    // Map between the search criteria to string that needs to be passed to theAPI as per the contract
    static Map<SearchCriteria, String> searchCriteriaToFieldName = new Map<SearchCriteria, String>();

    // Map between the actual data category enum to the string that describes what the data category is about
    // This map can be used to provide details on what information was unavailable in the event of failures
    static Map<DataCategory, String> dataCategoryToDescription = new Map<DataCategory, String>();

    static {
        /********************** dataCategoryToFieldName **********************/
        dataCategoryToFieldName.put(DataCategory.PROFILE, 'profile');
        dataCategoryToFieldName.put(DataCategory.PROFILE_BASIC, 'profile.basic');
        dataCategoryToFieldName.put(DataCategory.PROFILE_EMAILS, 'profile.emails');
        dataCategoryToFieldName.put(DataCategory.PROFILE_PHONES, 'profile.phones');
        dataCategoryToFieldName.put(DataCategory.PROFILE_ADDRESSES, 'profile.addresses');
        dataCategoryToFieldName.put(DataCategory.COMPLIANCE, 'compliance');
        dataCategoryToFieldName.put(DataCategory.SECONDARY_USERS, 'secondary_users');
        dataCategoryToFieldName.put(DataCategory.BUSINESS_INFO, 'business_details');
        dataCategoryToFieldName.put(DataCategory.ACCOUNT_INFO, 'account_attribute');
        dataCategoryToFieldName.put(DataCategory.LIMITATIONS, 'limitations');
        dataCategoryToFieldName.put(DataCategory.TRANSACTIONS, 'transactions');
        dataCategoryToFieldName.put(DataCategory.CASES, 'cases');
        dataCategoryToFieldName.put(DataCategory.ACTIVITIES, 'activities');
        dataCategoryToFieldName.put(DataCategory.NOTES, 'notes');
        dataCategoryToFieldName.put(DataCategory.PRODUCTS, 'products');
        dataCategoryToFieldName.put(DataCategory.WALLET, 'financial_instruments');
        dataCategoryToFieldName.put(DataCategory.LINKED_ACCOUNTS, 'linked_accounts');
        dataCategoryToFieldName.put(DataCategory.PREVIOUS_INTERACTIONS, 'previous_interactions');

        /********************** fieldNameToDataCategory **********************/
        fieldNameToDataCategory.put('profile', DataCategory.PROFILE);
        fieldNameToDataCategory.put('profile.basic', DataCategory.PROFILE_BASIC);
        fieldNameToDataCategory.put('profile.emails', DataCategory.PROFILE_EMAILS);
        fieldNameToDataCategory.put('profile.phones', DataCategory.PROFILE_PHONES);
        fieldNameToDataCategory.put('profile.addresses', DataCategory.PROFILE_ADDRESSES);
        fieldNameToDataCategory.put('compliance', DataCategory.COMPLIANCE);
        fieldNameToDataCategory.put('secondary_users', DataCategory.SECONDARY_USERS);
        fieldNameToDataCategory.put('businessinfo', DataCategory.BUSINESS_INFO);
        fieldNameToDataCategory.put('accountinfo', DataCategory.ACCOUNT_INFO);
        fieldNameToDataCategory.put('limitations', DataCategory.LIMITATIONS);
        fieldNameToDataCategory.put('transactions', DataCategory.TRANSACTIONS);
        fieldNameToDataCategory.put('cases', DataCategory.CASES);
        fieldNameToDataCategory.put('activities', DataCategory.ACTIVITIES);
        fieldNameToDataCategory.put('notes', DataCategory.NOTES);
        fieldNameToDataCategory.put('products', DataCategory.PRODUCTS);
        fieldNameToDataCategory.put('wallet', DataCategory.WALLET);
        fieldNameToDataCategory.put('linked_accounts', DataCategory.LINKED_ACCOUNTS);
        fieldNameToDataCategory.put('previous_interactions', DataCategory.PREVIOUS_INTERACTIONS);

        /********************** searchCriteriaToURL **********************/
        searchCriteriaToFieldName.put(SearchCriteria.SECONDARY_USERS_PERMISSION_TO_SPEAK, 'secondary_users.permission_to_speak');
        searchCriteriaToFieldName.put(SearchCriteria.SECONDARY_USERS_PARTY_IDS, 'secondary_users.party_ids');
        searchCriteriaToFieldName.put(SearchCriteria.SECONDARY_USERS_ALL, 'secondary_users.all');
        searchCriteriaToFieldName.put(SearchCriteria.TRANSACTIONS_START_DATE, 'transactions.start_date');
        searchCriteriaToFieldName.put(SearchCriteria.TRANSACTIONS_END_DATE, 'transactions.end_date');
        searchCriteriaToFieldName.put(SearchCriteria.TRANSACTIONS_LOAD_SUMMARY, 'transactions.load_summary');
        searchCriteriaToFieldName.put(SearchCriteria.TRANSACTIONS_TRANSACTION_ID, 'transactions.transaction_id');
        searchCriteriaToFieldName.put(SearchCriteria.CASES_START_DATE, 'cases.start_date');
        searchCriteriaToFieldName.put(SearchCriteria.CASES_END_DATE, 'cases.end_date');
        searchCriteriaToFieldName.put(SearchCriteria.CASES_TRANSACTION_ID, 'cases.transaction_id');
        searchCriteriaToFieldName.put(SearchCriteria.ACTIVITIES_START_DATE, 'activities.start_date');
        searchCriteriaToFieldName.put(SearchCriteria.ACTIVITIES_END_DATE, 'activities.end_date');
        searchCriteriaToFieldName.put(SearchCriteria.ACTIVITIES_FILTER_GROUP, 'activities.filter_group');
        searchCriteriaToFieldName.put(SearchCriteria.ACTIVITIES_INCLUDE_ERROR_MESSAGES, 'activities.include_error_messsages');
        searchCriteriaToFieldName.put(SearchCriteria.NOTES_START_DATE, 'notes.start_date');
        searchCriteriaToFieldName.put(SearchCriteria.NOTES_END_DATE, 'notes.end_date');
        searchCriteriaToFieldName.put(SearchCriteria.PREVIOUS_INTERACTIONS_START_DATE, 'previous_interactions.start_date');
        searchCriteriaToFieldName.put(SearchCriteria.PREVIOUS_INTERACTIONS_END_DATE, 'previous_interactions.end_date');

        /********************** dataCategoryToDescription **********************/
        dataCategoryToDescription.put(DataCategory.PROFILE, 'Basic Info like Account type, name, email, phone, etc.,');
        dataCategoryToDescription.put(DataCategory.PROFILE_BASIC, 'Basic Info like Account type, name, picture, etc.,');
        dataCategoryToDescription.put(DataCategory.PROFILE_EMAILS, 'Emails');
        dataCategoryToDescription.put(DataCategory.PROFILE_PHONES, 'Phone Numbers');
        dataCategoryToDescription.put(DataCategory.PROFILE_ADDRESSES, 'Addresses');
        dataCategoryToDescription.put(DataCategory.COMPLIANCE, 'Compliance / CIP Status');
        dataCategoryToDescription.put(DataCategory.SECONDARY_USERS, 'Secondary users / Aliases');
        dataCategoryToDescription.put(DataCategory.BUSINESS_INFO, 'Business details like MCC code, Customer Service details, etc.,');
        dataCategoryToDescription.put(DataCategory.ACCOUNT_INFO, 'Account Manager Flags');
        dataCategoryToDescription.put(DataCategory.LIMITATIONS, 'Limitation Details');
        dataCategoryToDescription.put(DataCategory.TRANSACTIONS, 'Transaction Logs');
        dataCategoryToDescription.put(DataCategory.CASES, 'Cases');
        dataCategoryToDescription.put(DataCategory.ACTIVITIES, 'Activity Logs');
        dataCategoryToDescription.put(DataCategory.NOTES, 'Service Log Notes');
        dataCategoryToDescription.put(DataCategory.PRODUCTS, 'Product details - like PRO/VT, PPH and its status');
        dataCategoryToDescription.put(DataCategory.WALLET, 'Financial Instruments - Cards, Banks, PP Credit, etc.,');
        dataCategoryToDescription.put(DataCategory.LINKED_ACCOUNTS, 'Linked Accounts');
        dataCategoryToDescription.put(DataCategory.PREVIOUS_INTERACTIONS, 'Previous Interactions with Customer Service');
    }

    public static String getFieldNameFromDataCategory(Datacategory category)
    {
        if (category == null)
        {
            return null;
        }

        return dataCategoryToFieldName.get(category);
    }

    public static Datacategory getDataCategoryByFieldName(String fieldName)
    {
        if (String.isBlank(fieldName))
        {
            return null;
        }

        return fieldNameToDataCategory.get(fieldName.toLowerCase());
    }

    public static String getFieldNameFromSearchCriteria(SearchCriteria criteria)
    {
        if (criteria == null)
        {
            return null;
        }

        return searchCriteriaToFieldName.get(criteria);
    }

    public static List<String> getDescriptionForCategories(List<DataCategory> categories)
    {
        List<String> descriptions = new List<String>();

        if ((categories == null) || (categories.size() == 0))
        {
            return descriptions;
        }

        for (DataCategory category : categories)
        {
            String description = dataCategoryToDescription.get(category);
            if (String.isNotBlank(description))
            {
                descriptions.add(description);
            }
        }

        return descriptions;
    }

    // This method returns all the data categories that are involved in a pre-fetch
    // It is supposed to be ALL, but there is no guarantee in future and we may decide to pre-fetch
    // only the subset depending on our need
    public static List<DataCategory> getPrefetchDataCategories()
    {
        List<DataCategory> categories = new List<DataCategory>();
        categories.add(DataCategory.ALL);
        return categories;
    }
}