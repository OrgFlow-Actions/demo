/**
 * @description       : Test class for CallReportQuickActionPocController
 * @author            : kdoruibin@salesforce.com
 * @group             : 
 * @last modified on  : 09-09-2021
 * @last modified by  : kdoruibin@salesforce.com
 * Modifications Log 
 * Ver   Date         Author                     Modification
 * 1.1   09-09-2021   kdoruibin@salesforce.com   added system.runAs()
 * 1.0   12-09-2020   kdoruibin@salesforce.com   Initial Version
**/
@isTest(seeAllData=false)
public without sharing class Test_CallReportQuickActionPocController {
    @testSetup
    private static void setup() {
        TestDataFactory.createBypassCustomSetting();
        List<User> userList = TestDataFactory.createUsers(1, 'System Administrator');
        List<User> userIntegrationList = TestDataFactory.insertIntegrationUsers(1, 'System Administrator');
        TestDataFactory.createGlobalIntegrationSettings(userIntegrationList);
        List<Event> eventList = TestDataFactory.returnEvents(1, userList.get(0).Id); 
        List<Account> accountsList = TestDataFactory.createAccounts(1, 'Non_ERP_Account', userList.get(0).Id);
        List<Contact> contactList = TestDataFactory.returnContacts(1, 'Contact_D', userList.get(0).Id);
        contactList.get(0).AccountId = accountsList.get(0).Id;
        insert contactList;
        eventList.get(0).WhoId = contactList.get(0).Id;
        insert eventList;
    }

    @isTest
    private static void testSetup() {
        Test.startTest();
        List<User> testUserList = [SELECT Id FROM User WHERE Alias = 'test1'];
        List<Account> testAccountList = [SELECT Id FROM Account WHERE Ownerid = :testUserList[0].Id];
        List<Contact> testContactList = [SELECT Id FROM Contact WHERE OwnerId = :testUserList[0].Id];
        Test.stopTest();
        
        System.assertEquals(1, testUserList.size(), 'Expected one User');
        System.assertEquals(1, testAccountList.size(), 'Expected one Account');
        System.assertEquals(1, testContactList.size(), 'Expected one Contact');
    }

    @isTest
    private static void testCreateEvent() {
        User testUser = [SELECT Id FROM User WHERE Alias = 'test1' LIMIT 1];
        Account testAccount = [SELECT Id FROM Account WHERE Ownerid = :testUser.Id LIMIT 1];
        Contact testContact = [SELECT Id FROM Contact WHERE Ownerid = :testUser.Id LIMIT 1];

        Call_Report__c callReportToInsert = new Call_Report__c(
            StartDateTime__c = Datetime.newInstance(2015, 20 , 12, 00, 00, 00)
            , EndDateTime__c = Datetime.newInstance(2015, 20 , 12, 01, 00, 00)
            , Call_Notes__c = 'test123'
            , EventWhoIds__c = '["' + testContact.Id + '"]'
        );
        
        Id createdEventId;
        Test.startTest();
        System.runAs(testUser) {
            insert callReportToInsert;
            createdEventId = CallReportQuickActionPocController.createEvent(callReportToInsert.Id, testContact.Id, 'Manager');
        }
        System.assertEquals(Schema.Event.SObjectType, createdEventId.getSobjectType());
        Test.stopTest();
    }
}