//
//This class provides access to 'EmailTemplate' object.
//
//Author: Gennadiy Pervukhin (5-10-2014)
public class DC_EmailTemplateDAO
{
	//
	//Constants
	//
	private static final String OBJECT_NAME = 'EmailTemplate';
	
	private static final String BASIC_FIELDS = 'Id, DeveloperName, Subject, HtmlValue';
	//
	
	//
	//Public static methods
	//
	public static EmailTemplate getTemplateByDeveloperName(String developerName)
	{
		if (String.isBlank(developerName))
		{
			return null;
		}
		
		DC_SoqlQueryBuilder queryBuilder =
			new DC_SoqlQueryBuilder(BASIC_FIELDS, OBJECT_NAME);
		queryBuilder.condition = 'DeveloperName = \'' + developerName + '\'';
		
		return (EmailTemplate)DC_SoqlUtils.performSingleResultQuery(queryBuilder);
	}
	//
}