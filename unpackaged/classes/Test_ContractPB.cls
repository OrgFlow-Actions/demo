/*------------------------------------------------------------
Author: 		Ahmed LOUDRASSI (Salesforce) 2019-11-25
Description:   	Test Class for the Contract Process Builder.
History
<Date>      <Authors Name>     <Brief Description of Change>

------------------------------------------------------------*/

@isTest(seeAllData=false)
public class Test_ContractPB {
	/*-------------------------------------------------------------------------------------------------------
    Company: Salesforce
    Description: Setup one user for the test class
    History :
    --------------------------------------------------------------------------------------------------------*/
    @testSetup
    private static void setup() {
        TestDataFactory.createBypassCustomSetting();
        List<User> userList1 = TestDataFactory.createUsers(1, 'System Administrator');
       	List<User> userIntegrationList = TestDataFactory.insertIntegrationUsers(1, 'System Administrator');
        TestDataFactory.createGlobalIntegrationSettings(userIntegrationList);
        List<Discount_Model__c> discountModels = TestDataFactory.createDiscountModels(1, userList1.get(0).Id);
        TestDataFactory.createDEDiscountModelCustomSetting(discountModels.get(0));
        TestDataFactory.createDefaultOrgLevelBypassPB();
        
        BatchSettings__c batchSetting = new BatchSettings__c();
        batchSetting.DisableContractTriggerHelperUpdSales__c = false;
        batchSetting.Name = 'Default';
        insert batchSetting;
    }
    @isTest
    private static void testSetup() {
        Test.startTest();
        List<User> testUserList = [SELECT Id FROM User WHERE Alias = 'test1'];
        Test.stopTest();

        System.assertEquals(1, testUserList.size(), 'Expected Two user');
    }
    @isTest
    private static void testManagersManagerisASM() {
        User testUser = [SELECT Id, Manager_workaround__r.Id FROM User WHERE Alias = 'test1'];
        List<Account> accounts1 = TestDataFactory.createAccounts(1, 'Geographical_Account', testUser.Id);
        List<Contract> contracts = TestDataFactory.returnContracts(1, 'Pricing_contract', testUser.Id, accounts1);
        contracts.get(0).Revenue_forecast__c = 10000;
        contracts.get(0).Sales_Correction__c = true;
        Test.startTest();
       	insert contracts;
        Test.stopTest();
        
        System.assertEquals(testUser.Manager_workaround__r.Id, [SELECT Id, Area_manager_DE__r.Id FROM Contract LIMIT 1].Area_manager_DE__r.Id);
    }
    /*@isTest
    private static void testCheckNewCustomer() {
        User testUser = [SELECT Id, Manager_workaround__r.Id FROM User WHERE Alias = 'test1'];
        List<Account> accounts1 = TestDataFactory.returnAccounts(1, 'Geographical_Account', testUser.Id);
        accounts1.get(0).TS_CY_D_AllPLs_AllPCs_AllBrands__c = 0;
		accounts1.get(0).TS_CY_1_TD_D_AllPLs_AllPCs_AllBrands__c = 0;
        insert accounts1;
        List<Contract> contracts = TestDataFactory.returnContracts(1, 'Pricing_contract', testUser.Id, accounts1);
        contracts.get(0).Revenue_forecast__c = 10000;
        contracts.get(0).Sales_Correction__c = true;
        Test.startTest();
        insert contracts;
        Test.stopTest();
        
        System.assertEquals(true, [SELECT Id, New_customer__c FROM Contract LIMIT 1].New_customer__c);
    }*/
    @isTest
    private static void testClearContractOwnerExpirationNoticeOnExpiredContracts() {
        User testUser = [SELECT Id, Manager_workaround__r.Id FROM User WHERE Alias = 'test1'];
        List<Account> accounts1 = TestDataFactory.createAccounts(1, 'Geographical_Account', testUser.Id);
        List<Contract> contracts = TestDataFactory.returnContracts(1, 'Pricing_contract', testUser.Id, accounts1);
        contracts.get(0).Status = 'Active';
        contracts.get(0).OwnerExpirationNotice = '90';
        contracts.get(0).Revenue_forecast__c = 10000;
        contracts.get(0).Sales_Correction__c = true;
        Test.startTest();
       	insert contracts;
        Test.stopTest();
        
        System.assertEquals(null, [SELECT Id, OwnerExpirationNotice FROM Contract LIMIT 1].OwnerExpirationNotice);
    }
    @isTest
    private static void testDESetMaxApprovedDiscount() {
        User testUser = [SELECT Id, Manager_workaround__r.Id FROM User WHERE Alias = 'test1'];
        List<Account> accounts1 = TestDataFactory.returnAccounts(1, 'Geographical_Account', testUser.Id);
        accounts1.get(0).Country__c = 'DE';
        insert accounts1;
        List<Contract> contracts = TestDataFactory.returnContracts(1, 'Pricing_contract', testUser.Id, accounts1);
        contracts.get(0).Status = 'Draft';
        contracts.get(0).Revenue_forecast__c = 10000;
        contracts.get(0).Sales_Correction__c = true;
        Test.startTest();
        insert contracts;
        Test.stopTest();
        
        //System.assertEquals(0, [SELECT Id, Max_Approved_Discount__c FROM Contract LIMIT 1].Max_Approved_Discount__c);
    }
    @isTest
    private static void testSetApprovalStatusFieldOnCreation() {
        User testUser = [SELECT Id, Manager_workaround__r.Id FROM User WHERE Alias = 'test1'];
        List<Account> accounts1 = TestDataFactory.createAccounts(1, 'Geographical_Account', testUser.Id);
        List<Contract> contracts = TestDataFactory.returnContracts(1, 'Pricing_contract', testUser.Id, accounts1);
        contracts.get(0).Approval_Status__c = 'Pending';
        contracts.get(0).Revenue_forecast__c = 10000;
        contracts.get(0).Sales_Correction__c = true;
        Test.startTest();
        insert contracts;
        Test.stopTest();
        System.assertEquals('Not Submitted for Approval', [SELECT Id, Approval_Status__c FROM Contract LIMIT 1].Approval_Status__c);        
    }
    @isTest
    private static void testSetContractExternalID() {
        User testUser = [SELECT Id, Manager_workaround__r.Id FROM User WHERE Alias = 'test1'];
        List<Account> accounts1 = TestDataFactory.createAccounts(1, 'Geographical_Account', testUser.Id);
        List<Contract> contracts = TestDataFactory.returnContracts(1, 'Pricing_contract', testUser.Id, accounts1);
        contracts.get(0).Revenue_forecast__c = 10000;
        contracts.get(0).Sales_Correction__c = true;
        Test.startTest();
        insert contracts;
        Test.stopTest();
        Contract contract = [SELECT Id, Contract_External_ID__c, ContractNumber FROM Contract LIMIT 1];
        System.assertEquals(contract.ContractNumber, contract.Contract_External_ID__c);
    }   
    @isTest
    private static void testSetOwnerExpirationNotice() {
        User testUser = [SELECT Id, Manager_workaround__r.Id FROM User WHERE Alias = 'test1'];
        List<Account> accounts1 = TestDataFactory.returnAccounts(1, 'Geographical_Account', testUser.Id);
        accounts1.get(0).Country__c = 'DE';
        insert accounts1;
        List<Contract> contracts = TestDataFactory.returnContracts(1, 'Pricing_contract', testUser.Id, accounts1);
        contracts.get(0).OwnerExpirationNotice = '15';
        contracts.get(0).Revenue_forecast__c = 10000;
        contracts.get(0).Sales_Correction__c = true;
        Test.startTest();
        insert contracts;
        Test.stopTest();
        
        System.assertEquals('90', [SELECT Id, OwnerExpirationNotice FROM Contract LIMIT 1].OwnerExpirationNotice);
    }
    @isTest
    private static void testSetOwnersManagersEmailDE() {
        User testUser = [SELECT Id FROM User WHERE Alias = 'test1'];
        List<Account> accounts1 = TestDataFactory.createAccounts(1, 'Geographical_Account', testUser.Id);
        List<Contract> contracts = TestDataFactory.returnContracts(1, 'Pricing_contract', testUser.Id, accounts1);
        contracts.get(0).Revenue_forecast__c = 10000;
        contracts.get(0).Sales_Correction__c = true;
        Test.startTest();
        insert contracts;
        Test.stopTest();
        Contract contract = [SELECT Id, Owners_Managers_Email_DE__c, Owner.Manager.Email FROM Contract LIMIT 1];
        System.assertEquals(contract.Owner.Manager.Email, contract.Owners_Managers_Email_DE__c);
    }
    @isTest
    private static void testSetPooledOrderCommitment() {
        User testUser = [SELECT Id FROM User WHERE Alias = 'test1'];
        List<Account> accounts1 = TestDataFactory.createAccounts(1, 'Geographical_Account', testUser.Id);
        List<Contract> contracts = TestDataFactory.returnContracts(1, 'Pricing_contract', testUser.Id, accounts1);
        contracts.get(0).Pooled_order_commitment__c = 2;
        contracts.get(0).Revenue_forecast__c = 10000;
        contracts.get(0).Sales_Correction__c = true;
        Test.startTest();
        insert contracts;
        Test.stopTest();
        System.assertEquals(0, [SELECT Id, Pooled_order_commitment__c FROM Contract LIMIT 1].Pooled_order_commitment__c);
    }
    @isTest
    private static void testUpdateContractEndDate() {
        User testUser = [SELECT Id FROM User WHERE Alias = 'test1'];
        List<Account> accounts1 = TestDataFactory.createAccounts(1, 'Geographical_Account', testUser.Id);
        List<Contract> contracts = TestDataFactory.returnContracts(1, 'Pricing_contract', testUser.Id, accounts1);
        contracts.get(0).StartDate = Date.today();
        contracts.get(0).Status = 'Draft';
        contracts.get(0).Revenue_forecast__c = 10000;
        contracts.get(0).Sales_Correction__c = true;
        Test.startTest();
        insert contracts;
        Test.stopTest();
        //System.assertEquals(Date.today(), [SELECT Id, Contract_End_Date__c FROM Contract LIMIT 1].Contract_End_Date__c);
    }
    @isTest
    private static void testUpdateContractSalesOnEnd() {
        User testUser = [SELECT Id FROM User WHERE Alias = 'test1'];
        List<Account> accounts1 = TestDataFactory.createAccounts(1, 'Geographical_Account', testUser.Id);
        List<Contract> contracts = TestDataFactory.returnContracts(1, 'Pricing_contract', testUser.Id, accounts1);
        contracts.get(0).Contract_End_Date__c = Date.today();
        contracts.get(0).Revenue_forecast__c = 10000;
        contracts.get(0).Sales_Correction__c = true;
        Test.startTest();
        insert contracts;
        Test.stopTest();
    }
}