/*-------------------------------------------------------------------------------------------------------
Author:         Denis Zhdanov (dzhdanov@mycervello.com) (Salesforce) 20170818
Description:    DC Account Update Batch This is updating the postal code information in the accounts
History
20170627   Sergey Legostaev (slegostaev@mycervello.com)
20191117   Roberto Narbona -> added country dependency logic
----------------------------------------------------------------------------------------*/

global class DC_AccountUpdateBatch implements Database.Batchable<sObject>, Database.Stateful {
    
    private List<Id> postalCodeIds;
    global  Map<String, Postal_Codes__c> codeMap;
    
    public DC_AccountUpdateBatch(List<Id> postalCodeIds) {    
        this.postalCodeIds = postalCodeIds;
        this.codeMap = new Map<String, Postal_Codes__c>();
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        List<Postal_Codes__c> codes = [Select Id, Name, DC_ETM_Code__c,Country_Picklist__c FROM Postal_Codes__c WHERE Id IN :postalCodeIds];
        Set<String> zipCodes = new Set<String>();
        Set<String> countries = new Set<String>();  
        for(Postal_Codes__c postalCode : codes) {
            codeMap.put(postalCode.Name+postalCode.Country_Picklist__c, postalCode);
            zipCodes.add(postalCode.Name);
            countries.add(postalCode.Country_Picklist__c);
            
        }
        return Database.getQueryLocator('Select Id, DC_ETM_Code__c, Country__c, Postal_Code_Info__c, Postal_Code_Info__r.DC_ETM_Code__c, ETM2_Zip_Code__c FROM Account WHERE ETM2_Zip_Code__c IN :zipCodes and country__c IN :countries');
    }
    
    global void execute(Database.BatchableContext BC, List<Account> scope) {
        List<Account> accountsToUpdate = new List<Account>();
        for(Account tempAccount: scope) {
            if((tempAccount.Postal_Code_Info__c == null || tempAccount.Postal_Code_Info__r.DC_ETM_Code__c != tempAccount.DC_ETM_Code__c) && codeMap.get(tempAccount.ETM2_Zip_Code__c.toUpperCase()+tempAccount.Country__c) != null) {
                Postal_Codes__c postalCode = codeMap.get(tempAccount.ETM2_Zip_Code__c.toUpperCase()+tempAccount.Country__c);
                tempAccount.Postal_Code_Info__c = postalCode.Id;
                tempAccount.DC_ETM_Code__c = postalCode.DC_ETM_Code__c;
                accountsToUpdate.add(tempAccount);
            } 
        }  
        try {
            if (accountsToUpdate.isEmpty() == false) {
                update accountsToUpdate;
            }
        } catch (DmlException e) {
            DebugLog.addError(e.getMessage());
        }
    }
    
    global void finish(Database.BatchableContext BC) { 
        DebugLog.addinfo('This is the DC_AccountUpdateBatch JobId:',BC.getJobId());
    }
}