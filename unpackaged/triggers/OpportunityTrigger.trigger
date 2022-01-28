/*------------------------------------------------------------  
Author:     Richard Trum (Glimt) 2020-09-07   
Description:     Generic Trigger for Opportunity (Following Trigger Framework)
------------------------------------------------------------*/

trigger OpportunityTrigger on Opportunity (
        before insert
        , before update
        , before delete
        , after insert
        , after update
        , after delete
        , after undelete) {
    new OpportunityTriggerHandler().run();
}