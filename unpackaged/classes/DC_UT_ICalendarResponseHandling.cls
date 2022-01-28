//
//This class provides Unit tests for the subsystem which processes ICalendar-responses.
//Used abbreviations:
//- UT - unit tests
//- EDTT - email data transfer type
//
//Author: Gennadiy Pervukhin (13-11-2014)
@IsTest
private class DC_UT_ICalendarResponseHandling
{
	//
	//Constants
	//
	private static final Integer EDTT_BODY = 0;
	private static final Integer EDTT_BINARY_ATTACHMENT = 1;
	private static final Integer EDTT_TEXT_ATTACHMENT = 2;
	//
	
	//
	//Service methods
	//
	private static void prepareEnvironment()
	{
		//disable all triggers to optimize creation of test data
		DC_SettingsUtils.setTriggersSettingForCurrentRequest(false);
	}
	
	private static String generateIcsResponse(Event event, String iCalendarKey,
		String participationStatus, String comment)
	{
		String icsResponse = 'BEGIN:VCALENDAR\n'
			+ 'PRODID:-//Microsoft Corporation//Outlook 11.0 MIMEDIR//EN\n'
			+ 'VERSION:2.0\n'
			+ 'METHOD:REPLY\n'
			+ 'BEGIN:VEVENT\n'
			+ 'ORGANIZER:MAILTO:organizer@test.com\n'
			+ 'DTSTART:20141014T200000Z\n'
			+ 'DTEND:20141015T200000Z\n'
			+ 'TRANSP:OPAQUE\n'
			+ 'SEQUENCE:0\n'
			+ 'UID:' + iCalendarKey + '\n'
			+ 'DTSTAMP:20140714T065218Z\n'
			+ 'SUMMARY:Accepted: ' + event.Subject + '\n'
			+ 'DESCRIPTION:' + (comment != null ? comment : DC_StringUtils.EMPTY_STRING) + '\n'
			+ 'PRIORITY:5\n'
			+ 'X-MICROSOFT-CDO-IMPORTANCE:1\n'
			+ 'CLASS:PUBLIC\n'
			+ 'ATTENDEE;PARTSTAT=' + participationStatus + ':MAILTO:person@test.com\n'
			+ 'END:VEVENT\n'
			+ 'END:VCALENDAR\n'
		;
		
		return icsResponse;
	}
	
	private static Messaging.InboundEmail generateEmail(Event event,
		String icsResponse, String participationStatus, Integer emailDataTransferType)
	{
		Messaging.InboundEmail email = new Messaging.InboundEmail();
		email.subject = participationStatus + ': ' + event.Subject;
		email.fromAddress = 'dc_unit_tester@test.com';
		email.fromName = UserInfo.getName();
		
		//add ICS-content to the email according to the transfer type
		if (emailDataTransferType == EDTT_BODY)
		{
			email.plainTextBody = icsResponse;
		}
		else if (emailDataTransferType == EDTT_BINARY_ATTACHMENT)
		{
			Messaging.InboundEmail.BinaryAttachment binaryAttachment =
				new Messaging.InboundEmail.BinaryAttachment();
			binaryAttachment.fileName = 'response.ics';
			//mime type can be either ICS_APPLICATION or TEXT_CALENDAR_FILE
			binaryAttachment.mimeTypeSubType = DC_FileMimeType.ICS_APPLICATION;
			binaryAttachment.body = Blob.valueOf(icsResponse);
			
			email.binaryAttachments = new Messaging.InboundEmail.BinaryAttachment[] {
				binaryAttachment};
		}
		else if (emailDataTransferType == EDTT_TEXT_ATTACHMENT)
		{
			Messaging.InboundEmail.TextAttachment textAttachment =
				new Messaging.InboundEmail.TextAttachment();
			textAttachment.fileName = 'response.ics';
			//mime type can be either ICS_APPLICATION or TEXT_CALENDAR_FILE
			textAttachment.mimeTypeSubType = DC_FileMimeType.TEXT_CALENDAR_FILE;
			textAttachment.body = icsResponse;
			
			email.textAttachments = new Messaging.InboundEmail.TextAttachment[] {
				textAttachment};
		}
		
		return email;
	}
	
	private static void checkResults(Messaging.InboundEmailResult handlingResults,
		String relationId, String expectedStatus, String expectedComment)
	{
		//check that result is successful
		System.assertEquals(true, handlingResults.success);
		
		//re-read the attendee's data and check them
		EventRelation updatedRelation = DC_EventRelationDAO.getRelationById(relationId);
		System.assertEquals(expectedStatus, updatedRelation.Status);
		System.assertEquals(expectedComment, updatedRelation.Response);
	}
	//
	
	
	
	//
	//Test methods for 'DC_ES_ICalendarResponseHandler' and 'DC_ICalendarResponseManager' classes
	//
	@IsTest
	private static void test_ICalendarResponseHandler_mainWorkFlow()
	{
		//STEP #1: prepare the environment
		prepareEnvironment();
		
		//STEP #2: generate test data
		//- create a test event
		Event event1 = DC_UT_DataUtils.generateEvent('Event-1', DateTime.now(),
			DateTime.now().addHours(1));
		insert event1;
		//- create a test attendee
		User sfUser1 = DC_UT_DataUtils.createSfUser('ut_user1');
		EventRelation relation1 = DC_UT_DataUtils.generateEventRelation(event1.Id, sfUser1.Id);
		insert relation1;
		
		
		//STEP #3: perform testing
		//- TEST #1: respond with 'ACCEPTED' status
		String newStatus = 'ACCEPTED';
		String newComment = 'comment1';
		//generate ICS-response
		String iCalendarUID = DC_EventNoticesUtils.generateICalendarUID(event1.Id, relation1.Id);
		String icsResponse = generateIcsResponse(event1, iCalendarUID, newStatus, newComment);
		//generate a email with the response
		Messaging.InboundEmail emailWithResponse = generateEmail(event1, icsResponse,
			newStatus, EDTT_BINARY_ATTACHMENT);
		//execute the method
		DC_ES_ICalendarResponseHandler handler = new DC_ES_ICalendarResponseHandler();
		Messaging.InboundEmailResult handlingResults = handler.handleInboundEmail(
			emailWithResponse, new Messaging.InboundEnvelope());
		//check the results
		checkResults(handlingResults, relation1.Id,
			DC_AttendeeParticipationStatus.convertToKnownStatus(newStatus), newComment);
		
		
		//- TEST #2: respond with 'CONFIRMED' status and a new comment
		newStatus = 'CONFIRMED';
		newComment = 'comment'.repeat(100);
		//generate ICS-response
		icsResponse = generateIcsResponse(event1, iCalendarUID, newStatus, newComment);
		//generate a email with the response
		emailWithResponse = generateEmail(event1, icsResponse,
			newStatus, EDTT_TEXT_ATTACHMENT);
		//execute the method
		handlingResults = handler.handleInboundEmail(emailWithResponse,
			new Messaging.InboundEnvelope());
		//check the results
		checkResults(handlingResults, relation1.Id,
			DC_AttendeeParticipationStatus.convertToKnownStatus(newStatus),
			newComment.substring(0, DC_ICalendarResponseManager.MAX_LENGTH_OF_COMMENT));
		
		
		//- TEST #3: respond with 'DECLINED' status and an empty comment
		newStatus = 'DECLINED';
		newComment = null;
		//generate ICS-response
		icsResponse = generateIcsResponse(event1, iCalendarUID, newStatus, newComment);
		//generate a email with the response
		emailWithResponse = generateEmail(event1, icsResponse, newStatus, EDTT_BODY);
		//execute the method
		handlingResults = handler.handleInboundEmail(emailWithResponse,
			new Messaging.InboundEnvelope());
		//check the results
		checkResults(handlingResults, relation1.Id,
			DC_AttendeeParticipationStatus.convertToKnownStatus(newStatus), newComment);
		
		
		//- TEST #4: respond with 'TENTATIVE' status and a new comment
		newStatus = 'TENTATIVE';
		newComment = 'comment3';
		//generate ICS-response
		icsResponse = generateIcsResponse(event1, iCalendarUID, newStatus, newComment);
		//generate a email with the response
		emailWithResponse = generateEmail(event1, icsResponse,
			newStatus, EDTT_TEXT_ATTACHMENT);
		//execute the method
		handlingResults = handler.handleInboundEmail(emailWithResponse,
			new Messaging.InboundEnvelope());
		//check the results
		checkResults(handlingResults, relation1.Id,
			DC_AttendeeParticipationStatus.convertToKnownStatus(newStatus), newComment);
	}
	
	@IsTest
	private static void test_ICalendarResponseHandler_NegativeScenarios()
	{
		//STEP #1: prepare the environment
		prepareEnvironment();
		
		//STEP #2: generate test data
		//- create a test event
		Event event1 = DC_UT_DataUtils.generateEvent('Event-1', DateTime.now(),
			DateTime.now().addHours(1));
		insert event1;
		//- create a test attendee
		User sfUser1 = DC_UT_DataUtils.createSfUser('ut_user1');
		EventRelation relation1 = DC_UT_DataUtils.generateEventRelation(event1.Id, sfUser1.Id);
		relation1.Status = DC_AttendeeParticipationStatus.ACCEPTED;
		relation1.Response = 'Comment';
		insert relation1;
		
		
		//STEP #3: perform testing
		//- TEST #1: respond without ICS-content
		//generate ICS-response
		String iCalendarUID = DC_EventNoticesUtils.generateICalendarUID(event1.Id, relation1.Id);
		String icsResponse = 'This is not ICalendar-file';
		//generate a email with the response
		Messaging.InboundEmail emailWithResponse = generateEmail(event1, icsResponse,
			'TEMP', EDTT_TEXT_ATTACHMENT);
		//execute the method
		DC_ES_ICalendarResponseHandler handler = new DC_ES_ICalendarResponseHandler();
		Messaging.InboundEmailResult handlingResults = handler.handleInboundEmail(
			emailWithResponse, new Messaging.InboundEnvelope());
		//check that the attendee was not updated
		checkResults(handlingResults, relation1.Id, relation1.Status, relation1.Response);
		
		
		//- TEST #2: ICS-content includes invalid UID
		//generate ICS-response
		icsResponse = generateIcsResponse(event1, 'unknown_format_of_UID', 'TEMP', 'Comment2');
		//generate a email with the response
		emailWithResponse = generateEmail(event1, icsResponse,
			DC_AttendeeParticipationStatus.DECLINED, EDTT_TEXT_ATTACHMENT);
		//execute the method
		handlingResults = handler.handleInboundEmail(emailWithResponse,
			new Messaging.InboundEnvelope());
		//check that the attendee was not updated
		checkResults(handlingResults, relation1.Id, relation1.Status, relation1.Response);
		
		
		//- TEST #3: ICS-content includes invalid participation status
		//generate ICS-response
		icsResponse = generateIcsResponse(event1, iCalendarUID, 'TEMP', 'Comment3');
		//generate a email with the response
		emailWithResponse = generateEmail(event1, icsResponse, 'TEMP', EDTT_TEXT_ATTACHMENT);
		//execute the method
		handlingResults = handler.handleInboundEmail(emailWithResponse,
			new Messaging.InboundEnvelope());
		//check that the attendee was not updated
		checkResults(handlingResults, relation1.Id, relation1.Status, relation1.Response);
		
		
		//- TEST #4: the attendee has been deleted
		delete relation1;
		//generate ICS-response
		icsResponse = generateIcsResponse(event1, iCalendarUID,
			DC_AttendeeParticipationStatus.DECLINED, 'Comment4');
		//generate a email with the response
		emailWithResponse = generateEmail(event1, icsResponse,
			DC_AttendeeParticipationStatus.DECLINED, EDTT_TEXT_ATTACHMENT);
		//execute the method
		handlingResults = handler.handleInboundEmail(emailWithResponse,
			new Messaging.InboundEnvelope());
		//check that result is successful and nothing failed
		System.assertEquals(true, handlingResults.success);
		
		
		//- TEST #5: the event has been deleted
		delete event1;
		//generate ICS-response
		icsResponse = generateIcsResponse(event1, iCalendarUID,
			DC_AttendeeParticipationStatus.DECLINED, 'Comment5');
		//generate a email with the response
		emailWithResponse = generateEmail(event1, icsResponse,
			DC_AttendeeParticipationStatus.DECLINED, EDTT_TEXT_ATTACHMENT);
		//execute the method
		handlingResults = handler.handleInboundEmail(emailWithResponse,
			new Messaging.InboundEnvelope());
		//check that result is successful and nothing failed
		System.assertEquals(true, handlingResults.success);
	}
	
	@IsTest
	private static void test_ICalendarResponseHandler_IncorrectParameters()
	{
		//simply check that nothing fails
		DC_ICalendarResponseManager responseManager = new DC_ICalendarResponseManager(null);
		responseManager.processResponse();
	}
	
	
	
	//
	//Test methods for DC_ICalendarParseUtils
	@IsTest
	private static void test_ICalendarParseUtils_isIcsContentValid()
	{
		//incorrect parameters
		System.assertEquals(false, DC_ICalendarParseUtils.isIcsContentValid(null));
		System.assertEquals(false, DC_ICalendarParseUtils.isIcsContentValid(''));
		System.assertEquals(false, DC_ICalendarParseUtils.isIcsContentValid('Invalid ICS-content'));
		
		//correct parameters
		String icsContent = generateIcsResponse(new Event(), 'ICalendarKey',
			DC_AttendeeParticipationStatus.ACCEPTED, 'Comment1');
		System.assertEquals(true, DC_ICalendarParseUtils.isIcsContentValid(icsContent));
	}
	
	@IsTest
	private static void test_ICalendarParseUtils_extractPropertyValue()
	{
		//incorrect parameters
		System.assertEquals(null, DC_ICalendarParseUtils.extractPropertyValue(null, null));
		System.assertEquals(null, DC_ICalendarParseUtils.extractPropertyValue(
			null, DC_ICalendarParseUtils.PROPERTY_DESCRIPTION));
		System.assertEquals(null, DC_ICalendarParseUtils.extractPropertyValue(
			'', DC_ICalendarParseUtils.PROPERTY_ATTENDEE));
		System.assertEquals(null, DC_ICalendarParseUtils.extractPropertyValue(
			'Invalid ICS-content', DC_ICalendarParseUtils.PROPERTY_UID));
		
		//correct parameters
		String iCalendarKey = 'ICalendarKey';
		String comment = 'Comment1';
		String icsContent = generateIcsResponse(new Event(), iCalendarKey,
			DC_AttendeeParticipationStatus.ACCEPTED, comment);
		System.assertEquals(iCalendarKey, DC_ICalendarParseUtils.extractPropertyValue(
			icsContent, DC_ICalendarParseUtils.PROPERTY_UID));
		System.assertEquals(comment, DC_ICalendarParseUtils.extractPropertyValue(
			icsContent, DC_ICalendarParseUtils.PROPERTY_DESCRIPTION));
	}
	
	@IsTest
	private static void test_ICalendarParseUtils_extractAttendeeParticipationStatus()
	{
		//incorrect parameters
		System.assertEquals(null, DC_ICalendarParseUtils.extractAttendeeParticipationStatus(null));
		System.assertEquals(null, DC_ICalendarParseUtils.extractAttendeeParticipationStatus(''));
		System.assertEquals(null, DC_ICalendarParseUtils.extractAttendeeParticipationStatus(
			'Invalid ICS-content'));
		
		//correct parameters
		String icsContent = generateIcsResponse(new Event(), 'ICalendarKey',
			DC_AttendeeParticipationStatus.ACCEPTED, 'Comment');
		System.assertEquals(DC_AttendeeParticipationStatus.ACCEPTED,
			DC_ICalendarParseUtils.extractAttendeeParticipationStatus(icsContent));
	}
	//
	
	
	
	//
	//Unit tests for 'DC_AttendeeParticipationStatus' class
	//
	@IsTest
	private static void test_AttendeeParticipationStatus_convertToKnownStatus()
	{
		//incorrect parameters
		System.assertEquals(null, DC_AttendeeParticipationStatus.convertToKnownStatus(null));
		System.assertEquals(null, DC_AttendeeParticipationStatus.convertToKnownStatus(''));
		System.assertEquals(null, DC_AttendeeParticipationStatus.convertToKnownStatus('Unknown_Status'));
		
		//correct parameters
		System.assertEquals(DC_AttendeeParticipationStatus.ACCEPTED,
			DC_AttendeeParticipationStatus.convertToKnownStatus('ACCEPTED'));
		System.assertEquals(DC_AttendeeParticipationStatus.ACCEPTED,
			DC_AttendeeParticipationStatus.convertToKnownStatus('Accepted'));
		System.assertEquals(DC_AttendeeParticipationStatus.ACCEPTED,
			DC_AttendeeParticipationStatus.convertToKnownStatus('Tentative'));
		System.assertEquals(DC_AttendeeParticipationStatus.DECLINED,
			DC_AttendeeParticipationStatus.convertToKnownStatus('DECLINED'));
	}
	//
}