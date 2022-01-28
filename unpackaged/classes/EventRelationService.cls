/**20-May-2019: amitkumar.prabhat@mindtree.com
 * added method SaveCustomEventRelationSet() as part of LightningSync Project
 * added few more changes to enable classic cfe part of LightningSync Project
 **/
public without sharing class EventRelationService {
    // This method will create an EventRelation object for the given Event
    // It will override the current Event Relation for this object (if applicable)
    // This method should be used when there should only ever be a single Event Relation for each relation type per Event
	public void SaveEventRelation(string eventId, string relationId, boolean isWhat, boolean isInvitee, boolean isParent){            
        if(string.isBlank(relationId)){
            return;
        }
        
        string[] relationIds = new string[] { relationId };
        
        SaveEventRelationSet(eventId, relationIds, isWhat, isInvitee, isParent);
    }   
    
    // This method will create a collection of Event Relation objects
    // Any existing Event Relation objects that do not have an equivalent on the set passed into this method will be removed
    // This method should be used when you know the entire collection of Event Relations for a given Event and relation type
    public void SaveEventRelationSet(string eventId, List<string> relationIds, boolean isWhat, boolean isInvitee, boolean isParent){
        System.debug('Entering SaveEventRelationSet. Relation ids:');
        System.debug(relationIds);
        Boolean ltngProfile = EventRelationDetails.lightningSyncEnabledProfile();
        // delete any records for this event where the relation is no longer included
        list<EventRelation> ersToDelete = [select id 
                                           from EventRelation 
                                           where eventid = :eventId 
                                               and isInvitee = :isInvitee 
                                               and isWhat = :isWhat
                                           	   and isParent = :isParent
                                               and relationId not in :relationIds];
        
        System.debug('Removing Event Relations that are no longer relevant:');
        System.debug(ersToDelete);
        
        delete ersToDelete;
        
        System.debug('Relation ids:');
        System.debug(relationIds);
        //adding records from custom object for this event: changes part of LightningSync project
        Set<String> sids = new Set<String>();
        List<EventAttendees__c> att = [SELECT Id,EventId__c,RelationId__c FROM EventAttendees__c WHERE EventId__c = :eventId and IsParent__c = :isParent];
        Event parEvent = [select Call_Report__c,Subject from Event where id =: eventId limit 1][0];
    	 List<Event> childEventUpdate = new List<Event>();	         
        if(ltngProfile) {
        if(att.size() > 0){
                for(EventAttendees__c e:att){
                        String relId = e.RelationId__c;
                        relationIds.add(relId);
                        sids.add(relId);
                    System.debug('Lightning Sync:: added custom object records');
                    }
            }
        System.debug(relationIds);
        }
       //deleting records from custom object : changes part of LightningSync project
      if(ltngProfile) {
        List<Event> childEvents = [select id from Event 
                                            where OwnerId IN : sids 
                                            and Call_Report__c =: parEvent.Call_Report__c];
        if(att.size() > 0) Database.delete(att);
        if(childEvents.size() > 0) {
                    for(Event chld:childEvents) {
                        chld.Subject = 'Deleted#_'+ parEvent.Subject;
                        childEventUpdate.add(chld);
                           }
                    database.update(childEventUpdate);
                    } 
              } 
        
        // now ensure that each required record is included in the set
        for(string relationId : relationIds){
        	AddEventRelationToSet(eventId, relationId, isWhat, isInvitee, isParent);
        }
    
        }
    // This method will add an Event Relation to the given Event
    // Any existing Event Relation objects on the given Event with the same relation types will be preserved
    // Use this method to ensure that the related object is included in the det of Event Relations for this Event and relation type.
    public void AddEventRelationToSet(string eventId, string relationId, boolean isWhat, boolean isInvitee, boolean isParent){
        System.debug('AddEventRelationToSet. RelationId: ' + relationId);
        
        if(string.isBlank(relationId)){
            return;
        }
        
        // determine the records that already exist
        // TODO: maybe abstract / cache this a bit in order to reduce repeated calls?
        list<EventRelation> existingErs = [select id, relationId, eventid, isinvitee, iswhat, isParent
                                           from EventRelation 
                                           where eventid = :eventId 
                                               and isInvitee = :isInvitee  
                                               and isWhat = :isWhat
                                           	   and isParent = :isParent
                                               and relationId = :relationId];
        
        
        if(!existingErs.isEmpty()){
            System.debug('Event Relation not created because it already exists:');
            System.debug(existingErs);
            
            return;
        }
        
        // Event Relation does not already exist, so we need to create it
        system.debug('Event Relation created for: ' + relationId);
        EventRelation er = new EventRelation(EventId = eventId, RelationId = relationId, IsInvitee = isInvitee, IsWhat = isWhat, IsParent = isParent);
        
        insert er;
        
        system.debug(er);        
    }
    
    public void SaveCustomEventRelationSet(string eventId, List<string> relationIds, boolean isWhat, boolean isInvitee, boolean isParent){
        
		System.debug('Entering SaveCustomEventRelationSet. Relation ids:');
        System.debug(relationIds);
		 
        Set<String> sids = new Set<String>();
    	sids.addAll(relationIds);
		Event parEvent = [select Astra_Tech_Type__c,Call_Report__c,Contact_Id__c,Customer_Facing_Event__c,
                                  Related_to_Account_Opportunity__c,SBU__c,
                                  WhatCount,WhatId,WhoCount,WhoId,AccountId,
                                  DurationInMinutes,EventSubtype,Event_Status__c,
                                  IsAllDayEvent,IsArchived,IsDeleted,IsGroupEvent,
                                  IsPrivate,RecordTypeId,ShowAs,StartDateTime,Subject from Event where id =: eventId limit 1][0];
		List<EventRelation> es = [SELECT Id,EventId,RelationId FROM EventRelation WHERE EventId = :eventId AND RelationId IN :sids];
    	List<EventAttendees__c> att = [SELECT Id,EventId__c,RelationId__c FROM EventAttendees__c WHERE EventId__c = :eventId];
        List<EventAttendees__c> erdlist = new List<EventAttendees__c>(); 
        List<Event> childEventInsert = new List<Event>();
        
		for(EventRelation e:es){
    			String relId = e.RelationId;
    			sids.remove(relId);
    		}	
		
		for(EventAttendees__c e:att){
                        String relId = e.RelationId__c;
                        sids.remove(relId);
                    }
        for(String s:sids){ 
       if(string.isBlank(s)){
            return; 
        }        
            EventAttendees__c erd = new EventAttendees__c(); 
                       erd.EventId__c = eventId;
                       erd.Status__c = 'Not_Invited';
                       erd.RelationId__c = s;
                       erdlist.add(erd);
                        Event childEvent = parEvent.clone(false,true);
                        //childEvent.Assigned_to_me__c = false;
                        //childEvent.IsChild = true
                        childEvent.OwnerId = s;
                        childEventInsert.add(childEvent);
                    }
                    Database.insert(erdlist);
                    Database.insert(childEventInsert);
     	
    }
}