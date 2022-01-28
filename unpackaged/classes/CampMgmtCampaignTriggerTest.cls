//30-Jan-2019 added campaigntype: Inside Sales Campaign :Lightning Migration: amitkumar.prabhat@mindtree.com
//
@isTest
private class CampMgmtCampaignTriggerTest
{
    @TestSetup
    private static void setup() {
        TestDataFactory.createBypassCustomSetting();
        List<User> userList = TestDataFactory.returnUsers(1, 'System Administrator');
        userList.get(0).User_Country__c = 'Germany';
        insert userList;
        TestDataFactory.createGlobalIntegrationSettings(userList);
        TestDataFactory.createDefaultOrgLevelBypassPB();
    }
	// Related sessions are deactivated when campaign is deactivated.
	static testmethod void test01()
	{
		enableTrigger();

		Campaign campaign = CampMgmtTestHelpers.createTestCampaign('Test Campaign 1', 'DI_Campaign');
		Campaign session1 = CampMgmtTestHelpers.createTestSession(campaign.Id, 'Test Session 1', 'DI_Campaign_Session');
		Campaign session2 = CampMgmtTestHelpers.createTestSession(campaign.Id, 'Test Session 2', 'DI_Campaign_Session');

		campaign = [SELECT Id, IsActive FROM Campaign WHERE Id = :campaign.Id];
		session1 = [SELECT Id, IsActive FROM Campaign WHERE Id = :session1.Id];
		session2 = [SELECT Id, IsActive FROM Campaign WHERE Id = :session2.Id];

		System.assertEquals(true, campaign.IsActive);
		System.assertEquals(true, session1.IsActive);
		System.assertEquals(true, session2.IsActive);

		campaign.IsActive = false;
		update campaign;

		session1 = [SELECT Id, IsActive FROM Campaign WHERE Id = :session1.Id];
		session2 = [SELECT Id, IsActive FROM Campaign WHERE Id = :session2.Id];

		System.assertEquals(false, session1.IsActive);
		System.assertEquals(false, session2.IsActive);
	}
    
	// Correct campaign member status values are created for created 'DI_Mailing' campaigns.
	static testmethod void test02()
	{
		enableTrigger();

		Campaign campaign = CampMgmtTestHelpers.createTestCampaign('Test Campaign 1', 'DI_Mailing');
	}    
    
	// Correct campaign member status values are created for created DNA_Campaign' campaigns.
	static testmethod void test03()
	{
		enableTrigger();

        Campaign campaign = CampMgmtTestHelpers.createTestCampaign('Test Campaign 1', 'DNA_Campaign');
	} 

    static testmethod void test04()
	{
		enableTrigger();

        Campaign campaign = CampMgmtTestHelpers.createTestCampaign('Test Campaign 1', 'Inside_Sales_Campaign');
	}
	private static void enableTrigger()
	{
		BatchSettings__c settings = new BatchSettings__c();
		settings.Name = 'Default';
		settings.CampMgmtCampaignTriggerIsEnabled__c = true;
		insert settings;
	}
}