/*------------------------------------------------------------	
Author: 		Richard Trum (Glimt) 2019-11-28 	
Description:   	Test class for testing the apex class LeadController
------------------------------------------------------------*/

@IsTest

private class Test_LeadController {

    @IsTest
    private static void initiativeTest(){
        Field_Sales_Project__c initTest = new Field_Sales_Project__c();
		initTest.Title__c ='Testing initiative';
        initTest.AllowUsersToAddNewLeads__c = true;
        initTest.Description__c ='Testing to create an initiative';
        initTest.End_Date__c = Date.today();
        initTest.Start_Date__c = Date.today();
        initTest.Initiative_Type__c = 'Regional Initiative';
        insert initTest;

        Test.startTest();
		System.assertNotEquals(LeadController.getInitiatives(), null);
 
        Test.stopTest();
        
    }
    
    @IsTest
    private static void settingsTest(){
        List<LeadOpportunitySetting__mdt> settings = [SELECT DeveloperName, Country__c, Category__c FROM LeadOpportunitySetting__mdt WHERE IsTest__c =: true];

        Test.startTest();
		System.assertNotEquals(LeadController.getSalesLeadSettings(settings[0].Category__c, settings[0].Country__c), null);
 
        Test.stopTest();
        
    }
    
    @IsTest
    private static void TestGetPreferredDealers(){
        
        List<User> userList = TestDataFactory.createUsers(1, 'System Administrator');
        List<Account> accounts = TestDataFactory.returnAccounts(2, 'CIM_account', userList[0].Id);
        accounts[1].OneAccount_Type__c = 'Distributor';
        accounts[1].Name = 'Distributor';
        insert accounts;
        
        Preferred_dealer_item__c pdi = new Preferred_dealer_item__c();
        pdi.Account__c = accounts[0].Id;
        pdi.Dealer__c = accounts[1].Id;
        insert pdi;
        
        List<Preferred_dealer_item__c> result = LeadController.getPreferredDealers(accounts[0].Id);
        List<Account> dealers = LeadController.getDistributors('Distr', accounts[0].Id, 'Equipment & Imaging');
    }

    @isTest
    private static void searchResultReturnRecords() {
        List<User> userList = TestDataFactory.createUsers(1, 'System Administrator');
        List<Id> fixedResults = new List<Id>();
        List<Account> accounts = TestDataFactory.returnAccounts(1, 'CIM_account', userList[0].Id);
        accounts[0].OneAccount_Type__c = 'Distributor';
        accounts[0].Name = 'Distributor';
        accounts[0].DistributorCategories__c = 'Digital Group';
        insert accounts;
        
        fixedResults.add(accounts[0].Id);
        System.debug(fixedResults);
        Test.setFixedSearchResults(fixedResults);
        List<String> selectedIds = new List<String>();

        List<LookupSearchResult> results = LeadController.search('Distr', selectedIds, 'Equipment & Imaging');

        System.assertEquals(1, results.size());
        System.assertEquals(accounts[0].Id, results.get(0).getId());
    }
    
    @IsTest
    private static void TestRecentlyViewed(){
        List<User> userList = TestDataFactory.createUsers(1, 'System Administrator');
        List<Id> fixedResults = new List<Id>();
        List<Account> accounts = TestDataFactory.returnAccounts(2, 'CIM_account', userList[0].Id);
        accounts[1].OneAccount_Type__c = 'Distributor';
        accounts[1].Name = 'Distributor';
        insert accounts;
        
        Preferred_dealer_item__c pdi = new Preferred_dealer_item__c();
        pdi.Account__c = accounts[0].Id;
        pdi.Dealer__c = accounts[1].Id;
        insert pdi;
        
        List<LookupSearchResult> results = LeadController.getRecentlyViewed(accounts[0].Id, 'Equipment & Imaging');
        
    }

}