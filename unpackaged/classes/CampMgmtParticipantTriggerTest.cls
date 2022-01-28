@isTest
private class CampMgmtParticipantTriggerTest
{
	static testmethod void insertTest01()
	{
        Campaign campaign = CampMgmtTestHelpers.createTestCampaign('Test Campaign 1', 'DI_Campaign');      
        Campaign session = CampMgmtTestHelpers.createTestSession(campaign.Id, 'Test Session 1', 'DI_Campaign_Session');
        Account account = CampMgmtTestHelpers.createTestAccount('Test Account 1');
        Contact contact = CampMgmtTestHelpers.createTestContact(account.Id, 'Testis', 'Testisson', 'email@email.com');
		CampaignMember campaignMember = CampMgmtTestHelpers.createTestCampaignMember(campaign.Id, contact.Id, 'Confirmed');

		Session_Participant__c sessionParticipant = new Session_Participant__c();
		sessionParticipant.Session__c = session.Id;
		sessionParticipant.Contact__c = contact.Id;
		// Deliberately NOT setting the CampaignMemberId__c field! 
		sessionParticipant.Name = contact.Full_Name__c;
		insert sessionParticipant;

		sessionParticipant =
		[
			SELECT CampaignMemberId__c
			FROM Session_Participant__c
			WHERE Id = :sessionParticipant.Id
			LIMIT 1
		][0];

		System.assertEquals(campaignMember.Id, sessionParticipant.CampaignMemberId__c);
	}
}