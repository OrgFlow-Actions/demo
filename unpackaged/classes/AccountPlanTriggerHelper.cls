/**
 * @description       : AccountPlan2 trigger helper
 * @author            : kdoruibin@salesforce.com
 * @group             : 
 * @last modified on  : 11-12-2021
 * @last modified by  : naoussar@salesforce.com
**/
public with sharing class AccountPlanTriggerHelper {
	/**
    * @description Calls a recursive method to set AccountPlan__c.Offices__c based on number of children
    * @author kdoruibin@salesforce.com | 10-12-2021 
    * @param Map<Id AccountPlan2__c> newAccountPlan2List 
    **/
    public static void setOffices(List<Account_Plan__c> newAccountPlanList) {
        // Call recursive method to count ALL child accounts
        
		Map<Id, List<Account_Plan__c>> accountIdAccountPlanMap = new Map<Id, List<Account_Plan__c>>();
        for (Account_Plan__c accountPlan : newAccountPlanList) {
            if (accountIdAccountPlanMap.containsKey(accountPlan.Account__c)) {
                accountIdAccountPlanMap.get(accountPlan.Account__c).add(accountPlan);
            } else {
                accountIdAccountPlanMap.put(accountPlan.Account__c, new List<Account_Plan__c>{accountPlan});
            }
        }
		List<Account> parentAccountsList = [SELECT Id, (SELECT Id FROM ChildAccounts) FROM Account WHERE Id IN :accountIdAccountPlanMap.keySet()];
            for (Account parentAccount : parentAccountsList) {
                for (Account_Plan__c accountPlan : accountIdAccountPlanMap.get(parentAccount.Id)) {
                    accountPlan.Offices__c = parentAccount.ChildAccounts.size();
                }
            }
    }

    /**
    * @description Recursive method to count the number of child accounts
    *              !Currently not needed since we only care about direct children
    * @author kdoruibin@salesforce.com | 10-12-2021 
    * @param Set<Id> parentAccountIdSet 
    * @param Integer recordCount 
    * @return Integer 
    **/
    /*private static Integer countChildrenRecursive(Set<Id> parentAccountIdSet, Integer recordCount) {
        if (parentAccountIdSet.isEmpty()) return recordCount;

        parentAccountIdSet = new Map<Id, Account>([SELECT Id FROM Account WHERE ParentId IN :parentAccountIdSet]).keySet();
        recordCount += parentAccountIdSet.size();
        return countChildrenRecursive(parentAccountIdSet, recordCount);
    }*/

    /**
    * @description Sets the Account Plan 2 Name based on Account Name and Year
    * @author kdoruibin@salesforce.com | 10-12-2021 
    * @param List<AccountPlan2__c> newAccountPlan2List 
    **/
    public static void setAccountPlanName(List<Account_Plan__c> newAccountPlanList) {
        Set<Id> parentAccountIdSet = new Set<Id>();
        for (Account_Plan__c accountPlan : newAccountPlanList) {
            parentAccountIdSet.add(accountPlan.Account__c);
        }

        Map<Id, Account> parentAccountMap = new Map<Id, Account>([SELECT Id, Name FROM Account WHERE Id IN :parentAccountIdSet]);

        for (Account_Plan__c accountPlan : newAccountPlanList) {
            accountPlan.Name = accountPlan.Year__c + ' Plan - ' + parentAccountMap.get(accountPlan.Account__c)?.Name ;
        }
    }

    /**
    * @description Checks that there's only one Account Plan per year per account
    * @author kdoruibin@salesforce.com | 10-12-2021 
    * @param List<AccountPlan2__c> newAccountPlan2List 
    **/
    public static void checkUniquePerYear(List<Account_Plan__c> newAccountPlanList) {
        Map<String, Account_Plan__c> newAccountPlanKeyMap = new Map<String, Account_Plan__c>();
        Set<Id> parentAccountIdSet = new Set<Id>();
        for (Account_Plan__c newAccountPlan : newAccountPlanList) {
            String keyString = newAccountPlan.Account__c + newAccountPlan.Year__c;
            newAccountPlanKeyMap.put(keyString, newAccountPlan);
            parentAccountIdSet.add(newAccountPlan.Account__c);
        }


        for (Account_Plan__c existingAccountPlan : [SELECT Id, Account__c, Year__c FROM Account_Plan__c WHERE Account__c IN :parentAccountIdSet]) {
            String keyString = existingAccountPlan.Account__c + existingAccountPlan.Year__c;
            
            if (newAccountPlanKeyMap.get(keyString) == null) continue;

            String errorMessage = 'There can only be one Account Plan per year.';
            newAccountPlanKeyMap.get(keyString).addError(errorMessage);
        }
    }
    
    /**
    * @description create new account plan target lines when updating the business units of account plan  
    * @author naoussar@salesforce.com | 10-12-2021 
    * @param List<Account_Plan__c> list of updated account plan 
    **/
   public static void createAccountPlanEstimates(List<Account_Plan__c> updatedAccountPlan) {
       List<Id> accountPlanIds = new List<Id>();
       for(Account_Plan__c accountPlan: updatedAccountPlan){
           accountPlanIds.add(accountPlan.Id);
       }
       map<Id, List<String>> existingBUperAccPlan = new map<Id, List<String>>();
       for(AccountPlanEstimates__c accEstimates: [ SELECT Id,BusinessUnit__c,AccountPlan__c 
                                                  FROM AccountPlanEstimates__c 
                                                  WHERE  AccountPlan__c IN: accountPlanIds]){
       if(existingBUperAccPlan.containsKey(accEstimates.AccountPlan__c)){
             existingBUperAccPlan.get(accEstimates.AccountPlan__c).add(accEstimates.BusinessUnit__c);                                            
       }else{
             existingBUperAccPlan.put(accEstimates.AccountPlan__c,new List<String>{accEstimates.BusinessUnit__c} );
       }                          
       }
       List<AccountPlanEstimates__c> accountEstimates = new List<AccountPlanEstimates__c>();
       for(Account_Plan__c accPlan: updatedAccountPlan){
           if(!String.isEmpty(accPlan.BusinessUnits__c)){
               List<String> listOfbusinessUnits = accPlan.BusinessUnits__c.split(';');
               for(String businessUnit : listOfbusinessUnits){
                   if(existingBUperAccPlan.isEmpty() || (!existingBUperAccPlan.get(accPlan.Id).contains(businessUnit)) ){
                       AccountPlanEstimates__c newAccountEstimates = new AccountPlanEstimates__c ( AccountPlan__c = accPlan.Id , 
                                                                                         BusinessUnit__c  = businessUnit);
              
              			accountEstimates.add(newAccountEstimates);  
                   }
               }
       }
       }
       if(!accountEstimates.isEmpty()){
            insert accountEstimates;
       }
    
   }
}