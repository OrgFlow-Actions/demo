/**
 * @description       : Sets event description based on call notes
 *                      Anonymous apex call: Id batchJobId = Database.executeBatch(new BatchSetEventDescription('<year>'), 200);
 * @author            : kdoruibin@salesforce.com
 * @group             : 
 * @last modified on  : 05-11-2021
 * @last modified by  : kdoruibin@salesforce.com
 * Modifications Log 
 * Ver   Date         Author                     Modification
 * 1.0   05-10-2021   kdoruibin@salesforce.com   Initial Version
**/
global class BatchSetEventDescription implements Database.Batchable<SObject>, Database.Stateful {
    private String year;
    public BatchSetEventDescription(String year) {
        this.year = year;
    }

    global Database.QueryLocator start(Database.BatchableContext bc) {
        String query = 'SELECT Id, Description, Call_Report__r.Call_Notes__c FROM Event WHERE IsChild = false AND Customer_Facing_Event__c = true AND IsRecurrence = false AND IsRecurrence2 = false AND CALENDAR_YEAR(CreatedDate) IN (' + year + ')';
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext bc, List<Event> scope) {
        try {
            List<Event> eventToUpdateList = new List<Event>();

            for (Event eventToUpdate : scope) {
                if (String.isNotBlank(eventToUpdate.Description)) continue;
                if (eventToUpdate.Call_Report__r?.Call_Notes__c == null) continue;
                eventToUpdate.Description = eventToUpdate.Call_Report__r.Call_Notes__c;
                eventToUpdateList.add(eventToUpdate);
            }

            update eventToUpdateList;
        } catch (DmlException e) {
            DebugLog.addException(e, 'Trying dummy update from BatchSetEventDescription');
        }
    }

    global void finish(Database.BatchableContext bc) {
        DebugLog.addinfo('This is the BatchSetEventDescription JobId:', bc.getJobId());
    }
}