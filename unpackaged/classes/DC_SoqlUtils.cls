//
//This class provides utility methods for working with dynamic SOQL
//
//Author: Gennadiy Pervukhin [Cervello](27-10-2014)
public class DC_SoqlUtils
{
    //
    //Constants
    //
    private static final String DB_DATETIME_FORMAT = 'yyyy-MM-dd\'T\'HH:mm:ss\'Z\'';
    private static final String DB_DATE_FORMAT = 'yyyy-MM-dd';
    
    private static final String SEPARATOR_OF_FIELDS = ', ';
    
    private static final Integer MAX_STRING_LENGTH_FOR_IN_CLAUSE = 4000;
    
    public static final String WILDCARD_ZERO_OR_MORE_CHARS = '%';
    public static final String[] SPECIAL_CHARS_FOR_LIKE_OPERATOR =
    	new String[] {'%', '_', '\''};
    //
        
    //
    //Private static methods
    //
    @TestVisible
    private static String getSoqlRepresentation(DC_SoqlEnums.LogicOperator logicOperator)
    {
        if (logicOperator == DC_SoqlEnums.LogicOperator.AND_Operator)
        {
            return 'AND';
        }
        else if (logicOperator == DC_SoqlEnums.LogicOperator.OR_Operator)
        {
            return 'OR';
        }
        else
        {
            throw new DC_CustomException('SoqlUtils.getSoqlRepresentation: unknown logic operator: '
            	+ logicOperator);
        }
    }
    
    //method performs DML operation for sObject-list
    @TestVisible
    private static void callDmlOperation(DC_SoqlEnums.DmlOperation dmlOperation, sObject[] objects)
    {
        if (dmlOperation == DC_SoqlEnums.DmlOperation.Updating)
        {
            update objects;
        }
        else if (dmlOperation == DC_SoqlEnums.DmlOperation.Inserting)
        {
            insert objects;
        }
        else if (dmlOperation == DC_SoqlEnums.DmlOperation.Deleting)
        {
            delete objects;
        }
        else if (dmlOperation == DC_SoqlEnums.DmlOperation.Upserting)
        {
            upsert objects;
        }
        else if (dmlOperation == DC_SoqlEnums.DmlOperation.Undeleting)
        {
            undelete objects;
        }
        else
        {
            throw new DC_CustomException('SoqlUtils.callDmlOperation: unknown '
            	+ 'DML-operation: ' + dmlOperation);
        }
    }
    //
    
    //
    //Public static methods
    //
    //the following 2 methods perform DML operations safely for usual cases, because they
    //catch all catchable exceptions
    public static Boolean tryPerformDmlOperation(DC_SoqlEnums.DmlOperation dmlOperation,
    	sObject objectForOperation)
    {
        //we can't use calls like this
        //'return tryPerformDmlOperation(dmlOperation, new sObject[] {objectForOperation}, parameters);'
        //here, because 'DML on generic List<SObject> only allowed for insert, update or
        //delete operations'. So non-standard DML operations (upsert, undelete) can be called
        //only for a single object or for a list which contains objects of a concrete type.
        //That's why we'll create empty array of the same type as 'objectForOperation' 
        
        //STEP #1: check input parameters
        //we can't perform DML operation if some parameters are not correct 
        if (dmlOperation == null || objectForOperation == null)
        {
            return false;
        }
        
        //STEP #2: initialize array, put the passed object into it and call DML operation
        List<sObject> sObjects = (sObject[])DC_ApexTypeUtils.createEmptyListByTypeName(
            String.valueOf(objectForOperation.getSObjectType()));
        sObjects.add(objectForOperation);
        return tryPerformDmlOperation(dmlOperation, sObjects);
    }
    
    //NOTE: the following method processes standard and non-standard DML operations. All DML
    //operations can be performed for a list of objects, but it is important to know that
    //non-standard DML operations (upsert and undelete) can be performed only for lists which
    //contain objects of a concrete type. If you try to instantiate sObject-list in a code
    //and then call the method below for this list then System.TypeException will occur and
    //you'll get false result.
    //THE FIRST WAY to avoid this problem is to use only lists which contain objects of
    //a concrete type when you want to perform an upsert or undelete operation.
    //ANOTHER WAY is to call these operations in for-loop for an every single object (this
    //way is bad because of the limit 'Total number of DML statements issued = 150', every
    //DML statement (for list or for single object) counts against the number of allowed DML
    //queries. So, it is more effective to use the FIRST WAY).
    public static Boolean tryPerformDmlOperation(DC_SoqlEnums.DmlOperation dmlOperation,
    	sObject[] objects)
    {
        //STEP #1: check input parameters
        //we can't perform DML operation if some parameters are not correct 
        if (dmlOperation == null || objects == null)
        {
            return false;
        }
        
        //STEP #2: perform DML operation
        Boolean isOperationSuccessful = true;
        try
        {
            //simply call DML operation
            callDmlOperation(dmlOperation, objects);
        }
        catch (System.Exception e)
        {
            System.debug(LoggingLevel.ERROR, e);
            isOperationSuccessful = false;
        }
        return isOperationSuccessful;
    }
    
    
    //method simply performs query but catches all possible problems and exceptions
    public static List<sObject> performQuery(String soqlCommand)
    {
        //check input parameters
        if (String.isBlank(soqlCommand))
        {
            return null;
        }
        
        List<sObject> listOfObjects;
        try
        {
            listOfObjects = Database.query(soqlCommand);
        }
        catch (System.QueryException e)
        {
            System.debug(Logginglevel.ERROR, e);
            listOfObjects = null;
        }
        
        return listOfObjects;
    }
    
    public static List<sObject> performQuery(DC_SoqlQueryBuilder queryBuilder)
    {       
        if (queryBuilder == null)
        {
            return null;
        }
        
        return performQuery(queryBuilder.buildQuery());
    }
    
    
    //method simply performs query but catches all possible problems and exceptions
    //and returns single object  
    public static sObject performSingleResultQuery(String soqlCommand)
    {
        sObject resultObject = null;
        
        List<sObject> listOfsObjects = performQuery(soqlCommand);
        if (listOfsObjects != null && listOfsObjects.size() > 0)
        {
            resultObject = listOfsObjects[0];
        }
        
        return resultObject;
    }
    
    public static sObject performSingleResultQuery(DC_SoqlQueryBuilder queryBuilder)
    {       
        if (queryBuilder == null)
        {
            return null;
        }
        
        return performSingleResultQuery(queryBuilder.buildQuery());
    }
    
    public static Database.QueryLocator createQueryLocator(String queryString)
    {
    	if (String.isBlank(queryString))
    	{
    		return null;
    	}
    	
    	Database.QueryLocator queryLocator;
    	try
    	{
    		queryLocator = Database.getQueryLocator(queryString);
    	}
    	catch (System.QueryException e)
        {
            System.debug(Logginglevel.ERROR, e);
            queryLocator = null;
        }
        return queryLocator;
    }
    
    /*//method simply performs count() query, but catches all possible problems and exceptions
    public static Integer performCountQuery(String countQuery)
    {
        //check input parameters
        if (String.isBlank(countQuery))
        {
            return null;
        }
        
        Integer resultNumber;
        try
        {
            resultNumber = Database.countQuery(countQuery);
        }
        catch (System.QueryException e)
        {
            System.debug(Logginglevel.ERROR, e);
            resultNumber = null;
        }
        
        return resultNumber;
    }
    
    //method simply performs count() query, but catches all possible problems and exceptions
    public static Integer performCountQuery(DC_SoqlQueryBuilder queryBuilder)
    {
    	if (queryBuilder == null)
    	{
    		return null;
    	}
    	return performCountQuery(queryBuilder.buildQuery());
    }*/
    //
    
    
    //
    //Public static service methods
    //
    //the method returns string with escaped special SOQL chars 
    public static String escapeValueForLikeOperator(String sourceString)
    {
    	//check input parameters
        if (String.isBlank(sourceString))
        {
            return sourceString;
        }
        
        String resultString = sourceString;
        for (String specialChar : SPECIAL_CHARS_FOR_LIKE_OPERATOR)
        {
            resultString = resultString.replace(specialChar, '\\' + specialChar);
        }
        return resultString;
    }
    
    public static String escapeValueForEqualityOperator(String sourceString)
    {
    	//check input parameters
        if (String.isBlank(sourceString))
        {
            return sourceString;
        }
        
        return String.escapeSingleQuotes(sourceString);
    }
    
    public static String joinConditions(String[] listOfConditions,
    	DC_SoqlEnums.LogicOperator logicOperator)
    {
        //check input parameters
        if (listOfConditions == null || logicOperator == null)
        {
            return null;
        }
        
    	Set<String> setOfConditions = new Set<String>(listOfConditions);
        //remove null and empty strings, because they are not useful for conditions
        setOfConditions.remove(null);
        setOfConditions.remove('');
        
        //result condition
        String fullCondition = null;
        if (setOfConditions.size() > 0)
        {
        	String separatorForConditions = ') ' + getSoqlRepresentation(logicOperator) + ' (';
        	
	        fullCondition = String.join(new List<String>(setOfConditions), separatorForConditions);
	        //if result condition is not empty then we should wrap it by squares, because
	        //they were not added by join-function
	        if (String.isNotBlank(fullCondition))
	        {
	        	fullCondition = '(' + fullCondition + ')';
	        }
        }
        return fullCondition;
    }
    
    public static String joinStringsForINSection(List<String> listOfStrings)
    {
        //check input parameters
        if (listOfStrings == null)
        {
            return null;
        }
        
        Set<String> setOfStrings = new Set<String>(listOfStrings);
        //remove null and empty strings, because they are not useful for IN-conditions
        setOfStrings.remove(null);
        setOfStrings.remove('');
        
        String resultString = null;
        if (setOfStrings.size() > 0)
        {
	        resultString = String.join(new List<String>(setOfStrings), '\',\'');
	        //if result string contains chars then we should wrap it by quotes, because
	        //they were not added by join-function
	        if (String.isNotBlank(resultString))
	        {
	        	resultString = '\'' + resultString + '\'';
	        }
        }
        
        return resultString;
    }
    
    public static String joinFields(List<String> listOfFields)
    {
    	return DC_StringUtils.safeJoin(listOfFields, SEPARATOR_OF_FIELDS);
    }
    
    public static String[] selectCorrectValuesForInClause(String[] values)
    {
    	//check passed parameters
    	if (values == null)
    	{
    		return null;
    	}
    	
    	List<String> selectedValues = new List<String>();
    	for (String value : values)
    	{
    		if (value == null || value.length() <= MAX_STRING_LENGTH_FOR_IN_CLAUSE)
    		{
    			selectedValues.add(value);
    		}
    	}
    	return selectedValues;
    }
    
    
    //this method formats date from Date object and set start time of the day
    public static String formatDateTime(Date sourceDate)
    {
        //check input parameters
        if (sourceDate == null)
        {
            return null;
        }
        
        Datetime sourceDateTime = 
            DateTime.newInstanceGmt(sourceDate.year(), sourceDate.month(), sourceDate.day(), 0, 0, 0);
        return formatDateTime(sourceDateTime);
    }
    
    //this method formats date and time from DateTime object
    public static String formatDateTime(DateTime sourceDateTime)
    {
        //check input parameters
        if (sourceDateTime == null)
        {
            return null;
        }
        
        return sourceDateTime.formatGmt(DB_DATETIME_FORMAT);
    }
    
    //this method formats date from Date object
    public static String formatDate(Date sourceDate)
    {
        //check input parameters
        if (sourceDate == null)
        {
            return null;
        }
        Datetime sourceDateTime = DateTime.newInstanceGmt(sourceDate.year(),
        	sourceDate.month(), sourceDate.day(), 0, 0, 0);
        return formatDate(sourceDateTime);
    }
    
    //this method formats date from DateTime object
    public static String formatDate(DateTime sourceDateTime)
    {
        //check input parameters
        if (sourceDateTime == null)
        {
            return null;
        }
        
        return sourceDateTime.formatGmt(DB_DATE_FORMAT);
    }
    //
}