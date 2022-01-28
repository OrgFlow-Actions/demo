/*------------------------------------------------------------	
Author: 		Kevin Do (Salesforce) 2019-09-25 	
Description:   	Generic Trigger for Account (Following Trigger Framework)
------------------------------------------------------------*/

trigger AccountTrigger on Account (
        before insert
        , before update
        , before delete
        , after insert
        , after update
        , after delete
        , after undelete) {
    new AccountTriggerHandler().run();
}