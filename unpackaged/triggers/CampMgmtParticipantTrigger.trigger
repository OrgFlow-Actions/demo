trigger CampMgmtParticipantTrigger on Session_Participant__c (before insert, before update)
{
    for (Session_Participant__c p : trigger.new)
    {
    	// This trigger only operates in the case when a SessionParticipant
    	// is created without specifying a CampaignMember, and tries to infer
    	// it using best-effort from the Contact__c field instead, by checking
    	// for any existing CampaignMembers related to both the Contact__c and
    	// the parent Campaign of the related session, and using the Id of that
    	// CampaignMember if any.
    	if (p.CampaignMemberId__c == null)
    	{
	    	List<CampaignMember> campaignMemberList = 
	    	[
	    		SELECT Id
		    	FROM CampaignMember
		    	WHERE CampaignId IN
		    	(
		    		SELECT Parent_Event__c
		    		FROM Campaign
		    		WHERE Id = :p.Session__c
		    	)
		    	AND ContactId = :p.Contact__c  
		    	LIMIT 1  		
	    	];

	    	if (campaignMemberList.size() == 0)
	    		throw new al.IllegalStateException(Label.CampMgmt_NoCampaignMemberErrorMessage);

	    	p.CampaignMemberId__c = campaignMemberList[0].Id;
    	}
    }
}