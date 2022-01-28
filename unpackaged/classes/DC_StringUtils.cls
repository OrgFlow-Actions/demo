//
//This class provides utility methods to work with strings.
//
//Author: Gennadiy Pervukhin [Cervello] (5-11-2014)
public class DC_StringUtils
{
	//
	//Variables and constants
	//
	public static final String EMPTY_STRING = '';
	public static final String WHITE_SPACE = ' ';
	public static final String HTML_NON_BREAKING_SPACE = '&nbsp;';
	
	public static final String NEW_LINE_SYMBOL_IN_WINDOWS = '\r\n';
	public static final String NEW_LINE_SYMBOL_IN_UNIX = '\n';
	//
	
	//
	//Public static methods
	//
	public static String safeReplace(String sourceString, String replaceableValue,
    	String replacement)
    {
    	//quickly check passed parameters
    	if (sourceString == null || replaceableValue == null)
    	{
    		return sourceString;
    	}
    	
    	//if a replacement is null then we consider it's an empty string
    	if (replacement == null)
    	{
    		replacement = DC_StringUtils.EMPTY_STRING;
    	}
    	return sourceString.replace(replaceableValue, replacement);
    }
    
    public static String replaceLineBreaks(String sourceString, String replacementString)
    {
    	if (sourceString == null || replacementString == null)
    	{
    		return null;
    	}
    	
    	//at first we should escape \r\n sequence
    	String resultString = sourceString.replace(NEW_LINE_SYMBOL_IN_WINDOWS, replacementString);
    	//at second we should escape \n symbol
    	resultString = resultString.replace(NEW_LINE_SYMBOL_IN_UNIX, replacementString);
    	
    	return resultString;
    }
    
    public static String safeJoin(List<Object> values, String separator)
	{
		//check passed parameters
		if (values == null)
		{
			return null;
		}
		separator = (separator != null ? separator : EMPTY_STRING);
		return String.join(values, separator);
	}
	
	public static String truncateString(String sourceString, Integer targetLength)
	{
		if (String.isBlank(sourceString) || sourceString.length() <= targetLength)
		{
			return sourceString;
		}
		return sourceString.substring(0, targetLength);
	}
    //
}