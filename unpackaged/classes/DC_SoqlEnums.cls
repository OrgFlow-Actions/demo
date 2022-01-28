//
//This class contains enumerations that are used in SOQL
//
//Author: Gennadiy Pervukhin (27-10-2014)
public class DC_SoqlEnums
{
	//
    //Data types
    //
    //This enumeration contains logic operators which are used in SOQL-queries
    public enum LogicOperator
    {
        AND_Operator,
        OR_Operator
    }
    
    //This enumeration contains possible sorting directions
	public enum SortingOrder
	{
	    Ascending,
	    Descending
	}
	
	//This enumeration contains possible strategies of sorting of null values
	public enum NullValuesSortingOrder
	{
	    First,
	    Last
	}
    
    //This enumeration contains all DML operations
    public enum DmlOperation
    {
        Deleting,
        Inserting,
        Updating,
        Undeleting,
        Upserting
    }
    //
}