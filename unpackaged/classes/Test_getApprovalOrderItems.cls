/*-------------------------------------------------------------------------------------------------------
Author: 		Roberto Narbona 20200706
Description:   	Test Class to cover code getApprovalProcessRecordDetailController.getOrderItems
History	

--------------------------------------------------------------------------------------------------------*/

@isTest(seeAllData=false)

public with sharing class Test_getApprovalOrderItems {
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
    private static void testGetApprovalOrderItems() {
        User testUser = [SELECT Id FROM User WHERE Alias = 'test1'];
        System.runAs(testUser) {
            List<Pricebook2> pricebooks = TestDataFactory.createPricebooks(1, 'Turkey PREP Pricebook');
            List<Product2> products = TestDataFactory.createProducts(1);
            List<PricebookEntry> pricebookEntries = TestDataFactory.createPricebookEntries(1, pricebooks, products);
            List<Account> accounts = TestDataFactory.returnAccounts(1, 'CIM_Account', testUser.Id);
            accounts.get(0).Name= 'This is to pass test class';
            insert accounts;
            List<Order> orders = TestDataFactory.returnOrders(1, 'Direct_global_order', accounts);
            orders.get(0).Pricebook2Id = pricebooks.get(0).Id;
            orders.get(0).Name = 'This is to pass test class';
            orders.get(0).Distributor__c = accounts.get(0).Id;
            insert orders;
            List<OrderItem> orderItems = TestDataFactory.returnOrderItems(1, orders, pricebookEntries);
            insert orderItems;

            

            //Submit for Approval
            Approval.ProcessSubmitRequest app = new Approval.ProcessSubmitRequest();
            app.setObjectId(orders[0].id);
            app.setComments('Approve.');
            app.setSubmitterId(testUser.Id);
            app.setProcessDefinitionNameOrId('Turkey_PREP_Order_Approval_Process');
            app.setSkipEntryCriteria(true);
            Approval.ProcessResult result = Approval.process(app);
            ProcessInstanceWorkitem processInstanceRecord = [SELECT Id FROM ProcessInstanceWorkitem LIMIT 1];
            Id processInstanceRecordId = processInstanceRecord.Id;

            Test.StartTest();
            getApprovalProcessRecordDetailController.getOrderItems(processInstanceRecordId);
            Test.StopTest();
            System.assertEquals(1, getApprovalProcessRecordDetailController.getOrderItems(processInstanceRecordId).size());

        }
    }
}