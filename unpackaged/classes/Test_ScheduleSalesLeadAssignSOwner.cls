/**
 * @description       : Test class for ScheduleSalesLeadAssignSOwner
 * @author            : kdoruibin@salesforce.com
 * @group             : 
 * @last modified on  : 06-21-2021
 * @last modified by  : kdoruibin@salesforce.com
 * Modifications Log 
 * Ver   Date         Author                     Modification
 * 1.0   06-21-2021   kdoruibin@salesforce.com   Initial Version
**/
@isTest
public without sharing class Test_ScheduleSalesLeadAssignSOwner {
    
    public static String CRON_EXP = '0 0 0 15 3 ? 2022';

    @testSetup
    private static void setup() {
        Map<String,List<String>> dependentPicklistSalesLeadCountryCategoryMap =  GlobalUtils.getDependentPicklistValues(Field_Sales_Project_Members__c.Category__c);
        Map<String,List<String>> dependentPicklistSalesLeadCategoryBrandMap = GlobalUtils.getDependentPicklistValues(Field_Sales_Project_Members__c.Brand__c);
        TestDataFactory.createBypassCustomSetting();
        List<User> userList = TestDataFactory.returnUsers(1, 'System Administrator');
        userList[0].User_Country__c = 'USA';
        insert userList;
        List<User> userIntegrationList = TestDataFactory.insertIntegrationUsers(1, 'System Administrator');
        TestDataFactory.createGlobalIntegrationSettings(userIntegrationList);
        List<Account> accountList = TestDataFactory.returnAccounts(1, 'Non_ERP_Account', userList[0].Id);
        for (Account accountRecord : accountList) {
            accountRecord.Name = 'INSERT ' + accountRecord.Name;
            accountRecord.Country__c = 'US';
            accountRecord.BillingStreet = ' 590 Lincoln Street';
            accountRecord.BillingCity = 'Waltham';
            accountRecord.BillingState = 'MA';
            accountRecord.BillingPostalCode = '02541';
            accountRecord.BillingCountry = 'USA';
            accountRecord.ShippingStreet = ' 590 Lincoln Street';
            accountRecord.ShippingCity = 'Waltham';
            accountRecord.ShippingState = 'MA';
            accountRecord.ShippingPostalCode = '02541';
            accountRecord.ShippingCountry = 'USA';
        }
        insert accountList;

        User testUser = userList[0];
        Account testAccount = accountList[0];

        // Get LeadOpportunitySetting__mdt to configure Sales Leads
        List<LeadOpportunitySetting__mdt> testSettingList = [
            SELECT Id, Country__c, Category__c, AssignOwnerFrom__c, UserRoles__c, Brands__c 
            FROM LeadOpportunitySetting__mdt
            WHERE Country__c = 'US' AND Category__c != null AND UserRoles__c != null AND Brands__c != null
        ];

        // Create one user per setting to be assigned a specific user role in the territory
        List<User> territoryUserList = TestDataFactory.createUsers(testSettingList.size(), 'Lightning Sales Rep');
        
        // Associate the testAccount with an existing territory
        Territory2 testTerritory = [SELECT Id FROM Territory2 WHERE CurrencyIsoCode = 'USD' AND Territory_Level__c = 'Sales Rep' LIMIT 1];
        ObjectTerritory2Association accountTerritoryAssociation = new ObjectTerritory2Association(
            Territory2Id = testTerritory.Id
            , AssociationCause = 'Territory2Manual'
            , ObjectId = testAccount.Id
        );
        insert accountTerritoryAssociation;

        // Get correct picklistvalues
        Schema.DescribeFieldResult fieldResult = Field_Sales_Project_Members__c.Brand__c.getDescribe();
        // List<Schema.PicklistEntry> picklistEntryList = fieldResult.getPicklistValues();
        Map<String, String> brandPicklistLabelValueMap = new Map<String, String>();
        for (Schema.PicklistEntry picklistEntry : fieldResult.getPicklistValues()) {
            brandPicklistLabelValueMap.put(picklistEntry.getLabel(), picklistEntry.getValue());
        }

        // Create sales leads and user assignments based on LeadOpportunitySetting__mdt
        List<Field_Sales_Project_Members__c> testLeadList = new List<Field_Sales_Project_Members__c>();
        Map<String, UserTerritory2Association> userTerritoryMap = new Map<String, UserTerritory2Association>();
        Integer loopCount = 0;
        for (LeadOpportunitySetting__mdt testSetting : testSettingList) {
            String picklistBrandValue = brandPicklistLabelValueMap.get(testSetting.Brands__c?.split(';')[0].trim());
            String userRoleValue = testSetting.UserRoles__c?.split(';')[0].trim();
            if (picklistBrandValue == null) continue;
            if (userRoleValue == null) continue;

            Field_Sales_Project_Members__c testLead = new Field_Sales_Project_Members__c(
                Status__c = 'New'
                , Account__c = testAccount?.Id
                , Source__c = 'Email Campaign'
                //, Category__c = GlobalUtils.getCategoryFromBrand('USA' , picklistBrandValue, Field_Sales_Project_Members__c.Category__c,Field_Sales_Project_Members__c.Brand__c) //testSetting?.Category__c
                , Category__c = GlobalUtils.getCategoryFromBrand('USA',picklistBrandValue,dependentPicklistSalesLeadCountryCategoryMap,dependentPicklistSalesLeadCategoryBrandMap)
                , Brand__c = picklistBrandValue
            );
            testLeadList.add(testLead);

            UserTerritory2Association userTerritoryAssociation = new UserTerritory2Association(
                UserId = territoryUserList[loopCount].Id
                , Territory2Id = testTerritory.Id
                , RoleInTerritory2 = userRoleValue
            );
            userTerritoryMap.put(userRoleValue, userTerritoryAssociation);

            loopCount++;
        }

        System.runAs(testUser) {
            insert testLeadList;
            insert userTerritoryMap.values();
        }
    }

    @isTest
    private static void testSetup() {
        System.assertEquals(1, [SELECT Count() FROM Account WHERE Name LIKE 'INSERT%']);
        System.assertEquals(true, [SELECT Count() FROM Field_Sales_Project_Members__c WHERE Status__c = 'New'] > 0);
    }
    
    @isTest
    public static void testScheduledJob() {

        Test.startTest();
        ScheduleSalesLeadAssignSOwner schedulesalesLeadAssignSOwner = new ScheduleSalesLeadAssignSOwner();
        String jobId = System.schedule(
            'ScheduledApexTest'
            , CRON_EXP
            , schedulesalesLeadAssignSOwner
        );
        Test.stopTest();

        // Check schedulable is in the job list
        List<AsyncApexJob> jobsScheduled = [select Id, ApexClassID, ApexClass.Name, Status, JobType from AsyncApexJob where JobType = 'ScheduledApex'];
        System.assertEquals(1, jobsScheduled.size(), 'expecting one scheduled job');
        System.assertEquals('ScheduleSalesLeadAssignSOwner', jobsScheduled[0].ApexClass.Name, 'expecting specific scheduled job: ScheduleSalesLeadAssignSOwner');

        // check apex batch is in the job list
        List<AsyncApexJob> jobsApexBatch = [select Id, ApexClassID, ApexClass.Name, Status, JobType from AsyncApexJob where JobType = 'BatchApex'];
        System.assertEquals(1, jobsApexBatch.size(), 'expecting one apex batch job');
        System.assertEquals('BatchSalesLeadAssignSuggestedOwner', jobsApexBatch[0].ApexClass.Name, 'expecting specific batch job: BatchSalesLeadAssignSuggestedOwner');
    }
}