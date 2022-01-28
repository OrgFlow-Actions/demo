/**
 * @description       : Called by CallReportQuickActionPoc.js
 *                      Creates an Event as a CFE and relates it to the Created Call_Report__c record
 *                      that was created via the 'Report Event' action.
 * @author            : kdoruibin@salesforce.com
 * @group             : 
 * @last modified on  : 12-11-2020
 * @last modified by  : kdoruibin@salesforce.com
 * Modifications Log 
 * Ver   Date         Author                     Modification
 * 1.0   12-10-2020   kdoruibin@salesforce.com   Initial Version
**/
public with sharing class CallReportQuickActionPocController {
    @AuraEnabled
    public static String createEvent(Id callReportId, Id eventWhatId, String coTravel) {
        Call_Report__c callReport = [
            SELECT Id, StartDateTime__c, EndDateTime__c, ProductGroup__c, EventWhoIds__c, CreatedById, ActivityType__c, ActivitySubtype__c, Subject__c
            FROM Call_Report__c
            WHERE Id = :callReportId
        ];

        List<String> whoIdList = new List<String>();
        if (String.isNotBlank(callReport.EventWhoIds__c)) {
            whoIdList = (List<String>) JSON.deserialize(callReport.EventWhoIds__c, List<String>.class);
        }

        Address eventAddress;
        Contact eventContact;
        if (eventWhatId.getSobjectType() == Contact.sObjectType) {
            Id contactId = whoIdList.isEmpty() ? eventWhatId : whoIdList.get(0);
            eventContact = [SELECT AccountId, MailingAddress FROM Contact WHERE Id = :contactId];
            eventAddress = eventContact?.MailingAddress;
        } else if (eventWhatId.getSobjectType() == Lead.sObjectType) {
            eventAddress = [SELECT Address FROM Lead WHERE Id = :eventWhatId]?.Address;
        } else if (eventWhatId.getSobjectType() == Account.sObjectType) {
            eventAddress = [SELECT BillingAddress FROM Account WHERE Id = :eventWhatId]?.BillingAddress;
        } else if (eventWhatId.getSobjectType() == Opportunity.sObjectType) {
            eventAddress = [SELECT Account.BillingAddress FROM Opportunity WHERE Id = :eventWhatId]?.Account?.BillingAddress;
        } else if (eventWhatId.getSobjectType() == Order.sObjectType) {
            eventAddress = [SELECT Account.BillingAddress FROM Order WHERE Id = :eventWhatId]?.Account?.BillingAddress;
        } else if (eventWhatId.getSobjectType() == Field_Sales_Project_Members__c.sObjectType) {
            eventAddress = [SELECT Account__r.BillingAddress FROM Field_Sales_Project_Members__c WHERE Id = :eventWhatId]?.Account__r?.BillingAddress;
        }

        // List<String> whoIdList = (List<String>) JSON.deserialize(callReport.EventWhoIds__c, List<String>.class); //
        // Contact eventWho = [SELECT Id, AccountId, MailingStreet, MailingCity, MailingState, MailingCountry FROM Contact WHERE Id = :whoIdList[0]]; //
        String locationStringFormatted;
        if (eventAddress != null) {
            List<Object> locationParameters = new List<Object>{
                String.isNotBlank(eventAddress?.Street) ? eventAddress.Street : ''
                , String.isNotBlank(eventAddress?.City) ? ', ' + eventAddress.City : ''
                , String.isNotBlank(eventAddress?.State) ? ', ' + eventAddress.State : ''
                , String.isNotBlank(eventAddress?.Country) ? ', ' + eventAddress.Country : ''
            };
            locationStringFormatted = String.format('{0}{1}{2}{3}', locationParameters);
        }

        Event newEvent = new Event(
            Call_Report__c = callReportId
            , Customer_Facing_Event__c = true
            , OwnerId = callReport.CreatedById
            , WhoId = whoIdList.isEmpty() ? null : whoIdList.get(0)
            , WhatId = eventContact == null ? eventWhatId : eventContact.AccountId
            , IsAllDayEvent = false
            , StartDateTime = callReport.StartDateTime__c
            , EndDateTime = callReport.EndDateTime__c
            , SBU__c = callReport.ProductGroup__c
            , Astra_Tech_Type__c = callReport.ActivityType__c //'Cold Call'
            , Activity_Subtype__c = callReport.ActivitySubtype__c
            , Subject = callReport.Subject__c
            , Event_Status__c = 'Completed'
            , Location = locationStringFormatted
            ,Co_travel__c = coTravel
        );

        try {
            insert newEvent;
        } catch (Exception e) {
            DebugLog.addException(e, 'CallReportQuickActionPocController');
            throw new AuraHandledException(e.getMessage());
        }

        List<EventRelation> newEventRelationList = new List<EventRelation>();
        for (Id whoId : whoIdList) {
            if (whoId == newEvent.WhoId) continue;
            newEventRelationList.add(new EventRelation(
                EventId = newEvent.Id
                , RelationId = whoId
                , IsParent = true
                , IsWhat = false
            ));
        }

        try {
            insert newEventRelationList;
        } catch (Exception e) {
            DebugLog.addException(e, 'CallReportQuickActionPocController');
            throw new AuraHandledException(e.getMessage());
        }

        return newEvent.Id;
    }
    @AuraEnabled(cacheable=true)
    public static List<String> getPickListValuesIntoList(){
       List<String> pickListValuesList= new List<String>();
		Schema.DescribeFieldResult fieldResult = Event.Co_travel__c.getDescribe();
		List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
		for( Schema.PicklistEntry pickListVal : ple){
			pickListValuesList.add(pickListVal.getLabel());
		}     
		return pickListValuesList;
    }
}