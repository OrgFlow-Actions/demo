@isTest
private class CampMgmtCampaignMemberTriggerTest
{
    @testSetup
    private static void setup() {
        TestDataFactory.createBypassCustomSetting();
        List<User> userList = TestDataFactory.returnUsers(1, 'System Administrator');
        userList.get(0).User_Country__c = 'Germany';
        insert userList;
        TestDataFactory.createGlobalIntegrationSettings(userList);
        TestDataFactory.createDefaultOrgLevelBypassPB();
    }
	// CampMgmtCampaignMemberTrigger
	static testmethod void test01()
	{
		enableTrigger();

		Campaign campaign = CampMgmtTestHelpers.createTestCampaign('Test Campaign 1', 'DI_Campaign');
		Account account = CampMgmtTestHelpers.createTestAccount('Test Account 1');
		Contact contact = CampMgmtTestHelpers.createTestContact(account.Id, 'Testis', 'Testisson', 'email@email.com');
		CampaignMember campaignMember = CampMgmtTestHelpers.createTestCampaignMember(campaign.Id, contact.Id, 'Confirmed');

		campaignMember = [
			SELECT Id, Account__c
			FROM CampaignMember
			WHERE Id = :campaignMember.Id];
		
        System.assertEquals(account.Id, campaignMember.Account__c);
	}

	// CampMgmtCampaignMemberTrigger2; insert mode, multiple accounts to one campaign, both confirmed
	static testmethod void test02()
	{
		enableTrigger();

		Campaign campaign = CampMgmtTestHelpers.createTestCampaign('Test Campaign 1', 'DI_Campaign');

		Account account1 = CampMgmtTestHelpers.createTestAccount('Test Account 1');
		Contact contact1 = CampMgmtTestHelpers.createTestContact(account1.Id, 'Testis1', 'Testisson','email@email1.com');
        /*contact1.Email = 'test.testisson@dentsplysirona.com.invalid';
        contact1.InsertEmailMarketingConsentCollected__c = 'No';
        update contact1;*/
        
		CampaignMember campaignMember1 = CampMgmtTestHelpers.createTestCampaignMember(campaign.Id, contact1.Id, 'Confirmed');

		Account account2 = CampMgmtTestHelpers.createTestAccount('Test Account 2');
		Contact contact2 = CampMgmtTestHelpers.createTestContact(account2.Id, 'Testis2', 'Testisson','email@email2.com');
        /*contact2.Email = 'test2.testisson@dentsplysirona.com.invalid';
        contact2.InsertEmailMarketingConsentCollected__c = 'No';
        update contact2;*/
        
		CampaignMember campaignMember2 = CampMgmtTestHelpers.createTestCampaignMember(campaign.Id, contact2.Id, 'Confirmed');

		campaign = [
			SELECT CampaignMemberAccountIdList__c
			FROM Campaign
			WHERE Id = :campaign.Id];

		Set<String> accountIds = new Set<String>();
		if (campaign.CampaignMemberAccountIdList__c != null)
			accountIds.addAll(campaign.CampaignMemberAccountIdList__c.split(',', 0));
		
		System.assertEquals(2, accountIds.size());
		System.assert(accountIds.contains(String.valueOf(account1.Id).substring(0, 15)));
		//System.assert(accountIds.contains(String.valueOf(account2.Id).substring(0, 15)));
	}

	// CampMgmtCampaignMemberTrigger2; insert mode, multiple accounts to one campaign, only one confirmed
	static testmethod void test03()
	{
		enableTrigger();

		Campaign campaign = CampMgmtTestHelpers.createTestCampaign('Test Campaign 1', 'DI_Campaign');

		Account account1 = CampMgmtTestHelpers.createTestAccount('Test Account 1');
		Contact contact1 = CampMgmtTestHelpers.createTestContact(account1.Id, 'Testis1', 'Testisson','email@email1.com');

		CampaignMember campaignMember1 = CampMgmtTestHelpers.createTestCampaignMember(campaign.Id, contact1.Id, 'Confirmed');

		Account account2 = CampMgmtTestHelpers.createTestAccount('Test Account 2');
		Contact contact2 = CampMgmtTestHelpers.createTestContact(account2.Id, 'Testis1', 'Testisson','email@email2.com');

        contact2.Email = 'test2.testisson@dentsplysirona.com.invalid';
        contact2.InsertEmailMarketingConsentCollected__c = 'No';
        update contact2;
		CampaignMember campaignMember2 = CampMgmtTestHelpers.createTestCampaignMember(campaign.Id, contact2.Id, 'Suggested');

		campaign = [
			SELECT CampaignMemberAccountIdList__c
			FROM Campaign
			WHERE Id = :campaign.Id];

		Set<String> accountIds = new Set<String>();
		if (campaign.CampaignMemberAccountIdList__c != null)
			accountIds.addAll(campaign.CampaignMemberAccountIdList__c.split(',', 0));
		
		System.assertEquals(1, accountIds.size());
		System.assert(accountIds.contains(String.valueOf(account1.Id).substring(0, 15)));
	}

	// CampMgmtCampaignMemberTrigger2; insert mode, multiple accounts to one campaign, only one of type Participant
	static testmethod void test04()
	{
		enableTrigger();

		Campaign campaign = CampMgmtTestHelpers.createTestCampaign('Test Campaign 1', 'DI_Campaign');

		Account account1 = CampMgmtTestHelpers.createTestAccount('Test Account 1');
		Contact contact1 = CampMgmtTestHelpers.createTestContact(account1.Id, 'Testis1', 'Testisson','email@email1.com');

		CampaignMember campaignMember1 = CampMgmtTestHelpers.createTestCampaignMember(campaign.Id, contact1.Id, 'Confirmed', 'Participant');

		Account account2 = CampMgmtTestHelpers.createTestAccount('Test Account 2');
		Contact contact2 = CampMgmtTestHelpers.createTestContact(account2.Id, 'Testis1', 'Testisson','email@email2.com');

		CampaignMember campaignMember2 = CampMgmtTestHelpers.createTestCampaignMember(campaign.Id, contact2.Id, 'Confirmed', 'Speaker');

		campaign = [
			SELECT CampaignMemberAccountIdList__c
			FROM Campaign
			WHERE Id = :campaign.Id];

		Set<String> accountIds = new Set<String>();
		if (campaign.CampaignMemberAccountIdList__c != null)
			accountIds.addAll(campaign.CampaignMemberAccountIdList__c.split(',', 0));
		
		System.assertEquals(1, accountIds.size());
		System.assert(accountIds.contains(String.valueOf(account1.Id).substring(0, 15)));
	} 

	// CampMgmtCampaignMemberTrigger2; insert mode, multiple campaigns to one account, both confirmed
	static testmethod void test05()
	{
		enableTrigger();

		Account account = CampMgmtTestHelpers.createTestAccount('Test Account 1');

		Campaign campaign1 = CampMgmtTestHelpers.createTestCampaign('Test Campaign 1', 'DI_Campaign');
        
		Contact contact1 = CampMgmtTestHelpers.createTestContact(account.Id, 'Testis1', 'Testisson','email@email1.com');

        
		CampaignMember campaignMember1 = CampMgmtTestHelpers.createTestCampaignMember(campaign1.Id, contact1.Id, 'Confirmed');

		//Campaign campaign2 = CampMgmtTestHelpers.createTestCampaign('Test Campaign 2', 'DI_Campaign');  
		
		Contact contact2 = CampMgmtTestHelpers.createTestContact(account.Id, 'John', 'Doe','email@email2.com');

        
        //CampaignMember campaignMember2 = CampMgmtTestHelpers.createTestCampaignMember(campaign2.Id, contact2.Id, 'Confirmed');

		account = [
			SELECT ContactCampaignIdList__c
			FROM Account
			WHERE Id = :account.Id];

		Set<String> campaignIds = new Set<String>();
		if (account.ContactCampaignIdList__c != null)
			campaignIds.addAll(account.ContactCampaignIdList__c.split(',', 0));
		
		System.assertEquals(1, campaignIds.size());
		System.assert(campaignIds.contains(String.valueOf(campaign1.Id).substring(0, 15)));
		//System.assert(campaignIds.contains(String.valueOf(campaign2.Id).substring(0, 15)));
	}    

	// CampMgmtCampaignMemberTrigger2; insert mode, multiple campaigns to one account, only one confirmed
	static testmethod void test06()
	{
		enableTrigger();

		Account account = CampMgmtTestHelpers.createTestAccount('Test Account 1');

		Campaign campaign1 = CampMgmtTestHelpers.createTestCampaign('Test Campaign 1', 'DI_Campaign');       

		Contact contact1 = CampMgmtTestHelpers.createTestContact(account.Id, 'Testis1', 'Testisson','email@email1.com');

             
        CampaignMember campaignMember1 = CampMgmtTestHelpers.createTestCampaignMember(campaign1.Id, contact1.Id, 'Confirmed');

		Campaign campaign2 = CampMgmtTestHelpers.createTestCampaign('Test Campaign 2', 'DI_Campaign');  

		Contact contact2 = CampMgmtTestHelpers.createTestContact(account.Id, 'Testis1', 'Doe','email@email2.com');

        
        CampaignMember campaignMember2 = CampMgmtTestHelpers.createTestCampaignMember(campaign2.Id, contact2.Id, 'Suggested');

		account = [
			SELECT ContactCampaignIdList__c
			FROM Account
			WHERE Id = :account.Id];

		Set<String> campaignIds = new Set<String>();
		if (account.ContactCampaignIdList__c != null)
			campaignIds.addAll(account.ContactCampaignIdList__c.split(',', 0));
		
		System.assertEquals(1, campaignIds.size());
		System.assert(campaignIds.contains(String.valueOf(campaign1.Id).substring(0, 15)));
	} 

	// CampMgmtCampaignMemberTrigger2; insert mode, multiple campaigns to one account, only one of type Participant
	static testmethod void test07()
	{
		enableTrigger();

		Account account = CampMgmtTestHelpers.createTestAccount('Test Account 1');

		Campaign campaign1 = CampMgmtTestHelpers.createTestCampaign('Test Campaign 1', 'DI_Campaign');       

		Contact contact1 = CampMgmtTestHelpers.createTestContact(account.Id, 'Testis1', 'Testisson','email@email1.com');

        
        CampaignMember campaignMember1 = CampMgmtTestHelpers.createTestCampaignMember(campaign1.Id, contact1.Id, 'Confirmed', 'Participant');

		Campaign campaign2 = CampMgmtTestHelpers.createTestCampaign('Test Campaign 2', 'DI_Campaign');  
		
		Contact contact2 = CampMgmtTestHelpers.createTestContact(account.Id, 'John2', 'Doe','email@email2.com');

        
        CampaignMember campaignMember2 = CampMgmtTestHelpers.createTestCampaignMember(campaign2.Id, contact2.Id, 'Suggested', 'Speaker');

		account = [
			SELECT ContactCampaignIdList__c
			FROM Account
			WHERE Id = :account.Id];

		Set<String> campaignIds = new Set<String>();
		if (account.ContactCampaignIdList__c != null)
			campaignIds.addAll(account.ContactCampaignIdList__c.split(',', 0));
		
		System.assertEquals(1, campaignIds.size());
		System.assert(campaignIds.contains(String.valueOf(campaign1.Id).substring(0, 15)));
	}     
	
	private static void enableTrigger()
	{
		BatchSettings__c settings = new BatchSettings__c();
		settings.Name = 'Default';
		settings.CampMgmtCampaignMemberTriggerIsEnabled__c = true;
		insert settings;
	}
	
}