/*Version History
 * Date: 27-Nov-2018
 * Class Name: EventRelationDetails
 * Created By: Amit Kumar Prabhat
 * Related Test Class: EventRelationDetailsTest.cls
 * 16-Apr-2019:amitkumar.prabhat@mindtree.com: added method getAttendeesList related to Lightning Sync Project
 * 
 */
public with Sharing class EventRelationDetails {
    @AuraEnabled
    public static List < EventRelation > getEventRelationDetails(String eventid) {

        List < EventRelation > ev = [SELECT Relation.Name, IsInvitee, Status FROM EventRelation WHERE EventId =: eventid
            AND IsInvitee = true
        ];
        
        
        return ev;
    }
    
     @AuraEnabled
    public static List <AttendeesWrapperClass.DisplayAttendeesRecords> getAttendeesList(String eventid) {

         List<AttendeesWrapperClass.DisplayAttendeesRecords> attnList = 
		new List<AttendeesWrapperClass.DisplayAttendeesRecords>();
        
        List < EventRelation > ev = [SELECT Relation.Name, IsInvitee, Status FROM EventRelation WHERE EventId =: eventid
            AND IsInvitee = true
        ];
        
        if(ev != null && ev.size() > 0){
            
            for(EventRelation evlist : ev){
                
                AttendeesWrapperClass.DisplayAttendeesRecords newEvList = 
				new AttendeesWrapperClass.DisplayAttendeesRecords();
                newEvList.AttendeesName = evlist.Relation.Name;
                newEvList.status = evlist.Status;
                
                attnList.add(newEvList);
            }
            
        }
        
          List < EventAttendees__c > ev1 = [SELECT RelationId__c,Status__c FROM EventAttendees__c WHERE EventId__c =: eventid];
        
        if(ev1 != null && ev1.size() > 0){
            
            for(EventAttendees__c evlist : ev1){
                
                AttendeesWrapperClass.DisplayAttendeesRecords newEvList = 
				new AttendeesWrapperClass.DisplayAttendeesRecords();
                User usr = [Select Name from user where id=: evlist.RelationId__c];
                newEvList.AttendeesName = usr.Name;
                newEvList.status = evlist.Status__c;
                
                attnList.add(newEvList);
            }
            
        }   
        return attnList;
    }
    
   /* 19-Apr-2019: amitkumar.prabhat@mindtree.com
     * Method returns the value which determines whether current profile is added to 
      LightningSyncProfile custom meta data type. We want to escape DC* from these profile 
     to be use with Lighting Sync product*/ 
    public static Boolean lightningSyncEnabledProfile()
    {
       Boolean syncProfile = false;
       //Profile usrPro = [select name from profile where id=:UserInfo.getProfileId()];
     //List<LightningSyncProfiles__mdt> syncProfiles = [SELECT Label FROM LightningSyncProfiles__mdt WHERE label =: usrPro.Name];
       // if(syncProfiles.size() > 0) syncProfile = true;
         
     List<PermissionSetAssignment> psa_cnt = [SELECT PermissionSet.Name FROM PermissionSetAssignment WHERE AssigneeId = :Userinfo.getUserId() 
        AND PermissionSet.Name = 'Lightning_Sync'];
        if(psa_cnt.size() > 0) syncProfile = true;
        return syncProfile;
    } 
 /* 27-June-2019: amitkumar.prabhat@mindtree.com
     * Method Update Event Activity Type and CFE Flag if Event Origin is Outlook*/ 
    public static void updateNewOutlookEvent(Event[] events)
    {
       system.debug('Event from updateNewOutlookEvent');
        List<Event> selectedEvents = new List<Event>();
        for (Event event : events)
        {
               // String s = JSON.serialize(event);
                //if(s.contains('ProposedEventTimeframe'))    
               if(event.EventOrigin__c == null || event.EventOrigin__c == '')
                {
                // event.Astra_Tech_Type__c = 'Outlook';
                event.EventOrigin__c = 'Outlook';
                event.Customer_Facing_Event__c = false;
                event.Send_Calendar_Invites__c = false;
                selectedEvents.add(event);
            }
           } 
    }
}