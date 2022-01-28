//
//This class provides utilities to make compatible ICalendar-format and SF-event.
//
//Author: Gennadiy Pervukhin (11-11-2014)
public class DC_ICalendarForSfEventUtils
{
	//
	//Constants
	//
	private static final String ALARM_DESCRIPTION_FORMAT = 'Reminder for {0}';
	
	//all responses should go to this address, not to an address of a real organizer
	private static final String RESPONSE_MANAGER_EMAIL = DC_SettingsUtils.getStringValueByName(
		DC_SettingsUtils.ADDRESS_OF_REPLY_TO_EVENT_NOTICE);
	//
	
	//
	//Private static methods
	//
	private static void setAlarm(DC_ICalendarContentBuilder iCalendarBuilder, Event event)
	{ 
		//stop the method if reminder is not set
		if (event.IsReminderSet != true)
		{
			return;
		}
		
		iCalendarBuilder.eventAlarm = new DC_ICalendarContentBuilder.Alarm();
		//set alarm description
		iCalendarBuilder.eventAlarm.description = String.format(
			ALARM_DESCRIPTION_FORMAT, new String[] {event.Subject});
		//set alarm offset in minutes
		iCalendarBuilder.eventAlarm.offsetInMinutesFromStart =
			DC_DateTimeUtils.calculateOffsetInMinutes(event.StartDateTime,
				event.ReminderDateTime);
	}
	
	private static void setRecurrenceRule(DC_ICalendarContentBuilder iCalendarBuilder,
		Event event)
	{
		//stop the method if it's not a recurring event
		if (event.IsRecurrence != true)
		{
			return;
		}
		
		//set basic parameters
		DC_ICalendarContentBuilder.RecurrenceRule rule =
			new DC_ICalendarContentBuilder.RecurrenceRule();
		//in ICalendar we should set end date and time. That's why we take end
		//date of the recurring event and convert it to datetime, which is equal
		//to the end of this day
		DateTime eventEndDateTime = event.RecurrenceEndDateOnly;
		rule.endDateTime = eventEndDateTime.addDays(1).addSeconds(-1);
		
		//set parameters which depend on recurrence type
		if (event.RecurrenceType == DC_EventRecurrenceType.DAILY)
		{
			rule.frequency = DC_ICalendarContentBuilder.FREQUENCY_DAILY;
			rule.interval = event.RecurrenceInterval;
		}
		else if (event.RecurrenceType == DC_EventRecurrenceType.EVERY_WEEKDAY)
		{
			rule.frequency = DC_ICalendarContentBuilder.FREQUENCY_WEEKLY;
			rule.byDays = DC_ICalendarContentUtils.convertSfWeekDayCodes(
				event.RecurrenceDayOfWeekMask);
		}
		else if (event.RecurrenceType == DC_EventRecurrenceType.WEEKLY)
		{
			rule.frequency = DC_ICalendarContentBuilder.FREQUENCY_WEEKLY;
			rule.interval = event.RecurrenceInterval;
			rule.byDays = DC_ICalendarContentUtils.convertSfWeekDayCodes(
				event.RecurrenceDayOfWeekMask);
		}
		else if (event.RecurrenceType == DC_EventRecurrenceType.MONTHLY)
		{
			rule.frequency = DC_ICalendarContentBuilder.FREQUENCY_MONTHLY;
			rule.interval = event.RecurrenceInterval;
			rule.byMonthDays = createSafeIntegerArray(event.RecurrenceDayOfMonth);
		}
		else if (event.RecurrenceType == DC_EventRecurrenceType.MONTHLY_Nth)
		{
			rule.frequency = DC_ICalendarContentBuilder.FREQUENCY_MONTHLY;
			rule.interval = event.RecurrenceInterval;
			rule.byDays = DC_ICalendarContentUtils.convertSfWeekDayCodes(
				event.RecurrenceDayOfWeekMask);
			rule.positionsOfDays = getPositionsOfDays(event);
		}
		else if (event.RecurrenceType == DC_EventRecurrenceType.YEARLY)
		{
			rule.frequency = DC_ICalendarContentBuilder.FREQUENCY_YEARLY;
			rule.byMonthDays = createSafeIntegerArray(event.RecurrenceDayOfMonth);
			rule.byMonths = createSafeIntegerArray(
				DC_ICalendarContentUtils.convertSfMonthName(event.RecurrenceMonthOfYear));
		}
		else if (event.RecurrenceType == DC_EventRecurrenceType.YEARLY_Nth)
		{
			rule.frequency = DC_ICalendarContentBuilder.FREQUENCY_YEARLY;
			rule.byDays = DC_ICalendarContentUtils.convertSfWeekDayCodes(
				event.RecurrenceDayOfWeekMask);
			rule.byMonths = createSafeIntegerArray(
				DC_ICalendarContentUtils.convertSfMonthName(event.RecurrenceMonthOfYear));
			rule.positionsOfDays = getPositionsOfDays(event);
		}
		
		//set a new recurrence rule
		iCalendarBuilder.recurrentRule = rule;
	}
	
	private static Integer[] getPositionsOfDays(Event event)
	{
		Integer frequencyCode = DC_ICalendarContentUtils.convertSfFrequencyCode(
			event.RecurrenceInstance);
		return createSafeIntegerArray(frequencyCode);
	}
	
	private static Integer[] createSafeIntegerArray(Integer value)
	{
		if (value != null)
		{
			return (new Integer[] {value});
		}
		return null;
	}
	//
	
	//
	//Public static methods
	//
	public static DC_ICalendarContentBuilder initializeBuilder(
		Event event, User organizer)
	{
		DC_ICalendarContentBuilder iCalendarBuilder = new DC_ICalendarContentBuilder();
		
		//STEP #1: set parameters of the event
		iCalendarBuilder.summary = event.Subject;
		iCalendarBuilder.startDateTime = event.StartDateTime;
		iCalendarBuilder.isAllDayEvent = event.IsAllDayEvent;
		if (event.IsAllDayEvent == true)
		{
			//In SF end date of an all-day event is equal to the same one that
			//was selected in UI, but ICalendar requires that it is equal to the
			//next day after the day, which a user selected
			iCalendarBuilder.endDateTime = event.EndDateTime.addDays(1);
		}
		else
		{
			iCalendarBuilder.endDateTime = event.EndDateTime;
		}
		iCalendarBuilder.location = event.Location;
		iCalendarBuilder.description = event.Description;
		
		//- set an organizer
		iCalendarBuilder.organizer = new DC_ICalendarContentBuilder.Participant(
			organizer.Name, RESPONSE_MANAGER_EMAIL, organizer.Email, false);
		//- set attendees
		for (EventRelation eventRelation : event.EventRelations)
		{
			//only relations for SF-users should be included as attendees in iCalendar-file
			if (eventRelation.Relation.Type == DC_SObjectUtils.USER_TYPE)
			{
				//add an attendee (we expect reply from users only)
				iCalendarBuilder.attendees.add(new DC_ICalendarContentBuilder.Participant(
					eventRelation.Relation.Name, eventRelation.Relation.Email, true));
			}
		}
		
		//STEP #2: set an recurrence rule
		setRecurrenceRule(iCalendarBuilder, event);
		
		//STEP #3: set an alarm
		setAlarm(iCalendarBuilder, event);
		
		return iCalendarBuilder;
	}
	//
}