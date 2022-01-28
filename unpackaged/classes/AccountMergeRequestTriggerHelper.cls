/*-------------------------------------------------------------------------------------------------------
Author:         Roberto Narbona  20200625
Description:    Account Merge Request Trigger Helper Class
Test Class:     
History 
<Date>      <Authors Name>      <Brief Description of Change>
20200625    Roberto Narbona     Migrated AccountMergeRequestTrigger triggers. And fix merge bugs regarding
                                account parent relationship and duplicate account contact relationship  (#TFUS-000001782)
----------------------------------------------------------------------------------------*/

public with sharing class AccountMergeRequestTriggerHelper {
    public static void mergeAccounts(List<AccountMergeRequest__c> newAccountMergeRequestList) {
        // Check that the batch size is small enough to handle the merge statements
        // 150 DML statments per transaction is the limit
        
        if(newAccountMergeRequestList.size() >= 150)
        {
            for (AccountMergeRequest__c amr : newAccountMergeRequestList)
            {
                amr.addError('Cannot process merge request because the batch size is too large. Reduce the batch size to 150 records or below and try again.');
            }
            return;
        }
        
        // Get all accounts flagged for merge
        Set<string> oneSfIdsSet = new Set<string>();
        list<account> accountToUpdateList = new list<account>(); //remove parent field when the victim is parent of survivor.    
        
        for (AccountMergeRequest__c amr : newAccountMergeRequestList)
        {
            oneSfIdsSet.add(amr.Master_OneSFID__c);
            oneSfIdsSet.add(amr.Child_OneSFID__c);
        }
        
        Set<Account> accountsSet = new Set<Account>([select id, OneSF_Id__c, Parent.OneSF_Id__c from Account where OneSF_Id__c in :oneSfIdsSet]);
        
        // Build a map of OneSF Id to Account objects
        Map<string, Account> oneSfMappings = new Map<string, Account>();
        List<Id> accountIds = new List<Id>();
        for(Account account : accountsSet)
        {
            oneSfMappings.put(account.OneSF_Id__c, account);
            accountIds.add(account.Id);
        }
        
        // Build collection of all the child objects that will be merged
        Set<Event> childEventsSet = new Set<Event>([select id, Account.OneSF_Id__c from Event where AccountId in :accountIds]);
        Set<Case> childCasesSet = new Set<Case>([select id, Account.OneSF_Id__c from Case where Account.Id in :accountIds]);
        Set<Opportunity> childOpportunitiesSet = new Set<Opportunity>([select id, Account.OneSF_Id__c from Opportunity where Account.Id in :accountIds]);
        Set<Contact> childContactsSet = new Set<Contact>([select id, Account.OneSF_Id__c from Contact where Account.Id in :accountIds]);
        
        //collect ACRs
        List<AccountContactRelation> allAccountContactRelationsList = new List<AccountContactRelation>([select id, IsDirect, ContactId, Account.OneSF_Id__c from AccountContactRelation where Account.OneSF_Id__c in :oneSfIdsSet]);
        
        
        Map<string, List<AccountContactRelation>> allACRMap = new Map<string, List<AccountContactRelation>>();
        Map<string, AccountContactRelation> allACRsKeyContactAndSFIdMap = new Map<string, AccountContactRelation>();
        for (AccountContactRelation ACR : allAccountContactRelationsList){
            allACRsKeyContactAndSFIdMap.put(ACR.ContactId+ACR.Account.OneSF_Id__c,ACR);
            if(allACRMap.containsKey(ACR.Account.OneSF_Id__c) && allACRMap.get(ACR.Account.OneSF_Id__c) != null){
                List<AccountContactRelation> lstACRList = allACRMap.get(ACR.Account.OneSF_Id__c);
                lstACRList.add(ACR);
                allACRMap.put(ACR.Account.OneSF_Id__c,lstACRList);
            } else {
                allACRMap.put(ACR.Account.OneSF_Id__c, new List<AccountContactRelation> {ACR});
            }
        }

        // Merge accounts where required
        for (AccountMergeRequest__c amr : newAccountMergeRequestList)
        {
            Account masterAccount = oneSfMappings.get(amr.Master_OneSFID__c);
            Account childAccount = oneSfMappings.get(amr.Child_OneSFID__c);
            
            if(masterAccount == null){
                amr.addError('One SF ID for master account (' + amr.Master_OneSFID__c + ') does not correspond to a valid Account');
                continue;
            }
            
            if(childAccount == null){
                amr.addError('One SF ID for child account (' + amr.Child_OneSFID__c + ') does not correspond to a valid Account');
                continue;
            }
                        
            // Reset the merged objects list (also ensure that it is not null)
            amr.Merged_Child_Objects__c = '';
            
            // Update the Account Merge Request with the child objects that were merged
            // Do this before the merge so that we write the value before the merge is attempted (protects against losing the data in the event of a failure)
            for(Event e : childEventsSet)
            {
                if(e.Account.OneSF_Id__c == amr.Child_OneSFID__c)
                {
                    amr.Merged_Child_Objects__c = amr.Merged_Child_Objects__c + 'Event:' + e.Id + '\n';
                }
            }
            
            for(Case c : childCasesSet)
            {
                if(c.Account.OneSF_Id__c == amr.Child_OneSFID__c)
                {
                    amr.Merged_Child_Objects__c = amr.Merged_Child_Objects__c + 'Case:' + c.Id + '\n';
                }
            }
            
            for(Opportunity o : childOpportunitiesSet)
            {
                if(o.Account.OneSF_Id__c == amr.Child_OneSFID__c)
                {
                    amr.Merged_Child_Objects__c = amr.Merged_Child_Objects__c + 'Opportunity:' + o.Id + '\n';
                }
            }
            
            for(Contact c : childContactsSet)
            {
                if(c.Account.OneSF_Id__c == amr.Child_OneSFID__c)
                {
                    amr.Merged_Child_Objects__c = amr.Merged_Child_Objects__c + 'Contact:' + c.Id + '\n';
                }
            }
            
            databaseMergeAccount(masterAccount.Id, childAccount.Id, amr);
            //retry to fix known exceptions
            if (amr.Merge_Failure_Reason__c == null) {
                continue;
            }
            // check parent relationship
            if(masterAccount.Parent.OneSF_Id__c == childAccount.OneSF_Id__c){
                masterAccount.ParentId = null;
                accountToUpdateList.add(masterAccount);
            }
            //masterACR //childACR   allACRsKeyContactAndSFIdMap
            List<AccountContactRelation> masterACRsList = new List<AccountContactRelation>(allACRMap.get(amr.Master_OneSFID__c));
            List<AccountContactRelation> childACRsList =  new List<AccountContactRelation>(allACRMap.get(amr.Child_OneSFID__c));
            List<AccountContactRelation> accountContactRelationsToDeleteList = new List<AccountContactRelation>();
            //Checking what account has less contact to loop the list with less items
            if(! masterACRsList.isempty() && ! childACRsList.isempty() && masterACRsList.size() > childACRsList.size()){
                accountContactRelationsToDeleteList = checkDuplicateAccountContactRelationships(masterACRsList, allACRsKeyContactAndSFIdMap, amr.Child_OneSFID__c);
            }
            if(! masterACRsList.isempty() && ! childACRsList.isempty() && masterACRsList.size() <= childACRsList.size()){
                accountContactRelationsToDeleteList = checkDuplicateAccountContactRelationships(childACRsList, allACRsKeyContactAndSFIdMap, amr.Master_OneSFID__c);
            }

            
            try {
                //Update the parent account to remove the parent field
                if(! accountToUpdateList.isempty() ) {
                    update accountToUpdateList;
                }
                //Delete duplicate connections
                if(! accountContactRelationsToDeleteList.isempty() ) {
                    delete accountContactRelationsToDeleteList;
                }
                databaseMergeAccount(masterAccount.Id, childAccount.Id, amr);
            } catch(DMLException e) {
                system.debug(e.getMessage());
                DebugLog.addError(e.getMessage());
            }
        }
    }

    //This is the method to check duplicate non primary ACRs
    public static List<AccountContactRelation> checkDuplicateAccountContactRelationships(List<AccountContactRelation> AccountContactRelationToCheck, Map<string, AccountContactRelation> allACRsKeyContactAndSFIdMap, string oneSFId){
        List<AccountContactRelation> duplicateAccountContactRelationsList = new List<AccountContactRelation>();
        for (AccountContactRelation potentialDuplicateACR : AccountContactRelationToCheck){
            AccountContactRelation duplicateACR = new AccountContactRelation();
            duplicateACR = allACRsKeyContactAndSFIdMap.get(potentialDuplicateACR.ContactId+oneSFId);
           if( duplicateACR != null && potentialDuplicateACR.IsDirect == true) {
                duplicateAccountContactRelationsList.add(duplicateACR);
                continue;
            }
            if( duplicateACR != null ) {
                duplicateAccountContactRelationsList.add(potentialDuplicateACR);
                continue;
            }
        }
        return duplicateAccountContactRelationsList;
    }

    

    //this is the method to merge the accounts and capture exception issues
    public static void databaseMergeAccount(Id masterAccountId, Id childAccountId, AccountMergeRequest__c mergeRequestRecord){
        
        try {
                    
            Database.MergeResult result = Database.merge(new Account(Id = masterAccountId), childAccountId, false); 
            
            // Record any errors against the merge request        
            if (result.isSuccess()) 
            {            
                mergeRequestRecord.Accounts_Are_Merged__c = true;
                mergeRequestRecord.Merge_Failure_Reason__c = null;
            }
            else
            {
                mergeRequestRecord.Accounts_Are_Merged__c = false;
                mergeRequestRecord.Merged_Child_Objects__c = null;
                
                for(Database.Error err : result.getErrors()) 
                {
                    mergeRequestRecord.Merge_Failure_Reason__c = 'Failed: ' + err.getMessage();
                } 
            }
        } catch(DMLException e) {
            system.debug(e.getMessage());
            DebugLog.addError(e.getMessage());
        }
    }
}