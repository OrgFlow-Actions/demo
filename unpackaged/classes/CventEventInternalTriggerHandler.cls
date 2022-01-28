/*------------------------------------------------------------	
Author: 		Richard Trum (Glimt) 2020-03-03	
Description:   	Cvent Event Trigger Handler Class. 
History	
<Date>      <Authors Name>     <Brief Description of Change>
20200303 	Richard Trum	 	Created trigger framework for Cvent Events
------------------------------------------------------------*/

public class CventEventInternalTriggerHandler extends TriggerHandler {
    
    private List<CVENT__Cvent_Event__c> oldEventList, newEventList;
    private Map<Id, CVENT__Cvent_Event__c> oldEventMap, newEventMap;
    
    public CventEventInternalTriggerHandler() {
        oldEventList = (List<CVENT__Cvent_Event__c>) Trigger.old;
        newEventList = (List<CVENT__Cvent_Event__c>) Trigger.new;
        oldEventMap = (Map<Id, CVENT__Cvent_Event__c>) Trigger.oldMap;
        newEventMap = (Map<Id, CVENT__Cvent_Event__c>) Trigger.newMap;
    }
    
    /*protected override void beforeInsert() {

    }*/
    
    /*protected override void beforeUpdate() {

    }*/
    
    protected override void afterInsert() {
		CventEventInternalTriggerHelper.createCampaign(newEventList);
        CventEventInternalTriggerHelper.setEventOwner(newEventList);
    }
    
    protected override void afterUpdate() {
		CventEventInternalTriggerHelper.updateCampaign(newEventList);
        CventEventInternalTriggerHelper.setEventOwner(newEventList);
    }
}