public with sharing class WidgetController {

    @AuraEnabled(cacheable=true)
    public static List<SObject> fetchWidgets(Id User, String SearchParam){
        if (String.isBlank(SearchParam)) {
            return [SELECT Id, Name, Tags__c, Icon__c, ObjectName__c, (SELECT User__c FROM Pins__r) FROM Widget__c WHERE Id IN (SELECT Widget__c FROM Pin__c WHERE User__c = :User)];
        }
        else {
            string param = '%' + SearchParam + '%';
            return [SELECT Id, Name, Tags__c, Icon__c, ObjectName__c, (SELECT User__c FROM Pins__r WHERE User__c = :User) FROM Widget__c WHERE Name LIKE :param OR Tags__c LIKE :param];
        }
    }

    @AuraEnabled(cacheable=false)
    public static Pin__c pinWidget(Id WidgetId, Id UserId){
        List<Pin__c> existingPin = [SELECT Id, Widget__c, User__c FROM Pin__c WHERE Widget__c = :WidgetID AND User__c = :UserID ORDER BY Id];
        if(existingPin.size()>0 ){
            System.debug('Return existing pin');
            return existingPin[0];
        }
        else {
            Pin__c pin = new Pin__c(Widget__c = WidgetID, User__c = UserID);
        	insert pin;
            System.debug('Return new pin');
        	return pin;
        }
    }

    @AuraEnabled(cacheable=false)
    public static void unpinWidget(Id WidgetId, Id UserId){
        List<Pin__c> existingPin = [SELECT Id, Widget__c, User__c FROM Pin__c WHERE Widget__c = :WidgetID AND User__c = :UserID ORDER BY Id];
        if(existingPin.size()>0 ){
            System.debug('Removing existing pin');
            delete existingPin;
        }
        return;
    }

    @AuraEnabled(cacheable=true)
    public static List<SObject> fetchAllWidgets(Id User){
        return [SELECT Id, Name, Tags__c, Icon__c, ObjectName__c, (SELECT User__c FROM Pins__r WHERE User__c = :User) FROM Widget__c];
    }
}