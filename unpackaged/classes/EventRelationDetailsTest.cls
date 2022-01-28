/*Version History
 * Date: 19-Apr-2019
 * Class Name: EventRelationDetailsTest
 * Created By: Amit Kumar Prabhat(amitkumar.prabhat@mindtree.com)
 * Related to: CFE Lightning Development 
 * Related Class: EventRelationDetails
*/

@isTest
public class EventRelationDetailsTest {
  
@isTest
    
    static void getEventRelationDetailsTest(){
      test.startTest();
         Account a = new Account();
        a.Name = 'TestAccount';
        a.OneAccount_Type__c = 'Distributor';
        a.RecordTypeId = [select id, developerName from RecordType where developerName Like '%CIM_Account%'][0].Id;
        insert a;
           Call_Report__c cr=new Call_Report__c();
        cr.Courses__c=false;
        cr.Met_with_Assistant__c=false;
        cr.Met_with_Decision_Maker__c=false;
        cr.Placed_Order__c=false;
        cr.Left_Sample__c=false;
        insert cr;
        
        User u1 = new User();
        u1.LastName= 'testUser1';
        u1.Alias= 'testUsr1';
        u1.TimeZoneSidKey= 'Asia/Taipei';
        u1.LocaleSidKey= 'en_US';
        u1.EmailEncodingKey= 'ISO-8859-1';
        u1.LanguageLocaleKey = 'en_US';
        u1.Username = 'Testevent@testuser.com';
        u1.Email = 'Testtt1@salesforce.com';
        u1.ProfileId = [select id from profile where Name like '%Lightning Sales Rep%' Limit 1][0].Id;
        insert u1;
        Event childEvnt= new Event(WhatId=a.Id, Call_Report__c= cr.Id, subject='Test1', StartDateTime=System.Today()+10,
                              EndDateTime=System.Today()+20, SBU__c='Implants;Preventive',
                             Astra_Tech_Type__c='In Person Meeting', Customer_Facing_Event__c=true);
        insert childEvnt;
        EventRelation er=new  EventRelation(status= 'new', EventId=childEvnt.id, RelationId= u1.Id);
        insert er;
        
         EventAttendees__c erd = new EventAttendees__c(); 
                       erd.EventId__c = childEvnt.Id;
                       erd.Status__c = 'Not_Invited';
                       erd.RelationId__c = u1.Id;
           insert erd;
        
        System.runAs(u1){
           List<EventRelation> evRel=  EventRelationDetails.getEventRelationDetails(childEvnt.id);
            system.assertEquals(er.RelationId, evRel[0].RelationId) ;
          AttendeesWrapperClass.DisplayAttendeesRecords wrp = new AttendeesWrapperClass.DisplayAttendeesRecords();
          //System.assertEquals(true, EventRelationDetails.lightningSyncEnabledProfile());
            List<AttendeesWrapperClass.DisplayAttendeesRecords> evRels=  EventRelationDetails.getAttendeesList(childEvnt.id);
            system.assert(evRels.size() > 0);
        }
         
     test.stopTest();   
        
    }
  
}