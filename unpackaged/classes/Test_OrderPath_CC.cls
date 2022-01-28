/**
 * @description       : OrderPath_CC test class
 * @author            : kdoruibin@salesforce.com
 * @group             : 
 * @last modified on  : 02-18-2021
 * @last modified by  : kdoruibin@salesforce.com
 * Modifications Log 
 * Ver   Date         Author                     Modification
 * 1.0   11-13-2020   kdoruibin@salesforce.com   Initial Version
**/
@IsTest
public without sharing class Test_OrderPath_CC {
    /*-------------------------------------------------------------------------------------------------------
    Company: Salesforce
    Description: Setup one user for the test class
    History :
    --------------------------------------------------------------------------------------------------------*/
    @testSetup
    private static void setup() {
        List<User> userList = TestDataFactory.createUsers(1, '#System: System Administrator');
        TestDataFactory.createBypassCustomSetting();
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
    private static void testCheckCancelOrderPermission() {
        User testUser = [SELECT Id FROM User WHERE Alias = 'test1'];
        System.runAs(testUser) {
            Boolean hasCancelOrderPermission = FeatureManagement.checkPermission('Order_Management_2_0_Cancel_Order');
            System.assertEquals(hasCancelOrderPermission, OrderPath_CC.checkCancelOrderPermission());
        }
    }

    @isTest
    private static void testGetStageGuidance() {
        User testUser = [SELECT Id FROM User WHERE Alias = 'test1'];
        System.runAs(testUser) {
            List<Pricebook2> pricebooks = TestDataFactory.createPricebooks(1, 'BNL PRE');
            List<Product2> products = TestDataFactory.createProducts(1);
            List<PricebookEntry> pricebookEntries = TestDataFactory.createPricebookEntries(1, pricebooks, products);
            List<Account> accounts = TestDataFactory.createAccounts(1, 'Non_ERP_Account', testUser.Id);
            List<Order> orders = TestDataFactory.returnOrders(1, 'Free_Good_Order', accounts);
            orders.get(0).Pricebook2Id = pricebooks.get(0).Id;
            insert orders;
            Test.startTest();
            String result = OrderPath_CC.getStageGuidance(orders.get(0).Id);
            Test.stopTest();
            System.assertEquals(true, String.isNotBlank(result));
        }
    }

    @isTest
    private static void testSubmitForApproval() {
        User testUser = [SELECT Id FROM User WHERE Alias = 'test1'];
        System.runAs(testUser) {
            List<Pricebook2> pricebooks = TestDataFactory.createPricebooks(1, 'BNL PRE');
            List<Product2> products = TestDataFactory.createProducts(1);
            List<PricebookEntry> pricebookEntries = TestDataFactory.createPricebookEntries(1, pricebooks, products);
            List<Account> accounts = TestDataFactory.createAccounts(1, 'Non_ERP_Account', testUser.Id);
            List<Order> orders = TestDataFactory.returnOrders(1, 'Free_Good_Order', accounts);
            orders.get(0).Pricebook2Id = pricebooks.get(0).Id;
            insert orders;
            Test.startTest();
            try {
                String result = OrderPath_CC.submitForApproval(orders.get(0).Id, 'test');
            } catch (Exception e) {
                System.assertEquals('System.AuraHandledException', e.getTypeName());
            }
            Test.stopTest();
        }
    }
    
    @isTest
    private static void testOrderCancel() {
        User testUser = [SELECT Id FROM User WHERE Alias = 'test1'];
        System.runAs(testUser) {
            List<Pricebook2> pricebooks = TestDataFactory.createPricebooks(1, 'BNL PRE');
            List<Product2> products = TestDataFactory.createProducts(1);
            List<PricebookEntry> pricebookEntries = TestDataFactory.createPricebookEntries(1, pricebooks, products);
            List<Account> accounts = TestDataFactory.createAccounts(1, 'Non_ERP_Account', testUser.Id);
            List<Order> orders = TestDataFactory.returnOrders(1, 'Free_Good_Order', accounts);
            orders.get(0).Pricebook2Id = pricebooks.get(0).Id;
            insert orders;
            Test.startTest();
            String result = OrderPath_CC.orderCancel(orders.get(0).Id, 'test');
            System.assertEquals('SUCCESS', result);
            Test.stopTest();
        }
    }
}