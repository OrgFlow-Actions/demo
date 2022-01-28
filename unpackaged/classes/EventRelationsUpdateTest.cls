//Date: 11-jan-2019
//Created by: Gargi Pratihar(gargi.pratihar@mindtree.com)
//class name: EventRelationsUpdateTest
//Related class: EventRelationsUpdate

@isTest
public class EventRelationsUpdateTest {
  
@isTest
    
    static void changeStatusAcceptedTest(){
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
        User u2 = new User();
        u2.LastName= 'testUser2';
        u2.Alias= 'testUsr2';
        u2.TimeZoneSidKey= 'Asia/Taipei';
        u2.LocaleSidKey= 'en_US';
        u2.EmailEncodingKey= 'ISO-8859-1';
        u2.LanguageLocaleKey = 'en_US';
        u2.Username = 'Testevent2@testuser.com';
        u2.Email = 'Testtt2@salesforce.com';
        u2.ProfileId = [select id from profile where Name like '%#System: System Administrator%' Limit 1][0].Id;
        insert u2;
        Event childEvnt= new Event(WhatId=a.Id, Call_Report__c= cr.Id, subject='Test1', StartDateTime=System.Today()+10,
                              EndDateTime=System.Today()+20, SBU__c='Implants;Preventive',
                             Astra_Tech_Type__c='In Person Meeting', Customer_Facing_Event__c=true);
        insert childEvnt;
        Event childEvnt2= new Event(WhatId=a.Id, Call_Report__c= cr.Id, subject='Test1', StartDateTime=System.Today()+10,
                              EndDateTime=System.Today()+20, SBU__c='Implants;Preventive',
                             Astra_Tech_Type__c='In Person Meeting', Customer_Facing_Event__c=true);
        insert childEvnt2;
        EventRelation er=new  EventRelation(status= 'New', EventId=childEvnt.id, RelationId= u1.Id);
        insert er;
        EventRelation er2=new  EventRelation(status= 'New', EventId=childEvnt.id, RelationId= u2.Id);
        insert er2;
        System.runAs(u1){
            EventRelationsUpdate.changeStatusAccepted(childEvnt.id);
            
        }
        System.runAs(u2){
            EventRelationsUpdate.changeStatusAccepted(childEvnt.id);
        } 
     test.stopTest();   
        
    }
  @isTest  
    static void changeStatusRejectedTest(){
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
        User u2 = new User();
        u2.LastName= 'testUser2';
        u2.Alias= 'testUsr2';
        u2.TimeZoneSidKey= 'Asia/Taipei';
        u2.LocaleSidKey= 'en_US';
        u2.EmailEncodingKey= 'ISO-8859-1';
        u2.LanguageLocaleKey = 'en_US';
        u2.Username = 'Testevent2@testuser.com';
        u2.Email = 'Testtt2@salesforce.com';
        u2.ProfileId = [select id from profile where Name like '%#System: System Administrator%' Limit 1][0].Id;
        insert u2; 
        Event Evnt = new Event(WhatId=a.Id, Call_Report__c=cr.Id, subject='Test1', StartDateTime=System.Today()+10,
                              EndDateTime=System.Today()+20, SBU__c='Implants;Preventive',
                             Astra_Tech_Type__c='In Person Meeting', Customer_Facing_Event__c=true);
        insert Evnt;
        Event Evnt2 = new Event(WhatId=a.Id, Call_Report__c=cr.Id, subject='Test1', StartDateTime=System.Today()+10,
                              EndDateTime=System.Today()+20, SBU__c='Implants;Preventive',
                             Astra_Tech_Type__c='In Person Meeting', Customer_Facing_Event__c=true);
        insert Evnt2;
        
     EventRelation vr=new  EventRelation(status= 'New', EventId=Evnt.id, RelationId= u1.Id );
        insert vr;
      EventRelation vr2=new  EventRelation(status= 'New', EventId=Evnt.id, RelationId= u2.Id );
        insert vr2;
        System.runAs(u1){
        EventRelationsUpdate.changeStatusRejected(Evnt.id);
        }
        System.runAs(u2){
        EventRelationsUpdate.changeStatusRejected(Evnt.id);
        }
        test.stopTest();   
        
    }
}