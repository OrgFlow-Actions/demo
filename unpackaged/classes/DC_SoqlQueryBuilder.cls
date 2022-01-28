//
//This class is used to build dynamic SOQL-queries
//
//Author: Gennadiy Pervukhin (27-10-2014)
public class DC_SoqlQueryBuilder
{
    //
    //Constructors
    //
    public DC_SoqlQueryBuilder(String selectedFields, String objectName)
    {
        this.selectedFields = selectedFields;
        this.objectName = objectName;
    }
    
    public DC_SoqlQueryBuilder(String selectedFields, String objectName, String condition)
    {
        this.selectedFields = selectedFields;
        this.objectName = objectName;
        this.condition = condition;
    }
    //
    
    
    //
	//Constants
	//
	private static final String SEPARATOR_OF_SORTING_VALUES = ', ';
	//
    
    
    //
    //Public properties
    //
    public String selectedFields {get; set;}
    public String objectName  {get; set;}
    
    public String condition {get; set;}
    
    public String groupByBlockValue {get; set;}
    public String groupByRollupBlockValue {get; set;}
    public String orderByBlockValue {get; set;}
    public String havingBlockValue {get; set;}
    
    public Integer limitOfResult {get; set;}
    public Integer offsetOfResult {get; set;}
    //
    
    
    //
	//Private static methods
	//
	private static String generateSortingValue(DC_SortingField field)
	{
		if (String.isBlank(field.name))
		{
			return null;
		}
		
		//1) add sorting field
		String sortingValue = field.name;
		
		//2) add sorting order
		if (field.sortingOrder == DC_SoqlEnums.SortingOrder.Ascending)
		{
			sortingValue += ' ASC';
		}
		else if (field.sortingOrder == DC_SoqlEnums.SortingOrder.Descending)
		{
			sortingValue += ' DESC';
		}
		
		//3) add strategy of sorting of null values
		if (field.nullValuesOrder == DC_SoqlEnums.NullValuesSortingOrder.First)
		{
			sortingValue += ' NULLS FIRST';
		}
		else if (field.nullValuesOrder == DC_SoqlEnums.NullValuesSortingOrder.Last)
		{
			sortingValue += ' NULLS LAST';
		}
		
		return sortingValue;
	}
	//
    
    
    //
    //Public methods
    //
    public void setOrderByBlock(DC_SortingField[] sortingFields)
	{
		//check input parameters
		if (sortingFields == null)
		{
			this.orderByBlockValue = null;
			return;
		}
		
		//generate all sorting values
		List<String> sortingValues = new List<String>();
		for (DC_SortingField sortingField : sortingFields)
		{
			if (sortingField != null)
			{
				String sortingValue = generateSortingValue(sortingField);
				if (String.isNotBlank(sortingValue))
				{
					sortingValues.add(sortingValue);
				}
			}
		}
		
		//generate a final value for sorting
		this.orderByBlockValue = String.join(sortingValues, SEPARATOR_OF_SORTING_VALUES);
	}
    
    public String buildQuery()
    {
        //check required data
        if (String.isBlank(this.selectedFields) || String.isBlank(this.objectName))
        {
            return null;
        }
        
        //create main part of the query
        String soqlQuery = 'SELECT ' + this.selectedFields + ' FROM ' + this.objectName;
        
        //add WHERE section to the query
        if (String.isNotBlank(this.condition))
        {
            soqlQuery += ' WHERE ' + this.condition;
        }
        
        //NOTE: we do not need WITH section at this time
        
        //add GROUP BY or GROUP BY ROLLUP section to the query
        if (String.isNotBlank(this.groupByBlockValue))
        {
            soqlQuery += ' GROUP BY ' + this.groupByBlockValue;
        }
        else if (String.isNotBlank(this.groupByRollupBlockValue))
        {
        	soqlQuery += ' GROUP BY ROLLUP (' + this.groupByRollupBlockValue + ')';
        }
        
        //add HAVING block to the query
        if (String.isNotBlank(this.havingBlockValue))
        {
            soqlQuery += ' HAVING ' + this.havingBlockValue;
        }
        
        //add ORDER BY block to the query
        if (String.isNotBlank(this.orderByBlockValue))
        {
            soqlQuery += ' ORDER BY ' + this.orderByBlockValue;
        }
        
        //add LIMIT block to the query (limit must be a non-negative value)
        if (this.limitOfResult >= 0)
        {
            soqlQuery += ' LIMIT ' + this.limitOfResult;
        }
        
        //add OFFSET block to the query (SOQL offset must be a non-negative value)
        if (this.offsetOfResult >= 0)
        {
            soqlQuery += ' OFFSET ' + this.offsetOfResult;
        }
        
        return soqlQuery;
    }
}