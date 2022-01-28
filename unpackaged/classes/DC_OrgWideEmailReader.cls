//
//This class reads 'OrgWideEmailAddress' object and caches it
//
//Author: Gennadiy Pervukhin (31-10-2014)
public class DC_OrgWideEmailReader
{
	//
	//Constants
	//
	private static final String OBJECT_NAME = 'OrgWideEmailAddress';
	private static final String BASIC_FIELDS = 'Id';
	//
	
	//
	//Static variables
	//
	//this map stores mappings between email addresses and corresponding
	//'OrgWideEmailAddress' objects
	private static Map<String, OrgWideEmailAddress> mapOfEmailsAndObjects =
		new Map<String, OrgWideEmailAddress>();
	//
	
	//
	//Private static methods
	//
	private static OrgWideEmailAddress readOrgWideAddressByEmail(String email)
	{
		DC_SoqlQueryBuilder queryBuilder = new DC_SoqlQueryBuilder(BASIC_FIELDS, OBJECT_NAME);
		queryBuilder.condition = 'Address = \'' + email + '\'';
		queryBuilder.limitOfResult = 1;
		
		return (OrgWideEmailAddress)DC_SoqlUtils.performSingleResultQuery(queryBuilder);
	}
	//
	
	//
	//Public static methods
	//
	public static Id getOrgWideAddressIdByEmail(String email)
	{
		//check passed parameters
		if (String.isBlank(email))
		{
			return null;
		}
		
		OrgWideEmailAddress orgWideAddress;
		if (mapOfEmailsAndObjects.containsKey(email))
		{
			orgWideAddress = mapOfEmailsAndObjects.get(email);
		}
		else
		{
			//read an object from DB
			orgWideAddress = readOrgWideAddressByEmail(email);
			//save the object to the map (even if it's null). As a result, all next
			//calls to this method with the same email will not cause a new SOQL-query
			mapOfEmailsAndObjects.put(email, orgWideAddress);
		}
		
		return (orgWideAddress != null ? orgWideAddress.Id : null);
	}
	//
}