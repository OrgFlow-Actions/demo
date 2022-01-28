trigger StandardLeadTrigger on Lead (
        before insert
        , before update
        , before delete
        , after insert
        , after update
        , after delete
        , after undelete) {
    new StandardLeadTriggerHandler().run();
}