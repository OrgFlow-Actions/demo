//
//This class provides utilities related with event notifications.
//
//Author: Gennadiy Pervukhin (28-10-2014)
public class DC_EventNoticesUtils
{
    //
    //Constants
    //
    private static final Integer CODE_NEW_ATTENDEES = 1;
    private static final Integer CODE_DELETED_ATTENDEES = 2;
    private static final Integer CODE_UNCHANGED_ATTENDEES = 3;
    
    private static final String SEPARATOR_IN_UID = '_';
    private static final String UID_FORMAT = '{0}' + SEPARATOR_IN_UID
        + '{1}' + SEPARATOR_IN_UID + '{2}';
    private static final Integer NUMBER_OF_PARTS_IN_UID = 3;
    private static final Integer INDEX_OF_EVENT_ID_IN_UID = 0;
    private static final Integer INDEX_OF_PERSON_ID_IN_UID = 1;
    private static final Integer INDEX_OF_HOST_NAME_IN_UID = 2;
    
    private static final String ALARM_DESCRIPTION_FORMAT = 'Reminder for {0}';
    //
    
    //
    //Static variables 
    //
    @TestVisible
    private static Set<Id> idsOfEventRTsForNotices;
    private static String partOfUID_InstanceUrl = getPartOfUID_InstanceUrl();
    //
    
    //
    //Private static methods
    //
    private static void readIdsOfEventRTsForNotices()
    {
        if (idsOfEventRTsForNotices == null)
        {
            idsOfEventRTsForNotices = DC_SettingsUtils.getIdsOfEventRTsForNotices();
        }
    }
    
    private static Boolean customNoticesEnabled(Event event)
    {
        //read Ids of event record types, which support custom notifications,
        //from custom settings
        readIdsOfEventRTsForNotices();
        
        //- check if custom notifications are enabled for the event
        if (event.Send_Calendar_Invites__c != true
            || (event.RecordTypeId != null && !idsOfEventRTsForNotices.contains(event.RecordTypeId)))
        {
            return false;
        }
        
        //- check if the event is not a child recurring event (it has no reference
        //to recurrence activity or it's a main recurring event)
        return (event.RecurrenceActivityId == null || event.IsRecurrence == true);
    }
    
    private static EventRelation[] findAttendees(Event oldEvent, Event newEvent,
        Integer attendeesGroupCode)
    {
        if (oldEvent == null || newEvent == null)
        {
            return new EventRelation[0];
        }
        
        //find attendees
        if (attendeesGroupCode == CODE_NEW_ATTENDEES)
        {
            //get attendees who exist after update, but did not exist before update
            return DC_SetUtils.findRelativeComplement(
                newEvent.EventRelations, oldEvent.EventRelations);
        }
        else if (attendeesGroupCode == CODE_DELETED_ATTENDEES)
        {
            //get attendees who existed before update, but do not exist after update
            return DC_SetUtils.findRelativeComplement(
                oldEvent.EventRelations, newEvent.EventRelations);
        }
        else
        {
            //get attendees who existed before update and exist after update
            return DC_SetUtils.findIntersection(newEvent.EventRelations,
                oldEvent.EventRelations);
        }
    }
    
    private static DC_SObjectHelper initializeHelperForOrganizers(
        DC_EventNoticesBuildersGroup[] buildersGroups)
    {
        //extract events from groups
        List<Event> events = new List<Event>();
        for (DC_EventNoticesBuildersGroup buildersGroup : buildersGroups)
        { 
            events.add(buildersGroup.event);
        }
        
        //extract organizers of events
        String[] organizersIds = DC_SObjectUtils.extractStringFieldValues(
            events, DC_EventDAO.FIELD_ORGANIZER_ID);
        //get organizers
        User[] organizers = DC_UserDAO.getUsersByIds(organizersIds);
        //initialize and return a helper for organizers
        return DC_SObjectHelper.createHelperForList(organizers);
    }
    
    private static String getPartOfUID_InstanceUrl()
    {
        if (String.isBlank(partOfUID_InstanceUrl))
        {
            String instanceUrl = Url.getSalesforceBaseUrl().toExternalForm();
            if (String.isNotBlank(instanceUrl))
            {
                partOfUID_InstanceUrl = instanceUrl.replaceAll('[:./]', '');
            }
        }
        return partOfUID_InstanceUrl;
    }
    //
    
    //
    //Public static methods
    //
    public static Event[] reReadEventsForNotices(Event[] events, Boolean selectAttachments)
    {
        //check passed parameters
        if (events == null || events.size() == 0)
        {
            return new Event[0];
        }
        
        //STEP #1: prepare a filter
        //- initialize a new filter
        DC_EventDAO.Filter filter = new DC_EventDAO.Filter();
        //- fill Ids of events
        filter.ids = DC_SObjectUtils.extractIds(events, false);
        
        //- initialize and fill a sub-filter for child event relations
        filter.selectRelations = true;
        filter.relationsFilter = new DC_EventRelationDAO.Filter();
        //filter.relationsFilter.relatedSObjectTypes = DC_EventRelationDAO.RELATED_PERSON_OBJECTS;
        filter.relationsFilter.sortingFields.add(
            new DC_SortingField(DC_EventRelationDAO.FIELD_RELATION_NAME));
        
        //- initialize and fill a sub-filter for child attachments
        filter.selectAttachments = selectAttachments;
        if (selectAttachments)
        {
            filter.attachmentsFilter = new DC_AttachmentDAO.Filter();
            filter.attachmentsFilter.sortingFields.add(
                new DC_SortingField( DC_AttachmentDAO.FIELD_NAME));
        }
        
        //STEP #2: get and return events
        return DC_EventDAO.getEventsByFilter(filter);
    }
    
    public static DC_EventNoticeReceiver[] generateReceivers(EventRelation[] attendees)
    {
        //check passed parameters
        if (attendees == null)
        {
            return null;
        }
        
        List<DC_EventNoticeReceiver> receivers = new List<DC_EventNoticeReceiver>();
        for (EventRelation attendee : attendees)
        {
            //only SF-users should receive emails
            if (attendee.Relation.Type == DC_SObjectUtils.USER_TYPE)
            {
                //generate iCalendarUID 
                String iCalendarUID = generateICalendarUID(attendee.EventId, attendee.Id);
                //generate and add a new receiver
                receivers.add(new DC_EventNoticeReceiver(attendee.RelationId,
                    null, iCalendarUID));
            }
        }
        return receivers;
    }
    
    public static DC_EventNoticeReceiver generateReceiverForOrganizer(Event event)
    {
        //check passed parameters
        if (event == null)
        {
            return null;
        }
        //generate iCalendarUID 
        String iCalendarUID = generateICalendarUID(event.Id, event.OwnerId);
        //generate and return a receiver
        return new DC_EventNoticeReceiver(event.OwnerId, null, iCalendarUID);
    }
    
    public static Event[] selectEventsForNotices(Event[] events)
    {
        //check passed parameters
        if (events == null)
        {
            return null;
        }
        
        List<Event> selectedEvents = new List<Event>();
        for (Event event : events)
        {
            if (customNoticesEnabled(event))
            {
                selectedEvents.add(event);
            }
        }
        return selectedEvents;
    }
    
    public static Event [] selectEventsForNoticesWhenCreating(Event[] events, boolean fromTrigger){
        //check passed parameters
        if (events == null)
        {
            return null;
        }
        
        List<Event> selectedEvents = new List<Event>();
        
        for (Event event : selectEventsForNotices(events))
        {
            if (!fromTrigger || event.Bypass_Auto_Invites_When_Creating__c == null || event.Bypass_Auto_Invites_When_Creating__c == false)
            {
                selectedEvents.add(event);
            }
        }
        
        return selectedEvents;
    }
    
    public static EventRelation[] findNewAttendees(Event oldEvent, Event newEvent)
    {
        return findAttendees(oldEvent, newEvent, CODE_NEW_ATTENDEES);
    }
    
    public static EventRelation[] findDeletedAttendees(Event oldEvent, Event newEvent)
    {
        return findAttendees(oldEvent, newEvent, CODE_DELETED_ATTENDEES);
    }
    
    public static EventRelation[] findUnchangedAttendees(Event oldEvent, Event newEvent)
    {
        return findAttendees(oldEvent, newEvent, CODE_UNCHANGED_ATTENDEES);
    }
    
    public static Boolean isUpdateNoticeRequired(Event oldEvent, Event newEvent,
        EventRelation[] newAttendees, EventRelation[] deletedAttendees)
    {
        if (oldEvent == null || newEvent == null)
        {
            return false;
        }
        
        Boolean isUpdateNoticeRequired =
            (oldEvent.Subject != newEvent.Subject ||
            oldEvent.Location != newEvent.Location ||
            oldEvent.OwnerId != newEvent.OwnerId ||
            oldEvent.StartDateTime != newEvent.StartDateTime ||
            oldEvent.EndDateTime != newEvent.EndDateTime ||
            oldEvent.IsAllDayEvent != newEvent.IsAllDayEvent ||
            newEvent.IsRecurrence &&
                (oldEvent.RecurrenceType != newEvent.RecurrenceType ||
                oldEvent.RecurrenceInterval != newEvent.RecurrenceInterval ||
                oldEvent.RecurrenceTimeZoneSidKey != newEvent.RecurrenceTimeZoneSidKey ||
                oldEvent.RecurrenceStartDateTime != newEvent.RecurrenceStartDateTime ||
                oldEvent.RecurrenceEndDateOnly != newEvent.RecurrenceEndDateOnly ||
                oldEvent.RecurrenceMonthOfYear != newEvent.RecurrenceMonthOfYear ||
                oldEvent.RecurrenceInstance != newEvent.RecurrenceInstance ||
                oldEvent.RecurrenceDayOfWeekMask != newEvent.RecurrenceDayOfWeekMask ||
                oldEvent.RecurrenceDayOfMonth != newEvent.RecurrenceDayOfMonth) ||
            (oldEvent.Send_Calendar_Invites__c == false && newEvent.Send_Calendar_Invites__c == true) ||
            (newAttendees != null && newAttendees.size() > 0) ||
            (deletedAttendees != null && deletedAttendees.size() > 0)
            );
        
        return isUpdateNoticeRequired;
    }
    
    
    public static void generateAndSendEmails(DC_EventNoticesBuildersGroup[] buildersGroups)
    {
        //check passed parameters
        if (buildersGroups == null)
        {
            return;
        }
        
        //STEP #1: prepare necessary data
        DC_SObjectHelper organizersHelper = initializeHelperForOrganizers(buildersGroups);
        
        //STEP #2: generate emails
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        for (DC_EventNoticesBuildersGroup buildersGroup : buildersGroups)
        {
            Event currentEvent = buildersGroup.event;
            
            //- get organizer for the event
            User organizer = (User)organizersHelper.getSObjectById(currentEvent.OwnerId);
            
            //- initialize the build parameters which will be used in all builders
            DC_EventNoticesBuilder.BuildParameters parameters =
                new DC_EventNoticesBuilder.BuildParameters();
            //- initialize and set a content builder
            parameters.contentBuilder = new DC_EventNoticeContentBuilder(currentEvent, organizer);
            //- build and set a templated ICalendar-content
            DC_ICalendarContentBuilder iCalendarBuilder =
                DC_ICalendarForSfEventUtils.initializeBuilder(currentEvent, organizer);
            parameters.iCalendarTemplate = iCalendarBuilder.buildContent(true);
            
            //build messages in an every builder
            for (DC_EventNoticesBuilder noticesBuilder : buildersGroup.builders)
            {
                emails.addAll(noticesBuilder.buildMessages(parameters));
            }
        }
        
        //STEP #3: send all emails
        DC_EmailUtils.sendEmails(emails, true);
    }
    
    public static String generateICalendarUID(String eventId, String participantId)
    {
        return String.format(UID_FORMAT, new String[] {eventId, participantId, partOfUID_InstanceUrl});
    }
    
    public static ICalendarUID parseICalendarUID(String keyInString)
    {
        //check input parameters
        if (String.isBlank(keyInString))
        {
            return null;
        }
        
        //extract parts of the key
        String[] partsOfKey = keyInString.split(SEPARATOR_IN_UID);
        //analyze parts of the UID and create a UID-object
        ICalendarUID uId = null;
        if (partsOfKey.size() == NUMBER_OF_PARTS_IN_UID
            && partsOfKey[INDEX_OF_EVENT_ID_IN_UID].length() == DC_SObjectUtils.ID_LENGTH
            && DC_SObjectUtils.idBelongToSObject(partsOfKey[INDEX_OF_EVENT_ID_IN_UID], Event.SObjectType)
            && partsOfKey[INDEX_OF_PERSON_ID_IN_UID].length() == DC_SObjectUtils.ID_LENGTH)
        {
            //in this branch we can create a correct key
            uId = new ICalendarUID();
            uId.eventId = partsOfKey[INDEX_OF_EVENT_ID_IN_UID];
            uId.personId = partsOfKey[INDEX_OF_PERSON_ID_IN_UID];
            uId.hostName = partsOfKey[INDEX_OF_HOST_NAME_IN_UID];
        }
        
        return uId;
    }
    //
    
    
    
    
    //
    //Data types
    //
    public class ICalendarUID
    {
        //
        //Properties
        //
        public String eventId {get; set;}
        public String personId {get; set;}
        public String hostName {get; set;}
        //
    }
    //
}