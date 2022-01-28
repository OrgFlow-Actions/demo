//
//This class manages all processes which are related with event notifications.
//
//Author: Gennadiy Pervukhin (28-10-2014)
public class DC_EventNoticesManager
{
    //
    //Private static methods
    //
    private static void addNoticesBuilder(DC_EventNoticesBuildersGroup buildersGroup,
        EventRelation[] eventAttendees, DC_EventNoticeReceiver receiverForOrganizer,
        DC_EventNoticesBuilder.ICreator builderCreator)
    {
        //generate receivers for the attendees
        DC_EventNoticeReceiver[] noticeReceivers =
            DC_EventNoticesUtils.generateReceivers(eventAttendees);
        //add a receiver for the organizer to the list
        if (receiverForOrganizer != null)
        {
            noticeReceivers.add(receiverForOrganizer);
        }
        
        //generate a new builder of notices and add it to the group
        if (noticeReceivers.size() > 0)
        {
            buildersGroup.builders.add(builderCreator.createBuilder(
                buildersGroup.event, noticeReceivers));
        }
    }
    
    private static DC_EventNoticesBuildersGroup[] createBuildersGroups(Event[] events,
        Boolean considerOrganizer, DC_EventNoticesBuilder.ICreator builderCreator)
    {
        //initialize and fill a list of groups
        List<DC_EventNoticesBuildersGroup> buildersGroups =
            new List<DC_EventNoticesBuildersGroup>();
        for (Event event : events)
        {
            //initialize a group of builders for the current event (event object
            //should contain all data necessary for notifications)
            DC_EventNoticesBuildersGroup buildersGroup =
                new DC_EventNoticesBuildersGroup(event);
            
            //create a receiver for the event's organizer
            DC_EventNoticeReceiver receiverForOrganizer = (considerOrganizer
                ? DC_EventNoticesUtils.generateReceiverForOrganizer(event) : null);
            //add a notices builder to the group
            addNoticesBuilder(buildersGroup, event.EventRelations,
                receiverForOrganizer, builderCreator);
            
            //add the group to the list
            if (buildersGroup.isNotEmpty())
            {
                buildersGroups.add(buildersGroup);
            }
        }
        
        return buildersGroups;
    }
    
    private static DC_EventNoticesBuildersGroup createBuildersGroup_onEventUpdated(
        String newEventId)
    {
        //get special versions of old and new events which were tracked in the tracker
        Event oldEvent = DC_EventsUpdateTrackerForNotices.getOldEvent(newEventId);
        Event newEvent = DC_EventsUpdateTrackerForNotices.getNewEvent(newEventId);
        
        if (oldEvent == null || newEvent == null)
        {
            return null;
        }
        
        //- initialize receivers for organizers
        DC_EventNoticeReceiver receiverForNewOrganizer = null;
        DC_EventNoticeReceiver receiverForOldOrganizer = null;
        DC_EventNoticeReceiver receiverForUnchangedOrganizer = null;
        if (oldEvent.OwnerId == newEvent.OwnerId)
        {
            receiverForUnchangedOrganizer =
                DC_EventNoticesUtils.generateReceiverForOrganizer(newEvent);
        }
        else
        {
            receiverForNewOrganizer =
                DC_EventNoticesUtils.generateReceiverForOrganizer(newEvent);
            receiverForOldOrganizer =
                DC_EventNoticesUtils.generateReceiverForOrganizer(oldEvent);
        }
        
        
        
        //- create a new group of builders (pass a newEvent object which contains
        //all data necessary for notifications)
        DC_EventNoticesBuildersGroup buildersGroup = new DC_EventNoticesBuildersGroup(newEvent);
        
        EventRelation[] deletedAttendees =
                DC_EventNoticesUtils.findDeletedAttendees(oldEvent, newEvent);
        
        EventRelation[] newAttendees = DC_EventNoticesUtils.findNewAttendees(oldEvent, newEvent);
        
        EventRelation[] unchangedAttendees =
                    DC_EventNoticesUtils.findUnchangedAttendees(oldEvent, newEvent);
        
        if (newEvent.Event_Status__c == 'Cancelled' 
            && newEvent.Event_Status__c != oldEvent.Event_Status__c) {
          EventRelation[] attendees = new EventRelation[] {};
          attendees.addAll(deletedAttendees);
          attendees.addAll(unchangedAttendees);
          addNoticesBuilder(buildersGroup, attendees,
                receiverForUnchangedOrganizer, new DC_EventCancellationsBuilder.Creator());
        } else {
            //1) add a builder for cancellations (deleted attendees). These emails
            //should be queued at first, because in some cases a same user should
            //get a cancellation and a new invitation after the update (for example,
            //when we set a new organizer and added the old one in the attendees)
            addNoticesBuilder(buildersGroup, deletedAttendees, receiverForOldOrganizer,
                new DC_EventCancellationsBuilder.Creator());
            
            //2) add a builder for new invites (new attendees)
            addNoticesBuilder(buildersGroup, newAttendees, receiverForNewOrganizer,
                new DC_EventInvitesBuilder.Creator());
            
            //3) add a builder for update notices if the event's changes suppose that
            //(unchanged attendess)
            if (DC_EventNoticesUtils.isUpdateNoticeRequired(oldEvent, newEvent,
                newAttendees, deletedAttendees))
            {
                addNoticesBuilder(buildersGroup, unchangedAttendees,
                    receiverForUnchangedOrganizer, new DC_EventUpdatesBuilder.Creator());
            }        
        }
        
        return buildersGroup;
    }
    
    /*this method implements a whole process of working with notifications of one
    type (from selection of suitable events to sending emails)*/
    private static void manageNoticesForEvents(Event[] events,
        DC_EventNoticesBuilder.ICreator builderCreator)
    {
        //1) create a list of groups with notices builders
        DC_EventNoticesBuildersGroup[] buildersGroups = createBuildersGroups(
            events, true, builderCreator);
        
        //2) generate and send emails
        DC_EventNoticesUtils.generateAndSendEmails(buildersGroups);
    }
    //
    
    //
    //Public static methods
    //
    public static void manageNotices_onEventsInserted(Event[] events, boolean fromTrigger)
    {
        //1) select events which support custom notifications only
        Event[] selectedEvents = DC_EventNoticesUtils.selectEventsForNoticesWhenCreating(events, fromTrigger);
        if (selectedEvents == null || selectedEvents.size() == 0)
        {
            return;
        }
        
        //2) re-read events to include data necessary for notices (including attachments)
        selectedEvents = DC_EventNoticesUtils.reReadEventsForNotices(
            selectedEvents, true);
        
        //3) start the process for selected events and their attendees
        manageNoticesForEvents(selectedEvents, new DC_EventInvitesBuilder.Creator());
    }
    
    public static void manageNotices_onEventsDeleted(Event[] events)
    {
        //1) get deleted events from the tracker
        Event[] selectedEvents = DC_EventsDeletionTrackerForNotices.getDeletedEvents();
        if (selectedEvents == null || selectedEvents.size() == 0)
        {
            return;
        }
        
        //2) start the process for selected events and their attendees
        manageNoticesForEvents(selectedEvents, new DC_EventCancellationsBuilder.Creator());
    }
    
    public static void manageNotices_onEventsUpdated(Map<Id, Event> oldEvents,
        Event[] newEvents)
    {
        //STEP #1: select new events which support custom notifications only
        Event[] selectedNewEvents = DC_EventNoticesUtils.selectEventsForNotices(newEvents);
        //check passed parameters
        if (oldEvents == null || selectedNewEvents == null || selectedNewEvents.size() == 0)
        {
            return;
        }
        
        //STEP #2: process with updated events and fill a list of builders groups
        List<DC_EventNoticesBuildersGroup> buildersGroups =
            new List<DC_EventNoticesBuildersGroup>();
        for (Event newEvent : selectedNewEvents)
        {
            //- create a new group of builders
            DC_EventNoticesBuildersGroup buildersGroup = createBuildersGroup_onEventUpdated(newEvent.Id);
            //- if a new group is not empty then add it to the list
            if (buildersGroup != null && buildersGroup.isNotEmpty())
            {
                buildersGroups.add(buildersGroup);
            }
        }
        
        //STEP #3: generate and send emails
        DC_EventNoticesUtils.generateAndSendEmails(buildersGroups);
    }
    //
}