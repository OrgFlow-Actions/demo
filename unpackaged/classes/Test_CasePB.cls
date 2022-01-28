/*------------------------------------------------------------
Author: 		Ahmed LOUDRASSI (Salesforce) 2019-11-28
Description:   	Test Class for the Case Process Builder.
History
<Date>      <Authors Name>     <Brief Description of Change>

------------------------------------------------------------*/

@isTest(seeAllData=false)
public class Test_CasePB {
	/*-------------------------------------------------------------------------------------------------------
    Company: Salesforce
    Description: Setup one user for the test class
    History :
    --------------------------------------------------------------------------------------------------------*/
    @testSetup
    private static void setup() {
        TestDataFactory.createBypassCustomSetting();
        List<User> userList = TestDataFactory.createUsers(1, 'System Administrator');
    }
    @isTest
    private static void testSetup() {
        Test.startTest();
        List<User> testUserList = [SELECT Id FROM User WHERE Alias = 'test1'];
        Test.stopTest();

        System.assertEquals(1, testUserList.size(), 'Expected one user');
    }
    @isTest
    private static void testAssignToEqualsMe() {
       	User testUser = [SELECT Id FROM User WHERE Alias = 'test1'];
        List<Case> cases = TestDataFactory.returnCases(1, 'Credits_and_Re_bills', testUser.Id);
        cases.get(0).User_Country__c = 'Germany';
        cases.get(0).Assign_To__c = 'Me';
        Test.startTest();
        insert cases;
        Test.stopTest(); 
        Case testCase = [SELECT Id, OwnerId, Assign_To__c FROM Case WHERE Subject = 'TestCase'];
        System.assertEquals(null, testCase.Assign_To__c);
        System.assertEquals(UserInfo.getUserId(), testCase.OwnerId);
    }
    @isTest
    private static void testAssignToEqualsPreviousOwner() {
       	User testUser = [SELECT Id FROM User WHERE Alias = 'test1'];
        List<Case> cases = TestDataFactory.returnCases(1, 'Credits_and_Re_bills', testUser.Id);
        cases.get(0).User_Country__c = 'Germany';
        cases.get(0).Assign_To__c = 'Previous Owner';
        Test.startTest();
        insert cases;
        Test.stopTest();
        System.assertEquals(null, [SELECT Id, Assign_To__c FROM Case WHERE Subject = 'TestCase'].Assign_To__c);
    }
    @isTest
    private static void testE2CSupportEmail() {
        System.runAs(new User(Id = UserInfo.getUserId())) {
            List<Group> queues = TestDataFactory.createQueues(1, 'Case');
            Group queue = queues.get(0);
            User testUser = [SELECT Id FROM User WHERE Alias = 'test1'];
            List<Case> cases = TestDataFactory.returnCases(1, 'Credits_and_Re_bills', queue.Id);
            cases.get(0).Origin = 'Support email';
            Test.startTest();
            insert cases;
            Test.stopTest();
            //System.assertEquals(queue.Name, [SELECT Id, Support_Email__c FROM Case WHERE Subject = 'TestCase'].Support_Email__c);
        }
    }
}