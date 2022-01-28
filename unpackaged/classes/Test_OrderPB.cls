/*------------------------------------------------------------
Author: 		Ahmed LOUDRASSI (Salesforce) 2019-10-21
Description:   	Test Class for the Opportunity Process Builder.
History
<Date>      <Authors Name>     <Brief Description of Change>

------------------------------------------------------------*/

@isTest(seeAllData=false)
public class Test_OrderPB {
	/*-------------------------------------------------------------------------------------------------------
    Company: Salesforce
    Description: Setup one user for the test class
    History :
    --------------------------------------------------------------------------------------------------------*/
    @testSetup
    private static void setup() {
        TestDataFactory.createBypassCustomSetting();
        List<User> userList = TestDataFactory.createUsers(1, 'System Administrator');
        List<Account> accounts1 = TestDataFactory.returnAccounts(1, 'Geographical_Account', userList.get(0).Id);
        userList.get(0).Personal_Order_Account__c = accounts1.get(0).Id;
        update userList;
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
    private static void testSetCurrencyToEURInNordics() {
        
        User testUser = [SELECT Id FROM User WHERE Alias = 'test1'];
        List<Account> accounts1 = TestDataFactory.returnAccounts(1, 'Geographical_Account', testUser.Id);
        accounts1.get(0).Country__c = 'SE';
        insert accounts1;
        List<Order> orders = TestDataFactory.returnOrders(1, 'Free_Good_Order', accounts1);
        Test.startTest();
        insert orders;
        Test.stopTest();

        System.assertEquals('EUR', [SELECT Id, CurrencyIsoCode FROM Order LIMIT 1].CurrencyIsoCode);
    }
    @isTest
    private static void testGlobalOrderUpdatePayer() {
        User testUser = [SELECT Id, Personal_Order_Account__c FROM User WHERE Alias = 'test1'];
        List<Account> accounts1 = TestDataFactory.returnAccounts(1, 'Geographical_Account', testUser.Id);
        insert accounts1;
        List<Order> orders = TestDataFactory.returnOrders(1, 'Free_Good_Order', accounts1);
        orders.get(0).Country__c = 'CA';
        System.runAs(testUser) {
            Test.startTest();
            insert orders;
            Test.stopTest(); 
        }  
        System.assertEquals(testUser.Personal_Order_Account__c, [SELECT Id, Account_for_Sample_in_AX__c FROM Order LIMIT 1].Account_for_Sample_in_AX__c);
    }
    @isTest
    private static void testUpdateCSResponsibleDateTime() {
        User testUser = [SELECT Id FROM User WHERE Alias = 'test1'];
        List<Account> accounts1 = TestDataFactory.returnAccounts(1, 'Geographical_Account', testUser.Id);
        insert accounts1;
        List<Order> orders = TestDataFactory.returnOrders(1, 'Free_Good_Order', accounts1);
        orders.get(0).Customer_Service_Rep_Responsible__c = testUser.Id;
        System.runAs(testUser) {
            Test.startTest();
            insert orders;
            Test.stopTest(); 
        }  
        Datetime dt = datetime.now();
        Order order = [SELECT Id, CS_Ownership_Assigned__c FROM Order LIMIT 1];
        System.assertEquals(dt.Hour() + dt.minute(), order.CS_Ownership_Assigned__c.Hour() + order.CS_Ownership_Assigned__c.Minute());
    }
}