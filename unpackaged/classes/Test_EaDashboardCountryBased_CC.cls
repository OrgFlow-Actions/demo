/*------------------------------------------------------------
Author: 		Ahmed LOUDRASSI (Salesforce) 2019-11-27
Description:   	Test Class for the EaDashboardCountryBased_CC Controller.
History
<Date>      <Authors Name>     <Brief Description of Change>
12092019	Miguel				Added GDW Integration User creation into the setup method
------------------------------------------------------------*/

@isTest(seeAllData=false)
public class Test_EaDashboardCountryBased_CC {
	@testSetup
    private static void setup() {
        TestDataFactory.createBypassCustomSetting();
        List<User> userList = TestDataFactory.returnUsers(1, 'System Administrator');
        userList.get(0).User_Country__c = 'Germany';
        insert userList;
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
    private static void testGetHomeDashboardName() {
        Test.startTest();
        System.assertEquals(true, EaDashboardCountryBased_CC.getHomeDashboardName('HomeOutsideSalesDashboard__c', 'HomeOutsideSalesDashboardFilter__c') != null);
        User testUser = [SELECT Id FROM User WHERE Alias = 'test1'];
        System.runAs(testUser) {
            System.assertEquals(true, EaDashboardCountryBased_CC.getHomeDashboardName('HomeOutsideSalesDashboard__c', 'HomeOutsideSalesDashboardFilter__c') != null);
        }
        System.assertEquals(null, EaDashboardCountryBased_CC.getHomeDashboardName('wrongName', 'wrongName'));
        Test.stopTest();
    }
    @isTest
    private static void testGetSObjectDashboardName() {
        User testUser = [SELECT Id FROM User WHERE Alias = 'test1'];
        List<Account> accountList = TestDataFactory.returnAccounts(2, 'Non_ERP_Account', testUser.Id);
        accountList.get(0).Country__c = 'DE';
        accountList.get(1).Country__c = 'FR';
        insert accountList;
        Test.startTest();
        System.assertEquals(true,
                            EaDashboardCountryBased_CC.getSObjectDashboardName('AccountInsideSalesDashboard__c','AccountInsideSalesDashboardFilter__c', accountList.get(0).Id, 'Country__c') != null);
        System.assertEquals(true,  
                            EaDashboardCountryBased_CC.getSObjectDashboardName('AccountInsideSalesDashboard__c','AccountInsideSalesDashboardFilter__c', accountList.get(1).Id, 'Country__c') != null);
        System.assertEquals(null,  
                            EaDashboardCountryBased_CC.getSObjectDashboardName('WrongName', 'WrongName', accountList.get(0).Id, 'Country__c'));
        Test.stopTest();
    }
    @isTest
    private static void testGetSObjectDashboardNameWithFilterField() {
        User testUser = [SELECT Id FROM User WHERE Alias = 'test1'];
        List<Account> accountList = TestDataFactory.returnAccounts(1, 'Non_ERP_Account', testUser.Id);
        accountList.get(0).Country__c = 'CA';
        insert accountList;
        Account_Plan__c accountPlan = new Account_Plan__c(Account__c = accountList.get(0).Id, Start_Date__c = system.today());
        insert accountPlan;
        Test.startTest();
        System.assertEquals(true,
                            EaDashboardCountryBased_CC.getSObjectDashboardName('AccountPlanDashboard__c','AccountPlanFilter__c', accountPlan.Id, 'account__r.Country__c') != null);
        Test.stopTest();
    }
}