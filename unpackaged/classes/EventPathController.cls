public with sharing class EventPathController {
    @AuraEnabled
    public static string setEventStatus(String eventId, String eventStatus){
        Event eventToUpdate = [SELECT Id, Event_Status__c FROM Event WHERE Id = :eventId];
        eventToUpdate.Event_Status__c = eventStatus;

        try {
            update eventToUpdate;
        } catch (Exception e) {
            DebugLog.addException(e, 'EventPathController');
            throw new AuraHandledException(e.getMessage());
        }

        return eventToUpdate.Event_Status__c;
    }
}