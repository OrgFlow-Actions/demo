/*-------------------------------------------------------------------------------------------------------
Author:         Kevin Ruibin Do (Salesforce) 20200617
Description:    Test class for OneDSCanadaSendEmailAction
History 
20200617        Kevin Ruibin Do - Created Class
--------------------------------------------------------------------------------------------------------*/

@IsTest(seeAllData=false)
public without sharing class Test_OneDSCanadaSendEmailAction {
    @TestSetup
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
            contactList[0].Email = 'test@test.test';
            contactList[0].InsertEmailMarketingConsentCollected__c = 'No';
            insert contactList;
    
            List<LoyaltyProgramParticipant__c> loyaltyPPList = new List<LoyaltyProgramParticipant__c>();
            loyaltyPPList.add(new LoyaltyProgramParticipant__c(
                Account__c = accountList[0].Id
                ,Contact__c = contactList[0].Id
            )); 
            insert loyaltyPPList;
        }
    }

    @isTest
    public static void testSendEmail() {
        User testUser = [SELECT Id FROM User WHERE Alias = 'test1' LIMIT 1];
        Contact testContact = [SELECT Id FROM Contact WHERE OwnerId =: testUser.Id];
        LoyaltyProgramParticipant__c loyaltyParticipant = [SELECT Id, Name, ExternalId__c FROM LoyaltyProgramParticipant__c WHERE CreatedById = :testUser.Id LIMIT 1];

        EmailTemplate testTemplate = new EmailTemplate();
        testTemplate.isActive = true;
        testTemplate.Name = 'Test Template';
        testTemplate.DeveloperName = 'test_template';
        testTemplate.TemplateType = 'text';
        testTemplate.FolderId = testUser.Id;
        insert testTemplate;

        List<OneDSCanadaSendEmailAction.EmailMessageResult> testEmailResultList = new List<OneDSCanadaSendEmailAction.EmailMessageResult>();
        OneDSCanadaSendEmailAction.EmailMessageRequest testEmailRequest = new OneDSCanadaSendEmailAction.EmailMessageRequest();

        testEmailRequest.emailTemplateDeveloperName = 'test_template';
        testEmailRequest.targetId = testContact.Id;
        testEmailRequest.whatId = loyaltyParticipant.Id;

        Test.startTest();
        System.runAs(testUser) {
            testEmailResultList = OneDSCanadaSendEmailAction.sendMail(new List<OneDSCanadaSendEmailAction.EmailMessageRequest>{ testEmailRequest });
        }
        Test.stopTest();
        System.assertEquals(true, testEmailResultList[0].success);
    }
}