/**
 * @description       : Test class for CallReportTrigger
 * @author            : kdoruibin@salesforce.com
 * @group             : 
 * @last modified on  : 04-27-2021
 * @last modified by  : kdoruibin@salesforce.com
 * Modifications Log 
 * Ver   Date         Author                     Modification
 * 1.0   01-14-2021   kdoruibin@salesforce.com   Initial Version
**/
@IsTest
public without sharing class Test_CallReportTrigger {
    
    @TestSetup
    static void makeData(){
        TestDataFactory.createBypassCustomSetting();
        List<User> userList = TestDataFactory.createUsers(1, 'System Administrator');
        List<User> userIntegrationList = TestDataFactory.insertIntegrationUsers(1, 'System Administrator');
        TestDataFactory.createGlobalIntegrationSettings(userIntegrationList);
        TestDataFactory.createEvents(1, userList.get(0).Id); 
    }

    @IsTest
    private static void testSetup() {
        Test.startTest();
        List<User> testUserList = [SELECT Id FROM User WHERE Alias = 'test1'];
        Test.stopTest();
		
        System.assertEquals(1, testUserList.size(), 'Expected one user');
    }

    @IsTest
    private static void testSetEventSbu() {
        User testUser = [SELECT Id FROM User WHERE Alias = 'test1' LIMIT 1];

        Schema.DescribeFieldResult fieldResult = Call_Report__c.ProductGroup__c.getDescribe();
        

        System.runAs(testUser) {
            List<Event> events = TestDataFactory.returnEvents(2, testUser.Id); 
            events.get(0).Customer_Facing_Event__c = true;
            insert events;
    
            List<Call_Report__c> callReportList = [SELECT Call_Notes__c FROM Call_Report__c];
            for (Call_Report__c callReport : callReportList) {
                callReport.Call_Notes__c = 'test123';
                callReport.ProductGroup__c = 'Implants';
            }
            Test.startTest();
            update callReportList;
            Test.stopTest();
        }

        for (Event eventToAssert : [SELECT Id, SBU__c FROM Event WHERE CreatedBy.Alias = 'test1']) {
            System.assertEquals('Implants', eventToAssert.SBU__c);
        }
    }

    @IsTest
    private static void testSetEventDescription() {
        User testUser = [SELECT Id FROM User WHERE Alias = 'test1' LIMIT 1];

        System.runAs(testUser) {
            List<Event> events = TestDataFactory.returnEvents(2, testUser.Id); 
            events.get(0).Customer_Facing_Event__c = true;
            events.get(1).Customer_Facing_Event__c = true;
            insert events;
    
            List<Call_Report__c> callReportList = [SELECT Call_Notes__c FROM Call_Report__c];
            for (Call_Report__c callReport : callReportList) {
                callReport.Call_Notes__c = 'test123';
            }
            update callReportList;
            events.get(0).Event_Status__c = 'Completed';
            update events;
            Test.startTest();
            for (Call_Report__c callReport : callReportList) {
                callReport.Call_Notes__c = 'test1234';
            }
            update callReportList;
            Test.stopTest();
        }

        Integer eventsWithUpdatedDescription = 0;
        for (Event eventToAssert : [SELECT Id, Description FROM Event WHERE CreatedBy.Alias = 'test1']) {
            if (eventToAssert.Description == 'test1234') eventsWithUpdatedDescription++;
        }

        System.assertEquals(2, eventsWithUpdatedDescription);
    }
}