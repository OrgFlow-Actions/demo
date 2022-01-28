/*-------------------------------------------------------------------------------------------------------
Author:         Ahmed LOUDRASSI (Salesforce) 20191113
Description:    OrderManagement_CC Class
--------------------------------------------------------------------------------------------------------*/

@isTest(seeAllData=false)
public with sharing class Test_OrderManagement_CC {
    /*-------------------------------------------------------------------------------------------------------
    Company: Salesforce
    Description: Setup one user for the test class
    History :
    --------------------------------------------------------------------------------------------------------*/
    @testSetup
    private static void setup() {
        List<User> userList = TestDataFactory.createUsers(1, '#System: System Administrator');
        System.runas(userList.get(0)) {
            /*List<PermissionSet> permissions = [SELECT Id FROM PermissionSet 
            WHERE Name = 'Global_System_Use_Any_API'
            OR Name = 'New_Salesforce_Mobile_App'
            OR Name = 'Geopointe_Base_Permissions'
            OR Name = 'Global_Analytics_Viewer'
            OR Name = 'Global_Analytics_All_permissions'];
            List<PermissionSetAssignment> permisssionSetsAssign = new List<PermissionSetAssignment>();
            for(PermissionSet ps : permissions) {
            permisssionSetsAssign.add(new PermissionSetAssignment(AssigneeId = userList.get(0).id, PermissionSetId = ps.Id));
            }
            System.debug('ahmed ' +permisssionSetsAssign.size());
            //insert permisssionSetsAssign;*/
        }
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
    private static void testUIThemeDisplayed() {
        User testUser = [SELECT Id FROM User WHERE Alias = 'test1'];
        System.runAs(testUser) {
            System.assertEquals(true, OrderManagement_CC.uIThemeDisplayed().contains('Theme'));
        }
    }
    @isTest 
    private static void testGetPriceBooks() {
        User testUser = [SELECT Id FROM User WHERE Alias = 'test1'];
        System.runAs(testUser) {
            TestDataFactory.createPricebooks(2, 'TestPricebook');
            Test.startTest();
            List<PriceBook2>  pricebooks = OrderManagement_CC.getPriceBooks();
            Test.stopTest();
            System.assertEquals(2, pricebooks.size());
        }
    }
    @isTest
    private static void testGetPriceBooksEntriesCurrencies() {
        User testUser = [SELECT Id FROM User WHERE Alias = 'test1'];
        System.runAs(testUser) {
            List<Pricebook2> pricebooks = TestDataFactory.createPricebooks(1, 'Pricebook');
            List<Product2> products = TestDataFactory.createProducts(3);
            List<PricebookEntry> pricebookEntries = TestDataFactory.createPricebookEntries(1, pricebooks, products);
            Test.startTest();
            List<AggregateResult> pricebooksEntriescurrencies = 
                OrderManagement_CC.getPriceBooksEntriesCurrencies(pricebooks.get(0).Id);
            Test.stopTest();
        }
    }
    @isTest
    private static void testGetOrder() {
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
            Order order = OrderManagement_CC.getOrder(orders.get(0).Id);
            Test.stopTest();
            System.assertEquals(true, order.Id == orders.get(0).Id);
        }
    }
    @isTest
    private static void testGetOrderItems() {
        User testUser = [SELECT Id FROM User WHERE Alias = 'test1'];
        System.runAs(testUser) {
            List<Pricebook2> pricebooks = TestDataFactory.createPricebooks(1, 'BNL PRE');
            List<Product2> products = TestDataFactory.createProducts(1);
            List<PricebookEntry> pricebookEntries = TestDataFactory.createPricebookEntries(1, pricebooks, products);
            List<Account> accounts = TestDataFactory.createAccounts(1, 'Non_ERP_Account', testUser.Id);
            List<Order> orders = TestDataFactory.returnOrders(1, 'Free_Good_Order', accounts);
            orders.get(0).Pricebook2Id = pricebooks.get(0).Id;
            insert orders;
            List<OrderItem> orderItems = TestDataFactory.createOrderItems(1, orders, pricebookEntries);
            Test.startTest();
            List<OrderItem> orderItemsTest = OrderManagement_CC.getOrderItems(orders.get(0).Id, 1, 10);
            Test.stopTest();
            System.assertEquals(true, orderItems.size() == orderItemsTest.size());
        } 
    }
    @isTest
    private static void testCloneOrder() {
        User testUser = [SELECT Id FROM User WHERE Alias = 'test1'];
        System.runAs(testUser) {
            List<Pricebook2> pricebooks = TestDataFactory.createPricebooks(1, 'BNL PRE');
            List<Product2> products = TestDataFactory.createProducts(1);
            List<PricebookEntry> pricebookEntries = TestDataFactory.createPricebookEntries(1, pricebooks, products);
            List<Account> accounts = TestDataFactory.createAccounts(1, 'Non_ERP_Account', testUser.Id);
            List<Order> orders = TestDataFactory.returnOrders(1, 'Free_Good_Order', accounts);
            orders.get(0).Pricebook2Id = pricebooks.get(0).Id;
            insert orders;
            List<OrderItem> orderItems = TestDataFactory.createOrderItems(1, orders, pricebookEntries);
            Test.startTest();
            Order order = OrderManagement_CC.cloneOrder(orders.get(0).Id, '');
            Test.stopTest();
            System.assertEquals(true, order.Pricebook2Id == orders.get(0).Pricebook2Id);
        }
    }
    
    @isTest
    private static void testInsertOrderItems() {
        User testUser = [SELECT Id FROM User WHERE Alias = 'test1'];
        System.runAs(testUser) {
            List<Pricebook2> pricebooks = TestDataFactory.createPricebooks(1, 'BNL PRE');
            List<Product2> products = TestDataFactory.createProducts(1);
            List<PricebookEntry> pricebookEntries = TestDataFactory.createPricebookEntries(1, pricebooks, products);
            List<Account> accounts = TestDataFactory.createAccounts(1, 'Non_ERP_Account', testUser.Id);
            List<Order> orders = TestDataFactory.returnOrders(1, 'Free_Good_Order', accounts);
            orders.get(0).Pricebook2Id = pricebooks.get(0).Id;
            insert orders;
            List<OrderItem> orderItems = TestDataFactory.returnOrderItems(1, orders, pricebookEntries);
            Test.startTest();
            String result1 = OrderManagement_CC.insertOrderItems(orderItems);
            //String result2 = OrderManagement_CC.insertOrderItems(null);
            Test.stopTest();
            System.assertEquals('SUCCESS', result1);
            //System.assertNotEquals('SUCCESS', result2);
        }
    }
    @isTest
    private static void testCloneOrderItems() {
        User testUser = [SELECT Id FROM User WHERE Alias = 'test1'];
        System.runAs(testUser) {
            List<Pricebook2> pricebooks = TestDataFactory.createPricebooks(1, 'BNL PRE');
            List<Product2> products = TestDataFactory.createProducts(1);
            List<PricebookEntry> pricebookEntries = TestDataFactory.createPricebookEntries(1, pricebooks, products);
            List<Account> accounts = TestDataFactory.createAccounts(1, 'Non_ERP_Account', testUser.Id);
            List<Order> orders = TestDataFactory.returnOrders(1, 'Free_Good_Order', accounts);
            orders.get(0).Pricebook2Id = pricebooks.get(0).Id;
            insert orders;
            List<OrderItem> orderItems = TestDataFactory.returnOrderItems(1, orders, pricebookEntries);
            insert orderItems;
            Test.startTest();
            System.assertEquals(true, OrderManagement_CC.cloneOrderItems(orderItems[0].Id) != null);
            Test.stopTest();
        }
    }
    @isTest
    private static void testGetProductsCounter() {
        User testUser = [SELECT Id FROM User WHERE Alias = 'test1'];
        System.runAs(testUser) {
            List<Pricebook2> pricebooks = TestDataFactory.createPricebooks(1, 'BNL PRE');
            List<Product2> productsParents = TestDataFactory.returnProducts(1);
            productsParents.get(0).PG1_Desc__c = 'PG1_Desc__c';
            productsParents.get(0).PG2_Desc__c = 'PG2_Desc__c';
            productsParents.get(0).PG3_Desc__c = 'PG3_Desc__c';
            productsParents.get(0).PG4_Desc__c = 'PG4_Desc__c';
            insert productsParents;
            List<Product2> products = TestDataFactory.returnProducts(1);
            products.get(0).GlobalSKUMapping__c = productsParents.get(0).Id;
            insert products;
            List<PricebookEntry> pricebookEntries = TestDataFactory.createPricebookEntries(1, pricebooks, products);
            List<Account> accounts = TestDataFactory.createAccounts(1, 'Non_ERP_Account', testUser.Id);
            List<Opportunity> opportunities = TestDataFactory.returnOpportunities(1, 'Account_Plan', testUser.Id);
            opportunities.get(0).AccountId = accounts.get(0).Id;
            insert opportunities;
            Test.startTest();
            Integer counter1 = OrderManagement_CC.getProductsCounter(
                pricebooks.get(0).Id,accounts.get(0).Id, 'Product+Article', 'USD',
                                                'PG1_Desc__c', 'PG2_Desc__c', 'PG3_Desc__c', 'PG4_Desc__c', true);
            Integer counter2 = OrderManagement_CC.getProductsCounter(
                pricebooks.get(0).Id,opportunities.get(0).Id, 'Article1,Article2', 'USD',
                'PG1_Desc__c', 'PG2_Desc__c', 'PG3_Desc__c', 'PG4_Desc__c', false);
            Test.stopTest();
        }
    }
      @isTest
    private static void testGetProducts() {
        User testUser = [SELECT Id FROM User WHERE Alias = 'test1'];
        System.runAs(testUser) {
            List<Pricebook2> pricebooks = TestDataFactory.createPricebooks(1, 'BNL PRE');
            List<Product2> productsParents = TestDataFactory.returnProducts(1);
            productsParents.get(0).PG1_Desc__c = 'PG1_Desc__c';
            productsParents.get(0).PG2_Desc__c = 'PG2_Desc__c';
            productsParents.get(0).PG3_Desc__c = 'PG3_Desc__c';
            productsParents.get(0).PG4_Desc__c = 'PG4_Desc__c';
            insert productsParents;
            List<Product2> products = TestDataFactory.returnProducts(1);
            products.get(0).GlobalSKUMapping__c = productsParents.get(0).Id;
            insert products;
            List<PricebookEntry> pricebookEntries = TestDataFactory.createPricebookEntries(1, pricebooks, products);
            List<Account> accounts = TestDataFactory.createAccounts(1, 'Non_ERP_Account', testUser.Id);
            List<Opportunity> opportunities = TestDataFactory.returnOpportunities(1, 'Account_Plan', testUser.Id);
            opportunities.get(0).AccountId = accounts.get(0).Id;
            insert opportunities;
            Test.startTest();
            List<Product2> products1 = OrderManagement_CC.getProducts(
                pricebooks.get(0).Id,accounts.get(0).Id, 'Product+Article', 'USD',
                                                    'PG1_Desc__c', 'PG2_Desc__c', 'PG3_Desc__c', 'PG4_Desc__c', 1, 10, true);
            List<Product2> products2 = OrderManagement_CC.getProducts(
                pricebooks.get(0).Id,opportunities.get(0).Id, 'Article1,Article2', 'USD',
                'PG1_Desc__c', 'PG2_Desc__c', 'PG3_Desc__c', 'PG4_Desc__c', 1, 10, false);
            Test.stopTest();
        }
    }
    @isTest
    private static void testGetOrderItemsCounter() {
        User testUser = [SELECT Id FROM User WHERE Alias = 'test1'];
        System.runAs(testUser) {
            List<Pricebook2> pricebooks = TestDataFactory.createPricebooks(1, 'BNL PRE');
            List<Product2> products = TestDataFactory.createProducts(1);
            List<PricebookEntry> pricebookEntries = TestDataFactory.createPricebookEntries(1, pricebooks, products);
            List<Account> accounts = TestDataFactory.createAccounts(1, 'Non_ERP_Account', testUser.Id);
            List<Order> orders = TestDataFactory.returnOrders(1, 'Free_Good_Order', accounts);
            orders.get(0).Pricebook2Id = pricebooks.get(0).Id;
            insert orders;
            TestDataFactory.createOrderItems(1, orders, pricebookEntries);
            Test.startTest();
            System.assertEquals(1, OrderManagement_CC.getOrderItemsCounter(orders.get(0).Id));
            Test.stopTest();
        }
    }
    @isTest
    private static void testDeleteOrderItem() {
        User testUser = [SELECT Id FROM User WHERE Alias = 'test1'];
        System.runAs(testUser) {
            List<Pricebook2> pricebooks = TestDataFactory.createPricebooks(1, 'BNL PRE');
            List<Product2> products = TestDataFactory.createProducts(1);
            List<PricebookEntry> pricebookEntries = TestDataFactory.createPricebookEntries(1, pricebooks, products);
            List<Account> accounts = TestDataFactory.createAccounts(1, 'Non_ERP_Account', testUser.Id);
            List<Order> orders = TestDataFactory.returnOrders(1, 'Free_Good_Order', accounts);
            orders.get(0).Pricebook2Id = pricebooks.get(0).Id;
            insert orders;
            List<OrderItem> orderItems = TestDataFactory.createOrderItems(1, orders, pricebookEntries);
            Test.startTest();
            System.assertEquals('SUCCESS', OrderManagement_CC.deleteOrderItem(orderItems.get(0).Id));
            //System.assertNotEquals('SUCCESS', OrderManagement_CC.deleteOrderItem('Fire Exception'));
            Test.stopTest();
        }
    }
    @isTest
    private static void testGetSBUDescriptions() {
        User testUser = [SELECT Id FROM User WHERE Alias = 'test1'];
        System.runAs(testUser) {
            List<Pricebook2> pricebooks = TestDataFactory.createPricebooks(1, 'BNL PRE');
            List<Product2> productsParents = TestDataFactory.returnProducts(1);
            productsParents.get(0).PG1_Desc__c = 'PG1_Desc__c';
            productsParents.get(0).PG2_Desc__c = 'PG2_Desc__c';
            productsParents.get(0).PG3_Desc__c = 'PG3_Desc__c';
            productsParents.get(0).PG4_Desc__c = 'PG4_Desc__c';
            insert productsParents;
            List<Product2> products = TestDataFactory.returnProducts(1);
            products.get(0).GlobalSKUMapping__c = productsParents.get(0).Id;
            insert products;
            List<PricebookEntry> pricebookEntries = TestDataFactory.createPricebookEntries(1, pricebooks, products);
            List<Account> accounts = TestDataFactory.createAccounts(1, 'Non_ERP_Account', testUser.Id);
            Test.startTest();
            String sbu1 = OrderManagement_CC.getSBUDescriptions(pricebooks.get(0).Id,accounts.get(0).Id, 'USD', true);
            String sbu2 = OrderManagement_CC.getSBUDescriptions(pricebooks.get(0).Id,accounts.get(0).Id, 'USD', false);
            Test.stopTest();
        }
    }
    @isTest
    private static void testGetContracts() {
        User testUser = [SELECT Id FROM User WHERE Alias = 'test1'];
        System.runAs(testUser) {
            List<Pricebook2> pricebooks = TestDataFactory.returnPricebooks(1, 'BNL PRE');
            pricebooks.get(0).Contract_Discount_types__c = 'Implants';
            insert pricebooks;
            List<Account> accounts = TestDataFactory.createAccounts(1, 'Non_ERP_Account', testUser.Id);
            List<Opportunity> opportunities = TestDataFactory.returnOpportunities(1, 'Account_Plan', testUser.Id);
            opportunities.get(0).AccountId = accounts.get(0).Id;
            insert opportunities;
            Field_Sales_Project_Members__c prospect1 = new Field_Sales_Project_Members__c();
            prospect1.Account__c = accounts.get(0).Id;
            prospect1.Category__c = 'Implants';
            prospect1.Status__c = 'New';
            insert prospect1;
            List<Contact> contacts = TestDataFactory.returnContacts(1, 'ContactGlobal', testUser.Id);
            contacts.get(0).AccountId = accounts.get(0).Id;
            insert contacts;            
            List<Event> events = TestDataFactory.returnEvents(1, testUser.Id);
            events.get(0).WhatId = accounts.get(0).Id;
            events.get(0).WhoId = contacts.get(0).Id;
            events.get(0).Subject = 'test';

            insert events;
            Test.startTest();
            List<Contract> contracts1 = OrderManagement_CC.getContracts(pricebooks.get(0).Id, accounts.get(0).Id, '');
            List<Contract> contracts2 = OrderManagement_CC.getContracts(pricebooks.get(0).Id, opportunities.get(0).Id, '');
            List<Contract> contracts3 = OrderManagement_CC.getContracts(pricebooks.get(0).Id, events.get(0).Id, '');
            List<Contract> contracts4 = OrderManagement_CC.getContracts(pricebooks.get(0).Id, prospect1.Id, '');
            Test.stopTest();
        }
    }

    @isTest
    private static void testGetRelatedAccountsWithContact() {
        User testUser = [SELECT Id FROM User WHERE Alias = 'test1'];
        System.runAs(testUser) {
            /*List<Pricebook2> pricebooks = TestDataFactory.returnPricebooks(1, 'BNL PRE');
            pricebooks.get(0).Contract_Discount_types__c = 'Implants';
            insert pricebooks;*/
            List<Account> accounts = TestDataFactory.createAccounts(3, 'CIM_Account', testUser.Id);
           /* List<Opportunity> opportunities = TestDataFactory.returnOpportunities(1, 'Account_Plan', testUser.Id);
            opportunities.get(0).AccountId = accounts.get(0).Id;
            insert opportunities;
            Field_Sales_Project_Members__c prospect1 = new Field_Sales_Project_Members__c();
            prospect1.Account__c = accounts.get(0).Id;
            prospect1.Category__c = 'Implants';
            prospect1.Status__c = 'New';
            insert prospect1;*/
            List<Contact> contacts = TestDataFactory.returnContacts(1, 'ContactGlobal', testUser.Id);
            contacts.get(0).AccountId = accounts.get(0).Id;
            insert contacts;      
                  
            List<Event> events = TestDataFactory.returnEvents(1, testUser.Id);
            events.get(0).WhatId = accounts.get(0).Id;
            events.get(0).WhoId = contacts.get(0).Id;
            events.get(0).Subject = 'test';
            insert events;
            List<AccountContactRelation> AccountContactRelation = TestDataFactory.returnAccountContactRelationhip(2);
            AccountContactRelation.get(0).AccountId = accounts.get(1).Id;
            AccountContactRelation.get(0).ContactId = contacts.get(0).Id;
            AccountContactRelation.get(1).AccountId = accounts.get(2).Id;
            AccountContactRelation.get(1).ContactId = contacts.get(0).Id;
            insert AccountContactRelation;
            
            Test.startTest();
            List<AccountContactRelation> accountContactRelations = OrderManagement_CC.getRelatedAccountsWithContact( contacts.get(0).Id );
            List<AccountContactRelation> accountContactRelations2 = OrderManagement_CC.getRelatedAccountsWithContact( events.get(0).Id );
            Test.stopTest();
        }
    }

    @isTest
    private static void testCreateOrder() {
        User testUser = [SELECT Id FROM User WHERE Alias = 'test1'];
        System.runAs(testUser) {
            List<Pricebook2> pricebooks = TestDataFactory.returnPricebooks(3, 'BNL PRE');
            pricebooks.get(0).Contract_Discount_types__c = 'Implants';
            pricebooks.get(0).Pricebook_Channel__c = 'Direct';
            pricebooks.get(1).Contract_Discount_types__c = 'Implants';
            pricebooks.get(1).Pricebook_Channel__c = 'Indirect';
            pricebooks.get(2).Contract_Discount_types__c = 'Implants';
            pricebooks.get(2).Pricebook_Channel__c = 'Free Good Order';
            insert pricebooks;
            List<Account> accounts = TestDataFactory.createAccounts(1, 'Non_ERP_Account', testUser.Id);
            List<Opportunity> opportunities = TestDataFactory.returnOpportunities(1, 'Account_Plan', testUser.Id);
            opportunities.get(0).AccountId = accounts.get(0).Id;
            insert opportunities;
            List<Contact> contacts = TestDataFactory.returnContacts(1, 'ContactGlobal', testUser.Id);
            contacts.get(0).AccountId = accounts.get(0).Id;
            insert contacts;
            
            Field_Sales_Project_Members__c prospect1 = new Field_Sales_Project_Members__c();
            prospect1.Account__c = accounts.get(0).Id;
            prospect1.Category__c = 'Implants';
            prospect1.Status__c = 'New';
            
            insert prospect1;
            List<Event> events = TestDataFactory.returnEvents(1, testUser.Id);
            events.get(0).WhatId = accounts.get(0).Id;
            events.get(0).WhoId = contacts.get(0).Id;
            events.get(0).Subject = 'test';

            insert events;

            Test.startTest();
            OrderManagement_CC.createOrder(pricebooks.get(0).Id, accounts.get(0).Id, '', '', '','');
            OrderManagement_CC.createOrder(pricebooks.get(1).Id, opportunities.get(0).Id, '', '', '','');
            OrderManagement_CC.createOrder(pricebooks.get(2).Id, opportunities.get(0).Id, '', '', '','');
            OrderManagement_CC.createOrder(pricebooks.get(0).Id, contacts.get(0).Id, '', '', '',accounts.get(0).Id);
            //OrderManagement_CC.createOrder(pricebooks.get(0).Id, contacts.get(0).Id, '', '', '',null);
            OrderManagement_CC.createOrder(pricebooks.get(0).Id, prospect1.Id, '', '', '','');
            OrderManagement_CC.createOrder(pricebooks.get(0).Id, events.get(0).Id, '', '', '',accounts.get(0).Id);
            OrderManagement_CC.createOrder(pricebooks.get(0).Id, events.get(0).Id, '', '', '',null);
            Test.stopTest();
        }
    }
    @isTest
    private static void testgetAccountRecordType() {
        User testUser = [SELECT Id FROM User WHERE Alias = 'test1'];
        System.runAs(testUser) {
            List<Pricebook2> pricebooks = TestDataFactory.returnPricebooks(3, 'BNL PRE');
            pricebooks.get(0).Contract_Discount_types__c = 'Implants';
            pricebooks.get(0).Pricebook_Channel__c = 'Direct';
            pricebooks.get(1).Contract_Discount_types__c = 'Implants';
            pricebooks.get(1).Pricebook_Channel__c = 'Indirect';
            pricebooks.get(2).Contract_Discount_types__c = 'Implants';
            pricebooks.get(2).Pricebook_Channel__c = 'Free Good Order';
            insert pricebooks;
            List<Account> accounts = TestDataFactory.createAccounts(1, 'Non_ERP_Account', testUser.Id);
            List<Opportunity> opportunities = TestDataFactory.returnOpportunities(1, 'Account_Plan', testUser.Id);
            opportunities.get(0).AccountId = accounts.get(0).Id;
            insert opportunities;
            List<Contact> contacts = TestDataFactory.returnContacts(1, 'ContactGlobal', testUser.Id);
            contacts.get(0).AccountId = accounts.get(0).Id;
            insert contacts;
            
            Field_Sales_Project_Members__c prospect1 = new Field_Sales_Project_Members__c();
            prospect1.Account__c = accounts.get(0).Id;
            prospect1.Category__c = 'Implants';
            prospect1.Status__c = 'New';
            
            insert prospect1;
            List<Event> events = TestDataFactory.returnEvents(1, testUser.Id);
            events.get(0).WhatId = accounts.get(0).Id;
            events.get(0).WhoId = contacts.get(0).Id;
            events.get(0).Subject = 'test';

            insert events;

            Test.startTest();
            OrderManagement_CC.getAccountRecordType( accounts.get(0).Id);
            OrderManagement_CC.getAccountRecordType( opportunities.get(0).Id);
            OrderManagement_CC.getAccountRecordType( contacts.get(0).Id);
            OrderManagement_CC.getAccountRecordType( prospect1.Id);
            OrderManagement_CC.getAccountRecordType( events.get(0).Id);
            Test.stopTest();
        }
    }

    @isTest
    private static void testGetSourceRecords() {
        User testUser = [SELECT Id FROM User WHERE Alias = 'test1'];
        System.runAs(testUser) {
            List<Pricebook2> pricebooks = TestDataFactory.returnPricebooks(1, 'AAAAatest');
            pricebooks.get(0).ShowPricingfromMicroServiceOM__c = true;
            pricebooks.get(0).SourceId__c = '2';
            pricebooks.get(0).CompanyCode__c = '057';
            pricebooks.get(0).Pricebook_Channel__c = 'Direct';
            insert pricebooks;
            List<Account> accounts = TestDataFactory.createAccounts(1, 'CIM_Account', testUser.Id);
            List<Opportunity> opportunities = TestDataFactory.returnOpportunities(1, 'Account_Plan', testUser.Id);
            opportunities.get(0).AccountId = accounts.get(0).Id;
            insert opportunities;
            List<Contact> contacts = TestDataFactory.returnContacts(1, 'ContactGlobal', testUser.Id);
            contacts.get(0).AccountId = accounts.get(0).Id;
            insert contacts;
            
            Field_Sales_Project_Members__c prospect1 = new Field_Sales_Project_Members__c();
            prospect1.Account__c = accounts.get(0).Id;
            prospect1.Category__c = 'Implants';
            prospect1.Status__c = 'New';
            
            insert prospect1;
            List<Event> events = TestDataFactory.returnEvents(1, testUser.Id);
            events.get(0).WhatId = accounts.get(0).Id;
            events.get(0).WhoId = contacts.get(0).Id;
            events.get(0).Subject = 'test';

            insert events;
            Test.startTest();
            List<Source_Record__c> sourceRecords = OrderManagement_CC.getSourceRecords( accounts.get(0).Id,pricebooks.get(0).Id,null);
            List<Source_Record__c> sourceRecords1 = OrderManagement_CC.getSourceRecords( null,accounts.get(0).Id,pricebooks.get(0).Id);
            List<Source_Record__c> sourceRecords2 = OrderManagement_CC.getSourceRecords( opportunities.get(0).Id,pricebooks.get(0).Id,null);
            List<Source_Record__c> sourceRecords3 = OrderManagement_CC.getSourceRecords( contacts.get(0).Id,pricebooks.get(0).Id,null);
            List<Source_Record__c> sourceRecords4 = OrderManagement_CC.getSourceRecords( events.get(0).Id,pricebooks.get(0).Id,null);
            List<Source_Record__c> sourceRecords5 = OrderManagement_CC.getSourceRecords( prospect1.Id,pricebooks.get(0).Id,null);
            Test.stopTest();
        }
    }
	
    @isTest
    private static void testCloneOrderWithPricingMicroServiceCallOut() {
        // Set mock callout class 
      	Test.setMock(HttpCalloutMock.class, new ProductPricingERPCallOutMock()); 
        User testUser = [SELECT Id FROM User WHERE Alias = 'test1'];
        System.runAs(testUser) {
            List<Pricebook2> pricebooks = TestDataFactory.returnPricebooks(1, 'BNL PRE');
            pricebooks.get(0).ShowPricingfromMicroServiceOM__c = true;
            pricebooks.get(0).SourceId__c = '2';
            pricebooks.get(0).CompanyCode__c = '057';
            pricebooks.get(0).Pricebook_Channel__c = 'Direct';
            insert pricebooks;
            List<Product2> products = TestDataFactory.returnProducts(1);
            products.get(0).Company_Code__c = '057';
            products.get(0).ERP_Source__c = 2;
            products.get(0).Article__c = '0520055';
            insert products;
            List<PricebookEntry> pricebookEntries = TestDataFactory.createPricebookEntries(1, pricebooks, products);
            List<Account> accounts = TestDataFactory.createAccounts(1, 'CIM_Account', testUser.Id);
            Account acc = [SELECT RecordType.DeveloperName FROM Account WHERE Id =: accounts.get(0).Id limit 1];
            List<Source_Record__c> sourceRecords = TestDataFactory.returnSourceRecords(1);
            sourceRecords.get(0).Name = 'test';
            sourceRecords.get(0).Source_Id__c = '2';
            sourceRecords.get(0).Customer_Id__c = '690862';
            sourceRecords.get(0).CIM_Account__c = acc.Id;
            insert sourceRecords;
            List<Order> orders = TestDataFactory.returnOrders(1, 'Direct_global_order', accounts);
            orders.get(0).Pricebook2Id = pricebooks.get(0).Id;
            orders.get(0).SourceRecord__c = sourceRecords.get(0).Id;
            insert orders;
            List<OrderItem> orderItems = TestDataFactory.createOrderItems(1, orders, pricebookEntries);
            //List<OrderItem> orderItems2 = TestDataFactory.createOrderItems(1, orders, pricebookEntries);
            Test.startTest();
            Order order = OrderManagement_CC.cloneOrder(orders.get(0).Id, '');
            ProductPricingERPCallOutWrapper.ProductEntry prodEntry = new ProductPricingERPCallOutWrapper.ProductEntry();
            prodEntry.productId='44';
            prodEntry.quantity=5;
            Test.stopTest();
            System.assertEquals(true, order.Pricebook2Id == orders.get(0).Pricebook2Id);
        }
    }

   
	
}