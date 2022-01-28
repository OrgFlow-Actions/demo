/**
 * @description       : 
 * @author            : kdoruibin@salesforce.com
 * @group             : 
 * @last modified on  : 03-29-2021
 * @last modified by  : kdoruibin@salesforce.com
 * Modifications Log 
 * Ver   Date         Author                     Modification
 * 1.0   04-23-2020   kdoruibin@salesforce.com   Initial Version
 * 1.1   14-01-2020   kdoruibin@salesforce.com   Bulkified setEventDescription() TFUS-000002565
**/

public without sharing class CallReportTriggerHelper {
    
    /**
    * @description Sets Event.SBU__c based on Call_Report__c.ProductGroup__c
    * @author kdoruibin@salesforce.com | 01-14-2021 
    * @param Map<Id Call_Report__c> newCallReportMap 
    * @param Map<Id Call_Report__c> oldCallReportMap 
    **/
    public static void setEventSbu(Map<Id, Call_Report__c> newCallReportMap, Map<Id, Call_Report__c> oldCallReportMap) {
        Map<Id, Call_Report__c> updatedCallReportMap = new Map<Id, Call_Report__c>();

        for (Call_Report__c callReport : newCallReportMap.values()) {
            if (callReport.ProductGroup__c != oldCallReportMap.get(callReport.Id).ProductGroup__c) {
                updatedCallReportMap.put(callReport.Id, callReport);
            }
        }

        List<Event> eventToCheckList = [SELECT Id, SBU__c, Call_Report__c FROM Event WHERE IsChild = false AND Call_Report__c IN :updatedCallReportMap.keySet()];
        List<Event> eventToUpdateList = new List<Event>();

        for (Event eventToCheck : eventToCheckList) {
            if (eventToCheck.SBU__c != updatedCallReportMap.get(eventToCheck.Call_Report__c).ProductGroup__c) {
                eventToCheck.SBU__c = updatedCallReportMap.get(eventToCheck.Call_Report__c).ProductGroup__c;
                eventToUpdateList.add(eventToCheck);
            }
        }

        try {
            update eventToUpdateList;
        } Catch (Exception e) {
            DebugLog.addException(e, 'Failed to update Event SBU field');
        }
    }

    /**
    * @description Populates Event.Description when Call_Report__c.Call_Notes__c is updated and Event.Event_Status__c == 'Completed'
    * @author kdoruibin@salesforce.com | 01-14-2021 
    * @param Map<Id Call_Report__c> newCallReportMap 
    * @param Map<Id Call_Report__c> oldCallReportMap 
    **/
    public static void setEventDescription(Map<Id, Call_Report__c> newCallReportMap, Map<Id, Call_Report__c> oldCallReportMap) {
        Map<Id, Call_Report__c> updatedCallReportMap = new Map<Id, Call_Report__c>();

        for (Call_Report__c callReport : newCallReportMap.values()) {
            if (callReport.Call_Notes__c != oldCallReportMap.get(callReport.Id).Call_Notes__c) {
                updatedCallReportMap.put(callReport.Id, callReport);
            }

        }
        
        List<Event> eventToCheckList = [SELECT Id, Description, Call_Report__c FROM Event WHERE IsChild = false /* AND Event_Status__c = 'Completed' */ AND Call_Report__c IN :updatedCallReportMap.keySet()];
        List<Event> eventToUpdateList = new List<Event>();

        for (Event eventToCheck : eventToCheckList) {
            Call_Report__c relatedCallReport = updatedCallReportMap.get(eventToCheck.Call_Report__c);
            if (eventToCheck.Description != relatedCallReport.Call_Notes__c) {
                eventToCheck.Description = relatedCallReport.Call_Notes__c;
                eventToUpdateList.add(eventToCheck);
            }
        }

        try {
            update eventToUpdateList;
        } catch (Exception e) {
            DebugLog.addException(e, 'Failed to update Event Description field');
        }
    }
}