/*------------------------------------------------------------	
Author: 		Kevin Do (Salesforce) 2020-04-23 	
Description:   	Generic TriggerHandler for Call_Report__c (Following Trigger Framework)
------------------------------------------------------------*/
public without sharing class CallReportTriggerHandler extends TriggerHandler {
    private List<Call_Report__c> oldCallReportList, newCallReportList;
    private Map<Id, Call_Report__c> oldCallReportMap, newCallReportMap;

    public CallReportTriggerHandler() {
        oldCallReportList = (List<Call_Report__c>) Trigger.old;
        newCallReportList = (List<Call_Report__c>) Trigger.new;
        oldCallReportMap = (Map<Id, Call_Report__c>) Trigger.oldMap;
        newCallReportMap = (Map<Id, Call_Report__c>) Trigger.newMap;
    }

    protected override void afterUpdate() {
        CallReportTriggerHelper.setEventSbu(newCallReportMap, oldCallReportMap);
        CallReportTriggerHelper.setEventDescription(newCallReportMap, oldCallReportMap);
    }
}