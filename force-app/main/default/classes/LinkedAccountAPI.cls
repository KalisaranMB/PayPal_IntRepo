public class LinkedAccountAPI {
    
    public static Customer360SO mapResponseToCustomer360SO(Customer360SO cx360SO, Customer360APIRequest request, Customer360APIResponse response)
    {
        System.debug('LinkedAccountAPI:mapResponseToCustomer360SO - mapping Linked Accounts Information');
        
        // Check if there are any failures in loading Linked Accounts
        if (response.isLinkedAccountsFailed() || (response.getCustomer360DO().linked_accounts == null) ||
            (response.getCustomer360DO().linked_accounts.size() == 0))
        {
            System.debug('No Linked accounts available in Customer360 API response');
            return cx360SO;
        }
        
        // Map Linked Accounts to the cx360SO object passed in the request
        for (LinkedAccountDO lacct : response.getCustomer360DO().linked_accounts)
        {
            cx360SO.linkedAccounts.add(mapLinkedAccountDOToSO(lacct));
        }

        return cx360SO;
    }

    public static Account storeResponseInSObject(Account acct, Customer360APIRequest request, Customer360APIResponse response)
    {
        System.debug('LinkedAccountAPI:storeResponseInSObject - Stroing Linked Accounts Information into SObject');
        
        // Check if there are any failures in loading Linked Accounts
        if (response.isLinkedAccountsFailed())
        {
            System.debug('Customer360API did not successfully load the linked accounts');
            return acct;
        }

        // Remove all linked accounts from the account
        removeLinkedAccountsFromAccount(acct);

        List<LinkedAccountDO> lacctDOs = response.getCustomer360DO().linked_accounts;
        
        if ((lacctDOs != null) && (lacctDOs.size() > 0))
        {
            List<LinkedAccountSO> lacctSOs = new List<LinkedAccountSO>();
            List<Linked_Account__c> linkedAccountObjsToInsert = new List<Linked_Account__c>();

            for (LinkedAccountDO lacctDO : lacctDOs)
            {
                LinkedAccountSO lacctSO = mapLinkedAccountDOToSO(lacctDO);
                lacctSO.linkedAccount.Account1__c = acct.Id;
                linkedAccountObjsToInsert.add(lacctSO.linkedAccount);
                lacctSOs.add(lacctSO);
            }

            // Now that we have collected all linked accounts to be inserted, lets go ahead and insert
            // This will create Id for all the linked accounts, the beauty of handling object be reference
            // will make sure the Id values are available when we access
            System.debug('Inserting Linked Accounts. Number of Records - ' + linkedAccountObjsToInsert.size());
            insert linkedAccountObjsToInsert;

            List<Linked_Account_Attributes__c> linkedAttributeObjsToInsert = new List<Linked_Account_Attributes__c>();

            for (LinkedAccountSO lso : lacctSOs)
            {
                for (LinkedAccountAttributeSO lattrSO : lso.attributes)
                {
                    // Link the newly created id into the child object - linked account attributes
                    lattrSO.attribute.Linked_Account__c = lso.linkedAccount.Id;
                    linkedAttributeObjsToInsert.add(lattrSO.attribute);
                }
            }

            // Insert all child objects
            System.debug('Inserting Linked Account Attributes. Number of Records - ' + linkedAttributeObjsToInsert.size());
            if (linkedAttributeObjsToInsert.size() > 0)
            {
                insert linkedAttributeObjsToInsert;
            }
        }

        // If Linked Accounts is loaded successfully (NOT a failure or partial success), update the cache time
        if (response.isLinkedAccountsSuccessfullyLoaded())
        {
            acct.Linked_Accounts_Loaded_Time__c = Datetime.now();
        }

        return acct;
    }

    private static LinkedAccountSO mapLinkedAccountDOToSO(LinkedAccountDO lacct)
    {
        LinkedAccountSO lacctSo = new LinkedAccountSO();
        lacctSo.linkedAccount = mapResponseToLinkedAccount(lacct);

        // Map Linked By Attributes
        if (lacct.linked_by != null)
        {
            lacctSo = mapLinkedByInfoDOToSO(lacctSo, lacct.linked_by);
        }

        return lacctSo;
    }

    private static Linked_Account__c mapResponseToLinkedAccount(LinkedAccountDO lacct)
    {
        Linked_Account__c acct = new Linked_Account__c();
        acct.Full_Name__c = lacct.full_name;
        acct.Account_Number__c = lacct.account_number;
        acct.Account_Number_Encrypted__c = lacct.payer_id;
        acct.Account_Type__c = lacct.account_type;
        acct.Account_Created_Time__c = lacct.create_time;
        acct.Account_Status__c = lacct.account_status;
        acct.Has_Strong_Link__c = lacct.strongly_connected;

        // Guest/Wax account
        if (String.isNotBlank(lacct.registration_type))
        {
            // Registration type 'FULL' indicates that the account is properly registered PayPal Account
            // Anything else can be treated as unregistered - which is GUEST or ANONYMOUS
            if (!lacct.registration_type.equalsIgnoreCase('full'))
            {
                acct.Is_Unregistered__c = true;
                acct.Unregistered_Account_Type__c = lacct.registration_type;
            }
        }
        
        return acct;
    }

    private static LinkedAccountSO mapLinkedByInfoDOToSO(LinkedAccountSO lacctSo, LinkedByInfoDO linked_by)
    {
        // Linked By Name
        lacctSo.attributes.add(mapLinkedByNameDOToSO(linked_by.name));

        // Linked by email
        if ((linked_by.emails != null) && (linked_by.emails.size() != 0))
        {
            for (LinkedByEmailDO email : linked_by.emails)
            {
                lacctSo.attributes.add(mapLinkedByEmailDOToSO(email));
            }
        }

        // Linked By Phone
        if ((linked_by.phones != null) && (linked_by.phones.size() != 0))
        {
            for (LinkedByPhoneDO phone : linked_by.phones)
            {
                lacctSo.attributes.add(mapLinkedByPhoneDOToSO(phone));
            }
        }

        // Linked By Address
        if ((linked_by.addresses != null) && (linked_by.addresses.size() != 0))
        {
            for (LinkedByAddressDO address : linked_by.addresses)
            {
                lacctSo.attributes.add(mapLinkedByAddressDOToSO(address));
            }
        }

        // Linked By Financial Instrument
        if ((linked_by.financial_instruments != null) && (linked_by.financial_instruments.size() != 0))
        {
            for (LinkedByFinancialInstrumentDO fi : linked_by.financial_instruments)
            {
                lacctSo.attributes.add(mapLinkedByFinancialInstrumentDOToSO(fi));
            }
        }

        return lacctSo;
    }

    private static LinkedAccountAttributeSO mapLinkedByNameDOToSO(LinkedByNameDO name)
    {
        LinkedAccountAttributeSO lattrSO = new LinkedAccountAttributeSO();
        lattrSO.attribute.Name = 'Name';
        lattrSO.attribute.Attribute_Value__c = name.full_name;
        lattrSO.attribute.Has_Strong_Link__c = name.strongly_connected;

        return lattrSO;
    }

    private static LinkedAccountAttributeSO mapLinkedByEmailDOToSO(LinkedByEmailDO email)
    {
        LinkedAccountAttributeSO lattrSO = new LinkedAccountAttributeSO();
        lattrSO.attribute.Name = 'Email';
        lattrSO.attribute.Has_Strong_Link__c = email.strongly_connected;

        if (email.email != null)
        {
            Contact_Email__c emailObj = ProfileEmailAPI.mapEmailDOToContactEmail(email.email);
            lattrSO.attribute.Attribute_Value__c = emailObj.Email_Address__c;
            lattrSO.attribute.Response_JSON__c = JSON.serialize(emailObj);
            lattrSO.email = emailObj;
        }

        return lattrSO;
    }

    private static LinkedAccountAttributeSO mapLinkedByPhoneDOToSO(LinkedByPhoneDO phone)
    {
        LinkedAccountAttributeSO lattrSO = new LinkedAccountAttributeSO();
        lattrSO.attribute.Name = 'Phone';
        lattrSO.attribute.Has_Strong_Link__c = phone.strongly_connected;

        if (phone.phone != null)
        {
            Contact_Phone__c phoneObj = ProfilePhoneAPI.mapPhoneDOToContactPhone(phone.phone);
            lattrSO.attribute.Attribute_Value__c = phoneObj.Phone_Number__c;
            lattrSO.attribute.Response_JSON__c = JSON.serialize(phoneObj);
            lattrSO.phone = phoneObj;
        }

        return lattrSO;
    }

    private static LinkedAccountAttributeSO mapLinkedByAddressDOToSO(LinkedByAddressDO address)
    {
        LinkedAccountAttributeSO lattrSO = new LinkedAccountAttributeSO();
        lattrSO.attribute.Name = 'Address';
        lattrSO.attribute.Has_Strong_Link__c = address.strongly_connected;

        if (address.address != null)
        {
            Contact_Address__c addressObj = ProfileAddressAPI.mapAddressDOToContactAddress(address.address);
            lattrSO.attribute.Attribute_Value__c = addressObj.Address_Line_1__c;
            lattrSO.attribute.Response_JSON__c = JSON.serialize(addressObj);
            lattrSO.address = addressObj;
        }

        return lattrSO;
    }

    private static LinkedAccountAttributeSO mapLinkedByFinancialInstrumentDOToSO(LinkedByFinancialInstrumentDO fi)
    {
        LinkedAccountAttributeSO lattrSO = new LinkedAccountAttributeSO();
        lattrSO.attribute.Has_Strong_Link__c = fi.strongly_connected;

        if (fi.financial_instrument != null)
        {
            // TBD - Based on the Wallet fields and values finalization, we need to re-visit what will be
            // returned here and how to map it properly to use.
            Account_Wallet__c fiObj = WalletAPI.mapFinancialInstrumentDOToSO(fi.financial_instrument);
            lattrSO.attribute.Name = fiObj.Financial_Instrument_Type__c;
            lattrSO.attribute.Attribute_Value__c = fiObj.Last_4_digits__c;
            lattrSO.attribute.Response_JSON__c = JSON.serialize(fiObj);
            lattrSO.financialInstrument = fiObj;
        }

        return lattrSO;
    }

    public static LinkedAccountAttributeSO mapLinkedAccountAttributeObjToSO(Linked_Account_Attributes__c attr)
    {
        LinkedAccountAttributeSO lattrSO = new LinkedAccountAttributeSO();
        lattrSO.attribute = attr;
        
        if (attr.Name.equalsIgnoreCase('Email') && String.isNotBlank(attr.Response_JSON__c))
        {
            try {
                lattrSO.email = (Contact_Email__c) JSON.deserialize(attr.Response_JSON__c, Contact_Email__c.class);
            } catch (Exception e) {
                System.debug(LoggingLevel.ERROR, 'Failed to deserialize Linked by Email JSON response. Id - ' + attr.Id + ', Message - ' + e.getMessage());
            }
        }
        else if (attr.Name.equalsIgnoreCase('Phone') && String.isNotBlank(attr.Response_JSON__c))
        {
            try {
                lattrSO.phone = (Contact_Phone__c) JSON.deserialize(attr.Response_JSON__c, Contact_Phone__c.class);
            } catch (Exception e) {
                System.debug(LoggingLevel.ERROR, 'Failed to deserialize Linked by Phone JSON response. Id - ' + attr.Id + ', Message - ' + e.getMessage());
            }
        }
        else if (attr.Name.equalsIgnoreCase('Address') && String.isNotBlank(attr.Response_JSON__c))
        {
            try {
                lattrSO.address = (Contact_Address__c) JSON.deserialize(attr.Response_JSON__c, Contact_Address__c.class);
            } catch (Exception e) {
                System.debug(LoggingLevel.ERROR, 'Failed to deserialize Linked by Address JSON response. Id - ' + attr.Id + ', Message - ' + e.getMessage());
            }
        }
        else if (String.isNotBlank(attr.Response_JSON__c))
        {
            // The only other possibility is financial instrument, so lets try it
            try {
                lattrSO.financialInstrument = (Account_Wallet__c) JSON.deserialize(attr.Response_JSON__c, Account_Wallet__c.class);
            } catch (Exception e) {
                System.debug(LoggingLevel.ERROR, 'Failed to deserialize Linked by Wallet JSON response. Id - ' + attr.Id + ', Message - ' + e.getMessage());
            }
        }

        return lattrSO;
    }

    private static void removeLinkedAccountsFromAccount(Account acct)
    {
        List<Linked_Account__c> laccts = queryLinkedAccountsFromAccount(acct.Id);
        System.debug('Removing existing linked accounts from the account. Number of records found - ' + laccts.size());
        if (laccts.size() > 0)
        {
            delete laccts;

            // Deleting the linked accounts will automatically delete all linked account attributes child object
            // because of the Master - Detail relationship
        }
        return;
    }

    private static List<Linked_Account__c> queryLinkedAccountsFromAccount(Id accountId)
    {
        return [SELECT Id, Account1__c FROM Linked_Account__c
                WHERE Account1__c=:accountId];
    }
    
}