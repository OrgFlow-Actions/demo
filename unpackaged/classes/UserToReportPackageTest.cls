@isTest
public with sharing class UserToReportPackageTest {    
    
@isTest
private static void UserToReportPackageTest(){

        Report_package__c pd1 = new Report_package__c ();
        insert pd1;
        
        Report_package__c pd2 = new Report_package__c ();
        insert pd2;
        
        User a = new User();
        a.FirstName = 'Test';
        a.LastName = 'User 1';
        a.UserName = 'richard.trum@dentsplysirona.com.123';
        a.Email = 'richard.trum@dentsplysirona.com';
        a.Alias = 'TestUs';
        a.ProfileId = '00e20000001Ygwu';
        a.User_country__c = 'Sweden';
        a.User_type__c = 'Sales Manager';
        a.CommunityNickname = 'TestUser';
        a.TimeZoneSidKey = 'GMT';
        a.LocaleSidKey = 'en_GB';
        a.LanguageLocaleKey= 'en_US';
        a.Emailencodingkey= 'ISO-8859-1';        
        a.Report_package__c = pd1.id;
        insert a;
        

          
        List<Report_package__c> opps = new List<Report_package__c> ();
        
        opps = [SELECT Id, Name FROM Report_package__c LIMIT 50]; 
                    
        ApexPages.currentPage().getParameters().put('id', a.id);     
        
        ApexPages.StandardController stdController = new ApexPages.StandardController(a);   
        
        UserToReportPackage controller = new UserToReportPackage(stdController);
        
        controller.fetchRecords();
                
        system.assertNotEquals(null, controller.getRadioValue);
        
        system.assertEquals(2, controller.ReportList.size());
        
        controller.getRadioValue = pd2.Id;
        
        controller.saveReport();
                
    }
       
    
    @isTest
private static void ReportPackageControllerTest(){
                       
        Report_package__c pd = new Report_package__c ();
        insert pd;
        
        Report_package_line__c pd1 = new Report_package_line__c ();
        pd1.Report_package__c = pd.Id;
        insert pd1;
   
        Report_package_line__c pd2 = new Report_package_line__c ();
        pd2.Report_package__c = pd.Id;
        insert pd2;
        
        User a = new User();
        a.FirstName = 'Test';
        a.LastName = 'User 1';
        a.UserName = 'richard.trum@dentsplysirona.com.123';
        a.Email = 'richard.trum@dentsplysirona.com';
        a.Alias = 'TestUs';
        a.ProfileId = '00e20000001Ygwu';
        a.User_country__c = 'Sweden';
        a.User_type__c = 'Sales Manager';
        a.CommunityNickname = 'TestUser';
        a.TimeZoneSidKey = 'GMT';
        a.LocaleSidKey = 'en_GB';
        a.LanguageLocaleKey= 'en_US';
        a.Emailencodingkey= 'ISO-8859-1';        
        a.Report_package__c = pd.id;
        insert a;
  
        List<Report_package_line__c> opps = new List<Report_package_line__c> ();
        
        opps = [SELECT Id, Name FROM Report_package_Line__c LIMIT 50];
        
        PageReference pageRef = new PageReference('/apex/Custom_Links_VF');
        Test.setCurrentPage(pageRef);
        
        //ApexPages.currentPage().getParameters().put('id', pd.id);   
                
        System.runAs(a) {                                 
                    
        ApexPages.StandardSetController stdController = new ApexPages.StandardSetController(opps);
                       
        ReportPackageController controller = new ReportPackageController(stdController);
                
        controller.fetchRecords();
                        
        system.assertEquals(2, controller.ReportList.size());
        
        }
                
    } 
     
    
    
    }