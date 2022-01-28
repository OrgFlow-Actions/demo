/*-------------------------------------------------------------------------------------------------------
Author: 		Ahmed LOUDRASSI (Salesforce) 20191113
Description:   	Event Trigger Helper Class
History	
20191113 	Ahmed LOUDRASSI			OrderSetAccountOwner triggers. (#)
12092019	Miguel					Added GDW Integration User creation into the setup method
18102020    Miguel                  Added testSetDiscountAllowedforTurkey User Story: #1833
--------------------------------------------------------------------------------------------------------*/

@isTest(seeAllData=false)
public with sharing class Test_OrderTrigger {
	/*-------------------------------------------------------------------------------------------------------
    Company: Salesforce
    Description: Setup one user for the test class
    History :
    --------------------------------------------------------------------------------------------------------*/
    @testSetup
    private static void setup() {
        TestDataFactory.createBypassCustomSetting();
        List<User> userList = TestDataFactory.createUsers(1, '#System: System Administrator'); 
        TestDataFactory.createGlobalIntegrationSettings(userList);
        TestDataFactory.createDefaultOrgLevelBypassPB();        
    }

    @isTest
    private static void testSetup() {
        Test.startTest();
        List<User> testUserList = [SELECT Id FROM User WHERE Alias = 'test1'];
        Test.stopTest();
		
        System.assertEquals(1, testUserList.size(), 'Expected one user');
    }
    @isTest
    public static void testOrderSetAccountOwner() {
        User testUser = [SELECT Id FROM User WHERE Alias = 'test1' limit 1];
        List<Account> accounts1 = TestDataFactory.createAccounts(1, 'Geographical_Account', testUser.Id);
        
        List<Order> orders = TestDataFactory.returnOrders(1, 'Free_Good_Order', accounts1);
        Test.startTest();
        insert orders;
        Test.stopTest();

        System.assertEquals(accounts1.get(0).OwnerId, [SELECT Id, Account_Owner__c FROM Order LIMIT 1].Account_Owner__c);
    }
    @isTest
    private static void testSetDiscountAllowedforTurkey() {      
		List<User> userList = TestDataFactory.createUsers(1, '#System: System Administrator');
        System.runAs(userList.get(0)){
        	User testUser = [SELECT Id FROM User WHERE Alias = 'test1' limit 1]; 
        	List<Pricebook2> pricebooksList = TestDataFactory.createPricebooks(1, 'TR Implants');
        	List<Product2> productsList = TestDataFactory.createProducts(1);
        	List<Discount_model__c> discountModelList = TestDataFactory.createDiscountModels(1, testUser.Id);
        	pricebooksList.get(0).Discount_Model__c = discountModelList.get(0).Id ; 
        	update pricebooksList ;   
        	List<PricebookEntry> pricebookEntriesList = TestDataFactory.createPricebookEntries(1, pricebooksList, productsList);
        	List<Discount_row__c> drs = TestDataFactory.createDiscountRows(discountModelList.get(0).Id);        
            List<Account> accountsList = TestDataFactory.createAccounts(1, 'Non_ERP_Account', testUser.Id);
            List<Order> ordersList = TestDataFactory.returnOrders(1, 'Free_Good_Order', accountsList);
            ordersList.get(0).Pricebook2Id = pricebooksList.get(0).Id;
            ordersList.get(0).Country__c = 'TR';
            ordersList.get(0).Order_Type__c = 'Implants';
            insert ordersList;
            List<OrderItem> orderItemsList = TestDataFactory.returnOrderItems(1, ordersList, pricebookEntriesList);        
            Test.startTest();
            insert orderItemsList;
            Order order= [SELECT Id, Allowed_Discount__c, Allowed_payment_terms_months__c, Payment_type_discount__c FROM Order WHERE Id = :ordersList.get(0).Id];
            System.assertEquals(1, order.Allowed_Discount__c); 
            order.Payment_Type__c = null ; 
            update order ;
            order= [SELECT Id, Allowed_Discount__c, Allowed_payment_terms_months__c, Payment_type_discount__c FROM Order WHERE Id = :ordersList.get(0).Id];
            System.assertEquals(0, order.Payment_type_discount__c);
            List<Discount_row__c> drToUpdateList = new List<Discount_row__c>{};
            for (Discount_row__c dr: drs){
                dr.Discount_lever__c = 'Payment type'; 
                dr.equals__c = 'DS credit card' ;
                dr.Allowed_Discount__c = 20 ; 
                drToUpdateList.add(dr);
            }
            update drToUpdateList ;
            order.Payment_Type__c = 'DS credit card' ; 
            update order ;
            Test.stopTest();
            order= [SELECT Id, Allowed_Discount__c, Allowed_payment_terms_months__c, Payment_type_discount__c FROM Order WHERE Id = :ordersList.get(0).Id];
            System.assertEquals(20, order.Payment_type_discount__c); 
        }
    }
}