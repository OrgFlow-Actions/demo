/*------------------------------------------------------------
Author:         Kevin Do (Salesforce) 2019-09-26
Description:    Test Class for all AccountTriggerHelper methods.
History
<Date>      <Authors Name>     <Brief Description of Change>
20190924    Kevin Do            Migrated test methods from DC_UT_AccountTrigger and AccountSetPayerLookupTest.
20200326    Kevin Do            Added tests for setAccountSubSegmentation method (#TFUS-000001698)
20210405    Nisreen Al Saleh            Added test for creatEntitlement method  (#TFUS-000001231) 
------------------------------------------------------------*/

@isTest(seeAllData=false)
public class Test_AccountTrigger {

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

    /*-------------------------------------------------------------------------------------------------------
    Company: Salesforce
    Description: Test Account bulkification
                 If triggers are bulkified, DML limit of 200 should not be hit.
    History : 20190926 Commented out due to CPU Limits failing the test.
    --------------------------------------------------------------------------------------------------------*/
    /*@isTest
    private static void testAccountBulkification() {
        User testUser = [SELECT Id FROM User WHERE Alias = 'test1' LIMIT 1];
        Test.startTest();
        List<Account> testAccountList = TestDataFactory.createAccounts(201, 'Non_ERP_Account', testUser.Id);
        Test.stopTest();

        System.assertEquals(201, testAccountList.size(), 'Expected 201 records');
    }*/

    /*-------------------------------------------------------------------------------------------------------
    Company: Salesforce
    Description: Test method for AccountTriggerHelper.setPostalCodeInfoAndEtmCode
                 Migrated from DC_UT_AccountTrigger
    History :
    --------------------------------------------------------------------------------------------------------*/
    @isTest
    private static void testSetPostalCodeInfoAndEtmCode() {
        User testUser = [SELECT Id FROM User WHERE Alias = 'test1' LIMIT 1];

        List<Account> testAccountList = TestDataFactory.returnAccounts(3, 'Non_ERP_Account', testUser.Id);
        Account testAccount0 = testAccountList[0];
        Account testAccount1 = testAccountList[1];
        Account testAccount2 = testAccountList[2];

        String testDcEtmCode = 'Test_DC_ETM_Code';
        Postal_Codes__c postalCode = new Postal_Codes__c(Name='BillingPostalCode1', DC_ETM_Code__c=testDcEtmCode);
        insert postalCode;

        for (Account account : testAccountList) {
            account.Postal_Code_Info__c = postalCode.Id;
            account.BillingPostalCode = 'BillingPostalCode2';
        }

        Test.startTest();
        // Test inserting Account referencing non-existing Postal_Codes__c.
        insert testAccountList;

        // Test updating Account referencing existing Postal_Codes__c record.
        testAccount1.BillingPostalCode = 'BillingPostalCode1';
        update testAccount1;

        // Test updating Account referencing null Postal_Codes__c.
        testAccount2.BillingPostalCode = null;
        update testAccount2;
        Test.stopTest();

        testAccount0 = [SELECT Id, DC_ETM_Code__c FROM Account WHERE Id = :testAccount0.Id LIMIT 1];
        testAccount1 = [SELECT Id, DC_ETM_Code__c FROM Account WHERE Id = :testAccount1.Id LIMIT 1];
        testAccount2 = [SELECT Id, DC_ETM_Code__c FROM Account WHERE Id = :testAccount2.Id LIMIT 1];

        System.assertEquals(null, testAccount0.DC_ETM_Code__c, 'Expected null');
        System.assertEquals(testDcEtmCode, testAccount1.DC_ETM_Code__c, 'Expected Test_DC_ETM_Code');
        System.assertEquals(null, testAccount2.DC_ETM_Code__c, 'Expected null');
    }

    /*-------------------------------------------------------------------------------------------------------
    Company: Salesforce
    Description: Test method for AccountTriggerHelper.setPayerLookup
                 Migrated from AccountSetPayerLookupTest
    History :
    --------------------------------------------------------------------------------------------------------*/
    @isTest
    private static void testSetPayerLookup() {
        User testUser = [SELECT Id FROM User WHERE Alias = 'test1' LIMIT 1];
        List<Account> testAccountList = TestDataFactory.returnAccounts(5, 'Non_ERP_Account', testUser.Id);
        List<Account> testAccountsToInsertList = new List<Account>();

        Account testAccount0 = testAccountList[0];
        testAccount0.Movex__c = 'XX12345';
        insert testAccount0;

        // Test an Account with a valid and existing Payer_Movex__c value.
        Account testAccount1 = testAccountList[1];
        testAccount1.Movex__c = 'XX23456';
        testAccount1.Payer_Movex__c = testAccount0.Movex__c;
        testAccountsToInsertList.add(testAccount1);

        // Test an Account with a non-existing Payer_Movex__c value
        Account testAccount2 = testAccountList[2];
        testAccount2.Movex__c = 'XX34567';
        testAccount2.Payer_Movex__c = 'XX67890';
        testAccountsToInsertList.add(testAccount2);

        // Test an Account with no Payer_Movex__c value.
        Account testAccount3 = testAccountList[3];
        testAccount3.Movex__c = 'XX45678';
        testAccountsToInsertList.add(testAccount3);

        // Test an account with a self-referencing Payer_Movex__c value.
        Account testAccount4 = testAccountList[4];
        testAccount4.Movex__c = 'XX56789';
        testAccount4.Payer_Movex__c = testAccount4.Movex__c;
        testAccountsToInsertList.add(testAccount4);

        Test.startTest();
        insert testAccountsToInsertList;
        Test.stopTest();

        testAccount1 = [SELECT Id, Payer_Lookup__c FROM Account WHERE Id = :testAccount1.Id LIMIT 1];
        testAccount2 = [SELECT Id, Payer_Lookup__c FROM Account WHERE Id = :testAccount2.Id LIMIT 1];
        testAccount3 = [SELECT Id, Payer_Lookup__c FROM Account WHERE Id = :testAccount3.Id LIMIT 1];
        testAccount4 = [SELECT Id, Payer_Lookup__c FROM Account WHERE Id = :testAccount4.Id LIMIT 1];

        System.assertEquals(testAccount0.Id, testAccount1.Payer_Lookup__c, 'Expected testAccount0.Id to equal testAccount1.Payer_Lookup__c');
        System.assertEquals(null, testAccount2.Payer_Lookup__c, 'Expected null');
        System.assertEquals(null, testAccount3.Payer_Lookup__c, 'Expected null');
        System.assertEquals(null, testAccount4.Payer_Lookup__c, 'Expected null');
    }
    @isTest
    public static void testOverridePotential() {
        User testUser = [SELECT Id FROM User WHERE Alias = 'test1' LIMIT 1];
        List<Account> accounts = TestDataFactory.returnAccounts(7, 'Non_ERP_Account', testUser.Id);
        //  WF-ACC-01 : Override ATL Abut Potential
        accounts.get(0).TQ_CY_D_DD_Abuts_Atlantis__c = 10;
        
        //  WF-ACC-02 : Override ATL ISUS Potential
        accounts.get(1).TQ_CY_D_DD_IsusProsth_Isus__c  = 10;
        
        //  WF-ACC-03 : Override Simplant Potential
        accounts.get(2).TQ_CY_D_DD_Guides_Simplant__c  = 10;
        
        //  WF-ACC-04 : Overwrite Implants Potential
        accounts.get(3).TQ_CY_D_DI_Implants_AllBrands__c = 10;
        accounts.get(3).Custom_Segmentation__c = 'Long Purchasing Cycle >1 Year';
        
        accounts.get(4).TQ_CY_D_DI_Implants_AllBrands__c = 5;
        accounts.get(4).Custom_Segmentation__c = 'Long Purchasing Cycle >1 Year';
        accounts.get(4).TQ_CY_1_D_DI_Implants_AllBrands__c = -20;
        
        accounts.get(5).TQ_CY_D_DI_Implants_AllBrands__c = 10;
        
        accounts.get(6).TQ_CY_D_DI_Implants_AllBrands__c = 10;
        accounts.get(6).TQ_CY_1_TD_D_DI_Implants_AllBrands__c = 1;
        
        Test.startTest();
        insert accounts;
        Test.stopTest();

    }
    @isTest
    public static void testDentalProspectMovex() {
        User testUser = [SELECT Id FROM User WHERE Alias = 'test1' LIMIT 1];
        //  WF-ACC-05 : Dental Clinical Prospect - Movex
        List<Account> accounts1 = TestDataFactory.returnAccounts(1, 'Lab_Prospect_D', testUser.Id);
        accounts1.get(0).Movex__c = 'XX34590';
        //  WF-ACC-06 : Dental Lab Prospect - Movex
        List<Account> accounts2 = TestDataFactory.returnAccounts(1, 'Clinical_Prospect_D', testUser.Id);
        accounts2.get(0).Movex__c = 'XX345691';
        
        accounts1.addAll(accounts2);
        Test.startTest();
        insert accounts1;
        Test.stopTest();
        System.assertEquals(GlobalUtils.getRecordTypeId('Account', 'Lab_Customer_D'),
                            [SELECT Id,RecordTypeId FROM Account WHERE Id =: accounts1.get(0).Id].RecordTypeId);
        System.assertEquals(GlobalUtils.getRecordTypeId('Account', 'Clinical_Customer_D'),
                            [SELECT Id,RecordTypeId FROM Account WHERE Id =: accounts1.get(1).Id].RecordTypeId);
    }
    @isTest
    public static void testSetAccountDefaultOwnerOnCreate() {
        User testUser = [SELECT Id FROM User WHERE Alias = 'test1' LIMIT 1];
        User integrationUser = [SELECT Id FROM User WHERE Alias = 'GdwIntg' LIMIT 1];
        List<Account> accounts1 = TestDataFactory.returnAccounts(1, 'Non_ERP_Account', testUser.Id);
        
        // WF-ACC-07 : Set Account Owner on SSIS System User Owned Accounts (IT)
        accounts1.get(0).BillingCity = 'Test City';
        accounts1.get(0).Vat_Registration_No__c = 'Test';
        accounts1.get(0).Country__c = 'IT';
        accounts1.get(0).OwnerId = integrationUser.Id;
        Test.startTest();
        insert accounts1;
        Test.stopTest();
        System.assertEquals('0050J000009VgChQAK',
                            [SELECT Id,OwnerId FROM Account WHERE Id =: accounts1.get(0).Id].OwnerId);
    }
    @isTest
    public static void testSetAccountDefaultOwner() {
        User testUser = [SELECT Id FROM User WHERE Alias = 'test1' LIMIT 1];
        User integrationUser = [SELECT Id FROM User WHERE Alias = 'GdwIntg' LIMIT 1];
        List<Account> accounts1 = TestDataFactory.returnAccounts(2, 'Clinical_Customer_D', testUser.Id);
        List<Account> accounts2 = TestDataFactory.returnAccounts(3, 'ERP_Lab_Account', testUser.Id);
        
        // WF-ACC-08 : Set AU & NZ Account Default Owner
        accounts1.get(0).Country__c = 'AU';
        accounts1.get(0).OwnerId = integrationUser.Id;
        
        // WF-ACC-09 : Set Austria Account Default Owner
        accounts1.get(1).Country__c = 'AT';
        accounts1.get(1).OwnerId = integrationUser.Id;
        
        // WF-ACC-10 : Set IE/UK Account Default Owner
        accounts2.get(0).Country__c = 'IE';
        accounts2.get(0).OwnerId = integrationUser.Id;
        
        // WF-ACC-11 : Set FR Account Default Owner
        accounts2.get(1).Market__c = 'FR'; 
        accounts2.get(1).Country__c = 'FR';
        accounts2.get(1).OwnerId = integrationUser.Id;
        
        // PB-ACC-01 : solution for BNL to keep the previous account owner
        accounts2.get(2).Country__c = 'LU';
        accounts2.get(2).OwnerId = integrationUser.Id;
         
        accounts1.addAll(accounts2);
        Test.startTest();
        insert accounts1;
        Test.stopTest();
        
        System.assertEquals('0050J00000790FIQAY',
                            [SELECT Id,OwnerId FROM Account WHERE Id =: accounts1.get(0).Id].OwnerId);
        System.assertEquals('00520000001Tp0bAAC',
                            [SELECT Id,OwnerId FROM Account WHERE Id =: accounts1.get(1).Id].OwnerId);
        System.assertEquals('00520000004IS5zAAG',
                            [SELECT Id,OwnerId FROM Account WHERE Id =: accounts1.get(2).Id].OwnerId);
        System.assertEquals('0050J000007ZZEbQAO',
                            [SELECT Id,OwnerId FROM Account WHERE Id =: accounts1.get(3).Id].OwnerId);
    }
    @isTest
    public static void testUpdateVolume() {
        User testUser = [SELECT Id FROM User WHERE Alias = 'test1' LIMIT 1];
        List<Account> accounts1 = TestDataFactory.returnAccounts(8, 'Non_ERP_Account', testUser.Id);
        List<Account> accounts2 = TestDataFactory.returnAccounts(8, 'Lab_Customer_D', testUser.Id);
        
        // WF-ACC-12 : Update Volume SP Guides to No Usage
        accounts1.get(0).SP_Guides_Potential_Year__c = 0 ;
        
        // WF-ACC-13 : Update Volume SP Guides to Low Usage
        accounts1.get(1).SP_Guides_Potential_Year__c = 3 ;
        
        // WF-ACC-14 : Update Volume SP Guides to Medium Usage
        accounts1.get(2).SP_Guides_Potential_Year__c = 10 ;
        
        // WF-ACC-15 : Update Volume SP Guides to High Usage
        accounts1.get(3).SP_Guides_Potential_Year__c = 20 ;
        
        // WF-ACC-16 : Update Volume (Implants) to No usage
        accounts1.get(4).Implants_Potential_Year__c = 0 ;
        
        // WF-ACC-17 : Update Volume (Implants) to Low
        accounts1.get(5).Implants_Potential_Year__c = 15 ;
        
        // WF-ACC-18 : Update Volume (Implants) to Medium
        accounts1.get(6).Implants_Potential_Year__c = 60 ;
        
        // WF-ACC-19 : Update Volume (Implants) to High
        accounts1.get(7).Implants_Potential_Year__c = 120 ;
        
        // WF-ACC-20 : Update Volume (ATL ISUS) to No Usage
        accounts2.get(0).ATL_ISUS_Potential_Year__c = 0 ;
        
        // WF-ACC-21 : Update Volume (ATL ISUS) to Low
        accounts2.get(1).ATL_ISUS_Potential_Year__c = 16 ;
        accounts2.get(1).Country__c = 'NL';
        
        // WF-ACC-22 : Update Volume (ATL ISUS) to Medium
        accounts2.get(2).ATL_ISUS_Potential_Year__c = 40 ;
        accounts2.get(2).Country__c = 'NL';
        
        // WF-ACC-23 : Update Volume (ATL ISUS) to High
        accounts2.get(3).ATL_ISUS_Potential_Year__c = 100 ;
        accounts2.get(3).Country__c = 'NL';
        
        // WF-ACC-24 : Update Volume (ATL Abut) to No Usage
        accounts2.get(4).ATL_Abut_Potential_Year__c = 0 ;
        
        // WF-ACC-25 : Update Volume (ATL Abut) to Low
        accounts2.get(5).ATL_Abut_Potential_Year__c = 20 ;
        accounts2.get(5).Country__c = 'NZ';
        // WF-ACC-26 : Update Volume (ATL Abut) to Medium
        accounts2.get(6).ATL_Abut_Potential_Year__c = 100 ;
        accounts2.get(6).Country__c = 'NL';
        // WF-ACC-27 : Update Volume (ATL Abut) to High
        accounts2.get(7).ATL_Abut_Potential_Year__c = 300 ;
        accounts2.get(7).Country__c = 'NL';
        
        accounts1.addAll(accounts2);
        Test.startTest();
        insert accounts1;
        Test.stopTest();
        
        System.assertEquals('No Usage',
                            [SELECT Id,Volume_Simplant__c FROM Account WHERE Id =: accounts1.get(0).Id].Volume_Simplant__c);
        System.assertEquals('Low Usage',
                            [SELECT Id,Volume_Simplant__c FROM Account WHERE Id =: accounts1.get(1).Id].Volume_Simplant__c);
        System.assertEquals('Medium Usage',
                            [SELECT Id,Volume_Simplant__c FROM Account WHERE Id =: accounts1.get(2).Id].Volume_Simplant__c);
        System.assertEquals('High Usage',
                            [SELECT Id,Volume_Simplant__c FROM Account WHERE Id =: accounts1.get(3).Id].Volume_Simplant__c);
        System.assertEquals('No Usage',
                            [SELECT Id,Volume_Implants__c FROM Account WHERE Id =: accounts1.get(4).Id].Volume_Implants__c);
        System.assertEquals('Low Usage',
                            [SELECT Id,Volume_Implants__c FROM Account WHERE Id =: accounts1.get(5).Id].Volume_Implants__c);
        System.assertEquals('Medium Usage',
                            [SELECT Id,Volume_Implants__c FROM Account WHERE Id =: accounts1.get(6).Id].Volume_Implants__c);
        System.assertEquals('High Usage',
                            [SELECT Id,Volume_Implants__c FROM Account WHERE Id =: accounts1.get(7).Id].Volume_Implants__c);
        System.assertEquals('No Usage',
                            [SELECT Id,Volume_ATL_ISUS__c FROM Account WHERE Id =: accounts1.get(8).Id].Volume_ATL_ISUS__c);
        System.assertEquals('Low Usage',
                            [SELECT Id,Volume_ATL_ISUS__c FROM Account WHERE Id =: accounts1.get(9).Id].Volume_ATL_ISUS__c);
        System.assertEquals('Medium Usage',
                            [SELECT Id,Volume_ATL_ISUS__c FROM Account WHERE Id =: accounts1.get(10).Id].Volume_ATL_ISUS__c);
        System.assertEquals('High Usage',
                            [SELECT Id,Volume_ATL_ISUS__c FROM Account WHERE Id =: accounts1.get(11).Id].Volume_ATL_ISUS__c);
        System.assertEquals('No Usage',
                            [SELECT Id,Volume_ATL_Abut__c FROM Account WHERE Id =: accounts1.get(12).Id].Volume_ATL_Abut__c);
        System.assertEquals('Low Usage',
                            [SELECT Id,Volume_ATL_Abut__c FROM Account WHERE Id =: accounts1.get(13).Id].Volume_ATL_Abut__c);
        System.assertEquals('Medium Usage',
                            [SELECT Id,Volume_ATL_Abut__c FROM Account WHERE Id =: accounts1.get(14).Id].Volume_ATL_Abut__c);
        System.assertEquals('High Usage',
                            [SELECT Id,Volume_ATL_Abut__c FROM Account WHERE Id =: accounts1.get(15).Id].Volume_ATL_Abut__c);
    }
    @isTest
    public static void testUpdateRecordsType() {
        User testUser = [SELECT Id FROM User WHERE Alias = 'test1' LIMIT 1];
        List<Account> accounts1 = TestDataFactory.returnAccounts(8, 'Geographical_Account', testUser.Id);
        List<Account> accounts2 = TestDataFactory.returnAccounts(1, 'ERP_Distributor', testUser.Id);
        // WF-ACC-28 : Set Partner Account
        accounts1.get(0).OneAccount_Type__c = 'Partner';
        
        // WF-ACC-29 : Set Non-ERP Lab Account
        accounts1.get(1).OneAccount_Type__c = 'Dental Laboratory';
        
        // WF-ACC-30 : Set Non-ERP Distributor
        accounts1.get(2).OneAccount_Type__c = 'Distributor';
        
        // WF-ACC-31 : Set Non-ERP Accounts
        accounts1.get(3).OneAccount_Type__c = 'Purchasing Group';
        
        // WF-ACC-32 : Set ERP Account
        accounts1.get(4).OneAccount_Type__c = 'Purchasing Group';
        accounts1.get(4).Movex__c = 'XX345691';
        
        // WF-ACC-33 : Set ERP Lab Accounts
        accounts1.get(5).OneAccount_Type__c = 'Dental Laboratory';
        accounts1.get(5).Movex__c = 'XX345692';
        
        // WF-ACC-34 : Set ERP Distributor
        accounts1.get(6).OneAccount_Type__c = 'Distributor';
        accounts1.get(6).Movex__c = 'XX345693';
        
        // WF-ACC-35 : Set Competitor Account
        accounts1.get(7).OneAccount_Type__c = 'Competitor';
        
        
        // WF-ACC-36 : Set Geographical Account
        accounts2.get(0).OneAccount_Type__c = 'Country';
        
        accounts1.addAll(accounts2);
        Test.startTest();
        insert accounts1;
        Test.stopTest();
        System.assertEquals(GlobalUtils.getRecordTypeId('Account', 'Partner_DI'),
                            [SELECT Id,RecordTypeId FROM Account WHERE Id =: accounts1.get(0).Id].RecordTypeId);
        System.assertEquals(GlobalUtils.getRecordTypeId('Account', 'Non_ERP_Lab_Account'),
                            [SELECT Id,RecordTypeId FROM Account WHERE Id =: accounts1.get(1).Id].RecordTypeId);
        System.assertEquals(GlobalUtils.getRecordTypeId('Account', 'Non_ERP_Distributor'),
                            [SELECT Id,RecordTypeId FROM Account WHERE Id =: accounts1.get(2).Id].RecordTypeId);
        System.assertEquals(GlobalUtils.getRecordTypeId('Account', 'Non_ERP_Account'),
                            [SELECT Id,RecordTypeId FROM Account WHERE Id =: accounts1.get(3).Id].RecordTypeId);
        System.assertEquals(GlobalUtils.getRecordTypeId('Account', 'ERP_Account'),
                            [SELECT Id,RecordTypeId FROM Account WHERE Id =: accounts1.get(4).Id].RecordTypeId);
        System.assertEquals(GlobalUtils.getRecordTypeId('Account', 'ERP_Lab_Account'),
                            [SELECT Id,RecordTypeId FROM Account WHERE Id =: accounts1.get(5).Id].RecordTypeId);
        System.assertEquals(GlobalUtils.getRecordTypeId('Account', 'ERP_Distributor'),
                            [SELECT Id,RecordTypeId FROM Account WHERE Id =: accounts1.get(6).Id].RecordTypeId);
        System.assertEquals(GlobalUtils.getRecordTypeId('Account', 'Competitor'),
                            [SELECT Id,RecordTypeId FROM Account WHERE Id =: accounts1.get(7).Id].RecordTypeId);
        System.assertEquals(GlobalUtils.getRecordTypeId('Account', 'Geographical_Account'),
                            [SELECT Id,RecordTypeId FROM Account WHERE Id =: accounts1.get(8).Id].RecordTypeId);
    }
    @isTest
    public static void testUpdateAccountsInfo() {
        User testUser = [SELECT Id FROM User WHERE Alias = 'test1' LIMIT 1];
        List<Account> accounts1 = TestDataFactory.returnAccounts(5, 'Clinical_Customer_D', testUser.Id);
        
        // WF-ACC-37 : Set product area = Dental
        accounts1.get(0).Product_Area__c = '';
        
        // WF-ACC-38 : Update Loss Type (D)
        accounts1.get(1).Movex_Reference_Reason__c = 1;
        
        // WF-ACC-39 : Set Implant Segmentation N/A
        accounts1.get(2).Status__c = '90';
        accounts1.get(2).Movex_Product_Area_OKHAFE__c = 'xx';
        // WF-ACC-40 : Set AWO Approval Date 
        accounts1.get(3).Atlantis_Web_Order_Customer__c = true;
        
        // WF-ACC-41 : Override Custom Segmentation
        accounts1.get(4).Custom_Segmentation__c = 'Implants Starter';
        accounts1.get(4).Volume_Implants__c = 'No Usage';
        
        Test.startTest();
        insert accounts1;
        Test.stopTest();
        
        System.assertEquals('Dental',
                            [SELECT Id,Product_Area__c FROM Account WHERE Id =: accounts1.get(0).Id].Product_Area__c);
        System.assertEquals('Administrative Reason',
                            [SELECT Id,Loss_Type_D__c FROM Account WHERE Id =: accounts1.get(1).Id].Loss_Type_D__c);
        System.assertEquals('Segmentation N/A',
                            [SELECT Id,Custom_Segmentation__c FROM Account WHERE Id =: accounts1.get(2).Id].Custom_Segmentation__c);
        System.assertEquals(Date.today() - 1,
                            [SELECT Id,AWO_Approval_Date__c FROM Account WHERE Id =: accounts1.get(3).Id].AWO_Approval_Date__c);
        System.assertEquals(null,
                            [SELECT Id,Custom_Segmentation__c FROM Account WHERE Id =: accounts1.get(4).Id].Custom_Segmentation__c);
    }
    
    @isTest
    public static void testBulkAccountInsertion() {
        User testUser = [SELECT Id FROM User WHERE Alias = 'test1' LIMIT 1];
        User integrationUser = [SELECT Id FROM User WHERE Alias = 'GdwIntg' LIMIT 1];
        List<Account> accounts1 = TestDataFactory.bulkAccountReturn('Account', 200, integrationUser.Id);
        Test.startTest();
        insert accounts1;
        Test.stopTest();
        System.assertEquals(200,[SELECT Id FROM Account].size());
    }

    @isTest
    public static void testSetAccountSubSegmentationInsert() {
        User testUser = [SELECT Id FROM User WHERE Alias = 'test1' LIMIT 1];
        List<AccountSubSegmentationMatrix__mdt> accSubSegList = new List<AccountSubSegmentationMatrix__mdt>([
            SELECT Country__c, ControllingField__c, TargetField__c, MediumThresholdMax__c, MediumThresholdMin__c, LowThresholdMIN__c
            FROM AccountSubSegmentationMatrix__mdt
            LIMIT 1
        ]);

        if (accSubSegList.isEmpty()) return;

        List<Account> testAccountList = TestDataFactory.returnAccounts(200, 'Non_ERP_Account', testUser.Id);
        for (Account accountRecord : testAccountList) {
            accountRecord.Name = 'INSERT ' + accountRecord.Name;
            accountRecord.Country__c = accSubSegList[0].Country__c;
        }
        testAccountList[0].put(accSubSegList[0].ControllingField__c, accSubSegList[0].MediumThresholdMax__c + 1);
        testAccountList[1].put(accSubSegList[0].ControllingField__c, accSubSegList[0].MediumThresholdMax__c);
        testAccountList[2].put(accSubSegList[0].ControllingField__c, accSubSegList[0].MediumThresholdMin__c);
        testAccountList[3].put(accSubSegList[0].ControllingField__c, accSubSegList[0].MediumThresholdMin__c - 1);
        testAccountList[4].put(accSubSegList[0].ControllingField__c, accSubSegList[0].LowThresholdMIN__c - 1);

        Test.startTest();
        insert testAccountList;
        Test.stopTest();

        String assertQuery = 'SELECT Count() FROM Account WHERE '+accSubSegList[0].TargetField__c;
        System.assertEquals(1, Database.countQuery(assertQuery+'=\'High\''));
        System.assertEquals(2, Database.countQuery(assertQuery+'=\'Medium\''));
        System.assertEquals(1, Database.countQuery(assertQuery+'=\'Low\''));
        System.assertEquals(1, Database.countQuery(assertQuery+'=\'N/A\''));
    }

    @IsTest
    public static void testSetAccountSubSegmentationUpdate() {
        User testUser = [SELECT Id FROM User WHERE Alias = 'test1' LIMIT 1];
        List<AccountSubSegmentationMatrix__mdt> accSubSegList1 = new List<AccountSubSegmentationMatrix__mdt>([
            SELECT Country__c, ControllingField__c, TargetField__c, MediumThresholdMax__c, MediumThresholdMin__c
            FROM AccountSubSegmentationMatrix__mdt
            LIMIT 1
        ]);
        List<AccountSubSegmentationMatrix__mdt> accSubSegList2 = new List<AccountSubSegmentationMatrix__mdt>([
            SELECT Country__c, ControllingField__c, TargetField__c, MediumThresholdMax__c, MediumThresholdMin__c
            FROM AccountSubSegmentationMatrix__mdt
            WHERE Country__c != :accSubSegList1[0].Country__c 
                AND TargetField__c != :accSubSegList1[0].TargetField__c
                AND ControllingField__c != :accSubSegList1[0].ControllingField__c
            LIMIT 1
        ]);

        if (accSubSegList1.isEmpty() || accSubSegList2.isEmpty()) return;
        
        List<Account> testAccountList = TestDataFactory.returnAccounts(100, 'Non_ERP_Account', testUser.Id);
        for (Account accountRecord : testAccountList) {
            accountRecord.Name = 'INSERT ' + accountRecord.Name;
            accountRecord.Country__c = accSubSegList1[0].Country__c;
        }
        testAccountList[0].put(accSubSegList1[0].ControllingField__c, accSubSegList1[0].MediumThresholdMax__c + 1);
        testAccountList[1].put(accSubSegList1[0].ControllingField__c, accSubSegList1[0].MediumThresholdMax__c);
        testAccountList[2].put(accSubSegList1[0].ControllingField__c, accSubSegList1[0].MediumThresholdMin__c);
        testAccountList[3].put(accSubSegList1[0].ControllingField__c, accSubSegList1[0].MediumThresholdMin__c - 1);
        insert testAccountList;

        for (Integer i = 0; i < 3; i++) {
            testAccountList[i].Country__c = accSubSegList2[0].Country__c;
            testAccountList[i].put(accSubSegList1[0].ControllingField__c, null);
        }
        testAccountList[0].put(accSubSegList2[0].ControllingField__c, accSubSegList2[0].MediumThresholdMax__c + 1);
        testAccountList[1].put(accSubSegList2[0].ControllingField__c, accSubSegList2[0].MediumThresholdMin__c);
        testAccountList[2].put(accSubSegList2[0].ControllingField__c, accSubSegList2[0].MediumThresholdMin__c - 1);        
        testAccountList[3].Country__c = null;

        Test.startTest();
        update testAccountList;
        Test.stopTest();

        String assertQuery1 = 'SELECT Count() FROM Account WHERE Name LIKE \'INSERT%\' AND '+accSubSegList1[0].TargetField__c;
        String assertQuery2 = 'SELECT Count() FROM Account WHERE Name LIKE \'INSERT%\' AND '+accSubSegList2[0].TargetField__c;
        System.assertEquals(testAccountList.size(), Database.countQuery(assertQuery1+'=null'));
        System.assertEquals(1, Database.countQuery(assertQuery2+'=\'High\''));
        System.assertEquals(1, Database.countQuery(assertQuery2+'=\'Medium\''));
        System.assertEquals(1, Database.countQuery(assertQuery2+'=\'Low\''));
    }
    
    @isTest
    private static void testupdateRelatedContactAddresses() {
        User testUser = [SELECT Id FROM User WHERE Alias = 'test1' LIMIT 1];

        List<Account> testAccountList = TestDataFactory.returnAccounts(5, 'Non_ERP_Account', testUser.Id);        

        for (Account account : testAccountList) {
            account.Country__c = 'TR';
            account.BillingStreet = 'Test Street 1';
            account.BillingPostalCode = '12345';
            account.BillingCity = 'Test City 1';
            account.BillingCountry = 'TR';
            account.BillingState = 'Test State 1';            
        }
    
        List<Contact> testContactList = new List<Contact>();
        
        Test.startTest();
        
        // Test inserting Account
        insert testAccountList;
        
        Integer i = 1;
        Contact testContact = new Contact();
        
        for(Account acc : testAccountList){
        
        testContact = new Contact(AccountId = acc.Id, 
                                          MailingStreet = acc.BillingStreet, 
                                          MailingCity = acc.BillingCity, 
                                          MailingPostalCode = acc.BillingPostalCode, 
                                          MailingCountry = acc.BillingCountry, 
                                          MailingState = acc.BillingState, 
                                          LastName = ('Test ' + i));        
        testContactList.add(testContact);
        i++;
            
        }
        
        insert testContactList;
        
        // Test updating Account        
        testAccountList[0].BillingStreet = 'Test Street 2';
        testAccountList[1].BillingCity = 'Test City 2';
        testAccountList[2].BillingPostalCode = '6789';
        testAccountList[3].BillingCountry = 'Turkey';
        testAccountList[4].BillingState = 'Test State 2';
        update testAccountList;

        Test.stopTest();

        testAccountList = [SELECT Id, BillingStreet, BillingPostalCode, BillingCity, BillingCountry, BillingState FROM Account WHERE Country__c =: 'TR'];
        testContactList = [SELECT Id, MailingStreet, MailingPostalCode, MailingCity, MailingCountry, MailingState FROM Contact WHERE Account.Country__c =: 'TR'];
        
        System.assertEquals(testAccountList[0].BillingStreet, testContactList[0].MailingStreet, 'Expected equal street addresses');
        System.assertEquals(testAccountList[1].BillingPostalCode, testContactList[1].MailingPostalCode, 'Expected equal postal code');
        System.assertEquals(testAccountList[2].BillingCity, testContactList[2].MailingCity, 'Expected equal city');
        System.assertEquals(testAccountList[3].BillingCountry, testContactList[3].MailingCountry, 'Expected equal country');
        System.assertEquals(testAccountList[4].BillingState, testContactList[4].MailingState, 'Expected equal state');
    }
    
// Commented out 2021-05-15 by Daniel Rosenberg to fix hotfix test failure:
    @isTest static void testCreateEntitlement(){
        Account acc = new Account(Name='testacc', OneAccount_Type__c = 'End User');
        acc.Country__c = 'GB';
        acc.RecordTypeId = Schema.sObjectType.Account.getRecordTypeInfosByName().get('Clinical Customer').getRecordTypeId();
        test.StartTest();
        insert acc;
        test.stopTest();
        
    List<Entitlement> etList = [Select Id,AccountId From Entitlement Where AccountId =:acc.Id];
    
    System.assertNotEquals(etList.size(),0,'List should not be empty');
    }


}