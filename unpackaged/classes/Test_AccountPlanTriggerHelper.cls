/*----------------------------------------------------------------------------------------
Author:         Nihad Aoussar (Salesforce) 20211020
Description:    test class for the AccountPlanTriggerHelper class
History:        
20211111        create setOfficesTest, setAccountPlanNameTest, checkUniquePerYearTest,createAccountPlanEstimatesTest
----------------------------------------------------------------------------------------*/
@isTest
public class Test_AccountPlanTriggerHelper {
    
    @testSetup
    public static void setup() {
        User user = TestDataFactory.createUsers(1, '#System: System Administrator')[0]; 
        System.runas(user) {
            Account currentAccount = TestDataFactory.createAccounts(1, 'CIM_Account', user.Id)[0];
            
    		Account_Plan__c accountPlan = new Account_Plan__c (AccountPlanOwner__c = user.Id ,
                                                       Year__c  = '2019',
                                                       Account__c = currentAccount.Id);
    		insert accountPlan;
            Account_Plan__c accountPlan2 = new Account_Plan__c (AccountPlanOwner__c = user.Id ,
                                                       Year__c  = '2019',
                                                       Account__c = currentAccount.Id,
                                                       BusinessUnits__c = 'Endodontics');
    		insert accountPlan2;
            
            AccountPlanEstimates__c newAccountEstimates = new AccountPlanEstimates__c ( AccountPlan__c = accountPlan2.Id , 
                                                                                         BusinessUnit__c  = 'Imaging');
            insert newAccountEstimates;
        }
    }
    
    @isTest
    public static void setOfficesTest(){
    User testUser = [SELECT Id FROM User WHERE Alias = 'test1'][0];
    System.runas(testUser) {
        List<Account_Plan__c> accountPlans = [SELECT Id,Account__c,Offices__c FROM Account_Plan__c WHERE AccountPlanOwner__c=:testUser.Id];
        Test.startTest();
        	AccountPlanTriggerHelper.setOffices(accountPlans);
        Test.stopTest();
        
        System.assertEquals(0, accountPlans[0].Offices__c, 'Account has no offices');
    
    } 
    }
   
    
    @isTest
    public static void setAccountPlanNameTest(){
    User testUser = [SELECT Id FROM User WHERE Alias = 'test1'][0];
    System.runas(testUser) {
        List<Account_Plan__c> accountPlans = [SELECT Id,Year__c,Account__c,Name FROM Account_Plan__c WHERE AccountPlanOwner__c=:testUser.Id];
        Test.startTest();
        	AccountPlanTriggerHelper.setAccountPlanName(accountPlans);
        Test.stopTest();
       
        System.assertEquals('2019 Plan - TestAccount0', accountPlans[0].Name, 'Account name has changed');
    
    } 
    }
    
    
    @isTest
    public static void checkUniquePerYearTest(){
    User testUser = [SELECT Id FROM User WHERE Alias = 'test1'][0];
    System.runas(testUser) {
        List<Account_Plan__c> accountPlans = [SELECT Id,Year__c,Account__c,Name FROM Account_Plan__c WHERE AccountPlanOwner__c=:testUser.Id];
        Test.startTest();
        try{
        	AccountPlanTriggerHelper.checkUniquePerYear(accountPlans);
        }catch(Exception ex){
            Boolean expectedExceptionThrown =  ex.getMessage().contains('There can only be one Account Plan per year') ? true : false;

            System.assertEquals(expectedExceptionThrown, true);
        }
        Test.stopTest();
    }   
    }

    @isTest
    public static void createAccountPlanEstimatesTest(){
    User testUser = [SELECT Id FROM User WHERE Alias = 'test1'][0];
    System.runas(testUser) {
        List<Account_Plan__c> accountPlans = [SELECT Id,BusinessUnits__c FROM Account_Plan__c WHERE AccountPlanOwner__c=:testUser.Id];
        Test.startTest();
        	AccountPlanTriggerHelper.createAccountPlanEstimates(accountPlans);
        Test.stopTest();
        set<Id> accountPlanIds = new set<Id>();
        for(Account_Plan__c accplan : accountPlans){
            accountPlanIds.add(accplan.Id);
        }
        
        List<AccountPlanEstimates__c> accEstimates = [ SELECT Id,AccountPlan__c 
                                                  FROM AccountPlanEstimates__c 
                                                  WHERE  AccountPlan__c IN: accountPlanIds];
        System.assertEquals(2, accEstimates.size(), 'Only one target line will be added');
    
    } 
    }
}