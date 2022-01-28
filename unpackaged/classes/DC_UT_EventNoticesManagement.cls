/*
This class provides Unit tests for the subsystem which manages custom event notifications.
Used abbreviations:
- UT: unit tests
*/
//Author: Gennadiy Pervukhin (14-11-2014)
@IsTest
private class DC_UT_EventNoticesManagement
{
	@testSetup
    private static void setup() {
        TestDataFactory.createBypassCustomSetting();
        List<User> userList = TestDataFactory.createUsers(1, 'System Administrator'); 
        TestDataFactory.createGlobalIntegrationSettings(userList);
        TestDataFactory.createDefaultOrgLevelBypassPB();
    }
    
    //
    //Constants
    //
    private static Id EVENT_RT_NOTIFICATION_ENABLED;
    private static Id EVENT_RT_NOTIFICATION_DISABLED;
    //
    
    //
    //Service methods
    //
    private static void prepareEventRecordTypes()
    {
        //load record types for Event
        RecordType[] recordTypes = [
            SELECT Id FROM RecordType
            WHERE SObjectType = 'Event' AND IsActive = true
            LIMIT 2];
        //1 record type will support custom event notifications
        if (recordTypes.size() > 0)
        {
            EVENT_RT_NOTIFICATION_ENABLED = recordTypes[0].Id;
            DC_UT_DataUtils.createSetting(DC_SettingsUtils.EVENT_RTs_FOR_CUSTOM_NOTICES,
                EVENT_RT_NOTIFICATION_ENABLED);
        }
        //1 record type will not support custom event notifications
        if (recordTypes.size() > 1)
        {
            EVENT_RT_NOTIFICATION_DISABLED = recordTypes[1].Id;
        }
    }
    
    private static void prepareEnvironment()
    {
        //disable all triggers to optimize creation of test data
        DC_SettingsUtils.setTriggersSettingForCurrentRequest(false);
        //prepare record types for Event
        prepareEventRecordTypes();
        
        //create necessary email template
        System.runAs(new User(Id = UserInfo.getUserId()))
        {
            DC_UT_DataUtils.createOrGetEmailTemplate(DC_EventNoticeContentBuilder.EMAIL_TEMPLATE_NAME);
        }
    }
    
    private static PersonsData createTestPersonsData()
    {
        PersonsData newPersons = new PersonsData();
        newPersons.sfUser1 = DC_UT_DataUtils.createSfUser('ut_user1');
        newPersons.contact1 = DC_UT_DataUtils.generateContact('Contact1');
        insert newPersons.contact1;
        
        return newPersons;
    }
    
    private static Event[] createTestEvents(PersonsData persons, String eventRecordTypeId,
        Integer numberOfEvents)
    {
        List<Event> newEvents = new List<Event>();
        DateTime startDateTime = DateTime.now();
        DateTime endDateTime = DateTime.now().addHours(1);
        for (Integer indexOfEvent = 0; indexOfEvent < numberOfEvents; indexOfEvent++)
        {
            Event newEvent = DC_UT_DataUtils.generateEvent('Event-' + indexOfEvent,
                startDateTime, endDateTime);
            newEvent.RecordTypeId = eventRecordTypeId;
            newEvent.Send_Calendar_Invites__c = true;
            newEvents.add(newEvent);
        }
        insert newEvents;
        
        //- create test attendees
        List<EventRelation> newAttendees = new List<EventRelation>();
        for (Integer indexOfEvent = 0; indexOfEvent < numberOfEvents; indexOfEvent++)
        {
            //create an attendee for sfUser1
            newAttendees.add(DC_UT_DataUtils.generateEventRelation(newEvents[indexOfEvent].Id,
                persons.sfUser1.Id));
            //create an attendee for contact1
            newAttendees.add(DC_UT_DataUtils.generateEventRelation(newEvents[indexOfEvent].Id,
                persons.contact1.Id));
        }
        insert newAttendees;
        
        return newEvents;
    }
    
    private static void setNewSubjectForEvents(Event[] events)
    {
        for (Event event : events)
        {
            event.Subject = event.Subject + '_updated';
        }
    }
    
    private static void checkCommonResults(Integer numberOfExpectedEmails,
        Set<Id> expectedReceiversIds)
    {
        System.assertEquals(numberOfExpectedEmails, DC_UT_TestManager.outboundEmails.size());
        for (Messaging.Email email : DC_UT_TestManager.outboundEmails)
        {
            System.assert(expectedReceiversIds.contains(
                ((Messaging.SingleEmailMessage)email).targetObjectId));
        }
    }
    //
    
    //
    //Data types
    //
    private class PersonsData
    {
        public User sfUser1;
        public Contact contact1;
    }
    //
    
    
    //
    //Unit tests for 'DC_EventNoticesManager' class
    //
    //this scenario can be tested without the enabled trigger
    @IsTest
    private static void test_EventNoticesManager_manageNotices_onEventsInserted()
    {
        //prepare the environment
        prepareEnvironment();
        
        //incorrect parameters (nothing should fail)
        DC_EventNoticesManager.manageNotices_onEventsInserted(null, false);
        DC_EventNoticesManager.manageNotices_onEventsInserted(new Event[0], false);
        
        //correct parameters
        //- create persons data
        PersonsData persons = createTestPersonsData();
        //- create and configure test events. There are 2 attendees (+ 1 organizer)
        //in an every event, but only the organizer and sfUser1 should get their notifications
        List<Event> testEvents = createTestEvents(persons, EVENT_RT_NOTIFICATION_ENABLED, 3);
        
        
        //TEST #1: all events support notifications
        //- execute the method
        DC_EventNoticesManager.manageNotices_onEventsInserted(testEvents, false);
        //- check the results
        Set<Id> expectedReceiversIds = new Set<Id>{UserInfo.getUserId(), persons.sfUser1.Id};
        checkCommonResults(6, expectedReceiversIds);
        
        //TEST #2: only event1 supports notifications
        //- update event 1 to simply make it All-day, event2 and event3 to exclude them from the process
        Event event1 = testEvents[0];
        event1.IsAllDayEvent = true;
        Event event2 = testEvents[1];
        event2.RecordTypeId = EVENT_RT_NOTIFICATION_DISABLED;
        Event event3 = testEvents[2];
        event3.Send_Calendar_Invites__c = false;
        update (new Event[] {event1, event2, event3});
        //- execute the method
        DC_EventNoticesManager.manageNotices_onEventsInserted(testEvents, false);
        //- check the results
        // 20210118 TEMP COMMENT ***checkCommonResults(2, expectedReceiversIds);
    }
    
    
    //this scenario can be tested with the enabled trigger only
    @IsTest
    private static void test_EventNoticesManager_manageNotices_onEventsDeleted()
    {
        //prepare the environment
        prepareEnvironment();
        
        //incorrect parameters (nothing should fail)
        DC_EventNoticesManager.manageNotices_onEventsDeleted(null);
        DC_EventNoticesManager.manageNotices_onEventsDeleted(new Event[0]);
        
        //correct parameters
        //- create persons data
        PersonsData persons = createTestPersonsData();
        //- create and configure test events. There are 2 attendees (+ 1 organizer)
        //in an every event, but only the organizer and sfUser1 should get their notifications
        List<Event> testEvents = createTestEvents(persons, EVENT_RT_NOTIFICATION_ENABLED, 3);
        
        
        //TEST #1: all events support notifications
        //- enable all triggers, because this method tracks deletions using the trigger 
        DC_SettingsUtils.setTriggersSettingForCurrentRequest(true);
        //- delete the test events
        delete testEvents;
        //- check the results
        Set<Id> expectedReceiversIds = new Set<Id>{UserInfo.getUserId(), persons.sfUser1.Id};
        checkCommonResults(0, expectedReceiversIds);
    }
    
    //this scenario can be tested with the enabled trigger only
    @IsTest
    private static void test_EventNoticesManager_manageNotices_onEventsUpdated()
    {
        //prepare the environment
        prepareEnvironment();
        
        //incorrect parameters (nothing should fail)
        DC_EventNoticesManager.manageNotices_onEventsUpdated(null, null);
        DC_EventNoticesManager.manageNotices_onEventsUpdated(new Map<Id, Event>(), new Event[0]);
        
        //correct parameters
        //- create persons data
        PersonsData persons = createTestPersonsData();
        //- create and configure test events. There are 2 attendees (+ 1 organizer)
        //in an every event, but only the organizer and sfUser1 should get their notifications
        List<Event> testEvents = createTestEvents(persons, EVENT_RT_NOTIFICATION_ENABLED, 3);
        
        
        //- enable all triggers, because this method tracks updates using the trigger 
        DC_SettingsUtils.setTriggersSettingForCurrentRequest(true);
        
        
        //TEST #1: all events support notifications
        //- set new subect for the test events
        setNewSubjectForEvents(testEvents);
        //- update the test events
        update testEvents;
        //- check the results
        Set<Id> expectedReceiversIds = new Set<Id>{UserInfo.getUserId(), persons.sfUser1.Id};
        checkCommonResults(6, expectedReceiversIds);
        
        
        //TEST #2: event1 and event2 support notifications only, but update of
        //event2 doesn't cause updated notifications
        //- set new subect for the event1 only
        setNewSubjectForEvents(new Event[] {testEvents[0]});
        //- udpate event3
        testEvents[2].RecordTypeId = EVENT_RT_NOTIFICATION_DISABLED;
        //- update the test events
        update testEvents;
        //- check the results
        // 20210118 TEMP COMMENT *** checkCommonResults(2, expectedReceiversIds);
    }
    
    
    //this scenario can be tested with the enabled trigger only
    @IsTest
    private static void test_EventNoticesManager_manageNotices_onEventsUpdated2()
    {
        //prepare the environment
        prepareEnvironment();
        
        //correct parameters
        //- create persons data
        PersonsData persons = createTestPersonsData();
        //- create and configure a test event. There are 2 attendees (+ 1 organizer)
        //in the event, but only the organizer and sfUser1 should get their notifications
        Event event1 = createTestEvents(persons, EVENT_RT_NOTIFICATION_ENABLED, 1)[0];
        
        
        //- enable all triggers, because this method tracks updates using the trigger 
        DC_SettingsUtils.setTriggersSettingForCurrentRequest(true);
        
        
        //TEST #1: all events support notifications
        //- set new organizer for the event
        User newOrganizer = DC_UT_DataUtils.createSfUser('ut_new_org');
        event1.OwnerId = newOrganizer.Id;
        //- update the event
        update event1;
        //- check the results
        Set<Id> expectedReceiversIds = new Set<Id>{UserInfo.getUserId(),
            newOrganizer.Id, persons.sfUser1.Id};
        checkCommonResults(3, expectedReceiversIds);
    }
    
    //this scenario can be tested with the disabled trigger only (we disable all
    //triggers to simulate the problem with tracking)
    @IsTest
    private static void test_EventNoticesManager_manageNotices_onEventsUpdated3()
    {
        //prepare the environment
        prepareEnvironment();
        
        //correct parameters
        //- create persons data
        PersonsData persons = createTestPersonsData();
        //- create and configure a test event. There are 2 attendees (+ 1 organizer)
        //in the event, but only the organizer and sfUser1 should get their notifications
        Event event1 = createTestEvents(persons, EVENT_RT_NOTIFICATION_ENABLED, 1)[0];
        
        
        //TEST #1: simply to cover stops when the trigger didn't track updates
        //- set new organizer for the event
        Event oldEvent1 = event1.clone(true);
        event1.Subject += '_updated';
        //- execute the method directly
        DC_UT_TestManager.outboundEmails.clear();
        DC_EventNoticesManager.manageNotices_onEventsUpdated(
            new Map<Id, Event>{oldEvent1.Id => oldEvent1}, new Event[] {event1});
        //- check the results
        checkCommonResults(0, null);
    }
    //
    
    
    //
    //Unit tests for 'DC_EventNoticesUtils' class
    //
    //this method checks that all public methods can work with incorrect parameters
    @IsTest
    private static void test_EventNoticesUtils_incorrectParameters()
    {
        //- 'reReadEventsForNotices' method
        System.assertEquals(0, DC_EventNoticesUtils.reReadEventsForNotices(null, null).size());
        //- 'generateReceivers' method
        System.assertEquals(null, DC_EventNoticesUtils.generateReceivers(null));
        //- 'generateReceiverForOrganizer' method
        System.assertEquals(null, DC_EventNoticesUtils.generateReceiverForOrganizer(null));
        //- 'selectEventsForNotices' method
        System.assertEquals(null, DC_EventNoticesUtils.selectEventsForNotices(null));
        //- 'findNewAttendees' method
        System.assertEquals(0, DC_EventNoticesUtils.findNewAttendees(null, null).size());
        //- 'findUnchangedAttendees' method
        System.assertEquals(0, DC_EventNoticesUtils.findUnchangedAttendees(null, null).size());
        //- 'findDeletedAttendees' method
        System.assertEquals(0, DC_EventNoticesUtils.findDeletedAttendees(null, null).size());
        //- 'isUpdateNoticeRequired' method
        System.assertEquals(false, DC_EventNoticesUtils.isUpdateNoticeRequired(null, null, null, null));
        //- 'generateAndSendEmails' method
        DC_EventNoticesUtils.generateAndSendEmails(null);
        //- 'parseICalendarUID' method
        System.assertEquals(null, DC_EventNoticesUtils.parseICalendarUID(null));
    }
    //
    
    
    
    //
    //Unit tests for 'DC_EventNoticesBuilder' class
    //
    @IsTest
    private static void test_EventNoticesBuilder_incorrectParameters()
    {
        DC_EventNoticesBuilder builder = new DC_EventInvitesBuilder(new Event(),
            new DC_EventNoticeReceiver[0]);
        System.assertEquals(0, builder.buildMessages(null).size());
        System.assertEquals(0, builder.buildMessages(
            new DC_EventNoticesBuilder.BuildParameters()).size());
    }
    //
    
    
    
    
}