/*-------------------------------------------------------------------------------------------------------
Author:         Nihad Aoussar (Salesforce) 20211020
Description:    OGSM objectives Controller Class
Test Class:     Test_ObjectivesController_OGSM
History:        
20211020        create fetchObjectives, updateObjectives, deleteObjective
----------------------------------------------------------------------------------------*/
public with sharing class ObjectivesController_OGSM {
   /*------------------------------------------------------------  
    Description:    Method to fetch objectives related to an accountPlan record
    Inputs:         Id of the account plan 
    ------------------------------------------------------------*/
    @AuraEnabled(cacheable=true)
    public static List<Objective__c> fetchObjectives(Id accountPlanId){
        try {
            return [ SELECT Id, Name , Objective__c, Goals__c , Initiatives__c, Measures__c, Status__c, IndicatedActions__c,StatusNotes__c ,CreatedDate 
                        from Objective__c 
                        where AccountPlan__c=:accountPlanId 
                         ];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
   /*------------------------------------------------------------  
    Description:    Method to update objective record
    Inputs:         Object to update  
    ------------------------------------------------------------*/
    @AuraEnabled(cacheable=false)
    public static void updateObjectives(Object data){
        List < Objective__c > objectivesForUpdate = ( List < Objective__c > ) JSON.deserialize(
            JSON.serialize( data ),
            List < Objective__c >.class);
        try {
            update objectivesForUpdate;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
   /*------------------------------------------------------------  
    Description:    Method to delete objective record
    Inputs:         Id of the record to update  
    ------------------------------------------------------------*/
    @AuraEnabled
    public static void deleteObjective(Id objectiveId){
        try {
            Objective__c obj = new Objective__c(Id = objectiveId);
            delete obj;
          
        }
        catch(Exception ex) {
            throw new AuraHandledException(ex.getMessage());
        }
    }
}