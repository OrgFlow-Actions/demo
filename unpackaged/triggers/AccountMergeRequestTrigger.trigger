/*------------------------------------------------------------  
Author:         Roberto Narbona 20200625   
Description:    Generic Trigger for AccountMergeRequest (Following Trigger Framework)
------------------------------------------------------------*/
trigger AccountMergeRequestTrigger on AccountMergeRequest__c (
        before insert
        , before update
        , before delete
        , after insert
        , after update
        , after delete
        , after undelete) {
    new AccountMergeRequestTriggerHandler().run();
}