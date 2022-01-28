@isTest
public class Product_profilling_new_override_test {
   
        public static testMethod void Product_profilling_new_override() {
            //create test user
            profile p = [SELECT Id From profile Where Name = '#System: System Administrator'];
            userrole r = [SELECT Id From UserRole Where Name = 'System Administrators'];
            Account a = new Account(Name='Test Acc');
            Non_ERP_Products__c prod = new Non_ERP_Products__c();
            prod.Name = 'Test product';
            Product_Profiling__c pp = new Product_Profiling__c();
            
            Contact c = new Contact (LastName='Test Atl Acc');
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
                              SBU_Ratio_ENDO__c = 0.2,
                              SBU_Ratio_ORTH__c = 0.2,
                              SBU_Ratio_PROS__C = 0.2,
                              SBU_Ratio_IMAG__c = 0.2);
            system.runAs(u){
            //create account
            insert(a);
            //create contact
            c.accountID=a.Id;
            insert(c);
            //create product
           	insert prod;
            pp.Product_Name__c = prod.Id;
                
            Test.startTest(); //switch to testing context
                PageReference pageRef = Page.Product_profilling_new_override_page; //create a page reference to our Visualforce page
                pageRef.getparameters().put('conid', c.Id); 
                Test.setCurrentPage(pageRef);
                
                Apexpages.StandardController sc = new Apexpages.StandardController(pp);
                Product_profilling_new_override ext = new  Product_profilling_new_override(sc);
                ext.save1();
                ext.cancel1();
            Test.stopTest(); //revert back to normal context
            }
        }
}