/*------------------------------------------------------------
Author:         Ahmed LOUDRASSI (Salesforce) 2019-11-27
Description:    Generic Trigger for Program_Participation__c (Following Trigger Framework)
------------------------------------------------------------*/
trigger ProgramParticipationTrigger on Program_Participation__c  (
        before insert
        , before update
        , before delete
        , after insert
        , after update
        , after delete
        , after undelete) {
    new ProgramParticipationTriggerHandler().run();
}