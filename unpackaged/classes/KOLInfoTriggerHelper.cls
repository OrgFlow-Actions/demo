/*-------------------------------------------------------------------------------------------------------
Author: 		Richard Trum (Glimt) 2019-11-29
Description:   	KOL Information Trigger Helper Class
Test Class:      
History	
20191129 		Richard Trum			Created triggers in the trigger framework for the KOL Information object
--------------------------------------------------------------------------------------------------------*/

public with sharing class KOLInfoTriggerHelper {
    
    /*------------------------------------------------------------	
	Description:   	Method to prevent duplicate KOL information records to created towards one contact
    Inputs:        	@param contactId
	------------------------------------------------------------*/
    
    public static void preventDuplicateKOLs(List<Expert__c> newKOLList){
        
        for(Expert__c exp : newKOLList){ 
        	List<Expert__c> existingKOLs = [SELECT Id FROM Expert__c WHERE Contact__c =: exp.Contact__c];
        
        	if(existingKOLs.size()>0){
            	exp.addError('A KOL record already exists related to this contact');
     		}
        }
    }
    
    public static void setExpertName(List<Expert__c> expertlist){
      for(Expert__c exp:expertlist){
        if(exp.Contact__c != null){
            Contact c = [select id, FirstName, LastName from Contact where Id=:exp.Contact__c];
            exp.Name = c.FirstName + ' ' + c.LastName + ' - KOL info';
        }

    }
  
    }
    
    public static void setNonHCProfession(List<Expert__c> expertlist){
        for(Expert__c exp : expertlist){          
            if(exp.Profession__c == 'Non-Healthcare Provider'){
                exp.Not_a_Healthcare_Professional__c = true;
                exp.Profession__c = 'Non-Healthcare Provider';
            }
            
        }  
        
    }
    
}