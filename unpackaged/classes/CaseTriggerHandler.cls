/*-------------------------------------------------------------------------------------------------------
Author:         NISREEN ALSALEH (Avity) 25-March-2021
Description:    Case Trigger Handler Class
--------------------------------------------------------------------------------------------------------*/

public class CaseTriggerHandler extends TriggerHandler {
     private List<Case> oldCaseList, newCaseList;
     private Map<Id, Case> oldCaseMap, newCaseMap;
    
    public CaseTriggerHandler(){
        oldCaseList = (List<Case>) Trigger.old;
        newCaseList = (List<Case>) Trigger.new;
        oldCaseMap = (Map<Id, Case>) Trigger.oldMap;
        newCaseMap = (Map<Id, Case>) Trigger.newMap;
    }
    
    protected override void beforeInsert() {
        CaseTriggerHelper.defaultEntitlement(newCaseList);
	}
	
    protected override void beforeUpdate() {
       CaseTriggerHelper.defaultEntitlement(newCaseList);
    }
    protected override void afterUpdate() {
         CaseTriggerHelper.completeResolutionTimeMilestone(newCaseList);
         CaseTriggerHelper.completeFirstResponseTime(newCaseList);
    }


}