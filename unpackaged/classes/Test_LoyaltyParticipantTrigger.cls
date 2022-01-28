/*-------------------------------------------------------------------------------------------------------
Author:         Kevin Ruibin Do (Salesforce) 20200908
Description:    Test class for LoyaltyProgramParticipant trigger methods
History 
20200908        Kevin Ruibin Do - Created Class
--------------------------------------------------------------------------------------------------------*/

@IsTest(seeAllData=false)
public class Test_LoyaltyParticipantTrigger {
    @testSetup
    static void makeData(){
        TestDataFactory.createBypassCustomSetting();
        List<User> userList = TestDataFactory.returnUsers(1, 'System Administrator');
        userList[0].User_Country__c = 'Canada';
        insert userList;
        TestDataFactory.createGlobalIntegrationSettings(userList);
        TestDataFactory.createDefaultOrgLevelBypassPB();

        // Setup Account, Contact, and LoyaltyProgramParticipant__c
        System.runAs(userList[0]) {
            List<Account> accountList = TestDataFactory.returnAccounts(1, 'CIM_Account', userList[0].Id);
            insert accountList;
    
            List<Contact> contactList = TestDataFactory.returnContacts(1, 'ContactGlobal', userList[0].Id);
            contactList[0].Preferred_Language__c = 'English';
            insert contactList;
        }
    }

    @IsTest
    public static void testSetExternalId() {
        User testUser = [SELECT Id FROM User WHERE Alias = 'test1' LIMIT 1];
        Account testAccount = [SELECT Id FROM Account WHERE OwnerId = :testUser.Id LIMIT 1];
        Contact testContact = [SELECT Id FROM Contact WHERE OwnerId = :testUser.Id LIMIT 1];

        Test.startTest();
        System.runAs(testUser) {
            LoyaltyProgramParticipant__c testParticipant = new LoyaltyProgramParticipant__c(
                Account__c = testAccount.Id
                ,Contact__c = testContact.Id
            );
            insert testParticipant;
        }
        Test.stopTest();

        System.assert(String.isNotEmpty([SELECT ExternalId__c FROM LoyaltyProgramParticipant__c WHERE CreatedById = :testUser.Id LIMIT 1].ExternalId__c), 'External Id was not set');
    }
}