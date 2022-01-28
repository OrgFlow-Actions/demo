/*-------------------------------------------------------------------------------------------------------
Author:         Kevin Ruibin Do (Salesforce) 20200617
Description:    Apex Controller for flow_recordVisualPickerController
Test Class:     Test_flowRecordVisualPicker
History 
20201015        Kevin Ruibin Do - Added check for Primary_Contact__c = false
20200617        Kevin Ruibin Do - Created Class
--------------------------------------------------------------------------------------------------------*/

public with sharing class flowRecordVisualPickerController {
    @AuraEnabled(cacheable=true)
    public static List<Contact> getRelatedContacts(String recordId) {
        return [
            SELECT Id, Full_Name__c, FirstName, LastName, Email, Title, Contact_Type__c, Sub_Contact_Type__c
            FROM Contact WHERE AccountId =: recordId AND Primary_Contact__c = false ORDER BY Full_Name__c ASC NULLS LAST
        ];
    }

    /**
    * @description Method to query records that will be shown in the visual picker
    * @author kdoruibin@salesforce.com | 02-16-2021 
    * @param String recordId 
    * @param String queryString 
    * @return string 
    **/
    @AuraEnabled(cacheable=true)
    public static string getRecords(String recordId, String queryString){
        try {
            return JSON.serialize(Database.query(queryString));
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}