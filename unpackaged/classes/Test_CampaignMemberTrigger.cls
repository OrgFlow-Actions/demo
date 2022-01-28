/*------------------------------------------------------------
Author: 		Ahmed LOUDRASSI (Salesforce) 2019-10-22
Description:   	Test Class for all CampaignMemberHelper methods.
History
20191022   Ahmed LOUDRASSI   Migrated CampMgmtCampaignMemberTrigger and CampMgmtCampaignMemberTrigger2 triggers. (#)
20191022   Ahmed LOUDRASSI   Migrated CampaignMember Workflows. (#)
------------------------------------------------------------*/
@isTest(seeAllData=false)
public class Test_CampaignMemberTrigger {

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
    public static void testUpdateCampaignMemberAccount() {
        User testUser = [SELECT Id FROM User WHERE Alias = 'test1' LIMIT 1];
        List<Account> accountsList = TestDataFactory.createAccounts(1, 'Non_ERP_Account', testUser.Id);
        List<Contact> contactList = TestDataFactory.returnContacts(1, 'Contact_D', testUser.Id);
        contactList.get(0).AccountId = accountsList.get(0).Id;
        insert contactList;
        List<Campaign> campaignList = TestDataFactory.createCampaigns(1, 'DNA_Campaign', testUser.Id);
        List<CampaignMember> campaignMembertList = TestDataFactory.returnCampaignMembers(1);

        campaignMembertList.get(0).ContactId = contactList.get(0).Id;
        campaignMembertList.get(0).CampaignId = campaignList.get(0).Id;

        Test.startTest();
        insert campaignMembertList;
        Test.stopTest();
        System.assertEquals(accountsList.get(0).Id, [SELECT ID, Account__c FROM  CampaignMember LIMIT 1].Account__c);
    }

    @isTest
    public static void testUpdateCampaignAndAccountIdCMList() {
        User testUser = [SELECT Id FROM User WHERE Alias = 'test1' LIMIT 1];
        List<Account> accountsList = TestDataFactory.createAccounts(1, 'Non_ERP_Account', testUser.Id);

        List<Contact> contactList = TestDataFactory.returnContacts(1, 'Contact_D', testUser.Id);
        contactList.get(0).AccountId = accountsList.get(0).Id;
        insert contactList;

        accountsList.get(0).ContactCampaignIdList__c = contactList.get(0).Id;
        update accountsList;

        List<Campaign> campaignList = TestDataFactory.returnCampaigns(1, 'DNA_Campaign', testUser.Id);
        campaignList.get(0).CampaignMemberAccountIdList__c = accountsList.get(0).Id;
		insert campaignList;

        List<CampaignMember> campaignMembertList = TestDataFactory.returnCampaignMembers(1);
        campaignMembertList.get(0).ContactId = contactList.get(0).Id;
        campaignMembertList.get(0).CampaignId = campaignList.get(0).Id;
		campaignMembertList.get(0).Status = 'Confirmed';
        campaignMembertList.get(0).Type__c = 'Participant';

        Test.startTest();
        insert campaignMembertList;
        Test.stopTest();
    }

    @isTest
    public static void testUpdateCampaignMembersInfo() {
        User testUser = [SELECT Id FROM User WHERE Alias = 'test1' LIMIT 1];
        List<Account> accountsList = TestDataFactory.createAccounts(1, 'Non_ERP_Account', testUser.Id);
        List<Contact> contactList = TestDataFactory.returnContacts(4, 'Contact_D', testUser.Id);
        contactList.get(0).AccountId = accountsList.get(0).Id;
        insert contactList;
        List<Campaign> campaignList = TestDataFactory.returnCampaigns(4, 'DI_Campaign', testUser.Id);
        for(Campaign cm : campaignList) {
            cm.SBU_Focus__c = 'Implants';
        }
        insert campaignList;
        List<CampaignMember> campaignMembertList = TestDataFactory.returnCampaignMembers(4);

        // WF-CAMM-01 : 'Set Account Strategy and W/L status'
		campaignMembertList.get(0).ContactId = contactList.get(0).Id;
        campaignMembertList.get(0).CampaignId = campaignList.get(0).Id;

        // WF-CAMM-02 : 'Set DI Campaign Member Info Based On Campaign'
        campaignMembertList.get(1).ContactId = contactList.get(1).Id;
        campaignMembertList.get(1).CampaignId = campaignList.get(1).Id;
        campaignMembertList.get(1).Type__c = 'Participant';

        campaignMembertList.get(2).ContactId = contactList.get(2).Id;
        campaignMembertList.get(2).CampaignId = campaignList.get(2).Id;
        campaignMembertList.get(2).Type__c = 'Participant';
        campaignMembertList.get(2).of_Guests_including_participant__c = 'Single Room';

        campaignMembertList.get(3).ContactId = contactList.get(3).Id;
        campaignMembertList.get(3).CampaignId = campaignList.get(3).Id;
        campaignMembertList.get(3).Type__c = 'Participant';
        campaignMembertList.get(3).of_Guests_including_participant__c = 'Double Room';

        Test.startTest();
        insert campaignMembertList;
        Test.stopTest();
    }

    @isTest
    public static void testetInternationalSpeaker() {
        User testUser = [SELECT Id FROM User WHERE Alias = 'test1' LIMIT 1];
        List<Account> accountsList = TestDataFactory.createAccounts(1, 'Non_ERP_Account', testUser.Id);
        List<Contact> contactList = TestDataFactory.returnContacts(1, 'Contact_D', testUser.Id);
        contactList.get(0).AccountId = accountsList.get(0).Id;
        contactList.get(0).International_Speaker__c = true;
        insert contactList;
        List<Campaign> campaignList = TestDataFactory.createCampaigns(1, 'DNA_Campaign', testUser.Id);
        List<CampaignMember> campaignMembertList = TestDataFactory.returnCampaignMembers(1);

        campaignMembertList.get(0).ContactId = contactList.get(0).Id;
        campaignMembertList.get(0).CampaignId = campaignList.get(0).Id;

        Test.startTest();
        insert campaignMembertList;
        Test.stopTest();

        System.assertEquals(true, [SELECT Id, International_Speaker__c FROM CampaignMember LIMIT 1].International_Speaker__c);
    }
    
    @isTest
    public static void testCreateOpportunities(){
               
        User testUser = [SELECT Id FROM User WHERE Alias = 'test1' LIMIT 1];
        List<Account> accountsList = TestDataFactory.createAccounts(2, 'CIM_Account', testUser.Id);
        accountsList.get(1).OneAccount_Type__c = 'Distributor';
        accountsList.get(0).Country__c = 'DE';
        update accountsList;
        
        List<Contact> contactList = TestDataFactory.returnContacts(2, 'ContactGlobal', testUser.Id);
        contactList.get(0).AccountId = accountsList.get(0).Id;
        contactList.get(0).Email = 'test1.test@dentsplysirona.com.invalid';
        contactList.get(0).InsertEmailMarketingConsentCollected__c = 'No';
        contactList.get(1).AccountId = accountsList.get(1).Id;
        contactList.get(1).Email = 'test2.test@dentsplysirona.com.invalid';
        contactList.get(1).InsertEmailMarketingConsentCollected__c = 'No';
        insert contactList;
        
        List<AccountContactRelation> relations = [SELECT AccountId, ContactId, Specialty__c FROM AccountContactRelation WHERE AccountId =: accountsList.get(1).Id];
        
        for(AccountContactRelation rel : relations){
            rel.Specialty__c = 'Dealer Sales Rep (CEREC)';
        }
        update relations;
        
        List<Campaign> campaignList = TestDataFactory.returnCampaigns(1, 'Digital_Marketing_Campaign', testUser.Id);
        campaignList.get(0).Brands__c = 'Sinius';
        campaignList.get(0).Convert_To__c = 'Opportunity';
        campaignList.get(0).Include_In_Dealer_Community__c = 'Yes';
        insert campaignList;
        List<CampaignMember> campaignMembertList = TestDataFactory.returnCampaignMembers(1);

        campaignMembertList.get(0).ContactId = contactList.get(0).Id;
        campaignMembertList.get(0).CampaignId = campaignList.get(0).Id;
        campaignMembertList.get(0).Dealer__c = accountsList.get(1).Id;
        campaignMembertList.get(0).Status = 'Registered';
        
		Test.startTest();
        insert campaignMembertList;
        campaignMembertList.get(0).Status = 'Responded';
        update campaignMembertList;
        	
        Test.stopTest();        
        
    }
    
    @isTest
    public static void testCreateSalesLead(){
               
        User testUser = [SELECT Id FROM User WHERE Alias = 'test1' LIMIT 1];
        List<Account> accountsList = TestDataFactory.createAccounts(2, 'CIM_Account', testUser.Id);
        accountsList.get(1).OneAccount_Type__c = 'Distributor';
        accountsList.get(0).Country__c = 'US';
        update accountsList;
        
        List<Contact> contactList = TestDataFactory.returnContacts(2, 'ContactGlobal', testUser.Id);
        contactList.get(0).AccountId = accountsList.get(0).Id;
        contactList.get(0).Email = 'test1.test@dentsplysirona.com.invalid';
        contactList.get(0).InsertEmailMarketingConsentCollected__c = 'No';
        contactList.get(1).AccountId = accountsList.get(1).Id;
        contactList.get(1).Email = 'test2.test@dentsplysirona.com.invalid';
        contactList.get(1).InsertEmailMarketingConsentCollected__c = 'No';
        insert contactList;
        
        List<AccountContactRelation> relations = [SELECT AccountId, ContactId, Specialty__c FROM AccountContactRelation WHERE AccountId =: accountsList.get(1).Id];
        
        for(AccountContactRelation rel : relations){
            rel.Specialty__c = 'Dealer Sales Rep (CEREC)';
        }
        update relations;
        
        List<Campaign> campaignList = TestDataFactory.returnCampaigns(1, 'Digital_Marketing_Campaign', testUser.Id);
        campaignList.get(0).Brands__c = 'Sinius';
        campaignList.get(0).Convert_To__c = 'Sales Lead';
        insert campaignList;
        List<CampaignMember> campaignMembertList = TestDataFactory.returnCampaignMembers(1);

        campaignMembertList.get(0).ContactId = contactList.get(0).Id;
        campaignMembertList.get(0).CampaignId = campaignList.get(0).Id;
        campaignMembertList.get(0).Dealer__c = accountsList.get(1).Id;
        campaignMembertList.get(0).Status = 'Registered';
        
		Test.startTest();
        insert campaignMembertList;
        campaignMembertList.get(0).Status = 'Responded';
        update campaignMembertList;
        	
        Test.stopTest();        
        
    }
}