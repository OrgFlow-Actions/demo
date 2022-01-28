//
//This class builds email invitations for events. 
//
//Author: Gennadiy Pervukhin (28-10-2014)
public class DC_EventInvitesBuilder extends DC_EventNoticesBuilder
{
	//
	//Constructors
	//
	public DC_EventInvitesBuilder(Event event, DC_EventNoticeReceiver[] noticeReceivers)
	{
		super(event, noticeReceivers);
	}
	//
	
	//
	//Constants
	//
	private static final Map<String, String> ICALENDAR_PLACEHOLDER_VALUES = new Map<String, String>
	{
		DC_ICalendarPlaceholder.STATUS => DC_ICalendarContentBuilder.STATUS_CONFIRMED,
		DC_ICalendarPlaceholder.METHOD => DC_ICalendarContentBuilder.getMethodForStatus(
			DC_ICalendarContentBuilder.STATUS_CONFIRMED)
	};
	//
	
	//
	//Private methods
	//
	private String generateEmailSubject()
	{
		return (this.event.Subject);
	}
	
	//the method replaces placeholders which depend on notification type
	private void configureICalendarBuilder(DC_ICalendarTemplatedBuilder iCalendarBuilder)
	{
		//- replace placeholder values
		iCalendarBuilder.replacePlaceholders(ICALENDAR_PLACEHOLDER_VALUES);
	}
	//
	
	
	
	//
	//Data types
	//
	/*this interface is used to create a new 'DC_EventInvitesBuilder' class*/
	public class Creator implements ICreator 
	{
		public DC_EventNoticesBuilder createBuilder(Event event,
			DC_EventNoticeReceiver[] noticeReceivers)
		{
			return (new DC_EventInvitesBuilder(event, noticeReceivers));
		}
	}
	//
}