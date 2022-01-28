/*------------------------------------------------------------	
	Author: 		Richard Trum (Glimt) 2020-09-15	
	Description:   	Test class related to the class flowContactController
	------------------------------------------------------------*/ 
    @IsTest
    private class Test_flowContactController {

        @TestSetup
        static void makeData(){
            User user1 = DC_UT_DataUtils.createSfUser('TestUser', 'Lightning Sales Rep');    
        }
        
        @IsTest
        private static void contactTest(){
        User user1 = [SELECT Id FROM User WHERE Username LIKE 'TestUser%' LIMIT 1];
        List<Account> acc = TestDataFactory.createAccounts(1, 'CIM_Account', user1.Id);
        Contact contact = new Contact();
        contact.AccountId = acc[0].Id;
        contact.FirstName = 'Test';
        contact.LastName = 'Test';
        insert contact;

        Test.startTest();
                
                List<Contact> result = flowContactController.getRelatedContacts(acc[0].Id, 'Account', 'Id', 'FirstName, LastName');
                System.assertNotEquals(result[0], null);
        
        Test.stopTest(); 
            
        }

        @IsTest
        private static void queryTest(){
            User user1 = [SELECT Id FROM User WHERE Username LIKE 'TestUser%' LIMIT 1];
            List<Account> acc = TestDataFactory.createAccounts(1, 'CIM_Account', user1.Id);
            Contact contact = new Contact();
            contact.AccountId = acc[0].Id;
            contact.FirstName = 'Test';
            contact.LastName = 'Test';
            insert contact;

            Test.startTest();
                
            List<sObject> result = flowContactController.executeSoql('AccountId','Contacts', 'Account', contact.AccountId);
            System.assertNotEquals(result[0], null);
            
            List<sObject> failResult = flowContactController.executeSoql('Accounting','Contacts', 'Account', contact.AccountId);
    
        Test.stopTest(); 

        }
        
        @IsTest
        private static void contactLookupTest(){
        User user1 = [SELECT Id FROM User WHERE Username LIKE 'TestUser%' LIMIT 1];
        List<Account> acc = TestDataFactory.createAccounts(1, 'CIM_Account', user1.Id);
        Contact contact = new Contact();
        contact.AccountId = acc[0].Id;
        contact.FirstName = 'Test';
        contact.LastName = 'Test';
        insert contact;
            
        List<String> searchObj = new List<String>();
        searchObj.add('Contact');
        
        List<String> selectedIds = new List<String>();    

        Test.startTest();
                
                List<LookupSearchResult> result = flowLookupLwcController.search('Test', selectedIds,acc[0].Id, searchObj);
        
        Test.stopTest(); 
            
        }
        
        @IsTest
        private static void contactRecentlyViewedTest(){
        User user1 = [SELECT Id FROM User WHERE Username LIKE 'TestUser%' LIMIT 1];
        List<Account> acc = TestDataFactory.createAccounts(1, 'CIM_Account', user1.Id);
        Contact contact = new Contact();
        contact.AccountId = acc[0].Id;
        contact.FirstName = 'Test';
        contact.LastName = 'Test';
        insert contact;
            
        List<String> searchObj = new List<String>();
        searchObj.add('Contact');
        
        List<String> selectedIds = new List<String>();    

        Test.startTest();
                
                List<LookupSearchResult> result = flowLookupLwcController.getRecentlyViewed(acc[0].Id, '');
        
        Test.stopTest(); 
            
        }
    
    }