@isTest
public class CoachingReportShareTest {
    @TestSetup
    static void makeData(){
        User u1 = new User(ProfileId = [SELECT Id FROM Profile WHERE Name = 'Lightning Sales Rep'].Id,LastName = 'last01',Email = 'puser0001@dentsplysirona.com',Username = 'puser0012@dentsplysirona.com' + System.currentTimeMillis(),
                            CompanyName = 'TEST',Title = 'title',Alias = 'alias01',TimeZoneSidKey = 'America/Los_Angeles',EmailEncodingKey = 'UTF-8',LanguageLocaleKey = 'en_US',LocaleSidKey = 'en_US',
                            User_Type__c='Sales Manager',User_Country__c='INDIA');
        insert u1;
        
        User u2 = new User(ProfileId = [SELECT Id FROM Profile WHERE Name = 'Lightning Sales Rep'].Id,LastName = 'last02',Email = 'puser0002@dentsplysirona.com',Username = 'puser0002@dentsplysirona.com' + System.currentTimeMillis(),
                            CompanyName = 'TEST',Title = 'title',Alias = 'alias02',TimeZoneSidKey = 'America/Los_Angeles',EmailEncodingKey = 'UTF-8',LanguageLocaleKey = 'en_US',LocaleSidKey = 'en_US',
                            User_Type__c='Sales Representative',User_Country__c='INDIA');
        insert u2;
    }

    static testMethod void CoachingReportShareToRep() 
    {        
        User u = [SELECT Id FROM User WHERE Email = 'puser0001@dentsplysirona.com' LIMIT 1];
        Test.startTest();                    
      
        Coaching_Feedback_Report__c coreport= new Coaching_Feedback_Report__c();
        coreport.Sales_Representative__c=u.Id;
        coreport.Report_Type__c='Coaching/Co-Travel';
        coreport.Date_of_Meeting__c=Date.newInstance(2019, 12, 9);
        
        insert coreport;
        System.debug('coaching report record%%%%%%%%%%%'+coreport);
        Test.StopTest();
        
        List<Coaching_Feedback_Report__share> coachingShare = [SELECT Id, UserOrGroupId, AccessLevel,RowCause FROM Coaching_Feedback_Report__share WHERE ParentId = :coreport.Id AND UserOrGroupId= :u.Id];
       // Test for only one manual share on job.
        System.assertEquals(coachingShare.size(), 1);
       // Test attributes of manual share.
          System.assertEquals(coachingShare[0].AccessLevel, 'Edit');
          System.assertEquals(coachingShare[0].RowCause, 'Manual');
          System.assertEquals(coachingShare[0].UserOrGroupId, u.id);
    }
    
     static testMethod void CoachingReportShareToManager() 
    {        
        User u = [SELECT Id FROM User WHERE Email = 'puser0001@dentsplysirona.com' LIMIT 1];
        
        Test.startTest();                    
        Coaching_Feedback_Report__c coreport= new Coaching_Feedback_Report__c();
        coreport.Sales_Manager__c=u.Id;
        coreport.Report_Type__c='Coaching/Co-Travel';
        coreport.Date_of_Meeting__c=Date.newInstance(2019, 12, 9);
        
        insert coreport;
        System.debug('coaching report record%%%%%%%%%%%'+coreport);
        Test.StopTest();
        
        List<Coaching_Feedback_Report__share> coachingShare = [SELECT Id, UserOrGroupId, AccessLevel,RowCause FROM Coaching_Feedback_Report__share WHERE ParentId = :coreport.Id AND UserOrGroupId= :u.Id];
       // Test for only one manual share on job.
        System.assertEquals(coachingShare.size(), 1);
       // Test attributes of manual share.
          System.assertEquals(coachingShare[0].AccessLevel, 'Edit');
          System.assertEquals(coachingShare[0].RowCause, 'Manual');
          System.assertEquals(coachingShare[0].UserOrGroupId, u.id);
    }
    
    static testMethod void CoachingReportShareToBoth() 
    {        
        User u1 = [SELECT Id FROM User WHERE Email = 'puser0001@dentsplysirona.com' LIMIT 1];
        
        User u2 = [SELECT Id FROM User WHERE Email = 'puser0002@dentsplysirona.com' LIMIT 1];
        
        Test.startTest();                    
        Coaching_Feedback_Report__c coreport= new Coaching_Feedback_Report__c();
        coreport.Sales_Manager__c=u1.Id;
        coreport.Sales_Representative__c=u2.Id;
        coreport.Report_Type__c='Coaching/Co-Travel';
        coreport.Date_of_Meeting__c=Date.newInstance(2019, 12, 9);
        
        insert coreport;
        System.debug('coaching report record%%%%%%%%%%%'+coreport);
        Test.StopTest();
        
        List<Coaching_Feedback_Report__share> coachingShare = [SELECT Id, UserOrGroupId, AccessLevel,RowCause FROM Coaching_Feedback_Report__share WHERE ParentId = :coreport.Id AND (UserOrGroupId= :u1.Id OR UserOrGroupId= :u2.Id)];
       // Test for only one manual share on job.
        System.assertEquals(coachingShare.size(), 2);
       // Test attributes of manual share.
          System.assertEquals(coachingShare[0].AccessLevel, 'Edit');
          System.assertEquals(coachingShare[0].RowCause, 'Manual');
          System.assertEquals(coachingShare[0].UserOrGroupId, u1.id);
          System.assertEquals(coachingShare[1].UserOrGroupId, u2.id);
    }
 }