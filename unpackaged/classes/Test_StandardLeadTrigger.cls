/*------------------------------------------------------------
Author: 		Richard Trum 2021-02-23
Description:   	Test Class for all StandardLeadTrigger methods.
History
20210223   Richard Trum   	Created trigger framework
------------------------------------------------------------*/
@isTest(seeAllData=false)
public class Test_StandardLeadTrigger {

    @testSetup
    private static void setup() {
        TestDataFactory.createBypassCustomSetting();
        List<User> userList = TestDataFactory.createUsers(1, 'System Administrator');
        List<User> userIntegrationList = TestDataFactory.insertIntegrationUsers(1, 'System Administrator');
        TestDataFactory.createGlobalIntegrationSettings(userIntegrationList);
    }

    @isTest
    private static void testUpdateCampaignMembers() {
        
        User testUser = [SELECT Id FROM User WHERE Alias = 'test1' LIMIT 1];
        List<Account> accountsList = TestDataFactory.createAccounts(1, 'CIM_Account', testUser.Id);
        accountsList.get(0).Country__c = 'US';
        update accountsList;
        
        Lead l = new Lead();        
        l.Email = 'test1.test@dentsplysirona.com.invalid';
        l.FirstName = 'Test';
        l.LastName = 'Test';
		l.Status = 'New';
        l.Company = 'Test Customer';
        insert l;
        
        List<Campaign> campaignList = TestDataFactory.returnCampaigns(1, 'Digital_Marketing_Campaign', testUser.Id);
        campaignList.get(0).Brands__c = 'Sinius';
        campaignList.get(0).Convert_To__c = 'Sales Lead';
        insert campaignList;
        List<CampaignMember> campaignMembertList = TestDataFactory.returnCampaignMembers(1);

        campaignMembertList.get(0).LeadId = l.Id;
        campaignMembertList.get(0).CampaignId = campaignList.get(0).Id;
        campaignMembertList.get(0).Status = 'Responded';
        insert campaignMembertList;
        
		Test.startTest();
        	
        	Database.LeadConvert lc = new Database.LeadConvert();
        	LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true LIMIT 1];
			lc.setConvertedStatus(convertStatus.MasterLabel);
        	lc.setAccountId(accountsList[0].Id);
        	lc.setDoNotCreateOpportunity(true);
        	lc.setLeadId(l.Id);
        	
        	//Convert lead
        	Database.LeadConvertResult lcr = Database.convertLead(lc, false);
        	
        Test.stopTest();        

    }    
}