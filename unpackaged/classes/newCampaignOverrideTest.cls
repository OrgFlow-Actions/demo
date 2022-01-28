@isTest
public class newCampaignOverrideTest {
   
        public static testMethod void newCampaignOverride() {
            //create test user
            profile p = [SELECT Id From profile Where Name = '#System: System Administrator'];
            userrole r = [SELECT Id From UserRole Where Name = 'System Administrators'];
//            Account a = new Account(Name='Test Acc');
            Campaign c = new Campaign();
//            Contact c = new Contact (LastName='Test Atl Acc');
            user u = new User(  firstname = 'tuserFname',
                              lastName = 'tuserLastname',
                              email = 'testtest.testtest@dentsplysirona.com',
                              Username = 'testtesttesttest@dentsplysirona.com',
                              EmailEncodingKey = 'ISO-8859-1',
                              Alias ='ttest',
                              TimeZoneSidKey = 'America/Los_Angeles',
                              LocaleSidKey = 'sv_SE',
                              LanguageLocaleKey = 'en_US',
                              User_Type__c = 'Other',
                              User_Country__c = 'Sweden',
                              CurrencyIsoCode = 'SEK',
                              ProfileId = p.Id,
                              UserRoleId = r.Id,
                              FieldSalesRatioPerc__c = 0,
                              SBU_Ratio_PREV__c = 0.1,
                              SBU_Ratio_REST__c = 0.2,
                              SBU_Ratio_CERE__c = 0.3,
                              SBU_Ratio_IMAG__c = 0.4,
                              SBU_Ratio_INST__c = 0);
            system.runAs(u){
         Test.startTest(); //switch to testing context
                PageReference pageRef = Page.newCampaignOverridePage; //create a page reference to our Visualforce page
                pageRef.getparameters().put('LinkOrder', 'Program'); 
                Test.setCurrentPage(pageRef);
                
                Apexpages.StandardController sc = new Apexpages.StandardController(c);
                newCampaignOverride ext = new  newCampaignOverride(sc);
                
         
                PageReference pageRef2 = Page.newCampaignOverridePage; //create a page reference to our Visualforce page
                pageRef2.getparameters().put('LinkOrder', 'Trade'); 
                Test.setCurrentPage(pageRef2);
                
               
                newCampaignOverride ext2 = new  newCampaignOverride(sc);
                
                          
                PageReference pageRef4 = Page.newCampaignOverridePage; //create a page reference to our Visualforce page
                pageRef4.getparameters().put('LinkOrder', 'Sponsorship'); 
                Test.setCurrentPage(pageRef4);
                
                Apexpages.StandardController sc4 = new Apexpages.StandardController(c);
                newCampaignOverride ext4 = new  newCampaignOverride(sc4);
                
                PageReference pageRef5 = Page.newCampaignOverridePage; //create a page reference to our Visualforce page
                pageRef5.getparameters().put('RecordType', '01220000000Ax7r'); 
                Test.setCurrentPage(pageRef5);
                
               Apexpages.StandardController sc5 = new Apexpages.StandardController(c);
                newCampaignOverride ext5 = new  newCampaignOverride(sc5);
                
            Test.stopTest(); //revert back to normal context
            }
        }
    public static testMethod void newCampaignOverride2() {
            //create test user
            profile p = [SELECT Id From profile Where Name = '#System: System Administrator'];
            userrole r = [SELECT Id From UserRole Where Name = 'System Administrators'];
//            Account a = new Account(Name='Test Acc');
            Campaign c = new Campaign();
//            Contact c = new Contact (LastName='Test Atl Acc');
            user u = new User(  firstname = 'tuserFname',
                              lastName = 'tuserLastname',
                              email = 'testtest.testtest@dentsplysirona.com',
                              Username = 'testtesttesttest@dentsplysirona.com',
                              EmailEncodingKey = 'ISO-8859-1',
                              Alias ='ttest',
                              TimeZoneSidKey = 'America/Los_Angeles',
                              LocaleSidKey = 'sv_SE',
                              LanguageLocaleKey = 'en_US',
                              User_Type__c = 'Other',
                              User_Country__c = 'Sweden',
                              CurrencyIsoCode = 'SEK',
                              ProfileId = p.Id,
                              UserRoleId = r.Id,
                              FieldSalesRatioPerc__c = 0,
                              SBU_Ratio_IMPL__c = 0.1,
                              SBU_Ratio_ENDO__c = 0.2,
                              SBU_Ratio_ORTH__c = 0.3,
                              SBU_Ratio_PROS__C = 0.4,
                              SBU_Ratio_IMAG__c = 0);
            system.runAs(u){
         Test.startTest(); //switch to testing context
                
                PageReference pageRef4 = Page.newCampaignOverridePage; //create a page reference to our Visualforce page
                pageRef4.getparameters().put('LinkOrder', 'Sponsorship'); 
                Test.setCurrentPage(pageRef4);
                
                Apexpages.StandardController sc4 = new Apexpages.StandardController(c);
                newCampaignOverride ext4 = new  newCampaignOverride(sc4);
                
                PageReference pageRef5 = Page.newCampaignOverridePage; //create a page reference to our Visualforce page
                pageRef5.getparameters().put('RecordType', '01220000000Ax7r'); 
                Test.setCurrentPage(pageRef5);
                
                //Apexpages.StandardController sc5 = new Apexpages.StandardController(c);
                newCampaignOverride ext5 = new  newCampaignOverride(sc4);
                
            Test.stopTest(); //revert back to normal context
            }
        }
        public static testMethod void newCampaignOverride3() {
            //create test user
            profile p = [SELECT Id From profile Where Name = '#System: System Administrator'];
            userrole r = [SELECT Id From UserRole Where Name = 'System Administrators'];
            Campaign c = new Campaign();
            Account a = new Account(Name='Test Acc');
            Campaign ca = new Campaign (Name='Test Campaign', Session_Start_Date_Time__c=datetime.now(), Session_End_Date_Time__c=datetime.now(), SBU_Focus__c= 'Implants', 
                                       Profession__c='Doctor', Target_Country__c ='Chile', Target_Group__c='Lab', Target_Type__c ='Dental Technician',Strategy__c='All');
            user u = new User(  firstname = 'tuserFname',
                              lastName = 'tuserLastname',
                              email = 'testtest.testtest@dentsplysirona.com',
                              Username = 'testtesttesttest@dentsplysirona.com',
                              EmailEncodingKey = 'ISO-8859-1',
                              Alias ='ttest',
                              TimeZoneSidKey = 'America/Los_Angeles',
                              LocaleSidKey = 'sv_SE',
                              LanguageLocaleKey = 'en_US',
                              User_Type__c = 'Other',
                              User_Country__c = 'Sweden',
                              CurrencyIsoCode = 'SEK',
                              ProfileId = p.Id,
                              UserRoleId = r.Id,
                              FieldSalesRatioPerc__c = 0,
                              SBU_Ratio_IMPL__c = 0.1,
                              SBU_Ratio_INST__c = 0.4,
                              SBU_Ratio_TRCE__c = 0.5,
                              SBU_Ratio_PROS__C = 0,
                              SBU_Ratio_IMAG__c = 0);
            system.runAs(u){
               //create account
            	insert(a);
            //create contact
            	ca.venue__c=a.Id;
            	insert(ca);
         Test.startTest(); //switch to testing context
                
                PageReference pageRef6 = Page.newCampaignOverridePage; //create a page reference to our Visualforce page
                pageRef6.getparameters().put('LinkOrder', ca.Id); 
                Test.setCurrentPage(pageRef6);
                system.debug(pageref6);
                Apexpages.StandardController sc6 = new Apexpages.StandardController(c);
                newCampaignOverride ext6 = new  newCampaignOverride(sc6);
                ext6.SBU();
                ext6.cancel1();
                
                
                
            Test.stopTest(); //revert back to normal context
            }
        }

}



/*
private class newCampaignOverrideTest {
    //newCampaignOverride.class
    static testMethod void newCampaignOverride() {
        //create test user
        profile p = [SELECT Id From profile Where Name = '#System: System Administrator'];
        userrole r = [SELECT Id From UserRole Where Name = 'System Administrators'];
        
        user u = new User(  firstname = 'tuserFname',
                            lastName = 'tuserLastname',
                            email = 'testtest.testtest@dentsplysirona.com',
                            Username = 'testtesttesttest@dentsplysirona.com',
                            EmailEncodingKey = 'ISO-8859-1',
                            Alias ='ttest',
                            TimeZoneSidKey = 'America/Los_Angeles',
                            LocaleSidKey = 'sv_SE',
                            LanguageLocaleKey = 'en_US',
                            User_Type__c = 'Other',
                            User_Country__c = 'Sweden',
                            CurrencyIsoCode = 'SEK',
                            ProfileId = p.Id,
                            UserRoleId = r.Id,
                            FieldSalesRatioPerc__c = 0,
                            SBU_Ratio_IMPL__c = 0.2,
                            SBU_Ratio_ENDO__c = 0.1,
                            SBU_Ratio_ORTH__c = 0.1,
                            SBU_Ratio_PROS__C = 0.2,
                            SBU_Ratio_IMAG__c = 0.4);
        Test.startTest(); //switch to testing context
        system.runAs(u){
        
        PageReference pageRef = Page.newCampaignOverridePage; //create a page reference to our Visualforce page
        Test.setCurrentPage(pageRef); //set the current page to that page
        ApexPages.StandardController standardController = new ApexPages.standardController(new Campaign()); //instantiate the standard controller for the Opportunity object
        newCampaignOverride ext = new newCampaignOverride(standardController); //construct the extension
        
        //pass some parameters to the page
        pageRef.getParameters().put('save_new', '1'); //set save_new key value pair
        pageRef.getParameters().put('save', '1'); //set save key value pair
        
        //execute the logic
        String validationURLString = ext.prepopulateValues().getURL(); //get the resulting url from the prepopulateValues method
        
        //validate the results
        System.assertEquals(true, validationURLString.toLowerCase().contains('nooverride=1')); //string contains the nooverride key value pair
        //System.assertEquals(true, validationURLString.contains('CF00N20000003jCk8='+u.FirstName)); //string contains the campaign coordinator key value pair
        //System.assertEquals(true, validationURLString.contains('CF00N20000003jCk8_lkid='+u.Id)); //string contains the campaign coordinator lookup ID key value pair
        System.assertEquals(true, validationURLString.contains('cpn5='+Date.Today().format())); //string contains the start date key value pair
        System.assertEquals(true, validationURLString.contains('cpn6='+Date.Today().format())); //string contains the end date key value pair
        System.assertEquals(true, validationURLString.contains('00N20000002oaCI='+u.User_Country__c)); //string contains the campaign country key value pair
        System.assertEquals(true, validationURLString.contains('00N2000000153o1='+u.User_Country__c)); //string contains the country key value pair
        System.assertEquals(true, validationURLString.contains('00N20000003jRJR='+u.User_Country__c)); //string contains the target country key value pair
        System.assertEquals(true, validationURLString.contains('00N0J000003rWNf='+'Imaging+Systems')); //string contains the SBU value = Imaging Systems
        System.assertEquals(true, validationURLString.contains('/701/e')); //string contains the new Opportunity URL
        System.assertEquals(false, validationURLString.toLowerCase().contains('save_new=1')); //string doesn't contain save_new=1
        System.assertEquals(false, validationURLString.toLowerCase().contains('save=1')); //string doesn't contain save=1
        }
        Test.stopTest(); //revert back to normal context
    }

}*/