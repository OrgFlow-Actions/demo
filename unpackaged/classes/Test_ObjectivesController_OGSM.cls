/*-------------------------------------------------------------------------------------------------------
Author:         Nihad Aoussar (Salesforce) 20211020
Description:    test class for the ObjectivesController_OGSM class
History:        
20211025        create fetchObjectives, updateObjectives, deleteObjective
----------------------------------------------------------------------------------------*/
@isTest
public with sharing class Test_ObjectivesController_OGSM {
    @testSetup
    public static void setup() {
        User user = TestDataFactory.createUsers(1, '#System: System Administrator')[0]; 
        System.runas(user) {
            Account currentAccount = TestDataFactory.createAccounts(1, 'CIM_Account', user.Id)[0];
            
    		Account_Plan__c accountPlan = new Account_Plan__c (AccountPlanOwner__c = user.Id ,
                                                       Year__c  = '2019',
                                                       Account__c = currentAccount.Id);
    		insert accountPlan;
        }
    }
    @isTest
    public static void fetchObjectivesByAccountPlanIdTest() {
    User testUser = [SELECT Id FROM User WHERE Alias = 'test1'][0];
    System.runas(testUser) {
        Account_Plan__c accountPlan = [SELECT Id FROM Account_Plan__c WHERE AccountPlanOwner__c=:testUser.Id];
        Objective__c objective = TestDataFactory.createObjective(1,accountPlan.Id)[0];
        Test.startTest();
        	List<Objective__c> objectives = ObjectivesController_OGSM.fetchObjectives(accountPlan.Id);
        Test.stopTest();
        System.assertEquals(objectives.size(), 1, 'one objective exist for this account plan');
    
    }    
    }

    @isTest
    public static void updateObjectivesTest() {
    User testUser = [SELECT Id FROM User WHERE Alias = 'test1'][0];
    System.runas(testUser) {
        Account_Plan__c accountPlan = [SELECT Id FROM Account_Plan__c WHERE AccountPlanOwner__c=:testUser.Id];
		List<Objective__c> objective = TestDataFactory.createObjective(1,accountPlan.Id);
  		objective[0].Initiatives__c = 'initiative updated';
        Test.startTest();
            ObjectivesController_OGSM.updateObjectives(objective);
            List<Objective__c> objectives = [ SELECT id, Name , Initiatives__c from Objective__c where AccountPlan__c=:accountPlan.Id]; 
        Test.stopTest();
    	System.assertEquals(objectives[0].Initiatives__c,'initiative updated', 'initiative value has been updated');
    }
    }

    @isTest
    public static void updateEmptyObjectivesTest() {
    User testUser = [SELECT Id FROM User WHERE Alias = 'test1'][0];
    System.runas(testUser) {
        Test.startTest();
        try{
            ObjectivesController_OGSM.updateObjectives(null);
            } 
        catch (AuraHandledException ex) {
            System.assertEquals('Script-thrown exception', ex.getMessage());
        } 
        Test.stopTest();
    }
    }

    @isTest
    public static void deleteObjectivesTest() {
    User testUser = [SELECT Id FROM User WHERE Alias = 'test1'][0];
    System.runas(testUser) {
        Account_Plan__c accountPlan = [SELECT Id FROM Account_Plan__c WHERE AccountPlanOwner__c=:testUser.Id];
		List<Objective__c> objective = TestDataFactory.createObjective(2,accountPlan.Id);
  		
        Test.startTest();
            ObjectivesController_OGSM.deleteObjective(objective[0].Id);
            List<Objective__c> objectives = [ SELECT id, Name FROM Objective__c WHERE AccountPlan__c=:accountPlan.Id]; 
        Test.stopTest();
    System.assertEquals(objectives.size(), 1, 'only one objective exist for this account plan After deletion');
    }
    }

    @isTest
    public static void deleteEmptyObjectiveTest() {
    User testUser = [SELECT Id FROM User WHERE Alias = 'test1'][0];
    System.runas(testUser) {
    	Test.startTest();
        try{
            ObjectivesController_OGSM.deleteObjective(Id.valueOf('a6Y8Y000000odO4UAI'));
        } catch (AuraHandledException ex) {
            System.assertEquals('Script-thrown exception', ex.getMessage());
        } 
        Test.stopTest();
    }
    }
}