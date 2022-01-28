/**
 * @description       : Test class for RelatedRecordWidget_CC
 * @author            : kdoruibin@salesforce.com
 * @group             : 
 * @last modified on  : 12-09-2020
 * @last modified by  : kdoruibin@salesforce.com
 * Modifications Log 
 * Ver   Date         Author                     Modification
 * 1.0   12-09-2020   kdoruibin@salesforce.com   Initial Version
**/
@isTest(seeAllData=false)
public without sharing class Test_RelatedRecordWidget_CC {
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
        List<Event> testEventList = [SELECT Id FROM Event WHERE Ownerid = :testUserList[0].Id];
        Test.stopTest();
		
        System.assertEquals(1, testUserList.size(), 'Expected one User');
        System.assertEquals(1, testEventList.size(), 'Expected one Event');
    }

    @isTest
    private static void testGetEventReord() {
        User testUser = [SELECT Id FROM User WHERE Alias = 'test1' LIMIT 1];
        Event testEvent = [SELECT Id FROM Event WHERE OwnerId = :testUser.Id LIMIT 1];
        System.assertEquals(testEvent.Id, RelatedRecordWidget_CC.getEventRecord(testEvent.Id, 'Id').Id);
    }
}