/*-------------------------------------------------------------------------------------------------------
Author:         Ahmed LOUDRASSI (Salesforce) 20191127
Description:    Expert  Trigger Handler Class
History
20191127   Ahmed LOUDRASSI   Migrated   setExpertName trigger. (#)
----------------------------------------------------------------------------------------*/

@isTest(seeAllData=false)
public with sharing class Test_ExpertTrigger {
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
    private static void testSetExpertName() {
        	User testUser = [SELECT Id FROM User WHERE Alias = 'test1' LIMIT 1];
        	List<Account> accountsList = TestDataFactory.createAccounts(1, 'Non_ERP_Account', testUser.Id);
            List<Contact> contactList = TestDataFactory.returnContacts(1, 'Contact_D', testUser.Id);
            contactList.get(0).AccountId = accountsList.get(0).Id;
            insert contactList;
            List<Expert__c> experts = TestDataFactory.returnExperts(1, contactList);	
        	Test.startTest();
        	insert experts;
        	Test.stopTest();
            Expert__c expert  = [select Id, Name from Expert__c];
            System.assertEquals(true, expert.Name.contains('- KOL info'));  
    }
}