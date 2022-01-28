/*------------------------------------------------------------
Author:         Ahmed LOUDRASSI (Salesforce) 2020-03-23
Description:    Test Class for all Order_Dealer_CC methods.
History
<Date>      <Authors Name>     <Brief Description of Change>
------------------------------------------------------------*/

@isTest(seeAllData=false)
public class Test_OrderDealer_CC {

    /*-------------------------------------------------------------------------------------------------------
    Company: Salesforce
    Description: Setup one user for the test class
    History :
    --------------------------------------------------------------------------------------------------------*/
    @testSetup
    private static void setup() {
        TestDataFactory.createBypassCustomSetting();
        List<User> userList = TestDataFactory.createUsers(1, 'System Administrator');
        List<User> userIntegrationList = TestDataFactory.insertIntegrationUsers(1, 'System Administrator');
        TestDataFactory.createGlobalIntegrationSettings(userIntegrationList);
    }
    @isTest
    private static void testSetup() {
        Test.startTest();
        List<User> testUserList = [SELECT Id FROM User WHERE Alias = 'test1'];
        Test.stopTest();

        System.assertEquals(1, testUserList.size(), 'Expected one user');
    }
    
    @isTest
    public static void testSaveDealers() {
        User testUser = [SELECT Id FROM User WHERE Alias = 'test1'];
        List<Account> accounts = TestDataFactory.returnAccounts(2, 'CIM_Account', testUser.Id);
        for(Account account : accounts) {
            account.OneAccount_Type__c = 'Distributor';
        }
        insert accounts;
        List<Id> dealerIds = new List<Id>();
        for (Account account : accounts) {
            dealerIds.add(account.Id);
        }
        List<Order> orders = TestDataFactory.createOrders(1, 'Free_Good_Order', accounts);
        Test.startTest();
        List<Preferred_dealer_item__c> preferredDealers = OrderDealer_CC.saveDealers(dealerIds, orders.get(0).Id);
        List<Preferred_dealer_item__c> preferredDealers1 = OrderDealer_CC.saveDealers(dealerIds, orders.get(0).Id);
        Test.stopTest();
        System.assertEquals(2, preferredDealers.size());
        System.assertEquals(2, OrderDealer_CC.getDealers(orders.get(0).Id).size());
    }

    @isTest
    public static void testSearch() {
        User testUser = [SELECT Id FROM User WHERE Alias = 'test1'];
        List<Account> accounts = TestDataFactory.returnAccounts(2, 'CIM_Account', testUser.Id);
        for (Account account : accounts) {
            account.OneAccount_Type__c = 'Distributor';
        }
        insert accounts;
        List<Id> fixedSearchResults = new List<Id>();
        for (Account account : accounts) {
            fixedSearchResults.add(account.Id);
        }
        Test.setFixedSearchResults(fixedSearchResults);
        System.assertEquals(2, OrderDealer_CC.search('Test', new List<String>()).size());
    }

    @isTest
    public static void testUpdateDealerInfo() {
        User testUser = [SELECT Id FROM User WHERE Alias = 'test1'];
        List<Account> accounts = TestDataFactory.returnAccounts(2, 'CIM_Account', testUser.Id);
        for(Account account : accounts) {
            account.OneAccount_Type__c = 'Distributor';
        }
        insert accounts;
        List<Order> orders = TestDataFactory.createOrders(1, 'Free_Good_Order', accounts);
        List<Preferred_dealer_item__c> dealers = TestDataFactory.createpreferredDealers(1, accounts, orders);
        Test.startTest();
        String orderNumber1 = OrderDealer_CC.updateDealerInfo(dealers.get(0).Id, orders.get(0).Id);
        Test.stopTest();
        Order order = [SELECT id, Dealer__c, Distributor__c FROM Order WHERE OrderNumber =:orderNumber1];
        system.assertEquals(dealers.get(0).Id, order.Dealer__c);
    }
}