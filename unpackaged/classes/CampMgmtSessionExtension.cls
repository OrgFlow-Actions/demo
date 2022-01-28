public class CampMgmtSessionExtension
{
    private final CampaignMember campaignMember;  
    
    public CampMgmtSessionExtension(ApexPages.StandardController stdController)
    {
   		// Load the main record context.
        if(!Test.isRunningTest())
            stdController.addFields(new String[] { 'CampaignId', 'Full_Name__c', 'ContactId' });
        campaignMember = (CampaignMember)stdController.getRecord();
        
        // Load initial values for the sessionIdList property.
        List<Session_Participant__c> sessionParticipantList = getSessionParticipantList();
        for (Session_Participant__c sessionParticipant : sessionParticipantList)
            sessionIdSet.add(sessionParticipant.Session__c);
    }
    
    // The sessionIdList property represent the list of checked sessions
    // and is backed by the sessionIdSet field.
    private Set<String> sessionIdSet = new Set<String>();     
    public List<String> getSessionIdList() { return new List<String>(sessionIdSet); }
    public void setSessionIdList(List<String> sessionIdList) { this.sessionIdSet = new Set<String>(sessionIdList); }    

    // The sessionList property provides the full set of selectable sessions.
    private List<Campaign> sessionList;
    public List<SelectOption> getSessionList()
    {
        if (sessionList == null)
        {
            sessionList =
            [
                SELECT Id, Name, Session_Occupancy__c, Session_Max_Occupancy__c
                FROM Campaign
                WHERE RecordType.DeveloperName = 'DI_Campaign_Session'
                AND Parent_Event__c = :campaignMember.CampaignId
            ]; 
        }
        
        List<SelectOption> result = new List<SelectOption>();
        
        for (Campaign session : sessionList)
        {
            String maxOccupancy = session.Session_Max_Occupancy__c == null ? '0' : session.Session_Max_Occupancy__c.format();
            List<String> arguments = new List<String> { session.Name , session.Session_Occupancy__c.format(), maxOccupancy };
            String label = String.format(System.Label.CampMgmt_SessionFormatString, arguments);
            result.add(new SelectOption(session.Id, label));
        }

        return result;
    }    

    public PageReference saveSessions()
    {       
        // Get fresh participant list since things may have been changed by others
        // since we initialized the controller.
        List<Session_Participant__c> sessionParticipantList = getSessionParticipantList();
        
        // 1. Delete any Session_Participant__c records from the database that
        // have no corresponding checked sessions.
        
        List<Session_Participant__c> sessionParticipantDeleteList = new List<Session_Participant__c>();
        for (Session_Participant__c sessionParticipant : sessionParticipantList)
        {
            if (!sessionIdSet.contains(sessionParticipant.Session__c))
                sessionParticipantDeleteList.add(sessionParticipant);
        }
        
        Database.delete(sessionParticipantDeleteList);
        
        // 2. Insert new Session_Participant__c records for checked sessions that
        // are not already in the database.

        Map<String, Session_Participant__c> sessionParticipantMap = new Map<String, Session_Participant__c>();
        for (Session_Participant__c sessionParticipant : sessionParticipantList)
            sessionParticipantMap.put(sessionParticipant.Session__c, sessionParticipant);
        
        List<Session_Participant__c> sessionParticipantInsertList = new List<Session_Participant__c>();  
        for (String sessionId : sessionIdSet)
        {
            if (!sessionParticipantMap.containsKey(sessionId))
            {
                Session_Participant__c newSessionParticipant = new Session_Participant__c(
                    Contact__c = campaignMember.ContactId,
                    Name = campaignMember.Full_Name__c,
                    Session__c = sessionId,
                    CampaignMemberId__c = campaignMember.Id
                );
                
                sessionParticipantInsertList.add(newSessionParticipant);
            }              
        }
        
        Database.insert(sessionParticipantInsertList);
        
        // Clear the session cache because session occupancy information has changed.
        sessionList = null;
        
        return null;
    }
    
    private List<Session_Participant__c> getSessionParticipantList()
    {
        List<Session_Participant__c> sessionParticipantList =
        [
            SELECT Session__c
            FROM Session_Participant__c
            WHERE CampaignMemberId__c = :campaignMember.Id
        ]; 
        
        return sessionParticipantList;
    }
}