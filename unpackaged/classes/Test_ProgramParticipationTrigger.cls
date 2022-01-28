/*-------------------------------------------------------------------------------------------------------
Author:         Ahmed LOUDRASSI (Salesforce) 20191127
Description:    ProgramParticipation  Trigger Handler Class
History
20191127   Ahmed LOUDRASSI   Migrated   setProgramParticipationName trigger. (#)
----------------------------------------------------------------------------------------*/

@isTest(seeAllData=false)
public with sharing class Test_ProgramParticipationTrigger {
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
    private static void testSetProgramParticipationName() {
        User testUser = [SELECT Id FROM User WHERE Alias = 'test1' LIMIT 1];
        List<Account> accountsList = TestDataFactory.createAccounts(1, 'Non_ERP_Account', testUser.Id);
        List<Contact> contactList = TestDataFactory.returnContacts(1, 'Contact_D', testUser.Id);
        contactList.get(0).AccountId = accountsList.get(0).Id;
        insert contactList;
        List<Program__c> programs = TestDataFactory.createPrograms(1);
        List<Program_Participation__c> programParticipations = TestDataFactory.returnProgramParticipations(1, contactList, programs);
        
        Test.startTest();
        insert programParticipations;
        Test.stopTest();  
        Program_Participation__c programParticipation = [select Id, Name, SBU__c, Participation_Type__c from Program_Participation__c];
        System.assertEquals(programs.get(0).Name + '-' + 
                            programParticipation.SBU__c + '-' +
                            programParticipation.Participation_Type__c, programParticipation.Name);
    }
}