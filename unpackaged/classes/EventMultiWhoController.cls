public with sharing class EventMultiWhoController {
    private final static Integer MAX_RESULTS = 5;

    @AuraEnabled(Cacheable=true)
    public static List<LookupSearchResult> search(String searchTerm, List<String> selectedIds) {
        // Prepare results
        List<LookupSearchResult> results = new List<LookupSearchResult>();
        try {
            // Prepare query paramters
            searchTerm += '*';
    
            // Execute search query
            List<List<SObject>> searchResults = [
                FIND :searchTerm
                IN ALL FIELDS
                RETURNING
                    Contact(Id, Name, Email, Account.Name WHERE Id NOT IN :selectedIds)
                LIMIT :MAX_RESULTS
            ];
    
            // Extract Contacts & convert them into LookupSearchResult
            String contactIcon = 'standard:contact';
            Contact[] contacts = ((List<Contact>) searchResults[0]);
            for (Contact contact : contacts) {
                results.add(new LookupSearchResult(
                        contact.Id
                        , 'Contact'
                        , contactIcon
                        , contact.Name
                        , contact.Account.Name/* 'Contact • ' + contact.Email */
                        , 'icon'
                ));
            }
        } catch (Exception e) {
            DebugLog.addException(e, 'search');
            throw new AuraHandledException(e.getMessage());
        }

        return results;
    }

    @AuraEnabled(Cacheable=true)
    public static List<LookupSearchResult> getContacts(Id contactId) {
        List<LookupSearchResult> results = new List<LookupSearchResult>();
        try {
            List<Contact> ContactList = new List<Contact>([
                SELECT Id, Name, Email, Account.Name 
                FROM Contact 
                WHERE Id = :contactId
            ]); 
            // Prepare results
            for (Contact contactRecord : ContactList) {
                LookupSearchResult searchResult = new LookupSearchResult(
                    contactRecord.Id
                    , 'Contact'
                    , 'standard:contact'
                    , contactRecord.Name
                    , contactRecord.Account.Name /* 'Contact • ' + contactRecord.Email */
                    , 'icon'
                );
                results.add(searchResult);
            }
        } catch (Exception e) {
            DebugLog.addException(e, 'getEventWhoids');
            throw new AuraHandledException(e.getMessage());
        }
        return results;
    }

    @AuraEnabled(Cacheable=true)
    public static List<LookupSearchResult> getEventWhoIds(Id eventId) {
        List<LookupSearchResult> results = new List<LookupSearchResult>();
        try {
            List<EventRelation> eventRelationList = new List<EventRelation>([
                SELECT RelationId, Relation.Name, Relation.Email, Account.Name, Event.WhoId 
                FROM EventRelation 
                WHERE EventId=:eventId AND isParent=true AND isWhat=false AND Relation.Type='Contact'
            ]); 
            
            for (EventRelation eventRelation : eventRelationList) {
                LookupSearchResult searchResult = new LookupSearchResult(
                    eventRelation.RelationId
                    , 'Contact'
                    , 'standard:contact'
                    , eventRelation.Relation.Name
                    , eventRelation.Account.Name /* 'Contact • ' + eventRelation.Relation.Email */
                    , 'icon'
                );
                if (eventRelation.Event.WhoId.equals(eventRelation.RelationId) && !results.isEmpty()) {
                    results.add(0, searchResult);
                } else {
                    results.add(searchResult);
                }
            }
        } catch (Exception e) {
            DebugLog.addException(e, 'getEventWhoids');
            throw new AuraHandledException(e.getMessage());
        }
        return results;
    }

    @AuraEnabled
    public static List<EventRelation> setEventWhoIds(Id eventId, List<Id> whoIdList) {
        List<Event> eventList = new List<Event>([SELECT Id, WhoId FROM Event WHERE Id=:eventId]);
        List<EventRelation> existingEventRelationList = new List<EventRelation>([
            SELECT Id, EventId, RelationId, IsParent, IsWhat
            FROM EventRelation
            WHERE EventId=:eventId AND isParent=true AND isWhat=false
        ]);
        Map<String, EventRelation> contactEvRelationMap = new Map<String, EventRelation>();
        for (EventRelation evRelationRecord : existingEventRelationList) {
            contactEvRelationMap.put(evRelationRecord.RelationId, evRelationRecord);
        }
        List<EventRelation> deleteEventRelationList = new List<EventRelation>();
        List<EventRelation> newEventRelationList = new List<EventRelation>();
        for (Id whoId : whoIdList) {
            if (null != contactEvRelationMap.get(whoId)) {
                newEventRelationList.add(contactEvRelationMap.get(whoId));
            } else {
                newEventRelationList.add(new EventRelation(
                    EventId = eventId
                    , RelationId = whoId
                    , IsParent = true
                    , isWhat = false
                ));
            }
        }
        for (EventRelation existingEvRelation : existingEventRelationList) {
            if (!newEventRelationList.contains(existingEvRelation)) {
                deleteEventRelationList.add(existingEvRelation);
            }
        }
        try {
            upsert newEventRelationList;
            delete deleteEventRelationList;
            eventList[0].WhoId = newEventRelationList[0].RelationId;
            update eventList;
        } catch (Exception e) {
            DebugLog.addException(e, 'EventMultiWhoController');
            throw new AuraHandledException(e.getMessage());
        }
        return newEventRelationList;
    }
}