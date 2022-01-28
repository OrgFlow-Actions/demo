trigger CventEventInternalTrigger on CVENT__Cvent_Event__c (
        before insert
        , before update
        , before delete
        , after insert
        , after update
        , after delete
        , after undelete    
) {
		new CventEventInternalTriggerHandler().run();
}