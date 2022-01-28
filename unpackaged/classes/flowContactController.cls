/*------------------------------------------------------------	
	Author: 		Richard Trum (Glimt)  	
	Description:   	
	------------------------------------------------------------*/ 
    public with sharing class flowContactController {
    
        /*------------------------------------------------------------	
        Description:   	
        Inputs:        	@param recordId - the account's Id
        ------------------------------------------------------------*/	
        @AuraEnabled(cacheable=true)
        public static List<Contact> getRelatedContacts(String recordId, String sObjectName, String accountField, String contactFields) {
        
		System.debug('Record Id: ' + recordId + ' AccountField: ' +accountField);            
        String accountQuery = 'SELECT ' + accountField + ' FROM ' + sObjectName + ' WHERE Id=:recordId';
        accountQuery = String.escapeSingleQuotes(accountQuery);

        List<sObject> acc = Database.query(accountQuery);

        String accId = String.valueOf(acc[0].get(accountField));
        String contactObject = 'Contact';
        String contactQuery = 'SELECT ' + contactFields;
        
            if(!contactFields.contains('AccountId')){
                contactQuery = contactQuery + ', AccountId';
            }
            if(!contactFields.contains('RecordTypeId')){
                contactQuery = contactQuery + ', RecordTypeId';
            }
            
        contactQuery = contactQuery + ' FROM ' + contactObject + ' WHERE AccountId =: accId ORDER BY Full_Name__c ASC NULLS LAST';            
        contactQuery = String.escapeSingleQuotes(contactQuery);

        List<sObject> contacts = Database.query(contactQuery);
                
        List<Contact> contactOutput = contacts;
        
        return contactOutput;
    
        }
    
        /*@AuraEnabled(cacheable=true)
        public static List<Network__c> getReferralNetworks(String recordId){
    
            List<Network__c> networkList = [SELECT Id, Name FROM Network__c WHERE Hub_Account__c =: recordId];
    
            System.debug(networkList);
    
            return networkList;
        }*/

        @AuraEnabled(cacheable=true)
        public static List<sObject> executeSoql(String fieldName, String childObject, String objectName, String recordId) {
          
          String field = String.escapeSingleQuotes(fieldName);
          String obj = String.escapeSingleQuotes(objectName);
          String childObj = String.escapeSingleQuotes(childObject);
          String record = String.escapeSingleQuotes(recordId);

          String soql = 'SELECT Id, (SELECT ' + field + ' FROM ' + childObj + ' LIMIT 1) FROM ' + obj;
          soql = soql + ' WHERE Id=: record LIMIT 1';
          
          Boolean fieldExists = false;  
          try {
            Schema.SObjectType so = Schema.getGlobalDescribe().get(objectName.toLowerCase());            
            List<Schema.ChildRelationship> children = so.getDescribe().getChildRelationships();  
               
              for(Schema.ChildRelationship child : children){
                  
                  if(child.getRelationshipName() == childObject){
                      fieldExists = child.getChildSObject().getDescribe().fields.getMap().containsKey(field.toLowerCase());
                  }
              }  
          }  
          catch(Exception e){
                System.debug(e);
          }  
		
          List<sObject> result = new List<sObject>();
          
          if(fieldExists == true){
            result = Database.query(soql);
          }
          return result;
        }
    
    

}