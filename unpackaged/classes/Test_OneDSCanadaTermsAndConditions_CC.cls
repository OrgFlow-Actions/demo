/*-------------------------------------------------------------------------------------------------------
Author:         Kevin Ruibin Do (Salesforce) 20200908
Description:    Test class for OneDSCanadaTermsAndConditions_CC
History 
20200908        Kevin Ruibin Do - Created Class
--------------------------------------------------------------------------------------------------------*/

@isTest(seeAllData=false)
public class Test_OneDSCanadaTermsAndConditions_CC {

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

            List<LoyaltyProgram__c> loyaltyProgramList = new List<Loyaltyprogram__c>();
            loyaltyProgramList.add(new LoyaltyProgram__c (
                Name = 'Apex Test'
            ));
            insert loyaltyProgramList;
    
            List<LoyaltyProgramParticipant__c> loyaltyPPList = new List<LoyaltyProgramParticipant__c>();
            loyaltyPPList.add(new LoyaltyProgramParticipant__c(
                LoyaltyProgram__c = loyaltyProgramList[0].Id
                ,Account__c = accountList[0].Id
                ,Contact__c = contactList[0].Id
            )); 
            insert loyaltyPPList;
        }
    }

    @isTest
    private static void testController() {
        User testUser = [SELECT Id FROM User WHERE Alias = 'test1' LIMIT 1];
        Contact testContact = [SELECT Id FROM Contact WHERE OwnerId =: testUser.Id];
        LoyaltyProgramParticipant__c loyaltyParticipant = [SELECT Id, Name, ExternalId__c FROM LoyaltyProgramParticipant__c WHERE CreatedById = :testUser.Id LIMIT 1];

        System.debug('debug::'+loyaltyParticipant);

        // Test the page
        Pagereference pageRef = Page.OneDSCanadaTermsAndConditions;
        Test.setCurrentPage(pageRef);
        // Add parameters to page URL
        ApexPages.currentPage().getParameters().put('Id', loyaltyParticipant.ExternalId__c);
        Datetime testDatetime = System.now();

        Test.startTest();
        OneDsCanadaTermsAndConditions_CC controller = new OneDsCanadaTermsAndConditions_CC();
        controller.firstName = 'Test FirstName';
        controller.lastName = 'Test LastName';
        controller.practiceName = 'Test PracticeName';
        controller.email = 'test@email.com';
        controller.hasAccepted = true;
        controller.accept();
        Test.stopTest();

        // Assert that fields were properly updated
        loyaltyParticipant = [SELECT FirstName__c, LastName__c, PracticeName__c, Email__c, AcceptedTermsAndConditions__c, TermsAndConditionsConsentDate__c, Contact__c FROM LoyaltyProgramparticipant__c WHERE Id = :loyaltyParticipant.Id];
        System.debug('loyaltyParticipant::'+loyaltyParticipant);

        System.assertEquals(null, controller.error);
        System.assertEquals(controller.firstName, loyaltyParticipant.FirstName__c);
        System.assertEquals(controller.lastName, loyaltyParticipant.LastName__c);
        System.assertEquals(controller.practiceName, loyaltyParticipant.PracticeName__c);
        System.assertEquals(controller.email, loyaltyParticipant.Email__c);
        System.assertEquals(controller.hasAccepted, loyaltyParticipant.AcceptedTermsAndConditions__c);
        System.assert(loyaltyParticipant.TermsAndConditionsConsentDate__c.isSameDay(testDatetime), 'Consent date was not set correctly on LoyaltyProgramParticipant__c');
        
        // Assert that Consent is properly updated
       /* Emails__c emailConsentRecord = [SELECT Id, Consent_Collection_Method__c, WhenCollected__c, WhereCollected__c FROM Emails__c WHERE Contact__c = :loyaltyParticipant.Contact__c ORDER BY CreatedDate DESC LIMIT 1];
        System.assertEquals('Digitally', emailConsentRecord.Consent_Collection_Method__c);
        // System.assertEquals('Yes', emailConsentRecord.Email_Marketing_Consent__c);
        System.assertEquals('Canada One DS Terms and Conditions Site', emailConsentRecord.WhereCollected__c);
        System.assert(emailConsentRecord.WhenCollected__c.isSameDay(testDatetime), 'Consent date was not set correctly on Contact');
    */}

    @IsTest
    private static void testControllerError() {
        // Test the page without providing any Id
        Pagereference pageRef = Page.OneDSCanadaTermsAndConditions;
        Test.setCurrentPage(pageRef);

        Test.startTest();
        OneDsCanadaTermsAndConditions_CC controller = new OneDsCanadaTermsAndConditions_CC();
        Test.stopTest();

        System.assertEquals(true, controller.error);
    }
}