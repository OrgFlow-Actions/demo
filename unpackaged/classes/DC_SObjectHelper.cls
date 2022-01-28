//
//This class is used as a helper to work with any SObjects.
//
//Author: Gennadiy Pervukhin (5-11-2014)
public class DC_SObjectHelper
{
	//
	//Constructor
	//
	private DC_SObjectHelper()
	{
	}
	//

	//
	//Variables
	//
	private SObject[] dbObjects;
	//map stores mappings between object Id and object
	private Map<String, SObject> mapOfSObjects;
	//
	
	//
	//Properties
	//
	public SObject[] allObjects
	{
		get
		{
			return this.dbObjects;
		}
	}
	//

	//
	//Private methods
	//
	private void setDbObjects(SObject[] channels)
	{
		this.dbObjects = channels;
		if (this.dbObjects == null)
		{
			this.dbObjects = new SObject[0];
		}
	}
	//
	
	//
    //Private service methods which are used for optimization
    //
    /*this method creates and fills the map of mappings between Id and a
    corresponding SObject to optimize the operations which work with Id*/
    private void optimizeWorkById()
    {
    	if (this.mapOfSObjects == null)
		{
			//initialize map
			this.mapOfSObjects = new Map<String, SObject>(this.dbObjects);
		}
    }
    //
    
    
	//
	//Public methods
	//
	public SObject getSObjectById(String sObjectId)
	{
		if (String.isBlank(sObjectId))
		{
			return null;
		}
		
		//the method automatically optimizes its work
		this.optimizeWorkById();
		//return a result from the map
		return this.mapOfSObjects.get(sObjectId);
	}
	//
	

	//
	//Public static methods
	//
	public static DC_SObjectHelper createHelperForList(SObject[] sObjects)
	{
		DC_SObjectHelper helper = new DC_SObjectHelper();
		helper.setDbObjects(sObjects);
		return helper;
	}
	//
}