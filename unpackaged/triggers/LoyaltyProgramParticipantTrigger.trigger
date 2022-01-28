/*------------------------------------------------------------	
Author: 		Kevin Ruibin Do (Salesforce) 2020-09-03	
Description:   	Generic Trigger for LoyaltyProgramParticipant__c (Following Trigger Framework)
------------------------------------------------------------*/

trigger LoyaltyProgramParticipantTrigger on LoyaltyProgramParticipant__c (
    before insert
    , before update
    , before delete
    , after insert
    , after update
    , after delete
    , after undelete
) {
    new LoyaltyProgramParticipantTriggerHandler().run();
}