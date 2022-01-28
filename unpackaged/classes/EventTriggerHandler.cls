/*-------------------------------------------------------------------------------------------------------
Author: 		Ahmed LOUDRASSI (Salesforce) 20191107
Description:   	Event Trigger Handler Class
History	
20191107 	Ahmed LOUDRASSI			CallReportEventTrigger, CallReportEventTriggerAfterInsert, DC_EventBackgroundJobs an DeleteClonedChildEvent triggers. (#)
--------------------------------------------------------------------------------------------------------*/

public class EventTriggerHandler extends TriggerHandler {
    private List<Event> oldEventList, newEventList;
    private Map<Id, Event> oldEventMap, newEventMap;
    
    public EventTriggerHandler() {
        oldEventList = (List<Event>) Trigger.old;
        newEventList = (List<Event>) Trigger.new;
        oldEventMap = (Map<Id, Event>) Trigger.oldMap;
        newEventMap = (Map<Id, Event>) Trigger.newMap;
    }
    protected override void beforeInsert() {
        EventTriggerHelper.preventRecurringCFE(newEventList);
        EventTriggerHelper.callReportEvent(newEventList);
        EventTriggerHelper.callReportEvent2(newEventList);
        EventTriggerHelper.updateNewOutlookEvent(newEventList);
        EventTriggerHelper.setEventDescription(newEventList, oldEventMap);
    }
    protected override void beforeUpdate() {
        EventTriggerHelper.preventRecurringCFE(newEventList);
        EventTriggerHelper.trackBeforeUpdate(newEventList);
        EventTriggerHelper.outlookReccurenceCheck(newEventList, oldEventMap);
        EventTriggerHelper.setEventDescription(newEventList, oldEventMap);
    }
    protected override void afterInsert() {
        EventTriggerHelper.manageNoticesOnEventsInserted(newEventList);
        EventTriggerHelper.setEventSubject(newEventMap, oldEventMap);
    }
    protected override void afterUpdate() {
        EventTriggerHelper.trackAfterUpdate(newEventList, oldEventMap);
        EventTriggerHelper.deleteClonedChildEventOnUpdate(newEventMap);
        EventTriggerHelper.setEventSubject(newEventMap, oldEventMap);
    }
    protected override void beforeDelete() {
        EventTriggerHelper.trackBeforeDelete(oldEventList);
    }
    protected override void afterDelete() {
        EventTriggerHelper.manageNoticesOnEventsDeleted(oldEventList);
        EventTriggerHelper.deleteClonedChildEventOnDelete(oldEventMap);
    }
}