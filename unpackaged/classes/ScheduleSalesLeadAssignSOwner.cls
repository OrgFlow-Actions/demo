/**
 * @description       : Class to schedule BatchSalesLeadAssignSuggestedOwner
 * @author            : kdoruibin@salesforce.com
 * @group             : 
 * @last modified on  : 06-21-2021
 * @last modified by  : kdoruibin@salesforce.com
 * Modifications Log 
 * Ver   Date         Author                     Modification
 * 1.0   06-15-2021   kdoruibin@salesforce.com   Initial Version
**/
global without sharing class ScheduleSalesLeadAssignSOwner implements Schedulable {
    global void execute (SchedulableContext ctx){
        Database.executeBatch(new BatchSalesLeadAssignSuggestedOwner(), 200);
    }
}