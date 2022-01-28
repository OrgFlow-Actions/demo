/*------------------------------------------------------------	
Author: 		Roberto Narbona
Description:   	Contact Trigger Handler Class. 
History	
<Date>      <Authors Name>     <Brief Description of Change>
20191128 	Roberto Narbona	 	Created trigger framework for Contact TFUS-000002832
------------------------------------------------------------*/

public class ContactTriggerHandler extends TriggerHandler {
  
    private List<Contact> oldContactList, newContactList;
    private Map<Id, Contact> oldContactMap, newContactMap;

    public ContactTriggerHandler() {
        oldContactList = (List<Contact>) Trigger.old;
        newContactList = (List<Contact>) Trigger.new;
        oldContactMap = (Map<Id, Contact>) Trigger.oldMap;
        newContactMap = (Map<Id, Contact>) Trigger.newMap;
    }
    
    protected override void beforeInsert() {
        ContactTriggerHelper.setValues(newContactList,newContactMap, oldContactMap);
    }
    protected override void beforeUpdate() {
        ContactTriggerHelper.setValues(newContactList,newContactMap, oldContactMap);
    }

    protected override void beforeDelete() {
        ContactTriggerHelper.showNoDeleteError(oldContactMap, oldContactList);
    }
    
}