/*----------------------------------------------------------------------------------------
Author:         Nihad Aoussar (Salesforce) 20211020
Description:    test class for the AccountPlanTriggerHandler class
History:        
20211111        creation
----------------------------------------------------------------------------------------*/
@isTest
public class Test_AccountPlanTriggerHandler {

    @testSetup
    private static void setup() {
        TestDataFactory.createBypassCustomSetting();
        List<User> userList = TestDataFactory.returnUsers(1, '#System: System Administrator');
        insert userList;
        TestDataFactory.createGlobalIntegrationSettings(userList);
        TestDataFactory.createDefaultOrgLevelBypassPB();
    } 
    
    
    @isTest
    public static void insertandupdateAccPlanTest(){
        
        User testUser = [SELECT Id FROM User WHERE Alias = 'test1'];
        System.runas(testUser) {
            List<Account> accountList = TestDataFactory.returnAccounts(1, 'CIM_Account', testUser.Id);
            accountList.get(0).Country__c = 'CA';
            insert accountList;
            Test.startTest();
            List<Account_Plan__c> accountPlans = TestDataFactory.returnAccountPlans(2,accountList.get(0).Id);
            insert accountPlans;
            for(Account_Plan__c accplan : accountPlans){
                accplan.BusinessUnits__c = '';
                accplan.Year__c = '2021';
            }
            
            update accountPlans;
            Test.stopTest();
            List<Account_Plan__c> accountPlanList = [SELECT Id FROM Account_Plan__c ];
            
            System.assertEquals(2, accountPlanList.size(), '2 Account Plan has been inserted andupdated');
        }
    }
}