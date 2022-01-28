//
//This class is a content builder for an ICS-file.
//
//Author: Gennadiy Pervukhin (5-11-2014)
public class DC_ICalendarContentBuilder
{
	//
	//Constructors
	//
	public DC_ICalendarContentBuilder()
	{
		this.isAllDayEvent = false;
		this.attendees = new List<Participant>();
	}
	//
	
	//
	//Constants
	//
	private static final String SEPARATOR_OF_CONTENT_LINES = '\n';
	private static final String SEPARATOR_OF_ATTRIBUTES = ';';
	private static final String SEPARATOR_OF_ATTRIBUTE_VALUES = ',';
	
	private static final String UNKNOWN_EMAIL = 'unknown_email';
	
	private static final String DATETIME_FORMAT = 'yyyyMMdd\'T\'HHmmss\'Z\'';
	private static final String DATE_FORMAT = 'yyyyMMdd';
	
	private static final String REQUEST_METHOD = 'REQUEST';
	private static final String CANCEL_METHOD = 'CANCEL';
	
	private static final String VERSION = '2.0';
	private static final String PRODUCT_ID = '-//salesforce.com/Custom_Event_Notifier//EN';
	private static final String DEFAULT_TRANSPARENCY = 'OPAQUE';
	private static final String DEFAULT_SEQUENCE = '0';
	private static final String DEFAULT_CLASS = 'PUBLIC';
	private static final String DEFAULT_PRIORITY = '5';
	
	public static final String STATUS_CONFIRMED = 'CONFIRMED';
	public static final String STATUS_TENTATIVE = 'TENTATIVE';
	public static final String STATUS_CANCELLED = 'CANCELLED';
	
	public static final String FREQUENCY_DAILY = 'DAILY';
	public static final String FREQUENCY_WEEKLY = 'WEEKLY';
	public static final String FREQUENCY_MONTHLY = 'MONTHLY';
	public static final String FREQUENCY_YEARLY = 'YEARLY';
	
	public static final String WEEK_DAY_SUNDAY = 'SU';
	public static final String WEEK_DAY_MONDAY = 'MO';
	public static final String WEEK_DAY_TUESDAY = 'TU';
	public static final String WEEK_DAY_WEDNESDAY = 'WE';
	public static final String WEEK_DAY_THURSDAY = 'TH';
	public static final String WEEK_DAY_FRIDAY = 'FR';
	public static final String WEEK_DAY_SATURDAY = 'SA';
	//
	
	//
	//Private variables
	//
	private String status;
	private String method;
	//
	
	//
	//Public variables
	//
	public Boolean isAllDayEvent;
	public DateTime startDateTime;
	public DateTime endDateTime;
	
	public Participant organizer;
	public String uId;
	public String location;
	public String summary;
	public String description;
	public String htmlDescription;
	
	public RecurrenceRule recurrentRule;
	public Alarm eventAlarm;
	//
	
	//
	//Properties
	//
	public List<Participant> attendees {get; private set;}
	//
	
	//
	//Private static methods
	//
	private static void addNonBlankContentLine(List<String> contentLines,
		String propertyName, String propertyValue)
	{
		if (String.isNotBlank(propertyValue))
		{
			contentLines.add(propertyName + propertyValue);
		}
	}
	
	private static String generateParticipantValue(Participant participant, Boolean addRSVP)
	{
		//add CN
		String participantValue = 'CN="' + participant.name + '"';
		//add RSVP
		if (addRSVP)
		{
			participantValue += ';RSVP=' + participant.isReplyExpected;
		}
		//add SENT-BY
		if (String.isNotBlank(participant.delegateEmail))
		{
			participantValue += ';SENT-BY="MAILTO:' + participant.delegateEmail + '"';
		}
		//add email address of the calendar user
		participantValue += ':MAILTO:' + (String.isNotBlank(participant.email)
			? participant.email : participant.delegateEmail);
		
		return participantValue;
	}
	
	private static String formatDateTimeProperty(String propertyName, DateTime dateTimeValue)
	{           
        return (propertyName + ':' + dateTimeValue.formatGmt(DATETIME_FORMAT));
	}
	//
	
	//
	//Private methods
	//
	private Boolean isStateCorrect(Boolean forTemplate)
	{
		return (this.startDateTime != null && this.endDateTime != null
			&& this.organizer != null
			&& (forTemplate || String.isNotBlank(this.uId)));
	}
	
	private void addEventDates(List<String> contentLines)
	{
		if (this.isAllDayEvent == true)
		{   
			contentLines.add(formatDateTimeProperty('DTSTART', convertLocalTimeToUTC(this.startDateTime)));
			contentLines.add(formatDateTimeProperty('DTEND', convertLocalTimeToUTC(this.endDateTime)));
		}
        else
		{   
			contentLines.add(formatDateTimeProperty('DTSTART', this.startDateTime));
			contentLines.add(formatDateTimeProperty('DTEND', this.endDateTime));
		}
	}
    
    private DateTime convertLocalTimeToUTC(DateTime dateTimeValue){
        TimeZone organiserTimeZone = UserInfo.getTimeZone();
        Integer offset = organiserTimeZone.getOffset(dateTimeValue) / 1000;
        
        return dateTimeValue.addSeconds(-offset);
    }
	
	private void addRecurrenceRule(List<String> contentLines)
	{
		if (this.recurrentRule != null && this.recurrentRule.endDateTime != null
			&& String.isNotBlank(this.recurrentRule.frequency))
		{
			List<String> attributes = new List<String>();
			//add frequency which is required
			attributes.add('FREQ=' + this.recurrentRule.frequency);
			//add INTERVAL (optional)
			if (this.recurrentRule.interval != null)
			{
				attributes.add('INTERVAL=' + this.recurrentRule.interval);
			}
			//add BYDAY (optional)
			String byDaysAttribute = DC_StringUtils.safeJoin(
				this.recurrentRule.byDays, SEPARATOR_OF_ATTRIBUTE_VALUES);
			if (String.isNotBlank(byDaysAttribute))
			{
				attributes.add('BYDAY=' + byDaysAttribute);
			}
			//add BYMONTHDAY (optional)
			String byMonthDaysAttribute = DC_StringUtils.safeJoin(
				this.recurrentRule.byMonthDays, SEPARATOR_OF_ATTRIBUTE_VALUES);
			if (String.isNotBlank(byMonthDaysAttribute))
			{
				attributes.add('BYMONTHDAY=' + byMonthDaysAttribute);
			}
			//add BYMONTH (optional)
			String byMonthsAttribute = DC_StringUtils.safeJoin(
				this.recurrentRule.byMonths, SEPARATOR_OF_ATTRIBUTE_VALUES);
			if (String.isNotBlank(byMonthsAttribute))
			{
				attributes.add('BYMONTH=' + byMonthsAttribute);
			}
			//add BYSETPOS (optional)
			String daysPositionsAttribute = DC_StringUtils.safeJoin(
				this.recurrentRule.positionsOfDays, SEPARATOR_OF_ATTRIBUTE_VALUES);
			if (String.isNotBlank(daysPositionsAttribute))
			{
				attributes.add('BYSETPOS=' + daysPositionsAttribute);
			}
			//add UNTIL (required)
			attributes.add('UNTIL=' + this.recurrentRule.endDateTime.formatGmt(DATETIME_FORMAT));
			
			//add RECURRENT RULE with all generated attributes
			contentLines.add('RRULE:' + DC_StringUtils.safeJoin(attributes, SEPARATOR_OF_ATTRIBUTES));
		}
	}
	
	private void addAlarm(List<String> contentLines)
	{
		if (this.eventAlarm != null && String.isNotBlank(this.eventAlarm.description)
			&& this.eventAlarm.offsetInMinutesFromStart != null)
		{
			contentLines.add('BEGIN:VALARM');
			contentLines.add('TRIGGER:'
				+ (this.eventAlarm.offsetInMinutesFromStart <= 0 ? '-' : '+')
				+ 'PT' + Math.abs(this.eventAlarm.offsetInMinutesFromStart) + 'M');
			//currently the system supports 'DISPLAY' action only 
			contentLines.add('ACTION:DISPLAY');
			contentLines.add('DESCRIPTION:' +
				DC_ICalendarContentUtils.escapeTextValue(this.eventAlarm.description));
			contentLines.add('END:VALARM');
		}
	}
	//
	
	//
	//Public methods
	//
	public void setStatus(String status)
	{
		//1) set status
		this.status = status;
		//2) set method
		this.method = getMethodForStatus(status);
	}
	
	/*
	The method builds correct content for an ics-file.
	All special chars in TEXT fields should be escaped otherwise a content will
	not be correct.	Here is the list of properties which have TEXT data type: PRODID,
	VERSION, METHOD, CN, DESCRIPTION, X-ALT-DESC, LOCATION, STATUS, SUMMARY, TRANSP.
	As for now, I'm sure that PRODID, VERSION, METHOD, STATUS and TRANSP properties
	always have	correct values, that's why I don't escape their	values and it allows
	me to get a better performance of this method. So, I directly escape only the
	following properties: DESCRIPTION, X-ALT-DESC, LOCATION, SUMMARY. And I use
	double quotes around CN values instead of escaping of its value. So, if the
	situation is changed then we will have to directly escape the values for other
	fields.
	*/
	public String buildContent(Boolean forTemplate)
	{
		//if the state of the builder is not correct then return null
		if (!isStateCorrect(forTemplate))
		{
			return null;
		}
		
		List<String> contentLines = new List<String>();
		//start the file
		contentLines.add('BEGIN:VCALENDAR');
		//add some system parameters of the file
		//- method is optional
		addNonBlankContentLine(contentLines, 'METHOD:',
			(forTemplate ? DC_ICalendarPlaceholder.METHOD : this.method));
		contentLines.add('PRODID:' + PRODUCT_ID);
		contentLines.add('VERSION:' + VERSION);
		
		//start the event
		contentLines.add('BEGIN:VEVENT');
		//add organizer details
		contentLines.add('ORGANIZER;' + generateParticipantValue(this.organizer, false));
		
		//add event dates
		this.addEventDates(contentLines);
	    //summary is optional
		addNonBlankContentLine(contentLines, 'SUMMARY:',
			DC_ICalendarContentUtils.escapeTextValue(this.summary));
		//location is optional
		addNonBlankContentLine(contentLines, 'LOCATION:',
			DC_ICalendarContentUtils.escapeTextValue(this.location));
		//TRY TO ADD a RECERRENCE RULE FOR the EVENT
		this.addRecurrenceRule(contentLines);
		
		//add attendees
	    for (Participant attendee : this.attendees)
	    {
	    	if (attendee != null)
	    	{
	    		contentLines.add('ATTENDEE;' + generateParticipantValue(attendee, true));
	    	}
	    }
	    
	    //add HTML-desciption (it's optional)
	    addNonBlankContentLine(contentLines, 'X-ALT-DESC;FMTTYPE=text/html:',
	    	DC_ICalendarContentUtils.escapeTextValue(this.htmlDescription));
	    //add plain text description (it's optional)
	    addNonBlankContentLine(contentLines, 'DESCRIPTION:',
	    	DC_ICalendarContentUtils.escapeTextValue(this.description));
		
		//add UID
		contentLines.add('UID:' + (forTemplate ? DC_ICalendarPlaceholder.UID : this.uId));
		//add STATUS (it's optional)
		addNonBlankContentLine(contentLines, 'STATUS:',
			(forTemplate ? DC_ICalendarPlaceholder.STATUS : this.status));
		
		//add some other system parameters
		contentLines.add('CLASS:' + DEFAULT_CLASS);
		contentLines.add('PRIORITY:' + DEFAULT_PRIORITY);
		contentLines.add('TRANSP:' + DEFAULT_TRANSPARENCY);
		contentLines.add('SEQUENCE:' + DEFAULT_SEQUENCE);
		
		String currentDateTimeStamp = DateTime.now().formatGmt(DATETIME_FORMAT);
		contentLines.add('DTSTAMP:' + currentDateTimeStamp);
		contentLines.add('CREATED:' + currentDateTimeStamp);
		contentLines.add('LAST-MODIFIED:' + currentDateTimeStamp);
		
		//TRY TO ADD an ALARM FOR the EVENT
		this.addAlarm(contentLines);
		
		//complete the event and the file
		contentLines.add('END:VEVENT');
		contentLines.add('END:VCALENDAR');
        
		return String.join(contentLines, SEPARATOR_OF_CONTENT_LINES);
	}
	//
	
	
	//
	//Public static methods
	//
	public static String getMethodForStatus(String status)
	{
		if (status == STATUS_CONFIRMED || status == STATUS_TENTATIVE)
		{
			return REQUEST_METHOD;
		}
		else if (status == STATUS_CANCELLED)
		{
			return CANCEL_METHOD;
		}
		return null;
	}
	//
	
	
	//
	//Data types
	//
	public class Participant
	{
		//
		//Constructors
		//
		public Participant(String name, String email, String delegateEmail, Boolean isReplyExpected)
		{
			this.name = name;
			this.email = (String.isNotBlank(email) ? email : UNKNOWN_EMAIL);
			this.delegateEmail = delegateEmail;
			this.isReplyExpected = isReplyExpected;
		}
		
		public Participant(String name, String email, Boolean isReplyExpected)
		{
			this(name, email, null, isReplyExpected);
		}
		//
		
		//
		//Properties
		//
		public String name {get; set;}
		public String email {get; set;}
		public String delegateEmail {get; set;}
		public Boolean isReplyExpected {get; set;}
		//
	}
	
	public class Alarm
	{
		//
		//Properties
		//
		public String description {get; set;}
		public Integer offsetInMinutesFromStart {get; set;}
		//
	}
	
	public class RecurrenceRule
	{
		//
		//Properties
		//
		//FREQ
		public String frequency {get; set;}
		//INTERVAL
		public Integer interval {get; set;}
		//BYDAY
		public String[] byDays {get; set;}
		//BYMONTH
		public Integer[] byMonths {get; set;}
		//BYMONTHDAY
		public Integer[] byMonthDays {get; set;}
		//BYSETPOS
		public Integer[] positionsOfDays {get; set;}
		//UNTIL
		public DateTime endDateTime {get; set;}
		//
	}
	//
}