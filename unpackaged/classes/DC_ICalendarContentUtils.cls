//
//This class provides utilities to work with ICS-content.
//
//Author: Gennadiy Pervukhin (7-11-2014)
public class DC_ICalendarContentUtils
{
	//
	//Constants
	//
	private static final String SEPARATOR_OF_FOLDED_LINES = '\r\n\t';
	//
	
	//
	//Variables
	//
	//this map stores mappings between SF-code of week day and corresponding ICalendar-code
	private static Map<Integer, String> MAP_OF_WEEK_DAY_CODES;
	//this map stores mappings between SF-code of frequency and corresponding ICalendar-code
	private static Map<String, Integer> MAP_OF_FREQUENCY_CODES;
	//this map stores mappings between SF-name of month and corresponding ICalendar-code
	private static Map<String, Integer> MAP_OF_MONTH_CODES; 
	//
	
	//
	//Private static methods
	//
	private static Map<Integer, String> getMapOfWeekDayCodes()
	{
		if (MAP_OF_WEEK_DAY_CODES == null)
		{
			MAP_OF_WEEK_DAY_CODES = new Map<Integer, String>();
			MAP_OF_WEEK_DAY_CODES.put(DC_SfWeekDay.CODE_SUNDAY,
				DC_ICalendarContentBuilder.WEEK_DAY_SUNDAY);
			MAP_OF_WEEK_DAY_CODES.put(DC_SfWeekDay.CODE_MONDAY,
				DC_ICalendarContentBuilder.WEEK_DAY_MONDAY);
			MAP_OF_WEEK_DAY_CODES.put(DC_SfWeekDay.CODE_TUESDAY,
				DC_ICalendarContentBuilder.WEEK_DAY_TUESDAY);
			MAP_OF_WEEK_DAY_CODES.put(DC_SfWeekDay.CODE_WEDNESDAY,
				DC_ICalendarContentBuilder.WEEK_DAY_WEDNESDAY);
			MAP_OF_WEEK_DAY_CODES.put(DC_SfWeekDay.CODE_THURSDAY,
				DC_ICalendarContentBuilder.WEEK_DAY_THURSDAY);
			MAP_OF_WEEK_DAY_CODES.put(DC_SfWeekDay.CODE_FRIDAY,
				DC_ICalendarContentBuilder.WEEK_DAY_FRIDAY);
			MAP_OF_WEEK_DAY_CODES.put(DC_SfWeekDay.CODE_SATURDAY,
				DC_ICalendarContentBuilder.WEEK_DAY_SATURDAY);
		}
		return MAP_OF_WEEK_DAY_CODES;
	}
	
	private static Map<String, Integer> getMapOfFrequencyCodes()
	{
		if (MAP_OF_FREQUENCY_CODES == null)
		{
			MAP_OF_FREQUENCY_CODES = new Map<String, Integer>();
			MAP_OF_FREQUENCY_CODES.put(DC_SfRecurrenceFrequency.CODE_FIRST, 1);
			MAP_OF_FREQUENCY_CODES.put(DC_SfRecurrenceFrequency.CODE_SECOND, 2);
			MAP_OF_FREQUENCY_CODES.put(DC_SfRecurrenceFrequency.CODE_THIRD, 3);
			MAP_OF_FREQUENCY_CODES.put(DC_SfRecurrenceFrequency.CODE_FOURTH, 4);
			MAP_OF_FREQUENCY_CODES.put(DC_SfRecurrenceFrequency.CODE_LAST, -1);
		}
		return MAP_OF_FREQUENCY_CODES;
	}
	
	private static Map<String, Integer> getMapOfMonthCodes()
	{
		if (MAP_OF_MONTH_CODES == null)
		{
			MAP_OF_MONTH_CODES = new Map<String, Integer>();
			MAP_OF_MONTH_CODES.put(DC_SfMonth.JANUARY, 1);
			MAP_OF_MONTH_CODES.put(DC_SfMonth.FEBRUARY, 2);
			MAP_OF_MONTH_CODES.put(DC_SfMonth.MARCH, 3);
			MAP_OF_MONTH_CODES.put(DC_SfMonth.APRIL, 4);
			MAP_OF_MONTH_CODES.put(DC_SfMonth.MAY, 5);
			MAP_OF_MONTH_CODES.put(DC_SfMonth.JUNE, 6);
			MAP_OF_MONTH_CODES.put(DC_SfMonth.JULY, 7);
			MAP_OF_MONTH_CODES.put(DC_SfMonth.AUGUST, 8);
			MAP_OF_MONTH_CODES.put(DC_SfMonth.SEPTEMBER, 9);
			MAP_OF_MONTH_CODES.put(DC_SfMonth.OCTOBER, 10);
			MAP_OF_MONTH_CODES.put(DC_SfMonth.NOVEMBER, 11);
			MAP_OF_MONTH_CODES.put(DC_SfMonth.DECEMBER, 12);
		}
		return MAP_OF_MONTH_CODES;
	}
	//
	
	//
	//Public static methods
	//
	/*this method escapes all special chars which should be escaped in TEXT value
	(TEXT is a data type from RFC 5545)*/
	public static String escapeTextValue(String text)
	{
		if (String.isNotBlank(text))
		{
			//escape line breaks and 3 special chars for TEXT data type: ,;\
			//NOTE: backslashes should be escaped at first
			text = text.replace('\\', '\\\\');
			text = DC_StringUtils.replaceLineBreaks(text, '\\n');
			text = text.replace(',', '\\,');
			text = text.replace(';', '\\;');
		}
		return text;
	}
	
	/*this method unescapes all special chars which were escaped in TEXT value
	(TEXT is a data type from RFC 5545)*/
	public static String unescapeTextValue(String text)
	{
		if (String.isNotBlank(text))
		{
			//unescape line breaks and 3 special chars for TEXT data type: ,;\
			text = text.replace('\\;', ';');
			text = text.replace('\\,', ',');
			text = text.replace('\\n', DC_StringUtils.NEW_LINE_SYMBOL_IN_WINDOWS);
			text = text.replace('\\\\', '\\');
		}
		return text;
	}
	
	/*this method unfolds ICalendar-content. More details about unfolding is in
	RFC 5545 (3.1. Content Lines)*/
	public static String unfoldContent(String icsContent)
	{
		if (String.isBlank(icsContent))
		{
			return icsContent;
		}
		
		String unfoldedContent = icsContent.replace(SEPARATOR_OF_FOLDED_LINES,
			DC_StringUtils.EMPTY_STRING);
		return unfoldedContent;
	}
	
	public static String[] convertSfWeekDayCodes(Integer[] sfWeekDayCodes)
	{
		List<String> convertedCodes = new List<String>();
		if (sfWeekDayCodes != null)
		{
			//get the map
			Map<Integer, String> mapOfWeekDayCodes = getMapOfWeekDayCodes();
			//look through all SF-codes
			for (Integer sfWeekDayCode : sfWeekDayCodes)
			{
				//try to find an ICalendar-code, which corresponds to SF-code
				String iCalendarWeekDayCode = mapOfWeekDayCodes.get(sfWeekDayCode);
				if (String.isNotBlank(iCalendarWeekDayCode))
				{
					convertedCodes.add(iCalendarWeekDayCode);
				}
			}
		}
		return convertedCodes;
	}
	
	public static String[] convertSfWeekDayCodes(Integer bitMaskOfSfWeekDays)
	{
		Integer[] sfWeekDayCodes = DC_SfWeekDay.extractDayCodesFromMask(bitMaskOfSfWeekDays);
		return convertSfWeekDayCodes(sfWeekDayCodes);
	}
	
	public static Integer convertSfFrequencyCode(String sfFrequencyCode)
	{
		//get the map
		Map<String, Integer> mapOfFrequencyCodes = getMapOfFrequencyCodes();
		//try to find an ICalendar-code, which corresponds to SF-code
		return mapOfFrequencyCodes.get(sfFrequencyCode);
	}
	
	public static Integer convertSfMonthName(String sfMonthName)
	{
		//get the map
		Map<String, Integer> mapOfMonthCodes = getMapOfMonthCodes();
		//try to find an ICalendar-code, which corresponds to SF-name
		return mapOfMonthCodes.get(sfMonthName);
	}
	//
}