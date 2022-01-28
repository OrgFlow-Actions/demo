/*------------------------------------------------------------	
Author: 		LOUDRASSI Ahmed (Salesforce) 2019-02-25 	
Description:   	Generic Trigger for OrderItem (Following Trigger Framework)
------------------------------------------------------------*/

trigger OrderItemTrigger on OrderItem (
        before insert
        , before update
        , before delete
        , after insert
        , after update
        , after delete
        , after undelete) {
    new OrderItemTriggerHandler().run();
}