//
//This class provides access to 'EventRelation' object
//
//Author: Gennadiy Pervukhin (27-10-2014)
public class DC_EventRelationDAO
{
	//
	//Constants
	//
	private static final String OBJECT_NAME = 'EventRelation';
	private static final String BASIC_FIELDS = 'Id, EventId, RelationId, '
		+ 'Relation.Name, Relation.Email, Relation.Type, Status, Response';
	
	public static final String FIELD_RELATION_NAME = 'Relation.Name';
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
		
		/*//- try to add a condition by events Ids
    	String stringOfEventsIds = DC_SoqlUtils.joinStringsForINSection(filter.eventsIds);
    	if (String.isNotBlank(stringOfEventsIds))
    	{
    		listOfConditions.add('EventId IN (' + stringOfEventsIds + ')'); 
    	}*/
    	
    	//- try to add a condition by related SObject types
    	String stringOfRelatedTypes = DC_SoqlUtils.joinStringsForINSection(
    		filter.relatedSObjectTypes);
    	if (String.isNotBlank(stringOfRelatedTypes))
    	{
    		listOfConditions.add('Relation.Type IN (' + stringOfRelatedTypes + ')'); 
    	}
    	
    	//join all the conditions by 'AND' operator
    	return DC_SoqlUtils.joinConditions(listOfConditions,
    		DC_SoqlEnums.LogicOperator.AND_Operator);
	}
	//
	
	//
	//Public static methods
	//
	public static EventRelation getRelationById(String relationId)
	{
		if (String.isBlank(relationId))
		{
			return null;
		}
		
		DC_SoqlQueryBuilder queryBuilder = new DC_SoqlQueryBuilder(BASIC_FIELDS, OBJECT_NAME);
		queryBuilder.condition = 'Id = \'' + relationId + '\'';
		return (EventRelation)DC_SoqlUtils.performSingleResultQuery(queryBuilder);
	}
	
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
		//public List<String> eventsIds {get; set;}
		public List<String> relatedSObjectTypes {get; set;}
		
		public List<DC_SortingField> sortingFields {get; private set;}
		//
	}
	//
}