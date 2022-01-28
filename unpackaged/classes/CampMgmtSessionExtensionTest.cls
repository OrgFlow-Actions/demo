@isTest
private class CampMgmtSessionExtensionTest
{
	static testmethod void getSessionListTest01()
	{
        Campaign campaign = CampMgmtTestHelpers.createTestCampaign('Test Campaign 1', 'DI_Campaign');      
        Campaign session = CampMgmtTestHelpers.createTestSession(campaign.Id, 'Test Session 1', 'DI_Campaign_Session');
        Account account = CampMgmtTestHelpers.createTestAccount('Test Account 1');
        Contact contact = CampMgmtTestHelpers.createTestContact(account.Id, 'Testis', 'Testisson', 'email@email.com');
		CampaignMember campaignMember = CampMgmtTestHelpers.createTestCampaignMember(campaign.Id, contact.Id, 'Confirmed');

		Test.startTest();
		
		Test.setCurrentPage(Page.CampMgmtSessionsPage);
		CampMgmtSessionExtension target = new CampMgmtSessionExtension(new ApexPages.StandardController(campaignMember));
		List<SelectOption> result = target.getSessionList();

		System.assertEquals(1, result.size());
		System.assertEquals(session.Id, result[0].getValue());
		System.assertEquals('Test Session 1 (0/0 seats occupied)', result[0].getLabel());

		Test.stopTest();
	}

	// No Session IDs returned when no SessionParticipants exist.
	static testmethod void getSessionIdListTest01()
	{
        Campaign campaign = CampMgmtTestHelpers.createTestCampaign('Test Campaign 1', 'DI_Campaign');      
        Campaign session = CampMgmtTestHelpers.createTestSession(campaign.Id, 'Test Session 1', 'DI_Campaign_Session');
        Account account = CampMgmtTestHelpers.createTestAccount('Test Account 1');
        Contact contact = CampMgmtTestHelpers.createTestContact(account.Id, 'Testis', 'Testisson', 'email@email.com');
		CampaignMember campaignMember = CampMgmtTestHelpers.createTestCampaignMember(campaign.Id, contact.Id, 'Confirmed');

		Test.startTest();
		
		Test.setCurrentPage(Page.CampMgmtSessionsPage);
		CampMgmtSessionExtension target = new CampMgmtSessionExtension(new ApexPages.StandardController(campaignMember));
		List<String> result = target.getSessionIdList();

		System.assertEquals(0, result.size());

		Test.stopTest();
	}

	// One correct Session ID returned when one SessionParticipant exists.
	static testmethod void getSessionIdListTest02()
	{
        Campaign campaign = CampMgmtTestHelpers.createTestCampaign('Test Campaign 1', 'DI_Campaign');      
        Campaign session = CampMgmtTestHelpers.createTestSession(campaign.Id, 'Test Session 1', 'DI_Campaign_Session');
        Account account = CampMgmtTestHelpers.createTestAccount('Test Account 1');
        Contact contact = CampMgmtTestHelpers.createTestContact(account.Id, 'Testis', 'Testisson', 'email@email.com');
		CampaignMember campaignMember = CampMgmtTestHelpers.createTestCampaignMember(campaign.Id, contact.Id, 'Confirmed');

		Session_Participant__c sessionParticipant = new Session_Participant__c();
		sessionParticipant.Session__c = session.Id;
		sessionParticipant.Contact__c = contact.Id;
		sessionParticipant.CampaignMemberId__c = campaignMember.Id;
		sessionParticipant.Name = contact.Full_Name__c;
		insert sessionParticipant;

		Test.startTest();
		
		Test.setCurrentPage(Page.CampMgmtSessionsPage);
		CampMgmtSessionExtension target = new CampMgmtSessionExtension(new ApexPages.StandardController(campaignMember));

		List<String> result = target.getSessionIdList();

		System.assertEquals(1, result.size());
		System.assertEquals(session.Id, result[0]);

		Test.stopTest();
	}

	// Added (checked) sessions are correctly inserted in the database.
	static testmethod void saveSessionsTest01()
	{
        Campaign campaign = CampMgmtTestHelpers.createTestCampaign('Test Campaign 1', 'DI_Campaign');      
        Campaign session = CampMgmtTestHelpers.createTestSession(campaign.Id, 'Test Session 1', 'DI_Campaign_Session');
        Account account = CampMgmtTestHelpers.createTestAccount('Test Account 1');
        Contact contact = CampMgmtTestHelpers.createTestContact(account.Id, 'Testis', 'Testisson', 'email@email.com');
		CampaignMember campaignMember = CampMgmtTestHelpers.createTestCampaignMember(campaign.Id, contact.Id, 'Confirmed');

		Test.startTest();
		
		Test.setCurrentPage(Page.CampMgmtSessionsPage);
		CampMgmtSessionExtension target = new CampMgmtSessionExtension(new ApexPages.StandardController(campaignMember));
		target.setSessionIdList(new String[] {session.Id});
		target.saveSessions();

		List<Session_Participant__c> result =
		[
			SELECT Session__c, Contact__c, CampaignMemberId__c, Name
			FROM Session_Participant__c
			WHERE Contact__c = :contact.Id AND Session__c = :session.Id
		];

		System.assertEquals(1, result.size());
		System.assertEquals(session.Id, result[0].Session__c);
		System.assertEquals(contact.Id, result[0].Contact__c);
		System.assertEquals(campaignMember.Id, result[0].CampaignMemberId__c);
		//System.assertEquals(campaignMember.Full_Name__c, result[0].Name);

		Test.stopTest();
	}	

	// Removed (unchecked) sessions are correctly deleted from the database.
	static testmethod void saveSessionsTest02()
	{
        Campaign campaign = CampMgmtTestHelpers.createTestCampaign('Test Campaign 1', 'DI_Campaign');      
        Campaign session = CampMgmtTestHelpers.createTestSession(campaign.Id, 'Test Session 1', 'DI_Campaign_Session');
        Account account = CampMgmtTestHelpers.createTestAccount('Test Account 1');
        Contact contact = CampMgmtTestHelpers.createTestContact(account.Id, 'Testis', 'Testisson', 'email@email.com');
		CampaignMember campaignMember = CampMgmtTestHelpers.createTestCampaignMember(campaign.Id, contact.Id, 'Confirmed');

		Session_Participant__c sessionParticipant = new Session_Participant__c();
		sessionParticipant.Session__c = session.Id;
		sessionParticipant.Contact__c = contact.Id;
		sessionParticipant.CampaignMemberId__c = campaignMember.Id;
		sessionParticipant.Name = campaignMember.Full_Name__c;
		insert sessionParticipant;

		Test.startTest();
		
		Test.setCurrentPage(Page.CampMgmtSessionsPage);
		CampMgmtSessionExtension target = new CampMgmtSessionExtension(new ApexPages.StandardController(campaignMember));
		target.setSessionIdList(new String[] {});
		target.saveSessions();

		List<Session_Participant__c> result =
		[
			SELECT CampaignMemberId__c, Name
			FROM Session_Participant__c
			WHERE Contact__c = :contact.Id AND Session__c = :session.Id
		];

		System.assertEquals(0, result.size());

		Test.stopTest();
	}				
}