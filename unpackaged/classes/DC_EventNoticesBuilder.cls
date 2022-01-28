//
//This is an abstract class for builders of event notices (invite/update/cancel). 
//
//Author: Gennadiy Pervukhin (28-10-2014)
public abstract class DC_EventNoticesBuilder
{
	//
	//Constructors
	//
	public DC_EventNoticesBuilder(Event event, DC_EventNoticeReceiver[] noticeReceivers)
	{
		this.event = event;
		this.noticeReceivers = noticeReceivers;
	}
	//
	
	//
	//Constants
	//
	private static final String EMAIL_OF_SENDER = DC_SettingsUtils.getStringValueByName(
		DC_SettingsUtils.SEND_EVENT_NOTICES_FROM_ADDRESS);
	private static final String REPLY_TO_ADDRESS = DC_SettingsUtils.getStringValueByName(
		DC_SettingsUtils.ADDRESS_OF_REPLY_TO_EVENT_NOTICE);
	
	private static final String ICALENDAR_FILE_NAME = 'invite.ics';
	//text/calendar; method=REQUEST - doesn't work for GMail
	private static final String ICALENDAR_FILE_CONTENT_TYPE = 'text/calendar';
	//
	
	//
	//Variables
	//
	protected Event event;
	protected DC_EventNoticeReceiver[] noticeReceivers;
	//
	
	//
	//Private abstract methods
	//
	private abstract String generateEmailSubject();
	private abstract void configureICalendarBuilder(DC_ICalendarTemplatedBuilder iCalendarBuilder);
	//
	
	//
	//Private virtual methods
	//
	protected virtual String generateEmailBody(DC_EventNoticeContentBuilder contentBuilder)
	{
		return contentBuilder.buildContent();
	}
	//
	
	//
	//Private methods
	//
	//the method initializes a new instance of the templated builder and configures it
	private DC_ICalendarTemplatedBuilder createICalendarBuilder(String iCalendarTemplate)
	{
		DC_ICalendarTemplatedBuilder iCalendarBuilder =
			new DC_ICalendarTemplatedBuilder(iCalendarTemplate);
		//- configure the builder according to implementation in child classes
		this.configureICalendarBuilder(iCalendarBuilder);
		return iCalendarBuilder;
	}
	
	private DC_SingleEmailMessageBuilder createCommonEmailBuilder(
		DC_EventNoticeContentBuilder contentBuilder)
	{
		//initialize builder
		DC_SingleEmailMessageBuilder emailBuilder = new DC_SingleEmailMessageBuilder();
		
		//set subject
		emailBuilder.subject = this.generateEmailSubject();
		//set orgWideEmailAddressId
		emailBuilder.orgWideEmailAddressId =
			DC_OrgWideEmailReader.getOrgWideAddressIdByEmail(EMAIL_OF_SENDER);
		//set Reply-To address
		emailBuilder.replyToAddress = REPLY_TO_ADDRESS;
		
		//set email body
		emailBuilder.htmlBody = this.generateEmailBody(contentBuilder);
		
		return emailBuilder;
	}
	//
	
	//
	//Public methods
	//
	public Messaging.SingleEmailMessage[] buildMessages(BuildParameters buildParameters)
	{
		//check passed parameters
		if (buildParameters == null || !buildParameters.isStateCorrect())
		{
			return new Messaging.SingleEmailMessage[0];
		}
		
		//STEP #1: prepare necessary data and helpers
		//- initialize a list of result messages
		List<Messaging.SingleEmailMessage> listOfMessages =
			new List<Messaging.SingleEmailMessage>();
		
		//- create a common 'DC_SingleEmailMessageBuilder' object
		DC_SingleEmailMessageBuilder emailBuilder = createCommonEmailBuilder(
			buildParameters.contentBuilder);
		
		//- create a common templated iCalendar builder
		DC_ICalendarTemplatedBuilder iCalendarBuilder = this.createICalendarBuilder(
			buildParameters.iCalendarTemplate);
		
		//generate separate email message for an every target (email messages
		//differ in address of a receiver and ICS-file)
		for (DC_EventNoticeReceiver noticeReceiver : this.noticeReceivers)
		{
			//- clear previous attachments, create and add a new ICalendar-attachment
			emailBuilder.fileAttachments.clear();
			String iCalendarFileBody = iCalendarBuilder.buildContent(
				DC_ICalendarPlaceholder.UID, noticeReceiver.iCalendarUID);

			emailBuilder.addFileAttachment(ICALENDAR_FILE_NAME,
				ICALENDAR_FILE_CONTENT_TYPE, iCalendarFileBody, true);

			emailBuilder.addFileAttachment(ICALENDAR_FILE_NAME,
				ICALENDAR_FILE_CONTENT_TYPE + '; method=REQUEST', iCalendarFileBody, false);
			
			//- change a target
			emailBuilder.changeTarget(noticeReceiver);
			
			//- generate a email message
			Messaging.SingleEmailMessage currentMessage = emailBuilder.buildMessage();
			if (currentMessage != null)
			{
				listOfMessages.add(currentMessage);
			}
		}
		
		return listOfMessages;
	}
	//
	
	
	//
	//Data types
	//
	public class BuildParameters
	{
		//
		//Constructors
		//
		public BuildParameters()
		{
		}
		//
		
		//
		//Properties
		//
		public DC_EventNoticeContentBuilder contentBuilder {get; set;}
		public String iCalendarTemplate {get; set;}
		//
		
		//
		//Public methods
		//
		public Boolean isStateCorrect()
		{
			return (this.contentBuilder != null);
		}
		//
	}
	
	/*this interface is used to create a new 'DC_EventNoticesBuilder' class*/
	public interface ICreator
	{
		DC_EventNoticesBuilder createBuilder(Event event, DC_EventNoticeReceiver[] noticeReceivers);
	}
	//
}