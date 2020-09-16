public class ServiceLogAPI {
    
    public static Customer360SO mapResponseToCustomer360SO(Customer360SO cx360SO, Customer360APIRequest request, Customer360APIResponse response)
    {
        System.debug('ServiceLogAPI:mapResponseToCustomer360SO - mapping Service Log Notes Information');
        
        // Check if there are any failures in loading Service Log Notes
        if (response.isNotesFailed() || (response.getCustomer360DO().notes == null) ||
            (response.getCustomer360DO().notes.size() == 0))
        {
            System.debug('No Service Log Notes available in Customer360 API response');
            return cx360SO;
        }
        
        // Map Notes to the cx360SO object passed in the request
        for (NoteDO note : response.getCustomer360DO().notes)
        {
            cx360SO.notes.add(mapNoteDOToSO(note));
        }

        return cx360SO;
    }

    public static Account storeResponseInSObject(Account acct, Customer360APIRequest request, Customer360APIResponse response)
    {
        System.debug('ServiceLogAPI:storeResponseInSObject - Storing Notes into SObject');
        
        // Check if there are any failures in loading Notes
        if (response.isNotesFailed())
        {
            System.debug('Customer360 API did not successfully load Account Notes');
            return acct;
        }

        // Remove all existing Notes from the account
        removeNotesFromAccount(acct);

        List<NoteDO> notes = response.getCustomer360DO().notes;
        
        if ((notes != null) && (notes.size() > 0))
        {
            List<Account_Note__c> noteObjs = new List<Account_Note__c>();

            for (NoteDO note : notes)
            {
                Account_Note__c noteObj = mapNoteDOToSO(note);
                noteObj.Account__c = acct.Id;
                noteObjs.add(noteObj);
            }

            insert noteObjs;
        }

        // If Account Notes are successfully loaded (NOT a failure or partial success), update the cache time
        if (response.isNotesSuccessfullyLoaded())
        {
            acct.ServiceLog_Notes_Loaded_Time__c = Datetime.now();
        }

        return acct;
    }

    private static void removeNotesFromAccount(Account acct)
    {
        List<Account_Note__c> notes = queryNotesFromAccount(acct.Id);
        System.debug('Removing existing notes from the account. Number of records found - ' + notes.size());
        if (notes.size() > 0)
        {
            delete notes;
        }
        return;
    }

    private static Account_Note__c mapNoteDOToSO(NoteDO note)
    {
        Account_Note__c nt = new Account_Note__c();
        nt.Note_Id__c = note.note_id;
        nt.Time_Created__c = note.create_time;
        nt.Category__c = note.category;
        nt.Actor__c = note.actor;
        nt.Summary__c = note.summary;
        
        return nt;
    }

    private static List<Account_Note__c> queryNotesFromAccount(Id accountId)
    {
        return [SELECT Id, Account__c FROM Account_Note__c
                WHERE Account__c=:accountId];
    }
}