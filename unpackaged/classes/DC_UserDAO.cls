//
//This class provides access to 'User' object.
//
//Author: Gennadiy Pervukhin (5-11-2014)
public class DC_UserDAO
{
    //
    //Constants
    //
    private static final String OBJECT_NAME = 'User';
    private static final String BASIC_FIELDS = 'Id, Name, Email, TimeZoneSidKey';
    //
    
    //
    //Public static methods
    //
    public static User[] getUsersByIds(String[] ids)
    {
        String stringOfIds = DC_SoqlUtils.joinStringsForINSection(ids);
        if (String.isBlank(stringOfIds))
        {
            return null;
        }
        
        DC_SoqlQueryBuilder queryBuilder =
            new DC_SoqlQueryBuilder(BASIC_FIELDS, OBJECT_NAME);
        queryBuilder.condition = 'Id IN (' + stringOfIds + ')';
        
        return DC_SoqlUtils.performQuery(queryBuilder);
    }
    
    public static Map<String, User> getUsersMapByPostalCodesSortedByCode(Set<String> codes) {
        System.debug('Codes2: '+codes);
        final String QUERY = 'select Id, Movex_Uer_ID__c from User where Movex_Uer_ID__c IN :codes';
        System.debug('query: '+ Database.query(QUERY));
        Map<String, User> usersMap = new Map<String, User>();
        for (User u : Database.query(QUERY)) {
            usersMap.put(u.Movex_Uer_ID__c, u);
        }
        return usersMap;
    }
    //
}