/*------------------------------------------------------------
Author:         Ahmed LOUDRASSI (Salesforce) 2019-11-27
Description:    Generic Trigger for Expert__c (Following Trigger Framework)
------------------------------------------------------------*/
trigger ExpertTrigger on Expert__c  (
        before insert
        , before update
        , before delete
        , after insert
        , after update
        , after delete
        , after undelete) {
    new ExpertTriggerHandler().run();
}