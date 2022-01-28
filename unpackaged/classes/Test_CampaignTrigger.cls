/*-------------------------------------------------------------------------------------------------------
Author:         Ahmed LOUDRASSI (Salesforce) 20191028
Description:    Campaign  Trigger Helper Class
History
20191028   Ahmed LOUDRASSI   Migrated  CampMgmtCampaignSessionTrigger, CampMgmtCampaignTrigger, CampMgmtCampaignTrigger2, CampMgmtCampaignSharingTrigger triggers. (#)
----------------------------------------------------------------------------------------*/

@isTest(seeAllData=false)
public with sharing class Test_CampaignTrigger {
    /*-------------------------------------------------------------------------------------------------------
    Company: Salesforce
    Description: Setup one user for the test class
    History :
    --------------------------------------------------------------------------------------------------------*/
    @testSetup
    private static void setup() {
        TestDataFactory.createBypassCustomSetting();
        List<User> userList = TestDataFactory.createUsers(1, 'System Administrator');
        List<Campaign> campaignList1 = TestDataFactory.returnCampaigns(1, 'DI_Campaign', userList.get(0).Id);
        campaignList1.get(0).SBU_Focus__c = 'Implants';
        campaignList1.get(0).isActive = true;
        campaignList1.get(0).StartDate = Date.today();
        insert campaignList1;       	  
    }

    @isTest
    private static void testSetup() {
        Test.startTest();
        List<User> testUserList = [SELECT Id FROM User WHERE Alias = 'test1'];
        Test.stopTest();
		
        System.assertEquals(1, testUserList.size(), 'Expected one user');
    }
    @isTest
    public static void testSetCampaignSessionsDefaultValues() {
        User testUser = [SELECT Id FROM User WHERE Alias = 'test1' LIMIT 1];
        Campaign campaign = [SELECT Id FROM Campaign LIMIT  1];
        
        List<Campaign> campaignList1 = TestDataFactory.returnCampaigns(1, 'DI_Campaign_Session', testUser.Id);
        campaignList1.get(0).Parent_Event__c = campaign.Id;
        
        Test.startTest();
        insert campaignList1;
        Test.stopTest();
        
        System.assertEquals(Date.today(), [SELECT Id, Session_Start_Date_Time__c, RecordType.DeveloperName FROM Campaign 
                                           	WHERE Id =: campaignList1.get(0).Id LIMIT 1].Session_Start_Date_Time__c);
    }
    @isTest
    public static void testSetCampaignMemberStatus() {
        User testUser = [SELECT Id FROM User WHERE Alias = 'test1' LIMIT 1];
        List<Campaign> campaignList1 = TestDataFactory.returnCampaigns(1, 'DNA_Campaign', testUser.Id);
        List<Campaign> campaignList2 = TestDataFactory.returnCampaigns(1, 'DI_Mailing', testUser.Id);
        List<Campaign> campaignList3 = TestDataFactory.returnCampaigns(1, 'Inside_Sales_Campaign', testUser.Id);
        campaignList1.addAll(campaignList2);
        campaignList1.addAll(campaignList3);
        Test.startTest();
        insert campaignList1;
        Test.stopTest();
        //System.assertEquals('test', [SELECT Id, Label FROM CampaignMemberStatus WHERE CampaignId =: campaignList1.get(1).Id].Label);
        //System.assertEquals(8, [SELECT Id FROM CampaignMemberStatus WHERE CampaignId =: campaignList1.get(1).Id].size());
        //System.assertEquals(8, [SELECT Id FROM CampaignMemberStatus WHERE CampaignId =: campaignList1.get(2).Id].size());
    }
    @isTest
    public static void testDeactivateCampaignSessions() {
        User testUser = [SELECT Id FROM User WHERE Alias = 'test1' LIMIT 1];
        Campaign campaignParent = [SELECT Id FROM Campaign WHERE RecordType.DeveloperName = 'DI_Campaign'];        
        
        List<Campaign> campaignList1 = TestDataFactory.returnCampaigns(1, 'DI_Campaign_Session', testUser.Id);
        campaignList1.get(0).Parent_Event__c = campaignParent.Id;
        campaignList1.get(0).isActive = true;
        
        Test.startTest();
        insert campaignList1;
        campaignParent.isActive = false;
        update campaignParent;
        Test.stopTest();
        System.assertEquals(false, [SELECT Id, isActive FROM Campaign WHERE Id =: campaignList1.get(0).Id].isActive);
    }
    @isTest
    public static void testCampaignSharing() {
        User testUser = [SELECT Id FROM User WHERE Alias = 'test1' LIMIT 1];

        List<Campaign> campaignList1 = TestDataFactory.returnCampaigns(1, 'DI_Campaign', testUser.Id);
        campaignList1.get(0).SBU_Focus__c = 'Implants';
        campaignList1.get(0).Campaign_Approver__c = testUser.Id;
        Test.startTest();
        insert campaignList1;
        Test.stopTest();
        System.assertEquals(1, [SELECT Id FROM CampaignShare 
                                WHERE CampaignId =: campaignList1.get(0).Id AND UserOrGroupId =: testUser.Id].size());
    }
    @isTest
    public static void testsetCountryOnInsert() {
        User testUser = [SELECT Id FROM User WHERE Alias = 'test1' LIMIT 1];
        
        List<Campaign> campaignList1 = TestDataFactory.returnCampaigns(3, 'Digital_Marketing_Campaign', testUser.Id);
        campaignList1.get(0).Campaign_Country__c = 'France';
        campaignList1.get(1).Country_Code_3_digit__c = 'FRA';
        
        Test.startTest();
        insert campaignList1;
        Test.stopTest();
        
    }
    @isTest
    public static void testsetCountryOnUpdate() {
        User testUser = [SELECT Id FROM User WHERE Alias = 'test1' LIMIT 1];
        
        List<Campaign> campaignList1 = TestDataFactory.returnCampaigns(3, 'Digital_Marketing_Campaign', testUser.Id);
        insert campaignList1;
        campaignList1.get(0).Campaign_Country__c = 'France';
        campaignList1.get(1).Country_Code_3_digit__c = 'FRA';
        
        Test.startTest();
        update campaignList1;
        Test.stopTest();

    }
}