/*------------------------------------------------------------	
Author: 		Kevin Do (Salesforce) 2020-04-23 	
Description:   	Generic Trigger for Call_Report__c (Following Trigger Framework)
------------------------------------------------------------*/
trigger CallReportTrigger on Call_Report__c (
    before insert
    , before update
    , before delete
    , after insert
    , after update
    , after delete
    , after undelete) {
    new CallReportTriggerHandler().run();
}