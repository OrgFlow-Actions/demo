//
//This class provides Unit tests for ICalendar-utilities.
//
//Used abbreviations:
//- UT: unit tests
//Author: Gennadiy Pervukhin (14-11-2014)
@IsTest
private class DC_UT_ContentBuildersForEvent
{
	//
	//Service methods
	//
	private static void prepareEnvironment()
	{
		//disable all triggers to optimize creation of test data
		DC_SettingsUtils.setTriggersSettingForCurrentRequest(false);
		
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
	
	private static Event createTestEvent(PersonsData persons, Boolean isRecurrence)
	{
		//STEP #1: create a test event
		Event newEvent = DC_UT_DataUtils.generateEvent('Event-1', DateTime.now(),
			DateTime.now().addHours(1));
		newEvent.Location = 'Test Location';
		newEvent.Description = 'Test Description';
		
		if (isRecurrence)
		{
			newEvent.IsRecurrence = true;
			newEvent.RecurrenceType = DC_EventRecurrenceType.DAILY;
			newEvent.RecurrenceInterval = 50;
			newEvent.RecurrenceStartDateTime = newEvent.StartDateTime;
			newEvent.RecurrenceEndDateOnly = Date.today().addDays(400);
		}
		else
		{
			newEvent.IsRecurrence = false;
		}
		
		newEvent.IsReminderSet = true;
		newEvent.ReminderDateTime = newEvent.StartDateTime.addMinutes(-15);
		
		insert newEvent;
		
		//STEP #2: create test attendees
		List<EventRelation> newAttendees = new List<EventRelation>();
		//create an attendee for sfUser1
		newAttendees.add(DC_UT_DataUtils.generateEventRelation(newEvent.Id, persons.sfUser1.Id));
		//create an attendee for contact1
		newAttendees.add(DC_UT_DataUtils.generateEventRelation(newEvent.Id, persons.contact1.Id));
		insert newAttendees;
		
		//STEP #3: create test attachments
		Attachment attachment1 = DC_UT_DataUtils.generateAttachment(
			'A1', newEvent.Id, Blob.valueOf('Content'));
		insert attachment1;
		
		//- re-read the event to get all necessary data
		newEvent = DC_EventNoticesUtils.reReadEventsForNotices(new Event[] {newEvent}, true)[0];
		return newEvent;
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
	//Unit tests
	//
	private static void test_ContentBuildersForEvent(Event event, User organizer)
	{
		//1) initialize and configure DC_ICalendarContentBuilder
		DC_ICalendarContentBuilder iCalendarBuilder =
			DC_ICalendarForSfEventUtils.initializeBuilder(event, organizer);
		iCalendarBuilder.uId = 'UID1';
		iCalendarBuilder.setStatus(DC_ICalendarContentBuilder.STATUS_CANCELLED);
		
		//2) build ICalendar-content
		System.assert(String.isNotBlank(iCalendarBuilder.buildContent(false)));
		
		//3) initiliaze DC_EventNoticeContentBuilder and build content for a notification
		DC_EventNoticeContentBuilder noticeContentBuilder =
			new DC_EventNoticeContentBuilder(event, organizer);
		System.assert(String.isNotBlank(noticeContentBuilder.buildContent()));
	}
	
	@IsTest
	private static void test_GenerateContentsForEvents()
	{
		//prepare the environment
		prepareEnvironment();
		
		//CREATE TEST DATA
		//- create persons data
		PersonsData persons = createTestPersonsData();
		//- create a test event
		Event event = createTestEvent(persons, true);
		//- read the organizer
		User organizer = DC_UserDAO.getUsersByIds(new String[] {UserInfo.getUserId()})[0];
		
		//TEST #1: (change recurrence type)
		//- configure the event
		event.RecurrenceType = DC_EventRecurrenceType.DAILY;
		event.RecurrenceInterval = 10;
		//- test the methods for the event
		test_ContentBuildersForEvent(event, organizer);
		
		//TEST #2: (change recurrence type)
		//- configure the event
		event.RecurrenceType = DC_EventRecurrenceType.EVERY_WEEKDAY;
		event.RecurrenceDayOfWeekMask = 100;
		//- test the methods for the event
		test_ContentBuildersForEvent(event, organizer);
		
		//TEST #3: (change recurrence type)
		//- configure the event
		event.RecurrenceType = DC_EventRecurrenceType.WEEKLY;
		event.RecurrenceInterval = 3;
		event.RecurrenceDayOfWeekMask = 100;
		//- test the methods for the event
		test_ContentBuildersForEvent(event, organizer);
		
		//TEST #4: (change recurrence type)
		//- configure the event
		event.RecurrenceType = DC_EventRecurrenceType.MONTHLY;
		event.RecurrenceInterval = 1;
		event.RecurrenceDayOfMonth = 15;
		//- test the methods for the event
		test_ContentBuildersForEvent(event, organizer);
		
		//TEST #5: (change recurrence type)
		//- configure the event
		event.RecurrenceType = DC_EventRecurrenceType.MONTHLY_Nth;
		event.RecurrenceInterval = 1;
		event.RecurrenceDayOfWeekMask = 32;
		event.RecurrenceInstance = DC_SfRecurrenceFrequency.CODE_FIRST;
		//- test the methods for the event
		test_ContentBuildersForEvent(event, organizer);
		
		//TEST #6: (change recurrence type)
		//- configure the event
		event.RecurrenceType = DC_EventRecurrenceType.YEARLY;
		event.RecurrenceDayOfMonth = 28;
		event.RecurrenceMonthOfYear = DC_SfMonth.SEPTEMBER;
		//- test the methods for the event
		test_ContentBuildersForEvent(event, organizer);
		
		//TEST #7.1: (change recurrence type and set All-Day flag)
		//- configure the event
		event.IsAllDayEvent = true;
		event.RecurrenceType = DC_EventRecurrenceType.YEARLY_Nth;
		event.RecurrenceDayOfWeekMask = 32;
		event.RecurrenceMonthOfYear = DC_SfMonth.SEPTEMBER;
		event.RecurrenceInstance = DC_SfRecurrenceFrequency.CODE_LAST;
		//- test the methods for the event
		test_ContentBuildersForEvent(event, organizer);
		
		//TEST #7.2: (use incorrect data)
		//- configure the event
		event.RecurrenceType = DC_EventRecurrenceType.YEARLY_Nth;
		event.RecurrenceMonthOfYear = null;
		//- test the methods for the event
		test_ContentBuildersForEvent(event, organizer);
		
		//TEST #8: event2 => (disable reminder and recurrence rule)
		//- create a test event2
		Event event2 = createTestEvent(persons, false);
		event2.IsReminderSet = false;
		//- test the methods for the event
		test_ContentBuildersForEvent(event2, organizer);
		
		//TEST #9: event2 => (set All-Day flag)
		//- configure the event2
		event2.IsAllDayEvent = true;
		//- test the methods for the event
		test_ContentBuildersForEvent(event2, organizer);
	}
	
	@IsTest
	private static void test_ICalendarContentBuilder_buildContent_incorrectParams()
	{
		//- 'buildContent' method
		DC_ICalendarContentBuilder builder = new DC_ICalendarContentBuilder();
		System.assertEquals(null, builder.buildContent(true));
		//- 'getMethodForStatus' method
		System.assertEquals(null, DC_ICalendarContentBuilder.getMethodForStatus(null));
	}
	
	@IsTest
	private static void test_EventNoticeContentBuilder_incorrectParams()
	{
		//- 'buildContent' method
		try
		{
			DC_EventNoticeContentBuilder builder = new DC_EventNoticeContentBuilder(null, null);
			System.assert(false);
		}
		catch (Exception error)
		{
			System.assert(true);
		}
	}
	
	@IsTest
	private static void test_ICalendarContentUtils_unfoldContent_incorrectParams()
	{
		//- 'unfoldContent' method
		System.assertEquals(null, DC_ICalendarContentUtils.unfoldContent(null));
	}
	
	@IsTest
	private static void test_SfWeekDay_incorrectParams()
	{
		//- 'extractDayCodesFromMask' method
		System.assertEquals(0, DC_SfWeekDay.extractDayCodesFromMask(-1).size());
		//- 'extractDayNamesFromMask' method
		System.assertEquals(0, DC_SfWeekDay.extractDayNamesFromMask(-1).size());
	}
	
	
	@IsTest
	private static void test_EmailTemplatesUtils_generateHtmlLink()
	{
		//incorrect parameters
		System.assertEquals(null, DC_EmailTemplatesUtils.generateHtmlLink(null, null));
		System.assertEquals('click me', DC_EmailTemplatesUtils.generateHtmlLink('click me', null));
		
		//correct parameters
		System.assert(String.isNotBlank(DC_EmailTemplatesUtils.generateHtmlLink(
			'click me', 'http:\\www.salesforce.com')));
	}
	//
}