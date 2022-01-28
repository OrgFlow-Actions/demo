//
//This class contains utility methods to work with email templates
//
//Author: Gennadiy Pervukhin (5-11-2014)
public class DC_EmailTemplatesUtils
{
	//
	//Public static methods
	//
	public static String generateHtmlLink(String linkText, String url)
	{
		if (String.isBlank(linkText) || String.isBlank(url))
		{
			return linkText;
		}
		
		return '<a href="' + url + '" target="_blank" style="text-decoration: none;">'
			+ '<span style="color: #345FB6;">' + linkText + '</span></a>';
	}
	//
}