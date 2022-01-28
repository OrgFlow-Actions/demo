/*-------------------------------------------------------------------------------------------------------
Author:         Roberto Narbona 
Description:    Contact Trigger Helper Class
Test Class:      
History 
20210401        Roberto Narbona         created showNoDeleteError method TFUS-000002832
20210908        Roberto Narbona        Refractoring done cause TFUS TFUS-000003164
--------------------------------------------------------------------------------------------------------*/

public with sharing class ContactTriggerHelper {
    public static void setValues(List<Contact> newContactList,Map<Id, Contact> newContactMap, Map<Id, Contact> oldContactMap){
        Map<String, CountryCodeMap__mdt> countryCodeMapping = new Map<String, CountryCodeMap__mdt>();
        List<CountryCodeMap__mdt> countryList = [SELECT  Country_Code_full__c, Country_Code_2_digit__c FROM CountryCodeMap__mdt];
        for (CountryCodeMap__mdt country : countryList) {
            countryCodeMapping.put(country.Country_Code_2_digit__c, country);
        }

        set<string> accIds = new set<string>();
        for(Contact contact : newContactList){
            if(contact.country__c == null){
                accIds.add(contact.AccountId);
            }
        }
        Map<ID, Account> mappAccIds = new Map<ID, Account>([SELECT Id, Country__c FROM Account WHERE Id IN: accIds]);
        for (Contact contact : newContactList) {
            //Migrated process builder entry -> Entry country validation
            
            If(!mappAccIds.isempty() && contact.Country__c == null && contact.AccountId != null && mappAccIds.get(contact.AccountId)!= null && mappAccIds.get(contact.AccountId).country__c != null){ //add account country null exception
                string country = mappAccIds.get(contact.AccountId).country__c;
                contact.country__c = countryCodeMapping.get(Country).Country_Code_full__c;
            }
            //Migrated process builder entry -> Marketing Consent not given 
            if((contact.Email == null || contact.InsertEmailMarketingConsentCollected__c == 'No' ) && (newContactMap == null  || (newContactMap != null && contact.email != oldContactMap.get(contact.Id).email) || (newContactMap != null && contact.InsertEmailMarketingConsentCollected__c != oldContactMap.get(contact.Id).InsertEmailMarketingConsentCollected__c)))
                {
                contact.Email_Consent_collected__c = 'No';
                contact.HasOptedOutOfEmail = true;
            }
            //Migrated process builder entry -> Email Marketing consent process 
            if( contact.Email != null && contact.InsertEmailMarketingConsentCollected__c == 'Yes' && (newContactMap == null ||(newContactMap != null && contact.InsertEmailMarketingConsentCollected__c != oldContactMap.get(contact.Id).InsertEmailMarketingConsentCollected__c) || (newContactMap != null && contact.email != oldContactMap.get(contact.Id).email))){
                contact.Email_Consent_collected__c = 'Yes';
                contact.Email_Consent_Date__c = system.today();
                contact.HasOptedOutOfEmail = false;
            }
            //Migrated process builder entry -> Email Opt-Out Denied by Customer *only for change so not insert*
            if( (newContactMap != null && contact.HasOptedOutOfEmail != oldContactMap.get(contact.Id).HasOptedOutOfEmail) 
                && contact.HasOptedOutOfEmail == true && contact.Email_Consent_collected__c != 'Please Select Yes or No'){
                    contact.Email_Consent_collected__c = 'No';
            }
            //Migrated process builder entry -> Email Opt-In Confirmed By Customer *only for change so not insert*
            if((newContactMap != null && contact.HasOptedOutOfEmail != oldContactMap.get(contact.Id).HasOptedOutOfEmail)
                && contact.HasOptedOutOfEmail == false && contact.Email_Consent_collected__c != 'Please Select Yes or No' ){
                    contact.Email_Consent_collected__c = 'Yes';

            }
            //Migrated process builder entry -> Email Marketing Consent - Delete Email
            if(contact.Email == null){
                contact.Email_Consent_Date__c = null;
                contact.HasOptedOutOfEmail= false;
            }
            //Migrated process builder entry -> Set Inactive Field Value in Duplicate Management
            if(contact.InsertEmailMarketingConsentCollected__c == 'Yes'){
                contact.inactive_dedupe_HQ__c = 'TRUE';
            }
            //Migrated process builder entry -> US Owner Assignment  
            if(!mappAccIds.isempty() && contact.accountId != null && mappAccIds.get(contact.AccountId) != null && mappAccIds.get(contact.AccountId).country__c != null && (mappAccIds.get(contact.AccountId).country__c == 'US' || mappAccIds.get(contact.AccountId).country__c == 'CA')   && contact.OwnerId != '0056M00000A0kR9QAJ'){
                contact.OwnerId = '0056M00000A0kR9QAJ';
            }
            //Migrated process builder entry -> BR Owner Assignment
            if(!mappAccIds.isempty() && contact.accountId != null && mappAccIds.get(contact.AccountId)!= null && mappAccIds.get(contact.AccountId).country__c != null && mappAccIds.get(contact.AccountId).country__c == 'BR' &&  contact.OwnerId != '0056M000009Z3c2QAC'){
                contact.OwnerId = '0056M000009Z3c2QAC';
            }

            //Migrated process builder entry -> Set Inactive Field Value in Duplicate - Active
            if(contact.Inactive__c == false){
                contact.inactive_dedupe_HQ__c = 'FALSE';
            }
        }
    }

    




    public static void showNoDeleteError(Map<Id, Contact> contactsMap, List<Contact> contactList){
        Map<Id, Contact> contactsCopy = contactsMap.clone();
        //keeping only those contacts with KOLs
        contactsCopy.keySet().retainAll(
        new Map<Id, AggregateResult>(
            [SELECT Contact__c Id 
             FROM Expert__c 
             WHERE Contact__c = :contactList
             GROUP BY Contact__c]).keySet());
        for(Contact record: contactsCopy.values()) {
            record.addError(Label.KOLDeleteError);
        }
    }
}