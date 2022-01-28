//
//This class is used to work with a templated content of ICS-file. 
//
//Author: Gennadiy Pervukhin (6-11-2014)
public class DC_ICalendarTemplatedBuilder
{
	//
	//Constructors
	//
	public DC_ICalendarTemplatedBuilder(String templatedContent)
	{
		this.templatedContent = (String.isNotBlank(templatedContent)
			? templatedContent : DC_StringUtils.EMPTY_STRING);
	}
	//
	
	//
	//Variables
	//
	private String templatedContent;
	//
	
	//
	//Public methods
	//
	//this method makes a copy of the current template, replace placeholders in
	//this copy only and then return it 
	public String buildContent(Map<String, String> mapOfPlaceholderValues)
	{
		//create a new copy of the template
		String content = (DC_StringUtils.EMPTY_STRING + this.templatedContent);
		//replace placeholders in the copy of the template
		if (mapOfPlaceholderValues != null)
		{
			for (String placeholder : mapOfPlaceholderValues.keySet())
			{
				content = DC_StringUtils.safeReplace(content, placeholder,
					mapOfPlaceholderValues.get(placeholder));
			}
		}
		return content;
	}
	
	//this is simply an overloaded version of another 'buildContent' method
	public String buildContent(String placeholder, String value)
	{
		return this.buildContent(new Map<String, String>{placeholder => value});
	}
	
	//this method replaces placeholders in the current template
	public void replacePlaceholders(Map<String, String> mapOfPlaceholderValues)
	{
		this.templatedContent = buildContent(mapOfPlaceholderValues);
	}
	//
}