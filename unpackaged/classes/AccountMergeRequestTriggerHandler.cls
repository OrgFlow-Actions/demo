/*------------------------------------------------------------  
Author:         Roberto Narbona  20200625
Description:    Account Merge Request Trigger Handler Class. 
History 
<Date>      <Authors Name>     <Brief Description of Change>
20200625    Roberto Narbona     Migrated AccountMergeRequestTrigger triggers. And fix merge bugs regarding
                                account parent relationship and duplicate account contact relationship  (#TFUS-000001782)
------------------------------------------------------------*/

public with sharing class AccountMergeRequestTriggerHandler extends TriggerHandler{
    private List<AccountMergeRequest__c> oldAccountMergeRequestList, newAccountMergeRequestList;
    private Map<Id, AccountMergeRequest__c> oldAccountMergeRequestMap, newAccountMergeRequestMap;

    public AccountMergeRequestTriggerHandler() {
        oldAccountMergeRequestList = (List<AccountMergeRequest__c>) Trigger.old;
        newAccountMergeRequestList = (List<AccountMergeRequest__c>) Trigger.new;
        oldAccountMergeRequestMap = (Map<Id, AccountMergeRequest__c>) Trigger.oldMap;
        newAccountMergeRequestMap = (Map<Id, AccountMergeRequest__c>) Trigger.newMap;
    }
    
    protected override void beforeInsert() {
        AccountMergeRequestTriggerHelper.mergeAccounts(newAccountMergeRequestList);
    }
    
    protected override void beforeUpdate() {
        AccountMergeRequestTriggerHelper.mergeAccounts(newAccountMergeRequestList);
    }
}