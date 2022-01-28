//
//This class contains constants for all possible recurrence types of SF-event.
//
//Author: Gennadiy Pervukhin (11-11-2014)
public class DC_SfWeekDay
{
	//
	//Constants
	//
	public static final Integer CODE_SUNDAY = 1;
	public static final Integer CODE_MONDAY = 2;
	public static final Integer CODE_TUESDAY = 4;
	public static final Integer CODE_WEDNESDAY = 8;
	public static final Integer CODE_THURSDAY = 16;
	public static final Integer CODE_FRIDAY = 32;
	public static final Integer CODE_SATURDAY = 64;
	
	public static final Integer CODE_ALL_DAYS = 127;
	
	public static final String NAME_SUNDAY = System.Label.DC_Sunday;
	public static final String NAME_MONDAY = System.Label.DC_Monday;
	public static final String NAME_TUESDAY = System.Label.DC_Tuesday;
	public static final String NAME_WEDNESDAY = System.Label.DC_Wednesday;
	public static final String NAME_THURSDAY = System.Label.DC_Thursday;
	public static final String NAME_FRIDAY = System.Label.DC_Friday;
	public static final String NAME_SATURDAY = System.Label.DC_Saturday;
	
	private static final Integer[] ALL_CODES = new Integer[]
	{
		CODE_SUNDAY, CODE_MONDAY, CODE_TUESDAY, CODE_WEDNESDAY, CODE_THURSDAY,
		CODE_FRIDAY, CODE_SATURDAY
	};
	//
	
	//
	//Variables
	//
	//this map stores mappings between day code and its name
	private static Map<Integer, String> MAP_OF_CODE_AND_NAME;
	//
	
	//
	//Private static methods
	//
	private static Map<Integer, String> getMapOfCodeAndName()
	{
		if (MAP_OF_CODE_AND_NAME == null)
		{
			MAP_OF_CODE_AND_NAME = new Map<Integer, String>();
			MAP_OF_CODE_AND_NAME.put(CODE_SUNDAY, NAME_SUNDAY);
			MAP_OF_CODE_AND_NAME.put(CODE_MONDAY, NAME_MONDAY);
			MAP_OF_CODE_AND_NAME.put(CODE_TUESDAY, NAME_TUESDAY);
			MAP_OF_CODE_AND_NAME.put(CODE_WEDNESDAY, NAME_WEDNESDAY);
			MAP_OF_CODE_AND_NAME.put(CODE_THURSDAY, NAME_THURSDAY);
			MAP_OF_CODE_AND_NAME.put(CODE_FRIDAY, NAME_FRIDAY);
			MAP_OF_CODE_AND_NAME.put(CODE_SATURDAY, NAME_SATURDAY);
		}
		return MAP_OF_CODE_AND_NAME;
	}
	//
	
	//
	//Public static methods
	//
	public static Integer[] extractDayCodesFromMask(Integer bitMask)
	{
		if (bitMask <= 0)
		{
			return (new Integer[0]);
		}
		
		List<Integer> selectedCodes = new List<Integer>();
		for (Integer dayCode : ALL_CODES)
		{
			//we use bitwise AND operator to check if the code is in the mask
			if ((bitMask & dayCode) > 0)
			{
				selectedCodes.add(dayCode);
			}
		}
		return selectedCodes;
	}
	
	public static String[] extractDayNamesFromMask(Integer bitMask)
	{
		//STEP #1: get day codes from the bit mask
		Integer[] dayCodes = extractDayCodesFromMask(bitMask);
		
		//STEP #2: convert the codes to names
		Map<Integer, String> mapOfCodeAndName = getMapOfCodeAndName();
		List<String> dayNames = new List<String>();
		for (Integer dayCode : dayCodes)
		{
			String dayName = mapOfCodeAndName.get(dayCode);
			if (String.isNotBlank(dayName))
			{
				dayNames.add(dayName);
			}
		}
		return dayNames;
	}
	//
	
	
	
	
	
	
	
	
	
	
}