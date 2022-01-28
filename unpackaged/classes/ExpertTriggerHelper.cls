/*-------------------------------------------------------------------------------------------------------
Author:         Ahmed LOUDRASSI (Salesforce) 20191127
Description:    Expert  Trigger Handler Class
History
20191127   Ahmed LOUDRASSI   Migrated   setExpertName trigger. (#)
----------------------------------------------------------------------------------------*/
public class ExpertTriggerHelper {
	
    /*------------------------------------------------------------
    Description:    Method migrated from  setExpertName trigger

    Inputs:         @param newExpertList
    ------------------------------------------------------------*/
    public static void setExpertName(List<Expert__c> newExpertList) { 
        List<Expert__c> expertsToUPdateList = new List<Expert__c>();
        List<ID> expertsToUPdateids = new List<ID>();
        for(Expert__c exp: newExpertList){
            if(exp.Contact__c != null){
                expertsToUPdateList.add(exp);
                expertsToUPdateids.add(exp.Contact__c);
            }
        }
        Map<ID,Contact> contacts = new Map<ID,Contact> 
                                    ([SELECT Id, FirstName, LastName FROM Contact WHERE Id =:expertsToUPdateids]);
        for(Expert__c exp : expertsToUPdateList) {
            exp.Name = contacts.get(exp.Contact__c).FirstName + ' ' + contacts.get(exp.Contact__c).LastName + ' - KOL info';
        }
    }
}