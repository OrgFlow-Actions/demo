/*------------------------------------------------------------
Author: 		Kevin Do (Salesforce) 2020-01-17
Description:   	Test Class for all ContractTriggerHelper methods.
History
<Date>      <Authors Name>     <Brief Description of Change>
20200117 	Kevin Do			Created Class
------------------------------------------------------------*/

@isTest(seeAllData=false)
public class Test_ContractTrigger {
    public static final Boolean RUN_TRIGGERS = true;
    public static final Boolean RUN_PROCESS_BUILDER = false;

    @TestSetup
    static void setup() {
        TestDataFactory.createBypassCustomSetting(RUN_TRIGGERS, RUN_PROCESS_BUILDER);
        List<User> userList = TestDataFactory.createUsers(1, 'System Administrator');
        List<User> userIntegrationList = TestDataFactory.insertIntegrationUsers(1, 'System Administrator');
        TestDataFactory.createGlobalIntegrationSettings(userIntegrationList);
        List<Discount_model__c> discountModelList = TestDataFactory.createDiscountModels(1, userList[0].Id);
        TestDataFactory.createDEDiscountModelCustomSetting(discountModelList[0]);
        TestDataFactory.createDiscountRows(discountModelList[0].Id);
		
        BatchSettings__c batchSetting = new BatchSettings__c();
        batchSetting.DisableContractTriggerHelperUpdSales__c = false;
        batchSetting.Name = 'Default';
        insert batchSetting;
        
        
    }

    @IsTest
    private static void testSetup() {
        Test.startTest();
        List<User> testUserList = [SELECT Id FROM User WHERE Alias = 'test1'];
        Test.stopTest();
        
        System.assertEquals(1, testUserList.size(), 'Expected one user');
    }

    /*-------------------------------------------------------------------------------------------------------
    Company: Salesforce
    Description: Test method for ContractTriggerHelper.updateSalesHistory()
                 Asserts that contract fields are set with correct values from Account before insert.
    History :
    --------------------------------------------------------------------------------------------------------*/
    @IsTest
    private static void testUpdateSalesHistory() {
        User testUser = [SELECT Id FROM User WHERE Alias = 'test1' LIMIT 1];
        List<Account> testAccountList = TestDataFactory.returnAccounts(3, 'Lab_Customer_D', testUser.Id);
        Account testAccount0 = testAccountList[0];
        testAccount0.Country__c = 'DE';
        // Fields needed for Account.Sales_L12MD__c formula field
        testAccount0.TS_CY_D_AllPLs_AllPCs_AllBrands__c = 1000;
        testAccount0.TS_CY_1_D_AllPLs_AllPCs_AllBrands__c = 2000;
        testAccount0.TS_CY_1_TD_D_AllPLs_AllPCs_AllBrands__c = 100;
        // Fields needed for Account.Sold_Implants_L12M__c formula field
        testAccount0.TQ_CY_1_D_DI_Implants_AllBrands__c = 1000;
        testAccount0.TQ_CY_1_TD_D_DI_Implants_AllBrands__c = 100;
        testAccount0.TQ_CY_D_DI_Implants_AllBrands__c = 2000;
        // Fields needed for Account.Sales_L13_24M_D__c formula field
        testAccount0.TS_CY_2_D_AllPLs_AllPCs_AllBrands__c = 1000;
        testAccount0.TS_CY_2_TD_D_AllPLs_AllPCs_AllBrands__c = 100;
        insert testAccountList;
        Id testAccountId = testAccount0.Id;

        Account accountToAssert = [
            SELECT Id, Sales_L12M_D__c, Sold_Implants_L12M__c, Sales_L13_24M_D__c 
            FROM Account
            WHERE Id = :testAccountId
            LIMIT 1
        ];

        // Insert one Contract that should be referenced in Contract.Previous_contract__c
        Contract initialContract = new Contract();
        initialContract.RecordTypeId = GlobalUtils.getRecordTypeId('Contract', 'Pricing_contract');
        initialContract.StartDate = Date.today();
        initialContract.Status = 'Draft';
        initialContract.Contract_length__c = '12';
        initialContract.AccountId = testAccount0.Id;
        initialContract.Implant_commitment_perc_input__c = '100';
        initialContract.General_practitioner__c = false;
        insert initialContract;

        List<Contract> insertContractList = new List<Contract>();
        Map<Id, Contract> testContractMap = new Map<Id, Contract>();
        for (Integer i = 0; i < 20; i++) {
            Contract testContract = new Contract();
            testContract.RecordTypeId = GlobalUtils.getRecordTypeId('Contract', 'Pricing_contract');
            testContract.StartDate = Date.today();
            testContract.Status = 'Draft';
            testContract.Contract_length__c = '12';
            testContract.AccountId = testAccount0.Id;
            testContract.Implant_commitment_perc_input__c = '100';
            testContract.General_practitioner__c = false;
            insertContractList.add(testContract);
        }
        
        Test.startTest();
        insert insertContractList;
        Test.stopTest();
        
        List<Contract> testContractList = [
            SELECT Id, Sales_L12M__c, Implant_volume_L12M__c, Sales_L24M__c, Implant_commitment_perc_input__c, Abutment_commitment__c, Pooled_order_commitment__c
            FROM Contract
            WHERE CreatedById = :testUser.Id
        ];

        for (Contract testContract : testContractList) {
            System.assertEquals(accountToAssert.Sales_L12M_D__c, testContract.Sales_L12M__c);
            System.assertEquals(accountToAssert.Sold_Implants_L12M__c, testContract.Implant_volume_L12M__c);
            System.assertEquals(accountToAssert.Sales_L12M_D__c + accountToAssert.Sales_L13_24M_D__c, testContract.Sales_L24M__c);
            System.assertEquals(initialContract.Id, testContract.Previous_contract__c);
        }
    }

    /*-------------------------------------------------------------------------------------------------------
    Company: Salesforce
    Description: Test method for ContractTriggerHelper.updateSalesHistory()
                 Asserts that contract discount is set according to discount rows
    History :
    --------------------------------------------------------------------------------------------------------*/
    @IsTest
    private static void testUpdateAllowedDiscount() {
        User testUser = [SELECT Id FROM User WHERE Alias = 'test1' LIMIT 1];
        List<Discount_model__c> testDiscountModelList = [SELECT Id FROM Discount_model__c WHERE OwnerId = :testUser.Id LIMIT 1];
        Id testDiscountModelId = testDiscountModelList[0].Id;
        List<Account> testAccountList = TestDataFactory.returnAccounts(3, 'Lab_Customer_D', testUser.Id);
        Account testAccount0 = testAccountList[0];
        testAccount0.Country__c = 'DE';
        // Fields needed for Account.Sales_L12MD__c formula field
        testAccount0.TS_CY_D_AllPLs_AllPCs_AllBrands__c = 1000;
        testAccount0.TS_CY_1_D_AllPLs_AllPCs_AllBrands__c = 2000;
        testAccount0.TS_CY_1_TD_D_AllPLs_AllPCs_AllBrands__c = 100;
        // Fields needed for Account.Sold_Implants_L12M__c formula field
        testAccount0.TQ_CY_1_D_DI_Implants_AllBrands__c = 1000;
        testAccount0.TQ_CY_1_TD_D_DI_Implants_AllBrands__c = 100;
        testAccount0.TQ_CY_D_DI_Implants_AllBrands__c = 2000;
        // Fields needed for Account.Sales_L13_24M_D__c formula field
        testAccount0.TS_CY_2_D_AllPLs_AllPCs_AllBrands__c = 1000;
        testAccount0.TS_CY_2_TD_D_AllPLs_AllPCs_AllBrands__c = 100;
        // Payment_Terms_D_JP__C referenced as is by Contract.Payment_terms__c 
        testAccount0.Payment_Terms_D_JP__c = 'LOW';
        insert testAccountList;
        Id testAccountId = testAccount0.Id;

        Account accountToAssert = [
            SELECT Id, Sales_L12M_D__c, Sold_Implants_L12M__c, Sales_L13_24M_D__c 
            FROM Account
            WHERE Id = :testAccountId
            LIMIT 1
        ];

        List<Contract> insertContractList = new List<Contract>();
        Map<Id, Contract> testContractMap = new Map<Id, Contract>();
        for (Integer i = 0; i < 20; i++) {
            Contract testContract = new Contract();
            testContract.RecordTypeId = GlobalUtils.getRecordTypeId('Contract', 'Pricing_contract');
            testContract.StartDate = Date.today();
            testContract.Status = 'Draft';
            testContract.Contract_length__c = '12';
            testContract.AccountId = testAccount0.Id;
            testContract.Implant_commitment_perc_input__c = '100';
            testContract.General_practitioner__c = false;
            testContract.Discount_model__c = testDiscountModelId;
            insertContractList.add(testContract);
        }
        
        Test.startTest();
        insert insertContractList;
        Test.stopTest();

        List<Contract> testContractList = [
            SELECT Id, Sales_L12M__c, Implant_volume_L12M__c, Sales_L24M__c, Implant_commitment_perc_input__c, Abutment_commitment__c, Pooled_order_commitment__c
            FROM Contract
            WHERE CreatedById = :testUser.Id
        ];

        for (Contract testContract : testContractList) {
            System.assertEquals(1, testContract.Allowed_discount_revenue_materials__c);
            System.assertEquals(1, testContract.Allowed_discount_revenue_equipments__c);
            System.assertEquals(1, testContract.Allowed_discount_Implants_materials__c);
            System.assertEquals(1, testContract.Allowed_discount_Implants_equipment__c);
            System.assertEquals(1, testContract.Allowed_discount_abutment_materials__c);
            System.assertEquals(1, testContract.Allowed_discount_abutment_equipment__c);
            System.assertEquals(1, testContract.Allowed_discount_pooling_materials__c);
            System.assertEquals(1, testContract.Allowed_discount_pooling_equipment__c);
            System.assertEquals(null, testContract.Payment_discount__c);
        }
    }  

}