//
//This class contains some utility methods to process with SObjects
//
//Author: Gennadiy Pervukhin (31-10-2014)
public class DC_SObjectUtils
{
	//
	//Constants
	//
	/*public static final String REGEXP_FOR_ID = '[a-zA-Z0-9]{' + ID_LENGTH + '}';*/
	public static final Integer ID_LENGTH = 18;
	
	public static final String CALENDAR_RESOURCE_TYPE = '023';
	public static final String USER_TYPE = 'User';
	//
	
	//
	//Private static methods
	//
	private static FieldPath extractFieldPath(String complexFieldName)
	{
		//split complex name to parts ('split' method is based on regex, that's
		//why we need to escape 'dot' char)
    	List<String> nameParts = complexFieldName.split('\\.');
    	
    	//build FieldPath
    	FieldPath path = new FieldPath();
    	//- field name is the latest part of the path
    	path.fieldName = nameParts[nameParts.size() - 1];
    	//- all parts, except the last one, are object references
    	nameParts.remove(nameParts.size() - 1);
    	path.objectReferences = nameParts;
    	
    	return path;
	}
	
	private static Object getComplexFieldValue(sObject dbObject, FieldPath path)
    {
        try
        {
    		//in an every iteration we get sObject which contains reference to
    		//another sObject or contains a necessary field
        	sObject lastSelectedObject = dbObject;
        	for (String objectReference : path.objectReferences)
        	{
        		//get reference to another sObject (parent object)
        		lastSelectedObject = lastSelectedObject.getSObject(objectReference);
        	}
        	
        	//at this point, we have a real object which contains a necessary field
            return lastSelectedObject.get(path.fieldName);
        }
        catch (Exception error)
        {
            System.debug(LoggingLevel.WARN, error);
        }
        return null;
    }
	//
	
	//
	//Public static methods
	//
    public static Boolean idBelongToSObject(String id, SObjectType objectType)
    {
    	//check passed parameters
    	if (String.isBlank(id))
    	{
    		return false;
    	}
    	
    	String objectKeyPrefix = objectType.getDescribe().getKeyPrefix();
    	return id.startsWith(objectKeyPrefix);
    }
    
    public static String[] extractIds(SObject[] dbObjects, Boolean saveOrder)
	{
		//check passed parameters
		if (dbObjects == null)
		{
			return null;
		}
		
		if (saveOrder)
		{
			return extractStringFieldValues(dbObjects, 'Id');
		}
		else
		{
			Map<String, SObject> mapOfDbObjects = new Map<String, SObject>(dbObjects);
			return (new List<String>(mapOfDbObjects.keySet()));
		}
	}
	
	/*
	This method uses reflection to read any field at any level of an object.
	Performance of the method is not perfect if it's used for thousands of objects
	*/
	public static String[] extractStringFieldValues(SObject[] dbObjects,
		String fieldName)
	{
		//check passed parameters
		if (dbObjects == null || String.isBlank(fieldName))
		{
			return null;
		}
		
		List<String> listOfValues = new List<String>();
		
		//extract a full path to the object
		FieldPath fieldPath = extractFieldPath(fieldName);
		for (SObject dbObject : dbObjects)
		{
			listOfValues.add((String)getComplexFieldValue(dbObject, fieldPath));
		}
		return listOfValues;
	}
	
	/*
	This method doesn`t use reflection to read a field of an object. It uses a
	special reader-class which reads the value in standard way without reflection.
	Performance of the method is good.
	*/
	public static String[] extractUniqueStringFieldValues(SObject[] dbObjects,
		IStringFieldReader fieldReader, Boolean saveOrder)
	{
		//check passed parameters
		if (dbObjects == null || fieldReader == null)
		{
			return null;
		}
		
		//extract a full path to the object
		List<String> uniqueValues;
		if (saveOrder)
		{
			uniqueValues = new List<String>();
			Set<String> selectedValues = new Set<String>();
			for (SObject dbObject : dbObjects)
			{
				String fieldValue = fieldReader.readValue(dbObject);
				if (!selectedValues.contains(fieldValue))
				{
					uniqueValues.add(fieldValue);
					selectedValues.add(fieldValue);
				}
			}
		}
		else
		{
			Set<String> selectedValues = new Set<String>();
			for (SObject dbObject : dbObjects)
			{
				selectedValues.add(fieldReader.readValue(dbObject));
			}
			uniqueValues = new List<String>(selectedValues);
		}
		
		return uniqueValues;
	}
    //
    
    
    
    //
    //Data types
    //
    public interface IStringFieldReader
    {
    	String readValue(SObject dbObject);
    }
    
    private class FieldPath
    {
    	public List<String> objectReferences = new List<String>();
    	public String fieldName;
    }
    //
}