//
//This class provides utility methods for working with Type object
//
//Author: Gennadiy Pervukhin (27-10-2014)
public class DC_ApexTypeUtils
{
    //
    //Public static methods
    //
    public static Type getType(String typeName)
    {
        //try get Type from a class name
        Type resultType;
        try
        {
            resultType = Type.forName(typeName);
        }
        catch (Exception e)
        {
            resultType = null;
            System.debug(LoggingLevel.ERROR, 'Exception occurred in ApexTypeUtils.getType: ' + e.getMessage());
        }
        
        return resultType;
    }
    
    //this method initializes empty list of a concrete type
    public static List<Object> createEmptyListByTypeName(String typeName)
    {
        String fullNameOfListType = 'List<' + typeName + '>';
        Type listType = DC_ApexTypeUtils.getType(fullNameOfListType);
        
        List<Object> resultList = null;
        if (listType != null)
        {
            resultList = (Object[])listType.newInstance();
        }
        
        return resultList;
    }
    //
}