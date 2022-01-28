//
//This class encapsulates details of a sorting field
//
//Author: Gennadiy Pervukhin (27-10-2014)
public class DC_SortingField
{
	//
	//Constructors
	//
	public DC_SortingField(String name)
	{
		this(name, DC_SoqlEnums.SortingOrder.Ascending);
	}
	
	public DC_SortingField(String name, DC_SoqlEnums.SortingOrder sortingOrder)
	{
		this(name, sortingOrder, DC_SoqlEnums.NullValuesSortingOrder.First);
	}
	
	public DC_SortingField(String name, DC_SoqlEnums.SortingOrder sortingOrder,
		DC_SoqlEnums.NullValuesSortingOrder nullValuesOrder)
	{
		this.name = name;
		this.sortingOrder = sortingOrder;
		this.nullValuesOrder = nullValuesOrder;
	}
	//
	
	//
	//Public properties
	//
	public String name {get; set;}
	public DC_SoqlEnums.SortingOrder sortingOrder {get; set;}
	public DC_SoqlEnums.NullValuesSortingOrder nullValuesOrder {get; set;}
	//
	
	//
	//Public methods
	//
	public String getSortingOrderName()
	{
		return String.valueOf(this.sortingOrder);
	}
	
	public void reverseSortingOrder()
	{
		if (this.sortingOrder == DC_SoqlEnums.SortingOrder.Ascending)
		{
			this.sortingOrder = DC_SoqlEnums.SortingOrder.Descending;
		}
		else if (this.sortingOrder == DC_SoqlEnums.SortingOrder.Descending)
		{
			this.sortingOrder = DC_SoqlEnums.SortingOrder.Ascending;
		}
	}
	//
}