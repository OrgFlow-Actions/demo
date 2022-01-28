/**
 * @description       : Test Class for EventMultiWhoController
 * @author            : kdoruibin@salesforce.com
 * @group             : 
 * @last modified on  : 12-09-2020
 * @last modified by  : kdoruibin@salesforce.com
 * Modifications Log 
 * Ver   Date         Author                     Modification
 * 1.0   12-09-2020   kdoruibin@salesforce.com   Initial Version
**/
@isTest(seeAllData=false)
public without sharing class Test_EventMultiWhoController {
    
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
    private static void testSearch() {
        User testUser = [SELECT Id FROM User WHERE Alias = 'test1' LIMIT 1];
        Contact testContact = [SELECT Id FROM Contact WHERE LastName LIKE 'Test%' LIMIT 1];
        Test.setFixedSearchResults(new List<Id>{testContact.Id});

        Test.startTest();
        System.assertEquals(1, EventMultiWhoController.search('test', new List<String>()).size());
        Test.stopTest();
    }

    @isTest
    private static void testGetContacts() {
        User testUser = [SELECT Id FROM User WHERE Alias = 'test1' LIMIT 1];
        Contact testContact = [SELECT Id FROM Contact WHERE LastName LIKE 'Test%' LIMIT 1];

        Test.startTest();
        System.assertEquals(1, EventMultiWhoController.getContacts(testContact.Id).size());
        Test.stopTest();
    }

    @isTest
    private static void testGetEventWhoIds() {
        User testUser = [SELECT Id FROM User WHERE Alias = 'test1' LIMIT 1];
        Event testEvent = [SELECT Id FROM Event WHERE OwnerId = :testUser.Id LIMIT 1];
        Contact testContact = [SELECT Id FROM Contact WHERE LastName LIKE 'Test%' LIMIT 1];

        Test.startTest();
        System.assertEquals(true, EventMultiWhoController.getEventWhoIds(testEvent.Id).size() > 0);
        Test.stopTest();
    }

    @isTest
    private static void testSetEventWhoIds() {
        User testUser = [SELECT Id FROM User WHERE Alias = 'test1' LIMIT 1];
        Event testEvent = [SELECT Id FROM Event WHERE OwnerId = :testUser.Id LIMIT 1];
        Contact testContact = [SELECT Id FROM Contact WHERE LastName LIKE 'Test%' LIMIT 1];

        Contact contactClone = testContact.clone();
        contactClone.LastName = 'Cloned Contact';
        insert contactClone;

        List<Id> contactIdList = new List<Id>();
        contactIdList.add(contactClone.Id);
        contactIdList.add(testContact.Id);

        Test.startTest();
        System.assertEquals(true, EventMultiWhoController.setEventWhoIds(testEvent.Id, contactIdList).size() > 0);
        Test.stopTest();
    }
}