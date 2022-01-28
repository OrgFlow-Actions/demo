/*------------------------------------------------------------	
Author: 		Miguel Coimbra (Salesforce) 2020-06-09
Description:   	Generic Trigger for OrderItem (Following Trigger Framework)
------------------------------------------------------------*/

trigger OrderTrigger on Order (
        before insert
        , before update
        , before delete
        , after insert
        , after update
        , after delete
        , after undelete) {
    new OrderTriggerHandler().run();
}