public with sharing class NavigateToCreateRecordController {
    @AuraEnabled(cacheable=true)
    public static String getRecord(Id recordId, String fields) {
        String sObjectName = recordId.getSobjectType().getDescribe().getName();
        String queryString = 'SELECT ' + fields + ' FROM ' + sObjectName + ' WHERE Id = \'' + recordId + '\'';
        List<SObject> queryResultList = Database.query(queryString);
        return JSON.serialize(queryResultList[0]);
    }
}