/*Version History
 * Date: 03-Dec-2018
 * Class Name: EventRelationsUpdate
 * Created By: Amit Kumar Prabhat(amitkumar.prabhat@mindtree.com)
 * Related to: CFE Development : 
 * Related Test Class: EventRelationsUpdateTest.cls
 * 25-March-2019 Amit k Prabhat: changed exception handling to show proper error message on UI
*/

public with Sharing class EventRelationsUpdate {
@AuraEnabled
    public static String changeStatusAccepted(Id eventId) {
    if (EventRelationDetails.lightningSyncEnabledProfile()) { 
       return System.Label.Ltng_Sync_CFE_NO_Accept_Decline;
        }
        else {
        if(eventId != null) {
            String current_user = UserInfo.getUserId();
            Event childEvnt = [select WhatId,Call_Report__c,subject,StartDateTime,EndDateTime,Astra_Tech_Type__c from Event where id =: eventId][0];
            Event userEvt = [select id from event where 
                             WhatId =: childEvnt.WhatId and 
                             call_report__c =: childEvnt.Call_Report__c and
                             subject =: childEvnt.subject and
                             StartDateTime =: childEvnt.StartDateTime and
                             EndDateTime =: childEvnt.EndDateTime and
                             Astra_Tech_Type__c =: childEvnt.Astra_Tech_Type__c and
                             Assigned_to_me__c = False and
                            IsChild = False][0];
            if(userEvt != null) {
            EventRelation eRel = [SELECT status FROM EventRelation WHERE EventId =: userEvt.Id and RelationId =:current_user];
                if( eRel.status == 'New') {
           eRel.status = 'Accepted';
             try {
            update eRel;
           }
            catch (Exception ex) {
           throw new AuraHandledException('Exception During Event Accept/Decline:'+ ex.getMessage()); 
        }
             }
            }
        }
        return 'SUCCESS';
        }
    }
@AuraEnabled
    public static String changeStatusRejected(Id eventId) {
         if (EventRelationDetails.lightningSyncEnabledProfile()) {
          return System.Label.Ltng_Sync_CFE_NO_Accept_Decline;
         }
        else {
        if(eventId != null) {
            String current_user = UserInfo.getUserId();
            Event childEvnt = [select WhatId,Call_Report__c,subject,StartDateTime,EndDateTime,Astra_Tech_Type__c from Event where id =: eventId][0];
            Event userEvt = [select id from event where 
                             WhatId =: childEvnt.WhatId and 
                             call_report__c =: childEvnt.Call_Report__c and
                             subject =: childEvnt.subject and
                             StartDateTime =: childEvnt.StartDateTime and
                             EndDateTime =: childEvnt.EndDateTime and
                             Astra_Tech_Type__c =: childEvnt.Astra_Tech_Type__c and
                             Assigned_to_me__c = False and
                            IsChild = False][0];
            
               if(userEvt != null) {
            EventRelation eRel = [SELECT status FROM EventRelation WHERE EventId =: userEvt.Id and RelationId =:current_user];
                if( eRel.status != 'Declined') {
           eRel.status = 'Declined';
             try {
            update eRel;
           }
            catch (Exception ex) {
            throw new AuraHandledException('Exception During Event Accept/Decline:'+ ex.getMessage()); 
        }
             }
            }
        }
         return 'SUCCESS'; 
        }
    }
    }