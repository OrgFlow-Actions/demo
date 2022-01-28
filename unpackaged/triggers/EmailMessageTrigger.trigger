/*------------------------------------------------------------	
Author: 		Ahmed LOUDRASSI (Salesforce) 2019-12-18	
Description:   	Generic Trigger for Event (Following Trigger Framework)
------------------------------------------------------------*/

trigger EmailMessageTrigger on EmailMessage (
        before insert
        , before update
        , before delete
        , after insert
        , after update
        , after delete
        , after undelete) {
    new EmailMessageTriggerHandler().run();
}