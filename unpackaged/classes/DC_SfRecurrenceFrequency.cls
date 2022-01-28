//
//This class contains constants for all possible recurrence frequencies, which
//are defined in SF.
//
//Author: Gennadiy Pervukhin (11-11-2014)
public class DC_SfRecurrenceFrequency
{
	//
	//Constants
	//
	public static final String CODE_FIRST = 'First';
	public static final String CODE_SECOND = 'Second';
	public static final String CODE_THIRD = 'Third';
	public static final String CODE_FOURTH = 'Fourth';
	public static final String CODE_LAST = 'Last';
	//
	
	//
	//Variables
	//
	//this map stores mappings between frequency code and its name
	private static Map<String, String> MAP_OF_CODE_AND_NAME;
	//
	
	//
	//Private static methods
	//
	private static Map<String, String> getMapOfCodeAndName()
	{
		if (MAP_OF_CODE_AND_NAME == null)
		{
			MAP_OF_CODE_AND_NAME = new Map<String, String>();
			MAP_OF_CODE_AND_NAME.put(CODE_FIRST, '1st');
			MAP_OF_CODE_AND_NAME.put(CODE_SECOND, '2nd');
			MAP_OF_CODE_AND_NAME.put(CODE_THIRD, '3rd');
			MAP_OF_CODE_AND_NAME.put(CODE_FOURTH, '4th');
			MAP_OF_CODE_AND_NAME.put(CODE_LAST, 'last');
		}
		return MAP_OF_CODE_AND_NAME;
	}
	//
	
	//
	//Public static methods
	//
	public static String convertFrequencyCode(String code)
	{
		//initialize or take the map
		Map<String, String> mapOfCodeAndName = getMapOfCodeAndName();
		//get name by the code and return it
		return mapOfCodeAndName.get(code);
	}
	//
}