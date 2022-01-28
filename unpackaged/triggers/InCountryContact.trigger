trigger InCountryContact on Contact (before insert, after insert, before update, after update, after delete, after undelete) {
    SObjectType triggerType = trigger.isDelete ? Trigger.old.getSObjectType() : Trigger.new.getSObjectType();

    if (!testInCountry1.InCountryReplicationTriggerHandler.disableTrigger && !testInCountry1.InCountryReplicationTriggerHandler.alreadyExecuted(triggerType)) {
        
        testInCountry1.InCountryReplicationTriggerHandler handler = new testInCountry1.InCountryReplicationTriggerHandler(triggerType.getDescribe().getName());
        if (Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate)) {
            handler.handleBeforeInsert();
        } else if (Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate)) {
            handler.handleAfterInsert();
            testInCountry1.InCountryReplicationTriggerHandler.registerExecution(triggerType);
        } else if (Trigger.isAfter && Trigger.isUndelete) {
            handler.handleAfterUndelete();
        }
    } 
    if (Trigger.isDelete && Trigger.isAfter) {
        SObjectType triggerType = trigger.isDelete ? Trigger.old.getSObjectType() : Trigger.new.getSObjectType();
        testInCountry1.InCountryReplicationTriggerHandler handler = new testInCountry1.InCountryReplicationTriggerHandler(triggerType.getDescribe().getName());
        handler.handleAfterDelete();
    }
}