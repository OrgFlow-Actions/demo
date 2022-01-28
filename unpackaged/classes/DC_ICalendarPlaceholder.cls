//
//This class provides contstants for placeholders which are used in a template
//of an ICalendar-file (ICS-file).
//
//Author: Gennadiy Pervukhin (6-11-2014)
public class DC_ICalendarPlaceholder
{
	//
	//Constants
	//
	private static final String PLACEHOLDER_SUFFIX = String.valueOf(DateTime.now().getTime());
	private static final String PLACEHOLDER_FORMAT = '[%{0}_{1}%]';
	
	public static final String STATUS = generatePlaceholder('STATUS');
	public static final String METHOD = generatePlaceholder('METHOD');
	public static final String UID = generatePlaceholder('UID'); 
	//
	
	//
	//Private static methods
	//
	private static String generatePlaceholder(String placeholderName)
	{
		return String.format(PLACEHOLDER_FORMAT,
			new String[] {placeholderName, PLACEHOLDER_SUFFIX});
	}
	//
}