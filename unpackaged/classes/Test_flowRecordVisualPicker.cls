/*-------------------------------------------------------------------------------------------------------
Author:         Kevin Ruibin Do (Salesforce) 200918
Description:    Test class for flow_recordVisualPickerController
History 
200918        Kevin Ruibin Do - Created Class
--------------------------------------------------------------------------------------------------------*/

@IsTest(seeAllData=false)
public without sharing class Test_flowRecordVisualPicker {
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
    
            List<Contact> contactList = TestDataFactory.returnContacts(2, 'ContactGlobal', userList[0].Id);

            for (Contact contact : contactList) {
                contact.AccountId = accountList[0].Id;
                contact.Preferred_Language__c = 'English';
                contact.Email = 'test@test.test';
                contact.InsertEmailMarketingConsentCollected__c = 'No';
                contact.Primary_Contact__c = false;
            }
            contactList[0].Primary_Contact__c = true;

            insert contactList;
        }
    }

    @IsTest
    private static void testGetRelatedContacts() {
        User testUser = [SELECT Id FROM User WHERE Alias = 'test1' LIMIT 1];
        Account testAccount = [SELECT Id FROM Account WHERE OwnerId = :testUser.Id LIMIT 1];

        List<Contact> testContactList = flowRecordVisualPickerController.getRelatedContacts(testAccount.Id);

        // Assert that only non-primary contacts are retrieved
        System.assertEquals(1, testContactList.size());
    }
}