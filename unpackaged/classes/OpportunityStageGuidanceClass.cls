/*------------------------------------------------------------  
Author:         Richard Trum (Glimt) 2019-11-05     
Description:    Class used for collecting data to be used in the Lightning Component OpportunityStageGuidance
                210421  kdoruibin   added method to update opportunity stage
------------------------------------------------------------*/

public class OpportunityStageGuidanceClass {
        
    /*------------------------------------------------------------  
    Description:    Helper method that collects information from both the source record (either an Oppty or Prospect),
                    as well as collecting custom metadata records from the custom metadata type called OppStageGuidance__mdt
    Inputs:         @param recordId - Source record Id, that could be either an opportunity or a lead
                    @param objectType - Input from the LC about which object this component is implemented within
                    @param stageField - Input on which field on the active object that is used for the path
                    @param countryField - Input on which field on the active object that is used for assigning a country(normally from the related account)
                    @param categoryField - Input on which field on the active object that is used for assigning a product category
    ------------------------------------------------------------*/  

        @AuraEnabled
        public static StageWrapper getOppStageGuidance(String recordId, String objectType, String stageField, String countryField, String categoryField, String recordTypeDeveloperName){
            
            String objId = recordId.substring(0,3);
            
            StageWrapper stInfo = new StageWrapper();
                
            String queryString = 'SELECT Id, ' + categoryField + ', ' + stageField + ', ' + countryField + ' FROM ' + objectType + ' WHERE Id =: recordId';
            
            List<sObject> oppList = new List<sObject>();
            
            try{
            oppList = Database.query(queryString);
            } catch(DmlException e){
                DebugLog.addException(e, 'Error on querying an opportunity/lead in OpportunityStageGuidanceClass');
                System.debug('The following exception has occurred: ' + e.getMessage());
            }
            
            
            String cat = '';
            String country = '';
            String multipleCountries = '';
                
            if(oppList[0] instanceOf Opportunity){
                Opportunity opp = (Opportunity) oppList[0];
                cat = opp.NA_Category__c;
                country = opp.Account.Country__c;
                multipleCountries = '%' + country + '%';
                stInfo.objectType = 'Opportunity';
                stInfo.currentStage = opp.StageName;
            }
            else{
               Field_Sales_Project_Members__c lead = (Field_Sales_Project_Members__c) oppList[0];
               cat = lead.Category__c;
               country = lead.Account__r.Country__c;
               multipleCountries = '%' + country + '%';
               stInfo.objectType = 'Field_Sales_Project_Members__c';
               stInfo.currentStage = lead.Status__c;
            }
            
            String queryCMDString = '';           
            List<OppStageGuidance__mdt> cmdt = new List<OppStageGuidance__mdt>();
            List<OppStageGuidance__mdt> cmdt_single = new List<OppStageGuidance__mdt>();
            List<OppStageGuidance__mdt> cmdt_multiple = new List<OppStageGuidance__mdt>();            
            
            try{
                
                cmdt_multiple = [SELECT OppStage__c, Default__c, Object__c, StageGuidanceDescr__c, Category__c, Country__c, CountrySelect__c, StageGuidance__c, FieldsToDisplay__c FROM OppStageGuidance__mdt WHERE Category__c =: cat AND RecordTypeDeveloperName__c =: recordTypeDeveloperName AND Object__r.QualifiedApiName =: stInfo.objectType AND CountrySelect__c LIKE: multipleCountries];
                
                if(cmdt_multiple.isEmpty()){
                	cmdt_single = [SELECT OppStage__c, Default__c, Object__c, StageGuidanceDescr__c, Category__c, Country__c, CountrySelect__c, StageGuidance__c, FieldsToDisplay__c FROM OppStageGuidance__mdt WHERE Category__c =: cat AND RecordTypeDeveloperName__c =: recordTypeDeveloperName AND Object__r.QualifiedApiName =: stInfo.objectType AND Country__c =: country];
                	cmdt.addAll(cmdt_single);
                }
                else{
                	cmdt.addAll(cmdt_multiple);    
                }

                if(cmdt.isEmpty()){
                    cmdt = [SELECT OppStage__c, Default__c, StageGuidanceDescr__c, Category__c, Country__c, CountrySelect__c, StageGuidance__c, FieldsToDisplay__c FROM OppStageGuidance__mdt WHERE (Default__c =:true AND Object__r.QualifiedApiName =: stInfo.objectType)];
                }
                
            } catch(DmlException e){
                DebugLog.addException(e, 'Error on querying custom metadata in OpportunityStageGuidanceClass');
            }
            System.debug(cmdt);    
            stInfo.stageInfo = cmdt;

            For(OppStageGuidance__mdt item : stInfo.stageInfo){
                
                if(item.OppStage__c == stInfo.currentStage){ 
                    stInfo.currentStageGuidance = item.StageGuidance__c;
                    
                    if(item.FieldsToDisplay__c != null){
                        stInfo.fieldsToDisplay = item.FieldsToDisplay__c.split(';');
                    }

                } 
            }

            return stInfo;
  
        }
    
        public class StageWrapper {
            @AuraEnabled public List<OppStageGuidance__mdt> stageInfo { get; set; }
            @AuraEnabled public String currentStage   { get; set; }
            @AuraEnabled public String currentStageGuidance { get; set;}
            @AuraEnabled public List<String> fieldsToDisplay {get; set;}
            @AuraEnabled public String objectType {get; set;}
            @AuraEnabled public String recordTypeDeveloperName {get; set;}
        }

        @AuraEnabled
        public static String updateStage2(Id recordId, String stageName, String stageField){
            SObject recordToUpdate = recordId.getSobjectType().newSObject(recordId);
            recordToUpdate.put(stageField, stageName);
            try {
                update recordToUpdate;
            } catch (Exception e) {
                DebugLog.addException(e, 'Could not update opportunity stage');
                throw new AuraHandledException(e.getMessage());
            }

            return (String) recordToUpdate.get(stageField);
        }

        @AuraEnabled
        public static OpportunityStage checkStageType(String stageName) {
            try {
                return [
                    SELECT Id, MasterLabel, IsClosed, IsWon, IsActive 
                    FROM OpportunityStage
                    WHERE MasterLabel = :stageName
                ];
            } catch (Exception e) {
                DebugLog.addException(e, 'Could not query stage type');
                throw new AuraHandledException(e.getMessage());
            }
        }
    
    }