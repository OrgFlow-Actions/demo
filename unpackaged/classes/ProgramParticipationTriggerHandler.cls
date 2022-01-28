/*-------------------------------------------------------------------------------------------------------
Author:         Ahmed LOUDRASSI (Salesforce) 20191127
Description:    ProgramParticipation  Trigger Handler Class
History
20191023   Ahmed LOUDRASSI   Migrated   setProgramParticipationName trigger. (#)
----------------------------------------------------------------------------------------*/
public with sharing class ProgramParticipationTriggerHandler extends TriggerHandler {
	private List<Program_Participation__c> oldProgramParticipationList, newProgramParticipationList;
    private Map<Id, Program_Participation__c> oldProgramParticipationMap, newProgramParticipationMap;

    public ProgramParticipationTriggerHandler() {
        oldProgramParticipationList = (List<Program_Participation__c>) Trigger.old;
        newProgramParticipationList = (List<Program_Participation__c>) Trigger.new;
        oldProgramParticipationMap = (Map<Id, Program_Participation__c>) Trigger.oldMap;
        newProgramParticipationMap = (Map<Id, Program_Participation__c>) Trigger.newMap;
    }
    protected override void beforeInsert() {
        ProgramParticipationTriggerHelper.setProgramParticipationName(newProgramParticipationList);
    }
    protected override void beforeUpdate() {
        ProgramParticipationTriggerHelper.setProgramParticipationName(newProgramParticipationList);
    }
}