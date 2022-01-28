//
//This class provides access to 'Attachment' object
//
//Author: Gennadiy Pervukhin (31-10-2014)
public class DC_AttachmentDAO
{
	//
	//Constants
	//
	private static final String BASIC_FIELDS = 'Id, Name';
	
	public static final String FIELD_NAME = 'Name';
	//
	
	//
	//Private static methods
	//
	private static String createConditionByFilter(Filter filter)
	{
		if (filter == null)
		{
			return null;
		}
		
		List<String> listOfConditions = new List<String>();
		
		/*//- try to add a condition by parents Ids
    	String stringOfParentsIds = DC_SoqlUtils.joinStringsForINSection(filter.parentsIds);
    	if (String.isNotBlank(stringOfParentsIds))
    	{
    		listOfConditions.add('ParentId IN (' + stringOfParentsIds + ')'); 
    	}*/
    	
    	//join all the conditions by 'AND' operator
    	return DC_SoqlUtils.joinConditions(listOfConditions,
    		DC_SoqlEnums.LogicOperator.AND_Operator);
	}
	//
	
	//
	//Public static methods
	//
	public static String createSubQueryByFilter(String sourceName, Filter filter,
		Boolean allowEmptyFilter)
	{
		String condition = createConditionByFilter(filter);
        if (String.isBlank(sourceName) || !allowEmptyFilter && String.isBlank(condition))
        {
        	return null;
        }
        
        DC_SoqlQueryBuilder queryBuilder = new DC_SoqlQueryBuilder(BASIC_FIELDS, sourceName);
    	queryBuilder.condition = condition;
    	queryBuilder.setOrderByBlock(filter.sortingFields);
        return queryBuilder.buildQuery();
	}
	//
	
	
	
	//
	//Data types
	//
	public class Filter
	{
		//
		//Constructors
		//
		public Filter()
		{
			this.sortingFields = new List<DC_SortingField>();
		}
		//
		
		//
		//Properties
		//
		//public List<String> parentsIds {get; set;}
		public List<DC_SortingField> sortingFields {get; private set;}
		//
	}
	//
}