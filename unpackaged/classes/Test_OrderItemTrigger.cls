/*------------------------------------------------------------
Author: 		LOUDRASSI Ahmed (Salesforce) 2020-02-25
Description:   	Test Class for all OrderItemTriggerHelper methods.
History
<Date>      <Authors Name>     <Brief Description of Change>
------------------------------------------------------------*/

@isTest(seeAllData=false)
public class Test_OrderItemTrigger {

    /*-------------------------------------------------------------------------------------------------------
    Company: Salesforce
    Description: Setup one user for the test class
    History :
    --------------------------------------------------------------------------------------------------------*/
    @testSetup
    private static void setup() {
        TestDataFactory.createBypassCustomSetting();
        List<User> userList = TestDataFactory.createUsers(1, '#System: System Administrator');
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
    private static void testSetPercentForFOC() {
        User testUser = [SELECT Id FROM User WHERE Alias = 'test1'];
        System.runAs(testUser) {
            List<Pricebook2> pricebooks = TestDataFactory.createPricebooks(1, 'BNL PRE');
            List<Product2> products = TestDataFactory.createProducts(1);
            List<PricebookEntry> pricebookEntries = TestDataFactory.createPricebookEntries(1, pricebooks, products);
            List<Account> accounts = TestDataFactory.createAccounts(3, 'Non_ERP_Account', testUser.Id);
            List<Order> orders = TestDataFactory.returnOrders(1, 'Free_Good_Order', accounts);
            orders.get(0).Pricebook2Id = pricebooks.get(0).Id;
            insert orders;
            List<OrderItem> orderItems = TestDataFactory.returnOrderItems(1, orders, pricebookEntries);
            orderItems.get(0).Free_of_Charge_Delivery__c = 'Dealer';
            Test.startTest();
            insert orderItems;
            update orderItems;
            Test.stopTest();
            System.assertEquals(100, [SELECT Id, Discount_Percent__c FROM OrderItem].Discount_Percent__c);
        }
    }
    @isTest
    private static void testOrderProductEvaluation() {
        User testUser = [SELECT Id FROM User WHERE Alias = 'test1'];
        System.runAs(testUser) {
            List<Pricebook2> pricebooks = TestDataFactory.createPricebooks(1, 'BNL PRE');
            List<Product2> products = TestDataFactory.createProducts(1);
            List<PricebookEntry> pricebookEntries = TestDataFactory.createPricebookEntries(1, pricebooks, products);
            List<Account> accounts = TestDataFactory.createAccounts(3, 'Non_ERP_Account', testUser.Id);
            List<Order> orders = TestDataFactory.returnOrders(1, 'Free_Good_Order', accounts);
            orders.get(0).Pricebook2Id = pricebooks.get(0).Id;
            orders.get(0).User_CountryPL__c = 'USA';
            insert orders;
            List<OrderItem> orderItems = TestDataFactory.returnOrderItems(1, orders, pricebookEntries);
            Test.startTest();
            insert orderItems;
            update orderItems;
            Test.stopTest();
            OrderItem orderItem = [SELECT Id, SIMPLANT_Line_Item__c, MTF_EvaluationNumber__c FROM OrderItem LIMIT 1];
            System.assertEquals(0, orderItem.SIMPLANT_Line_Item__c);
            System.assertEquals(0, orderItem.MTF_EvaluationNumber__c);
        }
    }
    @isTest
    private static void totalAmountOfSamplesAndFreeProducts() {
        User testUser = [SELECT Id FROM User WHERE Alias = 'test1'];
        System.runAs(testUser) {
            List<Pricebook2> pricebooks = TestDataFactory.createPricebooks(1, 'BNL PRE');
            List<Product2> products = TestDataFactory.createProducts(1);
            List<PricebookEntry> pricebookEntries = TestDataFactory.createPricebookEntries(1, pricebooks, products);
            List<Account> accounts = TestDataFactory.returnAccounts(1, 'Non_ERP_Account', testUser.Id);
            accounts.get(0).Sub_Account_Type__c = 'Sales Rep';
            accounts.get(0).OneAccount_Type__c = 'DENTSPLY';
            insert accounts;
            List<Order> orders = TestDataFactory.returnOrders(1, 'Free_Good_Order', accounts);
            orders.get(0).Pricebook2Id = pricebooks.get(0).Id;
            insert orders;
            List<OrderItem> orderItems = TestDataFactory.returnOrderItems(1, orders, pricebookEntries);
            orderItems.get(0).Account_for_Sample_in_AX__c = accounts.get(0).Id;
            Test.startTest();
            insert orderItems;
            update orderItems;
            Test.stopTest();
            OrderItem orderItem = [SELECT Id, Value_of_Samples_for_Sales_Rep__c, Quantity, UnitPrice FROM OrderItem LIMIT 1];
            System.assertEquals(true, orderItem.Value_of_Samples_for_Sales_Rep__c == (orderItem.Quantity * orderItem.UnitPrice));
        }
    }
    @isTest
    private static void testSetDiscountAllowedforTurkey() {
        User testUser = [SELECT Id FROM User WHERE Alias = 'test1'];
        System.runAs(testUser) {
            List<Pricebook2> pricebooks = TestDataFactory.createPricebooks(1, 'BNL PRE');
            List<Product2> products = TestDataFactory.createProducts(1);
            List<PricebookEntry> pricebookEntries = TestDataFactory.createPricebookEntries(1, pricebooks, products);
            List<Account> accounts = TestDataFactory.createAccounts(1, 'Non_ERP_Account', testUser.Id);
            List<Contract> contracts = TestDataFactory.returnContracts(1, 'Pricing_contract', testUser.Id, accounts);
            contracts.get(0).Revenue_forecast__c = 10000;
            contracts.get(0).Sales_Correction__c = true;
            contracts.get(0).Discount_End_year__c = 15;
            contracts.get(0).Discount__c = 15;
            insert contracts;
            List<Order> orders = TestDataFactory.returnOrders(1, 'Free_Good_Order', accounts);
            orders.get(0).Pricebook2Id = pricebooks.get(0).Id;
            orders.get(0).Country__c = 'TR';
            orders.get(0).Order_Type__c = 'Implants';
            orders.get(0).Allowed_discount__c = 10;
            orders.get(0).ContractId = contracts.get(0).Id;
            /*
            orders.get(1).Pricebook2Id = pricebooks.get(0).Id;
            orders.get(1).Country__c = 'TR';
            orders.get(1).Order_Type__c = 'Implants';
            orders.get(1).Allowed_discount__c = 10;*/
            insert orders;
            List<OrderItem> orderItems = TestDataFactory.returnOrderItems(1, orders, pricebookEntries);
            Test.startTest();
            insert orderItems;
            Test.stopTest();
            /*Order order1 = [SELECT Id, Allowed_discount__c, Discount_to_be_used__c FROM Order WHERE Id = :orders.get(0).Id];
            System.assertEquals(order1.Allowed_discount__c, order1.Discount_to_be_used__c);*/
            Order order2 = [SELECT Id, Contract.Discount_End_year__c, Discount_to_be_used__c FROM Order WHERE Id = :orders.get(0).Id];
            System.assertEquals(15, order2.Discount_to_be_used__c);
        }
    }
}