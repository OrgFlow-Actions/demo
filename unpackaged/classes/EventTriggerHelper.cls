/*-------------------------------------------------------------------------------------------------------
Author:         Ahmed LOUDRASSI (Salesforce) 20191107
Description:    Event Trigger Helper Class
History 
20211008    Kevin Ruibin Do         TFUS-000003304 Updated setEventSubject() to skip nordic users
20200609    Kevin Ruibin Do         TFUS-000001933 Changed boolean flag on manageNoticesOnEventsInserted to true
20191107    Ahmed LOUDRASSI         CallReportEventTrigger, CallReportEventTriggerAfterInsert, DC_EventBackgroundJobs an DeleteClonedChildEvent triggers. (#)
--------------------------------------------------------------------------------------------------------*/
public  with sharing class EventTriggerHelper {

    /*------------------------------------------------------------  
    Description:    Method migrated from CallReportEventTrigger trigger
    Inputs:         @param newEventList
    ------------------------------------------------------------*/
    public static void callReportEvent(List<Event> newEventList) {
        BatchSettings__c settings = BatchSettings__c.getInstance('Default');
        if (Test.isRunningTest() || settings.CallReportEventTriggerIsEnabled__c) {
            List<Call_Report__c> callReportToSave = new List<Call_Report__c>();
            List<Event> nullReportEventList = new List<event>();
            for(Event e : newEventList) {
                if(e.IsRecurrence){
                    e.Call_Report__c = null;
                } else if(e.Call_Report__c == null) {
                    Call_Report__c newcallreport = new Call_Report__c();
                    callReportToSave.add(newcallreport);
                    nullReportEventList.add(e);
                }
            }
            if(callReportToSave.size() > 0) {
                insert callReportToSave;
                integer i = 0;
                for(Call_Report__c cr : callReportToSave){
                    nullReportEventList[i].Call_Report__c = cr.Id;
                    i++;
                }
            }
        } 
    }
    
    /*------------------------------------------------------------	
    Description:   	Method migrated from CallReportEventTriggerAfterInsert trigger
                    Sets event.WhatId to Contact.AccountId if the event.WhoId is a Contact
                    and event.WhatId is null.
                    200428 kdoruibin - added escape on line 20
    Inputs:        	@param newEventList
	------------------------------------------------------------*/
    public static void callReportEvent2(List<Event> newEventList) {
        BatchSettings__c settings = BatchSettings__c.getInstance('Default');
        if (Test.isRunningTest() || settings.CallReportEventTriggerAfterInsertIsEnabl__c)  {
            set<Id> allC = new Set<Id>();
            List<event> eventnowhatid = new list<event>();
            for(Event e : newEventList) {
                if (e.Customer_Facing_Event__c == false) continue;
                if(e.WhatId == null && e.WhoId != null) {
                    String whoType = e.WhoId.getSObjectType().getDescribe().getName();
                    if('Contact'.equals(whoType)){
                        if(e.whatId == null) {
                            eventnowhatid.add(e);
                            allC.add(e.whoID);
                        }
                    }
                }
            }         
            if(allC.size() > 0) {
                Map<Id,Contact> ContactMap = new Map<Id,Contact> (); 
                List<Contact> Contactinfo = [SELECT Id, AccountId FROM Contact WHERE Id in :allC]; 
                
                for(Contact c : Contactinfo) { 
                    ContactMap.put(c.Id, c); 
                } 
                for(Event e : newEventList) {
                    if(e.whoId != null && e.WhatId == null
                       && 'Contact'.equals(e.WhoId.getSObjectType().getDescribe().getName())) {
                        Contact thisContact = ContactMap.get(e.WhoId); 
                        if(thisContact != null && thiscontact.AccountId != null){
                            e.WhatId = thiscontact.AccountId;
                        } 
                    } 
                } 
            }
        }
    }
    
    /*------------------------------------------------------------  
    Description:    Method migrated from DC_EventBackgroundJobs trigger
    Inputs:         @param newEventList
    ------------------------------------------------------------*/
    public static void updateNewOutlookEvent(List<Event> newEventList) {
        if (!DC_SettingsUtils.triggersEnabled() || EventRelationDetails.lightningSyncEnabledProfile())
            EventRelationDetails.updateNewOutlookEvent(newEventList);
    }
    /*------------------------------------------------------------  
    Description:    Method migrated from DC_EventBackgroundJobs trigger
    Inputs:         @param newEventList, oldEventMap
    ------------------------------------------------------------*/
    public static void outlookReccurenceCheck(List<Event> newEventList, Map<Id, Event> oldEventMap) {
        if (!DC_SettingsUtils.triggersEnabled() || EventRelationDetails.lightningSyncEnabledProfile()) {
            for(Event ev : newEventList) {
                if(ev.IsRecurrence2 == true && ev.EventOrigin__c == 'Outlook' 
                   && (ev.IsAllDayEvent != oldEventMap.get(ev.Id).IsAllDayEvent 
                       || ev.Description != oldEventMap.get(ev.Id).Description || ev.DurationInMinutes != oldEventMap.get(ev.Id).DurationInMinutes 
                       || ev.IsPrivate!= oldEventMap.get(ev.Id).IsPrivate || ev.IsReminderSet != oldEventMap.get(ev.Id).IsReminderSet 
                       || ev.Subject != oldEventMap.get(ev.Id).Subject ||ev.ActivityDateTime != oldEventMap.get(ev.Id).ActivityDateTime 
                       || ev.Send_Calendar_Invites__c != oldEventMap.get(ev.Id).Send_Calendar_Invites__c || ev.Location != oldEventMap.get(ev.Id).Location 
                       || ev.WhoId != oldEventMap.get(ev.Id).WhoId || ev.WhatId != oldEventMap.get(ev.Id).WhatId 
                      )){
                          ev.addError('Please update the recurring event from outlook');
                      }
            }
        }
    }
    /*------------------------------------------------------------  
    Description:    Method migrated from DC_EventBackgroundJobs trigger
    Inputs:         @param newEventList
    ------------------------------------------------------------*/
    public static void manageNoticesOnEventsInserted(List<Event> newEventList) {
        DC_EventNoticesManager.manageNotices_onEventsInserted(newEventList, true);
    }
    /*------------------------------------------------------------  
    Description:    Method migrated from DC_EventBackgroundJobs trigger
    Inputs:         @param newEventList
    ------------------------------------------------------------*/
    public static void trackBeforeUpdate(List<Event> newEventList) {
        DC_EventsUpdateTrackerForNotices.trackBeforeUpdate(newEventList);
    }
    /*------------------------------------------------------------  
    Description:    Method migrated from DC_EventBackgroundJobs trigger
    Inputs:         @param newEventList, @param oldEventMap
    ------------------------------------------------------------*/
    public static void trackAfterUpdate(List<Event> newEventList, Map<Id, Event> oldEventMap) {
        DC_EventsUpdateTrackerForNotices.trackAfterUpdate(newEventList);
        DC_EventNoticesManager.manageNotices_onEventsUpdated(oldEventMap, newEventList);
    }
    /*------------------------------------------------------------  
    Description:    Method migrated from DC_EventBackgroundJobs trigger
    Inputs:         @param oldEventList
    ------------------------------------------------------------*/
    public static void trackBeforeDelete(List<Event> oldEventList) {
        DC_EventsDeletionTrackerForNotices.trackBeforeDelete(oldEventList);
    }
    /*------------------------------------------------------------  
    Description:    Method migrated from DC_EventBackgroundJobs trigger
    Inputs:         @param oldEventList
    ------------------------------------------------------------*/
    public static void manageNoticesOnEventsDeleted(List<Event> oldEventList) {
        DC_EventNoticesManager.manageNotices_onEventsDeleted(oldEventList);
    }
    /*------------------------------------------------------------  
    Description:    Method migrated from DeleteClonedChildEvent trigger
    Inputs:         @param oldEventMap
    ------------------------------------------------------------*/
    public static void deleteClonedChildEventOnDelete(Map<Id,Event> oldEventMap) {
        if (EventRelationDetails.lightningSyncEnabledProfile()) {
            List<Event> childEve = new List<Event>();
            List<Event> childEventUpdate = new List<Event>();
            Set<ID> attendee = new Set<ID>();
            
            List<EventAttendees__c> att = [SELECT Id,EventId__c,RelationId__c 
                                           FROM EventAttendees__c 
                                           WHERE EventId__c IN :oldEventMap.keySet()];
            Map<ID,EventAttendees__c> attMap = new Map<ID,EventAttendees__c>();
            
            if(att.size() > 0) {
                for(EventAttendees__c chld : att) {
                    attMap.put(chld.RelationId__c, chld);
                }
                List<Event> childEvents = [SELECT id, OwnerId, Call_Report__c FROM Event 
                                           WHERE OwnerId IN : attMap.keySet()];
                for(Event clEvent : childEvents) {
                    Event parentEvent = oldEventMap.get(attMap.get(clEvent.OwnerId).EventId__c);
                    if(clEvent.Call_Report__c.equals(parentEvent.Call_Report__c)) {
                        clEvent.Subject = 'Deleted#_' + parentEvent.Subject;
                        childEventUpdate.add(clEvent);
                    }
                }
                database.update(childEventUpdate);
            }
        }
    }
    /*------------------------------------------------------------  
    Description:    Method migrated from DeleteClonedChildEvent trigger
    Inputs:         @param oldEventMap
    ------------------------------------------------------------*/
    public static void deleteClonedChildEventOnUpdate(Map<Id,Event> newEventMap) {
        if (EventRelationDetails.lightningSyncEnabledProfile()) {
            List<Event> ev = [SELECT id FROM Event 
                                        WHERE id IN :newEventMap.keySet() 
                                        AND subject LIKE 'Deleted#_%'];
            if(ev.size() > 0)       
                database.delete(ev);  
        }
    }

    /**
     * POC
     * Populates Event.Description with Call_Report__c.Call_Notes__c if the Event.Event_Status__c is changed to 'Completed'
     */
    public static void setEventDescription(List<Event> newEventList, Map<Id, Event> oldEventMap) {
        List<Event> completedEventList = new List<Event>();
        Set<Id> relatedCallReportIdSet = new Set<Id>();

        for (Event completedEvent : newEventList) {
            if (completedEvent.Call_Report__c == null) continue;
            String oldEventStatus = oldEventMap != null ? oldEventMap.get(completedEvent.Id).Event_Status__c : '';
            if ('Completed'.equals(completedEvent.Event_Status__c) && !'Completed'.equals(oldEventStatus)) {
                completedEventList.add(completedEvent);
                relatedCallReportIdSet.add(completedEvent.Call_Report__c);
            }
        }

        List<Event> eventToUpdateList = new List<Event>();
        Map<Id, Call_Report__c> callReportToCheckMap = new Map<Id, Call_Report__c>([SELECT Id, Call_Notes__c FROM Call_Report__c WHERE Id IN : relatedCallReportIdSet]);

        for (Event completedEvent : completedEventList) {
            Call_Report__c relatedCallReport = callReportToCheckMap.get(completedEvent.Call_Report__c);
            if (completedEvent.Description != relatedCallReport.Call_Notes__c) {
                completedEvent.Description = relatedCallReport.Call_Notes__c;
            }
        }
    }

    /**
     * Method for updating event subject if it's empty
     * TFUS-000003304: Added conditions to skip Nordic users
     * TFUS-000002466: Created Method
     */
    public static void setEventSubject(Map<Id, Event> newEventMap, Map<Id, Event> oldEventMap) {
        Set<Id> eventToQuerySet = new Set<Id>();
        User currentUser = [SELECT Id, User_Country__c FROM User WHERE Id = : UserInfo.getUserId()];

        for (Event eventToCheck : newEventMap.values()) {
            if (eventToCheck.Customer_Facing_Event__c == false) continue;
            if (String.isNotBlank(eventToCheck.Subject)) continue;
            // Skip default Subject for Nordic users
            if ('Denmark'.equals(currentUser?.User_Country__c)) continue;
            if ('Finland'.equals(currentUser?.User_Country__c)) continue;
            if ('Norway'.equals(currentUser?.User_Country__c)) continue;
            if ('Sweden'.equals(currentUser?.User_Country__c)) continue;

            eventToQuerySet.add(eventToCheck.Id);
        }

        // Do main logic
        List<Event> eventToUpdateList = new List<Event>();
        for (Event eventToUpdate : [SELECT Id, Astra_Tech_Type__c, What.Name, Who.Name FROM Event WHERE Id IN :eventToQuerySet]) {
            String eventActivityType = eventToUpdate.Astra_Tech_Type__c != null ? eventToUpdate.Astra_Tech_Type__c : '';
            String eventWhoName = eventToUpdate.Who.Name != null ? eventToUpdate.Who.Name : '';
            String eventWhatName = eventToUpdate.What.Name != null ? eventToUpdate.What.Name : '';
            eventToUpdate.Subject = eventActivityType + ' - ' + eventWhoName + ' - ' + eventWhatName;
            eventToUpdateList.add(eventToUpdate);
        }

        try {
            update eventToUpdateList;
        } catch (Exception e) {
            DebugLog.addException(e, 'EventTriggerHelper.setEventSubject');
        }

    }

    /**
     * TFUS-000001883
     */
    public static void preventRecurringCFE(List<Event> newEventList) {
        for (Event eventToCheck : newEventList) {
            if (eventToCheck.Customer_Facing_Event__c == true && eventToCheck.IsRecurrence2 == true) {
                eventToCheck.addError('Recurring Customer Facing Events are not allowed');
            }
        }
    }
}