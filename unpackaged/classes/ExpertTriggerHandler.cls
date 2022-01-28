/*-------------------------------------------------------------------------------------------------------
Author:         Ahmed LOUDRASSI (Salesforce) 20191127
Description:    Expert  Trigger Handler Class
History
20191023   Ahmed LOUDRASSI   Migrated   setExpertName trigger. (#)
----------------------------------------------------------------------------------------*/
public with sharing class ExpertTriggerHandler extends TriggerHandler {
	private List<Expert__c> oldExpertList, newExpertList;
    private Map<Id, Expert__c> oldExpertMap, newExpertMap;

    public ExpertTriggerHandler() {
        oldExpertList = (List<Expert__c>) Trigger.old;
        newExpertList = (List<Expert__c>) Trigger.new;
        oldExpertMap = (Map<Id, Expert__c>) Trigger.oldMap;
        newExpertMap = (Map<Id, Expert__c>) Trigger.newMap;
    }
    protected override void beforeInsert() {
        ExpertTriggerHelper.setExpertName(newExpertList);
    }
    protected override void beforeUpdate() {
        ExpertTriggerHelper.setExpertName(newExpertList);
    }
}