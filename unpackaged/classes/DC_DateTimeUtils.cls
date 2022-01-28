//
//This class contains utilities to work with DateTime. 
//
//Author: Gennadiy Pervukhin (5-11-2014)
public class DC_DateTimeUtils
{
	//
	//Constants
	//
	private static final Integer MILLISECONDS_IN_SECOND = 1000;
	private static final Integer MILLISECONDS_IN_MINUTE = 60000;
	
	public static final String DEFAULT_DATETIME_FORMAT = 'MM/dd/yyyy h:mm a';
	public static final String DEFAULT_DATE_FORMAT = 'MM/dd/yyyy';
	public static final String DEFAULT_TIME_FORMAT = 'h:mm a';
	
	private static final String FORMAT_OF_DATETIME_RANGE = '{0} - {1} {2}';
	private static final String SEPARATOR_OF_DATES_IN_RANGE = ' - ';
	//
	
	//
	//Public static methods
	//
	public static String formatDateTimeRange(DateTime startDateTimeGmt,
		DateTime endDateTimeGmt, String timeZoneId)
	{
		if (startDateTimeGmt == null || endDateTimeGmt == null
			|| String.isBlank(timeZoneId))
		{
			return null;
		}
		
		//STEP #1: prepare data
		//get an instance of a time zone
		TimeZone finalTimeZone = TimeZone.getTimeZone(timeZoneId);
		
		//convert start datetime from GMT to the passed time zone 
		startDateTimeGmt = startDateTimeGmt.addSeconds(
			finalTimeZone.getOffset(startDateTimeGmt)/MILLISECONDS_IN_SECOND);
		//convert end datetime from GMT to the passed time zone	
		endDateTimeGmt = endDateTimeGmt.addSeconds(
			finalTimeZone.getOffset(endDateTimeGmt)/MILLISECONDS_IN_SECOND);
		
		//STEP #2: build a formatted string
		String startDateTimeLabel = startDateTimeGmt.formatGmt(DEFAULT_DATETIME_FORMAT);
		//if start and end dates are equal then we don't show end date again (we
		//show end time only), otherwise we show end date and time
		String endDateTimeLabel;
		if (startDateTimeGmt.dateGmt() == endDateTimeGmt.dateGmt())
		{
			endDateTimeLabel = endDateTimeGmt.formatGmt(DEFAULT_TIME_FORMAT);
		}
        else
        {
            endDateTimeLabel = endDateTimeGmt.formatGmt(DEFAULT_DATETIME_FORMAT);
        }
		
		return String.format(FORMAT_OF_DATETIME_RANGE, new String[] {
			startDateTimeLabel, endDateTimeLabel, finalTimeZone.getDisplayName()});
	}
	
	public static String formatDateRangeGmt(DateTime startDateTimeGmt,
		DateTime endDateTimeGmt)
	{
		if (startDateTimeGmt == null || endDateTimeGmt == null)
		{
			return null;
		}
		
		//build a formatted string
		String formattedDateRange = startDateTimeGmt.formatGmt(DEFAULT_DATE_FORMAT);
		//if start and end dates are equal then we don't show end date again
		if (startDateTimeGmt.dateGmt() != endDateTimeGmt.dateGmt())
		{
			formattedDateRange += SEPARATOR_OF_DATES_IN_RANGE
				+ endDateTimeGmt.formatGmt(DEFAULT_DATE_FORMAT);
		}
		return formattedDateRange;
	}
	
	public static Integer calculateOffsetInMinutes(DateTime startDateTime,
		DateTime endDateTime)
	{
		if (startDateTime == null || endDateTime == null)
		{
			return 0;
		}
		
		Long offsetInMinutes = endDateTime.getTime() - startDateTime.getTime();
		return (Integer)(offsetInMinutes / MILLISECONDS_IN_MINUTE);
	}
	//
}