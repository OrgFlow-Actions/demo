//
//This class provides access to 'Event' object
//
//Author: Gennadiy Pervukhin (31-10-2014)
public class DC_EventDAO
{
	//
	//Constants
	//
	private static final String OBJECT_NAME = 'Event';
	private static final String BASIC_FIELDS = 'Id, Subject, Location, StartDateTime, '
		+ 'WhoId, WhatId, '
		+ 'EndDateTime, RecordTypeId, Description, '
		+ 'OwnerId, Owner.Name, Event_Status__c, '
		+ 'IsRecurrence, RecurrenceType, RecurrenceInterval, RecurrenceTimeZoneSidKey, '
		+ 'RecurrenceStartDateTime, RecurrenceEndDateOnly, RecurrenceMonthOfYear, '
		+ 'RecurrenceInstance, RecurrenceDayOfWeekMask, RecurrenceDayOfMonth, '
        + 'Astra_Tech_Type__c, Co_travel__c, Objective__c, '
		+ 'IsAllDayEvent, IsReminderSet, ReminderDateTime, Send_Calendar_Invites__c';
	
	private static final String EVENT_RELATIONS_NAME = 'EventRelations';
	private static final String ATTACHMENTS_RELATIONSHIP_NAME = 'Attachments';
	
	public static final String FIELD_ORGANIZER_ID = 'OwnerId';
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
		
		//- try to add a condition by events Ids
    	String stringOfIds = DC_SoqlUtils.joinStringsForINSection(filter.ids);
    	if (String.isNotBlank(stringOfIds))
    	{
    		listOfConditions.add('Id IN (' + stringOfIds + ')'); 
    	}
    	
    	//join all the conditions by 'AND' operator
    	return DC_SoqlUtils.joinConditions(listOfConditions,
    		DC_SoqlEnums.LogicOperator.AND_Operator);
	}
	
	private static String createFieldsListByFilter(Filter filter)
	{
		//check the filter
    	if (filter == null)
    	{
    		return null;
    	}
    	
    	List<String> allFields = new List<String>();
    	
    	//1) select basic fields
    	allFields.add(BASIC_FIELDS);
    	
    	//2) select event relations if it's needed
    	if (filter.selectRelations == true)
    	{
    		//build a query
    		String relationsQuery = DC_EventRelationDAO.createSubQueryByFilter(
    			EVENT_RELATIONS_NAME, filter.relationsFilter, true);
    		//extend fields list
    		if (String.isNotBlank(relationsQuery))
    		{
    			allFields.add('(' + relationsQuery + ')');
    		}
    	}
    	
    	//3) select attachments if it's needed
    	if (filter.selectAttachments == true)
    	{
    		//build a query
    		String attachmentsQuery = DC_AttachmentDAO.createSubQueryByFilter(
    			ATTACHMENTS_RELATIONSHIP_NAME, filter.attachmentsFilter, true);
    		//extend fields list
    		if (String.isNotBlank(attachmentsQuery))
    		{
    			allFields.add('(' + attachmentsQuery + ')');
    		}
    	}
    	
    	return DC_SoqlUtils.joinFields(allFields);
	}
	//
	
	//
	//Public static methods
	//
	public static Event getEventById(String id)
	{
		if (String.isBlank(id))
		{
			return null;
		}
		
		DC_SoqlQueryBuilder queryBuilder =
			new DC_SoqlQueryBuilder(BASIC_FIELDS, OBJECT_NAME);
		queryBuilder.condition = 'Id = \'' + id + '\'';
		
		return (Event)DC_SoqlUtils.performSingleResultQuery(queryBuilder);
	}
	
	public static Event[] getEventsByFilter(Filter filter)
	{
		String fieldsList = createFieldsListByFilter(filter);
		String condition = createConditionByFilter(filter);
        if (String.isBlank(fieldsList) || String.isBlank(condition))
        {
        	//Note: if the system can't create a real condition by the filter then
        	//it considers that the filter is incorrect, and nothing should be returned
        	return null;
        }
        
        DC_SoqlQueryBuilder queryBuilder = new DC_SoqlQueryBuilder(fieldsList, OBJECT_NAME);
    	queryBuilder.condition = condition;
        return DC_SoqlUtils.performQuery(queryBuilder);
	}
	//
	
    public static List<Event> getEventsByAccountId(String accountId) {
        return [select Id, Subject, ActivityDate, WhoId, Who.Name, OwnerId, Owner.Name,
                     		WhatId, What.Name,
                            Event_Status__c, Description, Call_Report__r.Id, 
                     		Call_Report__r.Call_Notes__c from Event where AccountId = :accountId order by ActivityDate desc, LastModifiedDate desc limit 2000];
    }
	
	
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
		}
		//
		
		//
		//Properties
		//
		public List<String> ids {get; set;}
		
		public Boolean selectRelations {get; set;}
		public DC_EventRelationDAO.Filter relationsFilter {get; set;}
		
		public Boolean selectAttachments {get; set;}
		public DC_AttachmentDAO.Filter attachmentsFilter {get; set;}
		//
	}
	//
}