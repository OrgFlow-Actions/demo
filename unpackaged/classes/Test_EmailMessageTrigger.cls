/*------------------------------------------------------------
Author: 		LOUDRASSI Ahmed (Salesforce) 2019-12-18
Description:   	Test Class for all EmailMessageTriggerHelper methods.
History
------------------------------------------------------------*/

@isTest(seeAllData=false)
public class Test_EmailMessageTrigger {

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
    }
    @isTest
    private static void testSetup() {
        Test.startTest();
        List<User> testUserList = [SELECT Id FROM User WHERE Alias = 'test1'];
        Test.stopTest();
        System.assertEquals(1, testUserList.size(), 'Expected one user');
    }
    @isTest
    private static void testPreventDeleteEmailMessagesSuccess() {
        User testUser = [SELECT Id FROM User WHERE Alias = 'test1'];
        List<Case> cases = TestDataFactory.createCases(1, 'Credits_and_Re_bills', testUser.Id);
        List<EmailMessage> emailMessages = TestDataFactory.returnEmailMessages(3, cases);
        insert emailMessages;
        Test.startTest();
        try {
            delete emailMessages;
        } catch (Exception e) {
            System.assertEquals(true, e.getMessage().contains(Label.PreventDeleteEmailMessage));
        }
        Test.stopTest();
        System.assertEquals(3, [SELECT Id FROM EmailMessage].size());
    }
    @isTest
    private static void testPreventDeleteEmailMessagesFailed() {
        User testUser = [SELECT Id FROM User WHERE Alias = 'test1'];
        List<Case> cases = TestDataFactory.createCases(1, 'Credits_and_Re_bills', testUser.Id);
        List<EmailMessage> emailMessages = TestDataFactory.returnEmailMessages(1, cases);
        emailMessages.get(0).RelatedToId = null;
        insert emailMessages;
        Test.startTest();
        try {
            delete emailMessages;
        } catch (Exception e) {
            System.assertEquals(true, e.getMessage().contains(Label.PreventDeleteEmailMessage));
        }
        Test.stopTest();
        System.assertEquals(0, [SELECT Id FROM EmailMessage].size());
    }
}