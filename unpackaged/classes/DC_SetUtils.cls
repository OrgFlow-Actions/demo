//
//This class provides utility methods for working with sets
//
//Author: Gennadiy Pervukhin (27-10-2014)
public class DC_SetUtils
{
	//
	//Private static methods
	//
	private static SObject[] selectObjects(Map<String, SObject> sourceMap,
		Set<String> selectedKeys)
	{
		List<SObject> selectedObjects = new List<SObject>();
		for (String selectedKey : selectedKeys)
		{
			selectedObjects.add(sourceMap.get(selectedKey));
		}
		return selectedObjects;
	}
	//
	
	//
	//Public static methods
	//
	/*the method returns the relative complement of 2 sets ("subtracts" 2 sets).*/
	public static SObject[] findRelativeComplement(SObject[] sourceList,
		SObject[] subtractedList)
	{
		//check passed parameters
		if (sourceList == null)
		{
			return null;
		}
		else if (subtractedList == null)
		{
			return sourceList;
		}
		
		//initialize maps
		Map<String, SObject> sourceMap = new Map<String, SObject>(sourceList);
		Map<String, SObject> subtractedMap = new Map<String, SObject>(subtractedList);
		
		//select keys which are in sourceMap, but not in subtractedMap
		Set<String> selectedKeys = sourceMap.keySet().clone();
		selectedKeys.removeAll(subtractedMap.keySet());
		
		//select objects according to selected keys
		return selectObjects(sourceMap, selectedKeys); 
	}
	
	/*the method returns the intersection of 2 sets.*/
	public static List<SObject> findIntersection(SObject[] list1, SObject[] list2)
	{
		//check passed parameters
		if (list1 == null || list2 == null)
		{
			return null;
		}
		
		Map<String, SObject> map1 = new Map<String, SObject>(list1);
		Map<String, SObject> map2 = new Map<String, SObject>(list2);
		
		//select keys which are in both map1 and map2
		Set<String> selectedKeys = map1.keySet().clone();
		selectedKeys.retainAll(map2.keySet());
		
		//select objects according to selected keys
		return selectObjects(map1, selectedKeys);
	}
	//
}