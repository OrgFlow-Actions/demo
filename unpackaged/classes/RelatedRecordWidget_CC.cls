/**
 * @description       : Used by callReportQuickACtionPocLwc
 * @author            : kdoruibin@salesforce.com
 * @group             : 
 * @last modified on  : 03-29-2021
 * @last modified by  : kdoruibin@salesforce.com
 * Modifications Log 
 * Ver   Date         Author                     Modification
 * 1.1   01-14-2021   kdoruibin@salesforce.com   Added permission checks
 * 1.0   12-09-2020   kdoruibin@salesforce.com   Initial Version
**/
public with sharing class RelatedRecordWidget_CC {
    
    /* @AuraEnabled(Cacheable=true)
    public static String getLookupFieldValue(Id recordId, String sObjectName, String lookupField) {
        String queryString = 'SELECT ' + lookupField + ' FROM ' +sObjectName + ' WHERE Id = \'' + recordId + '\'';
        List<SObject> queryResultList = Database.query(queryString);
        return (String) queryResultList[0].get(lookupField);
    } */

    /* @AuraEnabled(Cacheable=true)
    public static String getEventSbuFieldValue(Id recordId) {
        return (String) [SELECT SBU__c FROM Event WHERE Id = :recordId LIMIT 1].SBU__c;
    } */

    // Method to replace both above
    @AuraEnabled(Cacheable=true)
    public static SObject getEventRecord(Id recordId, String fields) {
        String queryString = 'SELECT ' + fields + ' FROM Event WHERE Id = \'' + recordId + '\'';
        List<Event> queryResultList = Database.query(queryString);
        SObjectAccessDecision securityDecision = Security.stripInaccessible(AccessType.READABLE, queryResultList);
        return securityDecision.getRecords()[0];
    }

    @AuraEnabled
    public static string completeEvent(Id recordId) {
        try {
            Event eventToUpdate = [SELECT Id, Event_Status__c FROM Event WHERE Id = :recordId LIMIT 1];
            if (eventToUpdate.Event_Status__c != 'Completed') {
                eventToUpdate.Event_Status__c = 'Completed';
                update eventToUpdate;
            }
            return JSON.serialize(eventToUpdate);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}