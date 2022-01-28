/*------------------------------------------------------------	
Author: 		Kevin Do (Salesforce) 2020-01-16 	
Description:   	Generic Trigger for Contract (Following Trigger Framework)
------------------------------------------------------------*/

trigger ContractTrigger on Contract (
    before insert
    , before update
    , before delete
    , after insert
    , after update
    , after delete
    , after undelete) {
    new ContractTriggerHandler().run();
}