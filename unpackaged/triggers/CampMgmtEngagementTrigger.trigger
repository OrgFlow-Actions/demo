trigger CampMgmtEngagementTrigger on Engagement__c (after delete, after insert, after update)
{
    // Don't run unless configured to do so.
    BatchSettings__c settings = BatchSettings__c.getInstance('Default');
    if (!Test.isRunningTest() && !settings.CampMgmtEngagementTriggerIsEnabled__c)
        return;
    
    Map<Id, Engagement__c> engagementMap;
    if (trigger.isDelete)
        engagementMap = trigger.oldMap;
    else if (trigger.isInsert || trigger.isUpdate || trigger.isUnDelete)
        engagementMap = trigger.newMap;    
    
    List<CampaignMember> membersDelete = new List<CampaignMember>();
    List<CampaignMember> membersUpsert = new List<CampaignMember>();
    
    //RecordType rtDiCampaignMember = [SELECT Id FROM RecordType WHERE DeveloperName = 'DI_Campaign_Member' AND SObjectType = 'CampaignMember'];    
    
    for (Engagement__c originalEngagement : engagementMap.values())
    {
        Campaign session =
            [SELECT Id, Parent_Event__c
             FROM Campaign
             WHERE Id = :originalEngagement.Session__c]; // If there's more or less than one, we SHOULD surface the error.*/

        /*Engagement__c originalEngagement =
            [SELECT Id, Speaker__c, Session__r.Parent_Event__c
             FROM Engagement__c
             WHERE Id = :e.Id]; // If there's more or less than one, we SHOULD surface the error.*/
        
        // Find the most prioritized among the related engagements (the ones sharing the same contact and campaign).
        Engagement__c primaryEngagement = null;
        List<Engagement__c> primaryEngagementList =
            [SELECT Id, Speaker__c, Session__r.Parent_Event__c, Request_Status__c, Request_Type__c, CurrencyIsoCode,
             Hotel__c, Hotel_Check_Out_Date__c, Hotel_Check_In_Date__c, Hotel_Arrangement_Status__c
             FROM Engagement__c
             WHERE Session__r.Parent_Event__c = :session.Parent_Event__c
             AND Speaker__c = :originalEngagement.Speaker__c
             ORDER BY Campaign_Member_Prio__c DESC];
        if (primaryEngagementList.size() > 0)
            primaryEngagement = primaryEngagementList[0];
        
        // Find the related DI campaign member (if any).
        CampaignMember member = null;
        List<CampaignMember> memberList =
            [SELECT Id
             FROM CampaignMember
             WHERE CampaignId = :session.Parent_Event__c
             AND ContactId = :originalEngagement.Speaker__c];
        if (memberList.size() == 1)
            member = memberList[0];
        else if (memberList.size() > 1)
            throw new BatchException('More than one CampaignMember record exists with CampaignId ' + session.Parent_Event__c + ' and ContactId ' + originalEngagement.Speaker__c + '.');

        if (primaryEngagement != null && primaryEngagement.Request_Status__c == 'Confirmed')
        {
        	if (primaryEngagement.Request_Type__c == 'Speaker')
            {
                session.Confirmed_Speaker__c = primaryEngagement.Speaker__c;
            	session.Confirmed_Moderator__c = null;
            }
            else if (primaryEngagement.Request_Type__c == 'Moderator')
            {
                session.Confirmed_Speaker__c = null;
            	session.Confirmed_Moderator__c = primaryEngagement.Speaker__c;
            }
            else if (primaryEngagement.Request_Type__c == 'Speaker & Moderator')
            {
                session.Confirmed_Speaker__c = primaryEngagement.Speaker__c;
                session.Confirmed_Moderator__c = primaryEngagement.Speaker__c;
            }
            else
            {
                session.Confirmed_Speaker__c = null;
                session.Confirmed_Moderator__c = null;
            }
        }
        else
        {
            session.Confirmed_Speaker__c = null;
            session.Confirmed_Moderator__c = null;
        }
        
        upsert session;
        
        if (primaryEngagement != null && primaryEngagement.Session__r != null && primaryEngagement.Request_Status__c != 'Confidential')
        {
            // Create member if it doesn't exist.
            if (member == null)
            {
                member = new CampaignMember();
                // The RecordType cannot be set for a CampaignMember record. It will always be
                // the same as the related Campaign.CampaignMemberRecordTypeId. See support case #09929481
                // for more information. This means the campaign members that we concern ourselves with
                // will never conclict with other types of campaign members, because they cannot coexist
                // in the same campaign.
                //member.RecordTypeId = rtDiCampaignMember.Id; // This line gives a compiler error - why is CampaignMember.RecordTypeId not writeable?!
                member.ContactId = primaryEngagement.Speaker__c;
                member.CampaignId = primaryEngagement.Session__r.Parent_Event__c;                    
            }
            
            if (primaryEngagement.Request_Status__c == 'Suggested')
                member.Status = 'Suggested';
            else if (primaryEngagement.Request_Status__c == 'Pending')
                member.Status = 'Invited';
            else if (primaryEngagement.Request_Status__c == 'Confirmed')
                member.Status = 'Confirmed';
            else if (primaryEngagement.Request_Status__c == 'Declined' || primaryEngagement.Request_Status__c == 'Cancelled (By DI)')
                member.Status = 'Cancelled';
            
            //member.Speaker_Engagement__c = primaryEngagement.Id;
            member.Type__c = primaryEngagement.Request_Type__c;
            member.CurrencyIsoCode = primaryEngagement.CurrencyIsoCode;
            member.Hotel__c = primaryEngagement.Hotel__c;
            member.Hotel_Check_Out__c = primaryEngagement.Hotel_Check_Out_Date__c;
            member.Hotel_Check_In__c = primaryEngagement.Hotel_Check_In_Date__c;
            member.Hotel_Arrangement_Status__c = primaryEngagement.Hotel_Arrangement_Status__c;    
            
            membersUpsert.add(member);
        }
        else if (member != null)
            membersDelete.add(member);
    }
    
    delete membersDelete;
    upsert membersUpsert;
}