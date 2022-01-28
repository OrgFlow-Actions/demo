/*------------------------------------------------------------	
Author: 		Richard Trum (Glimt) 2019-11-28	
Description:   	KOL Information (Expert__c) Trigger Handler Class. 
History	
<Date>      <Authors Name>     <Brief Description of Change>
20191128 	Richard Trum	 	Created trigger framework for KOL Information (Expert__c)
------------------------------------------------------------*/

public class KOLInfoTriggerHandler extends TriggerHandler {
  
    private List<Expert__c> oldKOLList, newKOLList;
    private Map<Id, Expert__c> oldKOLMap, newKOLMap;

    public KOLInfoTriggerHandler() {
        System.debug('KOL Trigger started');
        oldKOLList = (List<Expert__c>) Trigger.old;
        newKOLList = (List<Expert__c>) Trigger.new;
        oldKOLMap = (Map<Id, Expert__c>) Trigger.oldMap;
        newKOLMap = (Map<Id, Expert__c>) Trigger.newMap;
    }

    protected override void beforeInsert() {
		KOLInfoTriggerHelper.preventDuplicateKOLs(newKOLList);
        KOLInfoTriggerHelper.setExpertName(newKOLList);
        KOLInfoTriggerHelper.setNonHCProfession(newKOLList);
    }

    protected override void beforeUpdate() {
        KOLInfoTriggerHelper.setExpertName(newKOLList);
        KOLInfoTriggerHelper.setNonHCProfession(newKOLList);
    }
    
}