//
//This class provides the logic to manage responses to ICalendar-events.
//
//Author: Gennadiy Pervukhin (7-11-2014)
public class DC_ICalendarResponseManager
{
	//
	//Constructors
	//
	public DC_ICalendarResponseManager(Messaging.InboundEmail email)
	{
		this.email = email;
	}
	//
	
	//
	//Constants
	//
	@TestVisible
	private static final Integer MAX_LENGTH_OF_COMMENT = 255;
	
	private static final Set<String> SUPPORTED_FILE_MIME_TYPES = new Set<String> {
		DC_FileMimeType.TEXT_CALENDAR_FILE, DC_FileMimeType.ICS_APPLICATION};
	//
	
	//
	//Variables
	//
	private Messaging.InboundEmail email;

	private String icsContent;
	private DC_EventNoticesUtils.ICalendarUID iCalendarUID;
	private String newParticipationStatus;
	private String newComment;
	//
	
	//
	//Private static methods
	//
	private static String extractIcsContent(Messaging.InboundEmail email)
	{
		//STEP #1: try to find ICS-file in binary attachments
		if (email.binaryAttachments != null)
		{
			for (Messaging.InboundEmail.BinaryAttachment attachment : email.binaryAttachments)
			{
				//if we find ICS-file which is not empty, then we stop the method
				//and return content of the file
				if (SUPPORTED_FILE_MIME_TYPES.contains(attachment.mimeTypeSubType)
					&& attachment.body != null)
				{
					//body is of Blob type
					return attachment.body.toString();
				}
			}
		}
		
		//STEP #2: try to find ICS-file in text attachments
		if (email.textAttachments != null)
		{
			for (Messaging.InboundEmail.TextAttachment attachment : email.textAttachments)
			{
				//if we find ICS-file, then we stop the method and return content of the file
				if (SUPPORTED_FILE_MIME_TYPES.contains(attachment.mimeTypeSubType))
				{
					return attachment.body;
				}
			}
		}
		
		//STEP #3: if necessary content was not found in attachments, then we return
		//a text body of the email
		return email.plainTextBody;
	}
	
	private static Boolean isICalendarUIDSuitable(
		DC_EventNoticesUtils.ICalendarUID iCalendarUID)
	{
		return (iCalendarUID != null
			&& DC_SObjectUtils.idBelongToSObject(iCalendarUID.personId, EventRelation.SObjectType));
	}
	//
	
	//
	//Private methods
	//
	private Boolean processIcsContent()
	{
		//STEP #1: extract ICS-content
		this.icsContent = extractIcsContent(this.email);
		
		//STEP #2: process the results of the 1st step
		//- unfold the extracted ICS-content
		icsContent = DC_ICalendarContentUtils.unfoldContent(icsContent);
		
		//- validate the extracted ICS-content and return the result
		return DC_ICalendarParseUtils.isIcsContentValid(icsContent);
	}
	
	private Boolean processICalendarUID()
	{
		//- try to extract a string value of ICalendar-UID
		String iCalendarUIDInString = DC_ICalendarParseUtils.extractPropertyValue(
			this.icsContent, DC_ICalendarParseUtils.PROPERTY_UID);
		//- parse the extracted value
		this.iCalendarUID = DC_EventNoticesUtils.parseICalendarUID(iCalendarUIDInString);
		
		//- validate the iCalendar-UID and return the result
		return isICalendarUIDSuitable(this.iCalendarUID);
	}
	
	private Boolean processParticipationStatus()
	{
		//- extract participation status of an attendee
		String extractedParticipationStatus =
			DC_ICalendarParseUtils.extractAttendeeParticipationStatus(this.icsContent);
		//- convert the extracted status to a known status of participation
		this.newParticipationStatus = DC_AttendeeParticipationStatus.convertToKnownStatus(
			extractedParticipationStatus);
		
		//- check if the participation status was not found or was not converted
		return (String.isNotBlank(this.newParticipationStatus));
	}
	
	private void processComment()
	{
		//- extract a comment of an attendee
		this.newComment = DC_ICalendarParseUtils.extractPropertyValue(
			this.icsContent, DC_ICalendarParseUtils.PROPERTY_DESCRIPTION);
		//- correct the comment length
		if (this.newComment != null && this.newComment.length() > MAX_LENGTH_OF_COMMENT)
		{
			this.newComment = this.newComment.substring(0, MAX_LENGTH_OF_COMMENT);
		}
		//- unescape the comment
		this.newComment = DC_ICalendarContentUtils.unescapeTextValue(this.newComment);
	}
	
	private Boolean isAttendeeUpdateRequired(Event event, EventRelation attendee)
	{
		//update is required if either a status or a comment has been changed
		return (this.newParticipationStatus != attendee.Status
			|| (this.newComment != attendee.Response));
	}
	
	private void tryUpdateParticipationStatus()
	{
		//STEP #1: try to get an event
		Event event = DC_EventDAO.getEventById(this.iCalendarUID.eventId);
		//stop the method if the event has been deleted already
		if (event == null)
		{
			return;
		}
		//(Google doesn't allow to respond with a comment and simply sets an
		//original description of an event. We should ignore such comments)
		String applicableComment = (this.newComment != event.Description
			? this.newComment : null);
		
		//STEP #2: try to get an existing attendee
		EventRelation attendee = DC_EventRelationDAO.getRelationById(
			this.iCalendarUID.personId);
		//check that the attendee still exists and update is required
		if (attendee == null || !this.isAttendeeUpdateRequired(event, attendee))
		{
			return;
		}
		
		//STEP #3: set new parameters and update the object
		attendee.Status = this.newParticipationStatus;
		attendee.Response = applicableComment;
		attendee.RespondedDate = DateTime.now();
		Boolean isUpdateSuccessful = DC_SoqlUtils.tryPerformDmlOperation(
			DC_SoqlEnums.DmlOperation.Updating, attendee);
	}
	//
	
	//
	//Public static methods
	//
	//#WARNING: remove debugs
	public void processResponse()
	{
		//check input parameters
		if (this.email == null)
		{
			return;
		}
		
		//STEP #1: work with ICS-content
		Boolean isStepSuccessful = this.processIcsContent();
		System.debug('***** icsContent:\n' + icsContent);
		//- stop the method if the step is not successful
		if (!isStepSuccessful)
		{
			return;
		}
		
		//STEP #2: work with iCalendar-UID
		isStepSuccessful = this.processICalendarUID();
		//- stop the method if the step is not successful
		if (!isStepSuccessful)
		{
			return;
		}
		
		//STEP #3: work with the participation status of an attendee
		isStepSuccessful = this.processParticipationStatus();
		//- stop the method if the step is not successful
		if (!isStepSuccessful)
		{
			return;
		}
		
		//STEP #4: work with the comment of an attendee (no validations at this step)
		this.processComment();
		
		//STEP #5: if the method was not interrupted then we try to update a response
		this.tryUpdateParticipationStatus();
	}
	//
}