@isTest
public with sharing class WidgetControllerTest {
    @isTest static void testFetchWidgets(){
      Id userId = createTestUser();
      Id widgetId = createTestWidget();
      Pin__c pin = WidgetController.pinWidget(widgetId, userId);
      SObject testWidget = [SELECT Id, Name, Tags__c, Icon__c, ObjectName__c FROM Widget__c WHERE Id = :widgetId];
      List<SObject> test1 = WidgetController.fetchWidgets(userId,'');
      List<SObject> test2 = WidgetController.fetchWidgets(userId,'TestWidget');
      System.assertEquals(1, test1.size(), 'FetchWidgets should return 1 record');
      System.assertEquals(testWidget.Id, test1[0].Id, 'FetchWidgets should contain test widget');
      System.assertEquals(1, test2.size(), 'FetchWidgets should return 1 record when searching for "TestWidget"');      
      System.assertEquals(testWidget.Id, test2[0].Id, 'FetchWidgets should contain test widget when searching for "TestWidget"');
    }
    @isTest static void testPinWidget(){
      Id userId = createTestUser();
      Id widgetId = createTestWidget();

      //First pin
      Pin__c pin = WidgetController.pinWidget(widgetId, userId);
      System.assert(pin != null);
      System.assertEquals(widgetId, pin.Widget__c, 'The ID of the pinned widget should match');

      //Second pin
      Pin__c sPin = WidgetController.pinWidget(widgetId, userId);
      System.assert(sPin != null,'Pin should not be null');
      System.assertEquals(pin.Id, sPin.Id, 'First and second pins should match');
    }

    @isTest static void testUnpinWidget(){
      Id userId = createTestUser();
      Id widgetId = createTestWidget();

      //Confirm pin
      Pin__c pin = WidgetController.pinWidget(widgetId, userId);
      System.assert(pin != null);
      System.assertEquals(widgetId, pin.Widget__c, 'The ID of the pinned widget should match');

      //Confirm Unpin
      WidgetController.unpinWidget(WidgetId, UserId);

      //Confirm Unpin without pins
      WidgetController.unpinWidget(widgetId, userId);
    }

    @isTest static void testFetchAllWidgets(){
      Id userId = createTestUser();
      Id widgetId = createTestWidget();
      List<SObject> w = WidgetController.fetchAllWidgets(userId);
      System.assert(w.size() > 0,'FetchAllWidgets should have rows');
    }



    // Helper methods
    static Id createTestWidget() {
      Widget__c w = new Widget__c(Name='TestWidget');
      insert w;
      return w.Id;
    } 
    static Id createTestUser() {
      Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
      User u = new User(Alias='Testing', Email='WidgetController@salesforce.com', 
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', ProfileId = p.Id, 
        TimeZoneSidKey='America/Chicago', UserName='WidgetController@salesforce.com'); 
      insert u;
      return u.Id;
    } 
}