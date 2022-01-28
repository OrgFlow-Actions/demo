/*-------------------------------------------------------------------------------------------------------
Author: 		Ahmed LOUDRASSI (Salesforce) 20191107
Description:   	Event Trigger Helper Class
History	
20211008 	kdoruibin			Added test testSetEventSubjectNoridcsUser()
20201209 	kdoruibin			Added tests testSetEventDescription(), testSetEventSubject()
20191107 	Ahmed LOUDRASSI     CallReportEventTrigger, CallReportEventTriggerAfterInsert, DC_EventBackgroundJobs an DeleteClonedChildEvent triggers. (#)
--------------------------------------------------------------------------------------------------------*/

@isTest(seeAllData=false)
public with sharing class Test_EventTrigger {
	/*-------------------------------------------------------------------------------------------------------
    Company: Salesforce
    Description: Setup one user for the test class
    History :
    --------------------------------------------------------------------------------------------------------*/
    @testSetup
    private static void setup() {
        TestDataFactory.createBypassCustomSetting();
        List<User> userList = TestDataFactory.createUsers(1, 'System Administrator');
        List<User> userIntegrationList = TestDataFactory.insertIntegrationUsers(1, 'System Administrator');
        TestDataFactory.createGlobalIntegrationSettings(userIntegrationList);
        TestDataFactory.createEvents(1, userList.get(0).Id); 
    }

    @isTest
    private static void testSetup() {
        Test.startTest();
        List<User> testUserList = [SELECT Id FROM User WHERE Alias = 'test1'];
        Test.stopTest();
		
        System.assertEquals(1, testUserList.size(), 'Expected one user');
    }
    @isTest
    private static void testCallReportEvent() {
        User testUser = [SELECT Id FROM User WHERE Alias = 'test1' LIMIT 1];
		List<Event> events = TestDataFactory.returnEvents(2, testUser.Id); 
        events.get(0).IsRecurrence = true;
        events.get(0).RecurrenceStartDateTime = System.today();
		events.get(0).RecurrenceEndDateOnly = System.today() + 30;
        events.get(0).RecurrenceType = 'RecursDaily';
        events.get(0).RecurrenceInterval = 1;
        Test.startTest();
        insert events;
        Test.stopTest();
        System.assertEquals(true, [SELECT Id FROM Call_Report__c].size() > 0);
    }
    @isTest
    private static void testCallReportEvent2() {
        User testUser = [SELECT Id FROM User WHERE Alias = 'test1' LIMIT 1];
        List<Account> accountsList = TestDataFactory.createAccounts(1, 'Non_ERP_Account', testUser.Id);
        List<Contact> contactList = TestDataFactory.returnContacts(1, 'Contact_D', testUser.Id);
        contactList.get(0).AccountId = accountsList.get(0).Id;
        insert contactList;
        
        List<Event> events = TestDataFactory.returnEvents(1, testUser.Id);
        events.get(0).WhoId = contactList.get(0).Id;
        events.get(0).Customer_Facing_Event__c = true;
        
        Test.startTest();
        insert events;
        Test.stopTest();
        System.assertEquals(accountsList.get(0).Id, [SELECT WhatId FROM Event WHERE Id =:events.get(0).Id ].WhatId);
    }
    @isTest
    private static void testManageNoticesOnEventsInserted() {
        User testUser = [SELECT Id FROM User WHERE Alias = 'test1' LIMIT 1];
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'Lightning_Sync'];
		insert new PermissionSetAssignment(AssigneeId = testUser.id, PermissionSetId = ps.Id);
        
		System.runAs(testUser) {
            List<Event> events = [SELECT Id, DurationInMinutes FROM Event];       
            Test.startTest();
            events.get(0).DurationInMinutes = 60;
            update events;
            Test.stopTest();
        }
        //System.assertEquals(1, [SELECT Id FROM Call_Report__c].size());
    }
    @isTest
    private static void testTrackBeforeDelete() {
		User testUser = [SELECT Id FROM User WHERE Alias = 'test1' LIMIT 1];
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'Lightning_Sync'];
		insert new PermissionSetAssignment(AssigneeId = testUser.id, PermissionSetId = ps.Id);

        System.runAs(testUser) {
            List<Event> events = TestDataFactory.createEvents(1, testUser.Id); 
            TestDataFactory.createEventAttendees(1, testUser.Id, events);
            Test.startTest();
            delete events;
            Test.stopTest();  
        }     
    }
    @isTest
    private static void testSetEventDescription() {
        User testUser = [SELECT Id FROM User WHERE Alias = 'test1' LIMIT 1];

        System.runAs(testUser) {
            List<Event> events = TestDataFactory.returnEvents(2, testUser.Id); 
            events.get(0).Customer_Facing_Event__c = true;
            insert events;
    
            List<Call_Report__c> callReportList = [SELECT Call_Notes__c FROM Call_Report__c];
            for (Call_Report__c callReport : callReportList) {
                callReport.Call_Notes__c = 'test123';
            }
            update callReportList;
    
            List<Event> eventList = [SELECT Id, Event_Status__c FROM Event];
            for (Event eventToComplete : eventList) {
                eventToComplete.Event_Status__c = 'Completed';
            }
            Test.startTest();
            update eventList;
            Test.stopTest();
        }

        for (Event eventToAssert : [SELECT Id, Description FROM Event WHERE CreatedBy.Alias = 'test1']) {
            System.assertEquals('test123', eventToAssert.Description);
        }
    }
    @isTest
    private static void testSetEventSubject() {
        User testUser = [SELECT Id FROM User WHERE Alias = 'test1' LIMIT 1];

        // Get active picklist values
        List<String> pickListValuesList= new List<String>();
        Schema.DescribeFieldResult fieldResult = Event.Astra_Tech_Type__c.getDescribe();
		List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
		for( Schema.PicklistEntry pickListVal : ple){
            if (pickListVal.isActive()) pickListValuesList.add(pickListVal.getValue());
		}     

        List<Account> accountsList = TestDataFactory.createAccounts(1, 'Non_ERP_Account', testUser.Id);
        List<Contact> contactList = TestDataFactory.returnContacts(1, 'Contact_D', testUser.Id);
        contactList.get(0).AccountId = accountsList.get(0).Id;
        insert contactList;
        
        List<Event> events = TestDataFactory.returnEvents(1, testUser.Id); 
        events.get(0).WhoId = contactList.get(0).Id;
        events.get(0).Customer_Facing_Event__c = true;
        events.get(0).Astra_Tech_Type__c = pickListValuesList.get(0);
        
        Test.startTest();
        System.runAs(testUser) {
            insert events;
        }
        Test.stopTest();

        List<Event> testEventList = [SELECT Id, Astra_Tech_Type__c, Who.Name, What.Name, Subject FROM Event WHERE Id = :events.get(0).Id];
        System.assertEquals(true, testEventList.get(0).Subject.contains(testEventList.get(0).Astra_Tech_Type__c));
        System.assertEquals(true, testEventList.get(0).Subject.contains(testEventList.get(0).Who.Name));
        System.assertEquals(true, testEventList.get(0).Subject.contains(testEventList.get(0).What.Name));
    }
    
    @isTest
    private static void testSetEventSubjectNordicsUser() {
        User testUser = TestDataFactory.returnUsers(1, 'System Administrator')[0];
        testUser.User_Country__c = 'Sweden';
        insert testUser;

        // Get active picklist values
        List<String> pickListValuesList= new List<String>();
        Schema.DescribeFieldResult fieldResult = Event.Astra_Tech_Type__c.getDescribe();
		List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
		for( Schema.PicklistEntry pickListVal : ple){
            if (pickListVal.isActive()) pickListValuesList.add(pickListVal.getValue());
		}     

        List<Account> accountsList = TestDataFactory.createAccounts(1, 'Non_ERP_Account', testUser.Id);
        List<Contact> contactList = TestDataFactory.returnContacts(1, 'Contact_D', testUser.Id);
        contactList.get(0).AccountId = accountsList.get(0).Id;
        insert contactList;
        
        List<Event> events = TestDataFactory.returnEvents(1, testUser.Id); 
        events.get(0).WhoId = contactList.get(0).Id;
        events.get(0).Customer_Facing_Event__c = true;
        events.get(0).Astra_Tech_Type__c = pickListValuesList.get(0);
        
        Test.startTest();
        System.runAs(testUser) {
            insert events;
        }
        Test.stopTest();

        List<Event> testEventList = [SELECT Id, Astra_Tech_Type__c, Who.Name, What.Name, Subject FROM Event WHERE Id = :events.get(0).Id];
        System.assertEquals(true, String.isBlank(testEventList.get(0).Subject));
    }
}