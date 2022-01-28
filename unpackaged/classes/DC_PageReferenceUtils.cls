//
//This class provides utility methods for working with page reference
//
//Author: Gennadiy Pervukhin (5-11-2014)
public class DC_PageReferenceUtils
{
	//
	//Public static methods
	//
	/*this method generates a full URL for the page.*/
	public static String getFullUrl(PageReference reference)
	{
		return (reference != null
			? Url.getSalesforceBaseUrl().toExternalForm() + reference.getUrl() : null);
	}
	
	public static PageReference createReferenceToViewPage(Id objectId)
	{
		return (objectId != null ? new PageReference('/' + objectId) : null);
	}
	//
}