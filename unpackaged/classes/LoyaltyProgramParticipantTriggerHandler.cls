/*-------------------------------------------------------------------------------------------------------
Author: 		Kevin Ruibin Do (Salesforce) 20200903
Description:   	LoyaltyProgramParticipant__c Trigger Handler Class
History	
20200903 	    Kevin Ruibin Do - Created Class
--------------------------------------------------------------------------------------------------------*/

public class LoyaltyProgramParticipantTriggerHandler extends TriggerHandler {
    private List<LoyaltyProgramParticipant__c> oldLoyaltyProgramParticipantList, newLoyaltyProgramParticipantList;
    private Map<Id, LoyaltyProgramParticipant__c> oldLoyaltyProgramParticipantMap, newLoyaltyProgramParticipantMap;
    
    public LoyaltyProgramParticipantTriggerHandler() {
        oldLoyaltyProgramParticipantList = (List<LoyaltyProgramParticipant__c>) Trigger.old;
        newLoyaltyProgramParticipantList = (List<LoyaltyProgramParticipant__c>) Trigger.new;
        oldLoyaltyProgramParticipantMap = (Map<Id, LoyaltyProgramParticipant__c>) Trigger.oldMap;
        newLoyaltyProgramParticipantMap = (Map<Id, LoyaltyProgramParticipant__c>) Trigger.newMap;
    }

    protected override void beforeInsert() {
        LoyaltyProgramParticipantTriggerHelper.setExternalId(newLoyaltyProgramParticipantList);
    }
}