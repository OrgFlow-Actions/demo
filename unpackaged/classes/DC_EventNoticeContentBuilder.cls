//
//This class builds HTML-content for an event notification.
//
//Author: Gennadiy Pervukhin [Cervello] (5-11-2014)
public class DC_EventNoticeContentBuilder
{
	//
	//Constructors
	//
	public DC_EventNoticeContentBuilder(Event event, User organizer)
	{
		if (event == null || organizer == null)
		{
			throw new DC_CustomException('DC_EventNoticeContentBuilder was '
				+ 'initialized with incorrect parameters');
		}
		
		this.event = event;
		this.organizer = organizer;
		this.ogranizerTimeZone = TimeZone.getTimeZone(this.organizer.TimeZoneSidKey);
		this.eventTelephoneNumber = getTelephoneNumber();
	}
	//
	
	//
	//Variables
	//
	private Event event;
	private User organizer;
	private TimeZone ogranizerTimeZone;
	//this variable stores a generated content for reusing
	private String generatedNoticeContent;
	//this variable stores the telephone number of the associated account or contact
	//this reduces the number of SOQL calls required when multiple invites are generated for a single event
	private String eventTelephoneNumber;
	
	//these 2 variables are used to optimize the work with an email template
	private static String noticeTemplate;
	private static Boolean isNoticeTemplateQueried = false;
	//
	
	//
	//Constants
	//
	@TestVisible
	private static final String EMAIL_TEMPLATE_NAME = 'DC_EVENT_NOTIFICATION';
	
    private static final String KEY_MEETING_SUMMARY = '{%MEETING_SUMMARY%}';
    
	private static final String KEY_EVENT_DETAILS = '{%EVENT_DETAILS%}';
	
	private static final String EVENT_DETAILS_ROW =
		'<tr>\n' +
			'<th width="15%" style="text-align: right;" valign="top">{0}</th>\n' +
			'<td width="85%" style="text-align: left;" valign="top">{1}</td>\n' +
		'</tr>\n';
	
	private static final String SUFFIX_OF_ITEM_IN_LIST = ' - ';
	private static final String SEPARATOR_OF_LIST_ITEMS = '<br/>';
	private static final String SEPARATOR_OF_DAYS = ', ';
	
	//these constants describes user-friendly format of different recurrence rules
	private static final String RRULE_FORMAT_DAILY = System.Label.DC_RRULE_FORMAT_DAILY;//'Occurs every {0} day(s)';
	private static final String RRULE_FORMAT_WEEKDAY = System.Label.DC_RRULE_FORMAT_WEEKDAY;//'Occurs every weekday';
	private static final String RRULE_FORMAT_WEEKLY = System.Label.DC_RRULE_FORMAT_WEEKLY;//'Occurs every {0} week(s) on {1}';
	private static final String RRULE_FORMAT_MONTHLY = System.Label.DC_RRULE_FORMAT_MONTHLY;//'Occurs on day {0} of every {1} month(s)';
	private static final String RRULE_FORMAT_MONTHLY_Nth = System.Label.DC_RRULE_FORMAT_MONTHLY_Nth;//'Occurs on the {0} {1} of every {2} month(s)';
	private static final String RRULE_FORMAT_YEARLY = System.Label.DC_RRULE_FORMAT_YEARLY;//'Occurs every {0} {1}';
	private static final String RRULE_FORMAT_YEARLY_Nth = System.Label.DC_RRULE_FORMAT_YEARLY_Nth;//'Occurs on the {0} {1} of {2}';
	
	private static final String RRULE_FORMAT_COMMON_DATE_SUFFIX = System.Label.DC_RRULE_FORMAT_COMMON_DATE_SUFFIX;//' effective {0} until {1}';
	private static final String RRULE_FORMAT_COMMON_TIME_SUFFIX = System.Label.DC_RRULE_FORMAT_COMMON_TIME_SUFFIX;//' from {0} until {1} {2}';
	
	private static final String WHEN_FORMAT_ALL_DAY_EVENT = System.Label.DC_WHEN_FORMAT_ALL_DAY_EVENT;//'{0} All-Day Event';
	//
	
	//
	//Private static methods
	//
	private static String generateEventDetailsRow(String parameterName,
		String parameterValue)
	{
		return String.format(EVENT_DETAILS_ROW,
			new String[] {parameterName, parameterValue});
	}
	
	private static void prepareNoticeTemplate()
	{
		//the code tries to read the template 1 time per a transaction
		if (!isNoticeTemplateQueried)
		{
			EmailTemplate emailTemplate =
				DC_EmailTemplateDAO.getTemplateByDeveloperName(EMAIL_TEMPLATE_NAME);
			noticeTemplate = (emailTemplate != null ? emailTemplate.HtmlValue : null);
			
			isNoticeTemplateQueried = true;
		}
	}
	
	private static String formatDaysList(Integer bitMask)
	{
		return DC_StringUtils.safeJoin(DC_SfWeekDay.extractDayNamesFromMask(bitMask),
			SEPARATOR_OF_DAYS);
	}
	
	private static String formatDaysList_NthRule(Integer bitMask)
	{
		return (bitMask == DC_SfWeekDay.CODE_ALL_DAYS ? 'day' : formatDaysList(bitMask));
	}
	//
	
	//
	//Private methods
	//
	private String formatDateTime(DateTime sourceDateTime, String format)
	{
		return sourceDateTime.format(format, this.organizer.TimeZoneSidKey);
	}

	private String getTelephoneNumber(){
		System.debug('getTelephoneNumber');

		if(this.event.WhoId != null){
			List<Contact> contacts = [Select Phone FROM Contact WHERE Id = :this.event.WhoId];
			System.debug(contacts);

			if(contacts.size() > 0){
				Contact con = contacts[0];

				if(!String.isBlank(con.Phone)){
					return con.Phone;
				}
			}
		}

		
		Id accountId = this.event.WhatId;
		if(accountId != null){
			List<Account> accounts = [Select Phone FROM Account WHERE Id = :accountId];
			if(accounts.size() > 0){
				Account acc = accounts[0];

				if(acc.Phone != null){
					return acc.Phone;
				}
			}
		}

		return null;
	}
	
	private String generateRecurrenceDetails()
	{
		String recurrenceDetails = DC_StringUtils.EMPTY_STRING;
		if (this.event.RecurrenceType == DC_EventRecurrenceType.DAILY)
		{
			recurrenceDetails = String.format(RRULE_FORMAT_DAILY,
				new String[] {String.valueOf(this.event.RecurrenceInterval)});
		}
		else if (this.event.RecurrenceType == DC_EventRecurrenceType.EVERY_WEEKDAY)
		{
			recurrenceDetails = RRULE_FORMAT_WEEKDAY;
		}
		else if (this.event.RecurrenceType == DC_EventRecurrenceType.WEEKLY)
		{
			String formattedDays = formatDaysList(this.event.RecurrenceDayOfWeekMask);
			recurrenceDetails = String.format(RRULE_FORMAT_WEEKLY, new String[] {
				String.valueOf(this.event.RecurrenceInterval), formattedDays});
		}
		else if (this.event.RecurrenceType == DC_EventRecurrenceType.MONTHLY)
		{
			recurrenceDetails = String.format(RRULE_FORMAT_MONTHLY, new String[] {
				String.valueOf(this.event.RecurrenceDayOfMonth),
				String.valueOf(this.event.RecurrenceInterval)});
		}
		else if (this.event.RecurrenceType == DC_EventRecurrenceType.MONTHLY_Nth)
		{
			String formattedDays = formatDaysList_NthRule(this.event.RecurrenceDayOfWeekMask);
			recurrenceDetails = String.format(RRULE_FORMAT_MONTHLY_Nth, new String[] {
				DC_SfRecurrenceFrequency.convertFrequencyCode(this.event.RecurrenceInstance),
				formattedDays, String.valueOf(this.event.RecurrenceInterval)});
		}
		else if (this.event.RecurrenceType == DC_EventRecurrenceType.YEARLY)
		{
			recurrenceDetails = String.format(RRULE_FORMAT_YEARLY, new String[] {
				this.event.RecurrenceMonthOfYear, String.valueOf(this.event.RecurrenceDayOfMonth)});
		}
		else if (this.event.RecurrenceType == DC_EventRecurrenceType.YEARLY_Nth)
		{
			String formattedDays = formatDaysList_NthRule(this.event.RecurrenceDayOfWeekMask);
			recurrenceDetails = String.format(RRULE_FORMAT_YEARLY_Nth, new String[] {
				DC_SfRecurrenceFrequency.convertFrequencyCode(this.event.RecurrenceInstance),
				formattedDays, this.event.RecurrenceMonthOfYear});
		}
		
		return recurrenceDetails;
	}
	
	private String generateWhenDetails()
	{
		String whenDetails;
		if (this.event.IsRecurrence == true)
		{
			//generate description of recurrence type
			whenDetails = generateRecurrenceDetails();
			
			//add effective dates
			//- convert end date only to datetime value
			DateTime eventEndDateTime = this.event.RecurrenceEndDateOnly;
			//- format the value (end datetime should be formatted in UTC timezone)
			whenDetails += String.format(RRULE_FORMAT_COMMON_DATE_SUFFIX, new String[] {
				formatDateTime(this.event.RecurrenceStartDateTime, DC_DateTimeUtils.DEFAULT_DATE_FORMAT),
				eventEndDateTime.formatGmt(DC_DateTimeUtils.DEFAULT_DATE_FORMAT)});
			
			//add time of an every event if it's not an all day event
			if (this.event.IsAllDayEvent != true)
			{
				whenDetails += String.format(RRULE_FORMAT_COMMON_TIME_SUFFIX, new String[] {
					formatDateTime(this.event.StartDateTime, DC_DateTimeUtils.DEFAULT_TIME_FORMAT),
					formatDateTime(this.event.EndDateTime, DC_DateTimeUtils.DEFAULT_TIME_FORMAT),
					this.ogranizerTimeZone.getDisplayName()});
			}
		}
		else
		{
			//format datetime according to IsAllDayEvent flag
			if (this.event.IsAllDayEvent != true)
			{
				//- format datetime range
				whenDetails = DC_DateTimeUtils.formatDateTimeRange(
					this.event.StartDateTime, this.event.EndDateTime,
					this.organizer.TimeZoneSidKey);
			}
			else
			{
				//- format date range (ignore time zone conversions)
				String dateRange = DC_DateTimeUtils.formatDateRangeGmt(
					this.event.StartDateTime, this.event.EndDateTime);
				whenDetails = String.format(WHEN_FORMAT_ALL_DAY_EVENT,
					new String[] {dateRange});
			}
		}
		
		return whenDetails;
	}
	
	private String generateEventDetailsContent()
	{
		String eventDetailsContent = '';
		
		//STEP #1: add basic information
		//- add subject
		eventDetailsContent += generateSubjectField();
		//- add when details 
		eventDetailsContent += generateEventDetailsRow(System.Label.DC_When, generateWhenDetails());
		//- add location
		if (String.isNotBlank(this.event.Location))
		{
			eventDetailsContent += generateEventDetailsRow(System.Label.DC_Where, this.event.Location);
		}
		//- add telephone number
		if (String.isNotBlank(this.eventTelephoneNumber))
		{
			eventDetailsContent += generateEventDetailsRow(System.Label.DC_TelephoneNumber, this.eventTelephoneNumber);
		}
		//- add description
		if (String.isNotBlank(this.event.Description))
		{
			eventDetailsContent += generateEventDetailsRow(System.Label.DC_Description, this.event.Description);
		}
		
		
		//STEP #2: add information about event relations
		//- add an organizer
		String attendeesContent = SUFFIX_OF_ITEM_IN_LIST + this.organizer.Name
			+ ' (' + System.Label.DC_Organizer + ')' + SEPARATOR_OF_LIST_ITEMS;
		
		//- analyze event relations and build a content with attendees (relations
		//with persons: users/contacts/leads)
		List<EventRelation> eventResources = new List<EventRelation>();
		for (EventRelation eventRelation : this.event.EventRelations)
		{
			if (eventRelation.Relation.Type != DC_SObjectUtils.CALENDAR_RESOURCE_TYPE)
			{
				//add an attendee
				attendeesContent += SUFFIX_OF_ITEM_IN_LIST + eventRelation.Relation.Name
					+ ' (' + eventRelation.Relation.Type + ')' + SEPARATOR_OF_LIST_ITEMS;
			}
			else
			{
				eventResources.add(eventRelation);
			}
		}
		//- add attendees content
		eventDetailsContent += generateEventDetailsRow(System.Label.DC_Attendees, attendeesContent);
		
		//- add all resources
		if (eventResources.size() > 0)
		{
			String resourcesContent = '';
			for (EventRelation resource : eventResources)
			{
				resourcesContent += SUFFIX_OF_ITEM_IN_LIST + resource.Relation.Name
					+ SEPARATOR_OF_LIST_ITEMS;
			}
			eventDetailsContent += generateEventDetailsRow(System.Label.DC_Resources, resourcesContent);
		}
		
		
		//STEP #3: add information about attachments
		if (this.event.Attachments.size() > 0)
		{
			String attachmentsContent = '';
			for (Attachment attachment : this.event.Attachments)
			{
				String attachmentUrl = DC_PageReferenceUtils.getFullUrl(
					DC_PageReferenceUtils.createReferenceToViewPage(attachment.Id));
				attachmentsContent += SUFFIX_OF_ITEM_IN_LIST
					+ DC_EmailTemplatesUtils.generateHtmlLink(attachment.Name, attachmentUrl)
					+ SEPARATOR_OF_LIST_ITEMS;
			}
			eventDetailsContent += generateEventDetailsRow(System.Label.DC_Attachments, attachmentsContent);
		}
        
		eventDetailsContent += generateAdditionaFields();
		return eventDetailsContent;
	}
    
    private String generateSubjectField() {
        String link = String.format('<a href="{0}/{1}">{2}</a>', 
                                    new String[] { System.Url.getSalesforceBaseUrl().toExternalForm(), 
                                        this.event.Id, 
                                        this.event.Subject });
        return generateEventDetailsRow(System.Label.DC_Subject, link);
    }
    
    private String generateAdditionaFields() {
        String[] additionField = new String[]{};
        additionField.add(generateEventDetailsRow(System.Label.DC_Astra_Tech_Type, this.event.Astra_Tech_Type__c));
        if (String.isNotBlank(this.event.Co_travel__c)) additionField.add(generateEventDetailsRow(System.Label.DC_Co_travel , this.event.Co_travel__c));
        if (String.isNotBlank(this.event.Objective__c)) additionField.add(generateEventDetailsRow(System.Label.DC_Objective, this.event.Objective__c));
        return String.join(additionField, '');
    }
	
	private String buildTemplatedNoticeContent()
	{
		//generate a content with the event details
		String eventDetailsContent = this.generateEventDetailsContent();
        //upadate a header in the template 
        String updatedTemplate = DC_StringUtils.safeReplace(noticeTemplate, KEY_MEETING_SUMMARY, 
                                   System.Label.DC_MeetingSummary);
		//insert the content in the template
		String noticeContent = DC_StringUtils.safeReplace(updatedTemplate,
			KEY_EVENT_DETAILS, eventDetailsContent);
		
		return noticeContent;
	}
	//
	
	//
	//Public methods
	//
	public String buildContent()
	{
		if (this.generatedNoticeContent == null)
		{
			//prepare a notice template
			prepareNoticeTemplate();
			//build a notice content
			this.generatedNoticeContent = this.buildTemplatedNoticeContent();
		}
		return this.generatedNoticeContent;
	}
	//
}