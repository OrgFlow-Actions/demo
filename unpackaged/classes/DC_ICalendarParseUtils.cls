//
//This class provides utility methods to parse ICS-content. 
//
//Author: Gennadiy Pervukhin (7-11-2014)
/*
Notes about used regular expressions:
- (?s)/(?-s) is used to enable/disable DOTALL mode: . matches any character,
including a line terminator;
- (?m)/(?-m) is used to enable/disable MULTILINE mode: ^ and $ match just after
or just before, respectively, a line terminator;
- (?=X) - X, via zero-width positive lookahead.
*/
public class DC_ICalendarParseUtils
{
	//
	//Constants
	//
	//this pattern can be used to make basic validations of ICS-content.
	/*
	Notes:
	- the pattern doesn't guarantee that the file is absolutely correct, but we
	can consider that it's enough for our purpose.
	- (?=X) - is used to say that we need both UID and ATTENDEE properties, but
	it's not important in which order they are placed between BEGIN:VEVENT and
	END:VEVENT nodes.
	*/
	private static final Pattern PATTERN_FOR_ICS_CONTENT = Pattern.compile(
		'(?sm)^BEGIN\\:VCALENDAR$.*^METHOD\\:.*$.*^BEGIN\\:VEVENT$(?=.*^UID\\:.*$)'
		+ '(?=.*^ATTENDEE.*$).*^END\\:VEVENT$.*^END:VCALENDAR$.*');
	
	private static final String REGEXP_FOR_PROPERTY = '(?m)^{0}.*$';
	private static final String REGEXP_FOR_ATTRIBUTE = '(?m){0}[^;:$]+';
	
	public static final String PROPERTY_UID = 'UID:';
	public static final String PROPERTY_DESCRIPTION = 'DESCRIPTION:';
	public static final String PROPERTY_ATTENDEE = 'ATTENDEE';
	
	private static final String ATTRIBUTE_ATTENDEE_PARTICIPATION = 'PARTSTAT=';
	//
	
	//
	//Private static methods
	//
	private static String extractValueAfterMarker(String icsContent, String marker,
		String regexpForMarkerAndValue)
	{
		//get Matcher for the content
		Matcher contentMatcher = Pattern.compile(regexpForMarkerAndValue).matcher(icsContent);
		
		//stop the method if no matches found
		if (!contentMatcher.find())
		{
			return null;
		}
		
		//extract the marker and its value
		String markerAndValue = contentMatcher.group().trim();
		//extract and return a value after the marker
		return markerAndValue.substring(marker.length());
	}
	
	private static String extractAttributeValue(String propertyValue, String attributeName)
	{
		//check input parameters
		if (propertyValue == null)
		{
			return null;
		}
		
		//generate a regular expression for the attribute and its value
		String regexpForAttribute = String.format(REGEXP_FOR_ATTRIBUTE,
			new String[] {attributeName});
		return extractValueAfterMarker(propertyValue, attributeName, regexpForAttribute);
	}
	//
	
	//
	//Public static methods
	//
	public static Boolean isIcsContentValid(String icsContent)
	{
		if (String.isBlank(icsContent))
		{
			return false;
		}
		return PATTERN_FOR_ICS_CONTENT.matcher(icsContent).matches();
	}
	
	public static String extractPropertyValue(String icsContent, String propertyName)
	{
		//check input parameters
		if (icsContent == null || String.isBlank(propertyName))
		{
			return null;
		}
		
		//generate a regular expression for the property and its content
		String regexpForProperty = String.format(REGEXP_FOR_PROPERTY,
			new String[] {propertyName});
		return extractValueAfterMarker(icsContent, propertyName, regexpForProperty);
	}
	
	public static String extractAttendeeParticipationStatus(String icsContent)
	{
		//extract attendee information
		String attendeePropertyValue = extractPropertyValue(icsContent, PROPERTY_ATTENDEE);
		//extract participation status
		return extractAttributeValue(attendeePropertyValue,
			ATTRIBUTE_ATTENDEE_PARTICIPATION);
	}
	//
}