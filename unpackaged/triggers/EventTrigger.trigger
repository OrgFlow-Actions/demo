/*------------------------------------------------------------	
Author: 		Ahmed LOUDRASSI (Salesforce) 2019-11-07	
Description:   	Generic Trigger for Event (Following Trigger Framework)
------------------------------------------------------------*/

trigger EventTrigger on Event (
        before insert
        , before update
        , before delete
        , after insert
        , after update
        , after delete
        , after undelete) {
    new EventTriggerHandler().run();
}