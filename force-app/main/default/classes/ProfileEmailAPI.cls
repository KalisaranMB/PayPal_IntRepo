public class ProfileEmailAPI {
    
    public static Customer360SO mapResponseToCustomer360SO(Customer360SO cx360SO, Customer360APIRequest request, Customer360APIResponse response)
    {
        System.debug('ProfileEmailAPI:mapResponseToCustomer360SO - Mapping Email Information');

        if (response.isProfileEmailsFailed() || (response.getCustomer360DO().profile == null) ||
           (response.getCustomer360DO().profile.emails == null) || (response.getCustomer360DO().profile.emails.size() == 0))
        {
            System.debug('Customer360 API response does not have any emails');
            return cx360SO;
        }

        for (EmailDO email : response.getCustomer360DO().profile.emails)
        {
            cx360SO.primaryUser.emails.add(mapEmailDOToContactEmail(email));
        }

        return cx360SO;
    }

    public static ProfileAPI.InsertToSOHelper storeResponseInSObject(ProfileAPI.InsertToSOHelper soHelper, Customer360APIRequest request, Customer360APIResponse response)
    {
        System.debug('ProfileEmailAPI:storeResponseInSObject - Storing Email Information into SObject');

        if (response.isProfileEmailsFailed())
        {
            System.debug('Customer360 API did not successfully load any emails');
            return soHelper;
        }

        List<EmailDO> emails = response.getCustomer360DO().profile.emails;

        if (emails != null)
        {
            for (EmailDO email : emails)
            {
                Contact_Email__c emailObj = mapEmailDOToContactEmail(email);
                emailObj.Contact__c = soHelper.ct.Id;
                soHelper.recordsToInsert.add(emailObj);
            }
        }

        // If it is not the new contact that we created now, we may have some old emails to be deleted
        if (!soHelper.newContact)
        {
            soHelper.recordsToDelete.addAll(soHelper.ct.Contact_Emails__r);
        }

        // If Emails are successfully loaded (NOT a failure or partial success), lets update the last loaded time
        if (response.isProfileEmailsSuccessfullyLoaded())
        {
            soHelper.ct.Email_Loaded_Time__c = Datetime.now();
        }

        return soHelper;
    }

    public static Contact_Email__c mapEmailDOToContactEmail(EmailDO email)
    {
        Contact_Email__c ctEmail = new Contact_Email__c();
        ctEmail.Domain_Identifier__c = email.unique_email_identifier;
        ctEmail.Email_Address__c = email.email_id;
        ctEmail.Status__c = email.status;
        ctEmail.Confirmation_Status__c = email.confirmation_status;
        ctEmail.Trust_Status__c = email.trust_status;
        ctEmail.Is_Primary__c = email.primary;

        ctEmail.Is_Active__c = false;
        ctEmail.Is_Confirmed__c = false;
        ctEmail.Is_Trusted__c = false;

        // Is Email Active?
        if (String.isNotBlank(email.status) && email.status.equalsIgnoreCase('active'))
        {
            ctEmail.Is_Active__c = true;
        }

        // Is Email Confirmed?
        if (String.isNotBlank(email.confirmation_status) && email.confirmation_status.equalsIgnoreCase('confirmed'))
        {
            ctEmail.Is_Confirmed__c = true;
        }

        // Is Email Trusted?
        if (String.isNotBlank(email.trust_status) && email.trust_status.equalsIgnoreCase('trusted'))
        {
            ctEmail.Is_Trusted__c = true;
        }

        return ctEmail;
    }
}