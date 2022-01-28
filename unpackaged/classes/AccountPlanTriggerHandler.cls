/**
 * @description       : AccountPlan2__c trigger handler
 * @author            : kdoruibin@salesforce.com
 * @group             : 
 * @last modified on  : 11-12-2021
 * @last modified by  : naoussar@salesforce.com
**/
public with sharing class AccountPlanTriggerHandler extends TriggerHandler {
	private List<Account_Plan__c> oldAccountPlanList, newAccountPlanList;
    private Map<Id, Account_Plan__c> oldAccountPlanMap, newAccountPlanMap;

    public AccountPlanTriggerHandler() {
        oldAccountPlanList = (List<Account_Plan__c>) Trigger.old;
        newAccountPlanList = (List<Account_Plan__c>) Trigger.new;
        oldAccountPlanMap = (Map<Id, Account_Plan__c>) Trigger.oldMap;
        newAccountPlanMap = (Map<Id, Account_Plan__c>) Trigger.newMap;
    }

    protected override void beforeInsert() {
        AccountPlanTriggerHelper.setAccountPlanName(newAccountPlanList);
        AccountPlanTriggerHelper.setOffices(newAccountPlanList);
        AccountPlanTriggerHelper.checkUniquePerYear(newAccountPlanList);
    }
    
    protected override void afterUpdate() {
        List<Account_Plan__c> updatedAccountPlan = new List<Account_Plan__c>();
        for( Id accountPlanId : newAccountPlanMap.keySet() ){
  			if( oldAccountPlanMap.get(accountPlanId).BusinessUnits__c != newAccountPlanMap.get(accountPlanId).BusinessUnits__c){
     	    	updatedAccountPlan.add(newAccountPlanMap.get(accountPlanId));
    		}
        }
        AccountPlanTriggerHelper.createAccountPlanEstimates(updatedAccountPlan);
		
    }
    
    protected override void beforeUpdate() {
        List<Account_Plan__c> updatedAccountPlan = new List<Account_Plan__c>();
        for( Id accountPlanId : newAccountPlanMap.keySet() ){
  			if( oldAccountPlanMap.get(accountPlanId).Year__c != newAccountPlanMap.get(accountPlanId).Year__c){
     	    	updatedAccountPlan.add(newAccountPlanMap.get(accountPlanId));
    		}
        }
        AccountPlanTriggerHelper.checkUniquePerYear(updatedAccountPlan);
        AccountPlanTriggerHelper.setAccountPlanName(updatedAccountPlan);
		
    }


}