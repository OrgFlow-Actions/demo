/*-------------------------------------------------------------------------------------------------------
Author:         Kevin Do (Salesforce) 20190924
Description:    Account Trigger Helper Class
Test Class:     AccountSetPayerLookupTest, DC_UT_AccountTrigger 
History
20200914    Kevin Do            Hotfix: Replaced 'UK' country value with 'GB' 
20190924    Kevin Do            Migrated DC_AccountTrigger and AccountSetPayerLookup triggers. (#TFUS1030)
20190930    Ahmed LOUDRASSI     create overridePotential and dentalProspectMovex. (#TFUS-000001032)
20200128    Chris Payne         Fixes missing record type mapping for account ownership for AT accounts. (#TFUS-000001490)
20200326    Kevin Do            Added setAccountSubSegmentation method (#TFUS-000001698)
20200817    Richard Trum        Added method updateRelatedContactAddresses (#TFUS-000002084)
20210405    Nisreen Al-Saleh            Added method accountInsertTest (#TFUS-000001231)
----------------------------------------------------------------------------------------*/

public with sharing class AccountTriggerHelper {

    public static Boolean forceUpdate = false;
    private static final String SOBJECT_NAME = 'Account';
    private static final Map<String, String> SOBJECT_RECORD_TYPES = new Map<String, String> {
            'Lab_Prospect_D'=> 'Lab_Prospect_D', 'Lab_Customer_D'=> 'Lab_Customer_D',
            'Clinical_Prospect_D'=> 'Clinical_Prospect_D', 'Clinical_Customer_D'=> 'Clinical_Customer_D',
            'Distributors_Customer_D'=> 'Distributors_Customer_D', 'ERP_Account'=> 'ERP_Account',
            'ERP_Lab_Account'=> 'ERP_Lab_Account', 'DNA_Internal'=> 'DNA_Internal',
            'DNA_EndUser'=> 'DNA_EndUser', 'DNA_Distributor'=> 'DNA_Distributor',
            'DNA_Event'=> 'DNA_Event', 'CIM_Account'=> 'CIM_Account',
            'Partner_DI'=> 'Partner_DI','Non_ERP_Account'=> 'Non_ERP_Account',
            'Non_ERP_Lab_Account'=> 'Non_ERP_Lab_Account', 'Non_ERP_Distributor'=> 'Non_ERP_Distributor',
            'Competitor'=> 'Competitor', 'Geographical_Account'=> 'Geographical_Account',
            'ERP_Distributor'=> 'ERP_Distributor', 'DEX_Customer'=> 'DEX_Customer',
            'Distributors_Prospect_D'=> 'Distributors_Prospect_D', 'DEX_D_Prospect'=> 'DEX_D_Prospect',
            'Dummy_Dentsply_Implants_Account'=> 'Dummy_Dentsply_Implants_Account',
            'Dummy_Wellspect_Account'=> 'Dummy_Wellspect_Account', 'ERP_Lab_Account'=> 'ERP_Lab_Account'};
                                                
    /*------------------------------------------------------------  
    Description:    Method migrated from DC_AccountTrigger trigger
    Inputs:         @param newAccountList and @param oldAccountMap
    ------------------------------------------------------------*/
    public static void setPostalCodeInfoAndEtmCode(List<Account> newAccountList, Map<Id, Account> oldAccountMap) {
        Set<String> eTm2ZipCodecSet = new Set<String>();
        List<Account> accountEtm2ZipCodeList = new List<Account>();

        for (Account account : newAccountList) {
            if (!String.isEmpty(account.ETM2_Zip_Code__c)) {
                if (oldAccountMap == null) {
                    accountEtm2ZipCodeList.add(account);
                    eTm2ZipCodecSet.add(account.ETM2_Zip_Code__c);
                } else if (account.ETM2_Zip_Code__c != oldAccountMap.get(account.Id).ETM2_Zip_Code__c) {
                    accountEtm2ZipCodeList.add(account);
                    eTm2ZipCodecSet.add(account.ETM2_Zip_Code__c);
                }
            }
        }

        if (!accountEtm2ZipCodeList.isEmpty()) {
            updateFieldsByETM2ZipCode(accountEtm2ZipCodeList, eTm2ZipCodecSet);
        }
    }

    /*------------------------------------------------------------
    Description:    Method migrated from AccountSetPayerLookup trigger
    Inputs:         @param newAccountList and @param oldAccountMap
    ------------------------------------------------------------*/
    public static void setPayerLookup(List<Account> newAccountList, Map<Id, Account> oldAccountMap) {
        // Collect a list of all Payer_Movex__c values of the affected Accounts.
        List<Account> affectedAccountList = new List<Account>();
        Set<String> payerMovexNumberSet = new Set<String>();

        for (Account newAccount : newAccountList) {
            if (!String.isBlank(newAccount.Payer_Movex__c)) {
                if (oldAccountMap == null) {
                    affectedAccountList.add(newAccount);
                    payerMovexNumberSet.add(newAccount.Payer_Movex__c);
                } else if (newAccount.Payer_Movex__c != oldAccountMap.get(newAccount.Id).Payer_Movex__c) {
                    affectedAccountList.add(newAccount);
                    payerMovexNumberSet.add(newAccount.Payer_Movex__c);
                }
            }
        }

        // Short-circuit execution if no affected accounts were found.
        If (affectedAccountList.isEmpty()) {
            return;
        }

        Map<String, Id> accountMap = new Map<String, Id>();
        if (!payerMovexNumberSet.isEmpty()) {
            // Query the Id and Movex__c values for related payer Accounts.
            List<Account> accountList = [SELECT Id, Movex__c FROM Account WHERE Movex__c IN :payerMovexNumberSet];
            // Construct a map of Movex__c to Id.
            for (Account account : accountList) {
                accountMap.put(account.Movex__c, account.Id);
            }
        }

        // Set the Id value of the related payer Account in the Payer_Lookup__c field of each affected Account.
        for (Account account : affectedAccountList) {
            if (!String.isBlank(account.Payer_Movex__c) && accountMap.containsKey(account.Payer_Movex__c)) {
                Id payerLookupId = accountMap.get(account.Payer_Movex__c);

                // Don't create a circular lookup by setting the field to the Id value of the Account itself!
                if (account.Id != payerLookupId) {
                    account.Payer_Lookup__c = payerLookupId;
                    continue;
                }
            }
            account.Payer_Lookup__c = null;
        }
    }

    /*------------------------------------------------------------
    Description:    Helper method migrated from DC_AccountTrigger
                    Updates Postal_Code_Info__c and DC_ETM_Code__c fields
    Inputs:         @param accountList List of Account where ETM2ZipCode not null or was changed
                    @param eTM2ZipCodecSet Set of related ETM2ZipCodes from Account List
    ------------------------------------------------------------*/
    private static void updateFieldsByETM2ZipCode(List<Account> accountList, Set<String> eTM2ZipCodecSet) {
        List<Postal_Codes__c> postalCodesList = [
                SELECT Id, Name, DC_ETM_Code__c, Country_Picklist__c
                FROM Postal_Codes__c
                WHERE Name IN :eTM2ZipCodecSet];
        Map<String, Postal_Codes__c> namesPostalCodesMap = new Map<String, Postal_Codes__c>();

        for (Postal_Codes__c postalCodes : postalCodesList) {
            namesPostalCodesMap.put(postalCodes.Name+postalCodes.Country_Picklist__c, postalCodes);
        }

        for (Account account : accountList) {
            Postal_Codes__c postalCode = namesPostalCodesMap.get(account.ETM2_Zip_Code__c+account.Country__c);
            if (postalCode != null) {
                account.Postal_Code_Info__c = postalCode.Id;
                account.DC_ETM_Code__c = postalCode.DC_ETM_Code__c;
            }
        }
    }
    /*------------------------------------------------------------  
    Description:    Method migrated from  Workflows
                    WF-ACC-01 : 'Override ATL Abut Potential' (Created on 07/08/2014)
                    WF-ACC-02 : 'Override ATL ISUS Potential' (Created on 08/08/2014)
                    WF-ACC-03 : 'Override Simplant Potential' (Created on 09/05/2014)
                    WF-ACC-04 : 'Overwrite Implants Potential'(Created on 16/02/2015)
    Inputs:         @param newAccount
    ------------------------------------------------------------*/
    public static void overridePotential(Account newAccount) {
        // In case the potential is less than the current sales
        if('True'.equals(newAccount.Override_ATL_Abut_Potential__c)) {
            newAccount.ATL_Abut_Potential_Year__c = newAccount.Sold_Atlantis_Abut_s_L12M__c;
        }
        // In case the potential is less than the current sales
        if('True'.equals(newAccount.Override_ATL_ISUS_Potential__c)) {
            newAccount.ATL_ISUS_Potential_Year__c = newAccount.Sold_ATL_ISUS_L12M__c;
        }
        // In case the potential is less than the current sales
        if('True'.equals(newAccount.Override_Simplant_Potential__c)) {
            newAccount.SP_Guides_Potential_Year__c = newAccount.Sold_Guides_L12M__c;
        }
        /* 
            If Sold Implants L12M > Implants Potential / Year, 
            then the system will overwrite current potential with
            the Sold Implants L12M value. This Boolean logic checked in a help field
        */
        if('True'.equals(newAccount.Overwrite_Implants_Potential__c)) {
            if('Long Purchasing Cycle >1 Year'.equals(newAccount.Custom_Segmentation__c)) {
                if(((newAccount.Sold_Implants_L12M__c + newAccount.Sold_Implants_L13_24M__c) / 2) > 0) {
                    newAccount.Implants_Potential_Year__c = 
                        (newAccount.Sold_Implants_L12M__c + newAccount.Sold_Implants_L13_24M__c) / 2;
                }else {
                    newAccount.Implants_Potential_Year__c = 0;
                }
            }else {
                If(newAccount.Sold_Implants_L12M__c > 0) {
                    newAccount.Implants_Potential_Year__c = newAccount.Sold_Implants_L12M__c;
                }else {
                    newAccount.Implants_Potential_Year__c = 0;
                }                        
            }
        }
    }

    /*------------------------------------------------------------  
    Description:    Method migrated from  Workflows
                    WF-ACC-05 : 'Dental Clinical Prospect - Movex' (Created on 08/01/2010)
                    WF-ACC-06 : 'Dental Lab Prospect - Movex' (Created on 28/09/2009)
    Inputs:         @param newAccount
    ------------------------------------------------------------*/
    public static void dentalProspectMovex(Account newAccount) {
        //When Movex# is filled in, update record type from Dental Lab Prospect to Dental Lab Customer
        if(newAccount.RecordTypeId == GlobalUtils.getRecordTypeId(SOBJECT_NAME, SOBJECT_RECORD_TYPES.get('Lab_Prospect_D'))
           && String.IsNotBlank(newAccount.Movex__c)) {
               newAccount.RecordTypeId = GlobalUtils.getRecordTypeId(SOBJECT_NAME, SOBJECT_RECORD_TYPES.get('Lab_Customer_D'));
        }
        // When Movex# is filled in, update record type from Dental Clinical Prospect to Dental Clinical Customer
        if(newAccount.RecordTypeId == GlobalUtils.getRecordTypeId(SOBJECT_NAME, SOBJECT_RECORD_TYPES.get('Clinical_Prospect_D'))
           && String.IsNotBlank(newAccount.Movex__c)) {
               newAccount.RecordTypeId = GlobalUtils.getRecordTypeId(SOBJECT_NAME, SOBJECT_RECORD_TYPES.get('Clinical_Customer_D'));
        }
    }
    
    /*------------------------------------------------------------ 
    Description:    Method migrated from  Workflows
                    WF-ACC-07 : 'Set Account Owner on SSIS System User Owned Accounts (IT)' (Created on 26/10/2016)
    Inputs:         @param newAccountList
    ------------------------------------------------------------*/
    public static void setAccountDefaultOwnerOnCreate(List<Account> newAccountList) {
        List<CountryOwner__mdt> countriesOwnersList = [SELECT Country__c,OwnerId__c FROM CountryOwner__mdt];
        Map<String,String> countriesOwnersMap = new Map<String,String>();
        for(CountryOwner__mdt countryOwner : countriesOwnersList) {
            countriesOwnersMap.put(countryOwner.Country__c, countryOwner.OwnerId__c);         
        }
        Set<String> gdwIntegrationIds = new Set<String> (GlobalIntegrationSettings__c.getInstance().GdwIntegration__c.split(',')); 
        for(Account newAccount : newAccountList) {
            // Set Account Owner for Italian Accounts to Vincenzo
            if('IT'.equals(newAccount.Country__c) && gdwIntegrationIds.contains(newAccount.OwnerId)) {
                newAccount.OwnerId = countriesOwnersMap.get(newAccount.Country__c); 
            }
        }
    }
    /*------------------------------------------------------------ 
    Description:    Method migrated from  Workflows
                    WF-ACC-08 : 'Set AU & NZ Account Default Owner' (Created on 31/05/2017)
                    WF-ACC-09 : 'Set Austria Account Default Owner' (Created on 05/01/2018)
                    WF-ACC-10 : 'Set IE/GB Account Default Owner' (Created on 23/08/2019)
                    WF-ACC-11 : 'Set FR Account Default Owner' (Created on 23/02/2018) 
                    PB-ACC-01 : 'solution for BNL to keep the previous account owner' (Created on 15/05/2019)
    Inputs:         @param newAccountList
    ------------------------------------------------------------*/
    public static void setAccountDefaultOwner(List<Account> newAccountList, Map<Id, Account> oldAccountMap) {
        List<CountryOwner__mdt> countriesOwnersList = [SELECT Country__c,OwnerId__c FROM CountryOwner__mdt];
        Map<String,Id> countriesOwnersMap = new Map<String,Id>();
        for(CountryOwner__mdt countryOwner : countriesOwnersList) {
            countriesOwnersMap.put(countryOwner.Country__c, countryOwner.OwnerId__c);         
        }
        Set<String> gdwIntegrationIds = new Set<String> (GlobalIntegrationSettings__c.getInstance().GdwIntegration__c.split(',')); 
        for(Account newAccount : newAccountList) {
            // used to manage incorrect ownership integrations from AX
            if(('AU'.equals(newAccount.Country__c) || 'NZ'.equals(newAccount.Country__c)) && gdwIntegrationIds.contains(newAccount.OwnerId)) { 
                      newAccount.OwnerId = countriesOwnersMap.get(newAccount.Country__c); 
            }
            // No owner integration from ERP - defaulted to SSIS User and not visible to AT 
            // so this workflow sets CRM Analyst in AT as owner instead
            if('AT'.equals(newAccount.Country__c) && gdwIntegrationIds.contains(newAccount.OwnerId)
              && (newAccount.RecordTypeId == GlobalUtils.getRecordTypeId(SOBJECT_NAME, 'Distributors_Customer_D')
                 || (newAccount.RecordTypeId == GlobalUtils.getRecordTypeId(SOBJECT_NAME, 'Lab_Customer_D'))
                 || (newAccount.RecordTypeId == GlobalUtils.getRecordTypeId(SOBJECT_NAME, 'Clinical_Customer_D'))
                 || (newAccount.RecordTypeId == GlobalUtils.getRecordTypeId(SOBJECT_NAME, 'Dental_End_User_Movex'))))  {
                      newAccount.OwnerId = countriesOwnersMap.get(newAccount.Country__c); 
            }
            // Set IE/GB Account Default Owner  
            if(gdwIntegrationIds.contains(newAccount.OwnerId)
              && ('IE'.equals(newAccount.Country__c) || 'GB'.equals(newAccount.Country__c))
              && (newAccount.RecordTypeId == GlobalUtils.getRecordTypeId(SOBJECT_NAME, 'ERP_Account')
                  || newAccount.RecordTypeId == GlobalUtils.getRecordTypeId(SOBJECT_NAME, 'ERP_Lab_Account'))) {
                      newAccount.OwnerId = countriesOwnersMap.get(newAccount.Country__c); 
            }
            // Set FR Account Default Owner
            if(gdwIntegrationIds.contains(newAccount.OwnerId) && 'FR'.equals(newAccount.Market__c) && 'FR'.equals(newAccount.Country__c)
              && (newAccount.RecordTypeId == GlobalUtils.getRecordTypeId(SOBJECT_NAME, 'ERP_Account')
                  || newAccount.RecordTypeId == GlobalUtils.getRecordTypeId(SOBJECT_NAME, 'ERP_Lab_Account'))) {
                      newAccount.OwnerId = countriesOwnersMap.get(newAccount.Country__c); 
            }
            // solution for BNL to keep the previous account owner
            if(('NL'.equals(newAccount.Country__c) || 'BE'.equals(newAccount.Country__c) || 'LU'.equals(newAccount.Country__c)) 
               && newAccount.OwnerId == countriesOwnersMap.get(newAccount.Country__c) && gdwIntegrationIds.contains(newAccount.LastModifiedById)
               && oldAccountMap != null && newAccount.OwnerId != oldAccountMap.get(newAccount.Id).OwnerId)  {
                   newAccount.OwnerId = oldAccountMap.get(newAccount.Id).OwnerId;
            }
        }
    }
    /*------------------------------------------------------------ 
    Description:    Method migrated from  Workflows
                    WF-ACC-12 : 'Update Volume SP Guides to No Usage' (Created on 08/05/2014)
                    WF-ACC-13 : 'Update Volume SP Guides to Low Usage' (Created on 08/05/2014)
                    WF-ACC-14 : 'Update Volume SP Guides to Medium Usage' (Created on 08/05/2014)
                    WF-ACC-15 : 'Update Volume SP Guides to High Usage' (Created on 08/05/2014)
                    WF-ACC-16 : 'Update Volume (Implants) to No usage' (Created on 16/02/2015)
                    WF-ACC-17 : 'Update Volume (Implants) to Low' (Created on 16/02/2015)
                    WF-ACC-18 : 'Update Volume (Implants) to Medium' (Created on 16/02/2015)
                    WF-ACC-19 : 'Update Volume (Implants) to High' (Created on 16/02/2015)
                    WF-ACC-20 : 'Update Volume (ATL ISUS) to No Usage' (Created on 12/11/2013)
                    WF-ACC-21 : 'Update Volume (ATL ISUS) to Low' (Created on 12/11/2013)
                    WF-ACC-22 : 'Update Volume (ATL ISUS) to Medium' (Created on 11/11/2013)
                    WF-ACC-23 : 'Update Volume (ATL ISUS) to High'(Created on 11/11/2013)
                    WF-ACC-24 : 'Update Volume (ATL Abut) to No Usage'(Created on 18/06/2010)
                    WF-ACC-25 : 'Update Volume (ATL Abut) to Low'(Created on 29/05/2009)
                    WF-ACC-26 : 'Update Volume (ATL Abut) to Medium'(Created on 29/05/2009)
                    WF-ACC-27 : 'Update Volume (ATL Abut) to High'(Created on 29/05/2009)
    Inputs:         @param newAccount
    ------------------------------------------------------------*/
    public static void updateVolume(List<Account> newAccountList)  {
                
        Set<String> countriesSet1 = new Set<String>{'PL','DK','GB','CA','DE','ES'};
        Set<String> countriesSet2 = new Set<String>{'IT','LU','NZ','CH','AT','PT','AU'};
        Set<String> countriesSet3 = new Set<String>{'FR','NL','NO','BE','SE','FI'};
        Set<String> countriesSet4 = new Set<String> {'US','PL','DK','GB','CA','DE','ES'};    
        List<String> recordTypes1 = new List<String> {SOBJECT_RECORD_TYPES.get('Lab_Customer_D'),
                                                        SOBJECT_RECORD_TYPES.get('Lab_Prospect_D'),
                                                        SOBJECT_RECORD_TYPES.get('Clinical_Customer_D'),
                                                        SOBJECT_RECORD_TYPES.get('Clinical_Prospect_D')};
        List<String> recordTypes2 = new List<String> {SOBJECT_RECORD_TYPES.get('DEX_Customer'),
                                                        SOBJECT_RECORD_TYPES.get('Distributors_Prospect_D'),
                                                        SOBJECT_RECORD_TYPES.get('Distributors_Customer_D'),
                                                        SOBJECT_RECORD_TYPES.get('DEX_D_Prospect'),
                                                        SOBJECT_RECORD_TYPES.get('Partner_DI'),
                                                        SOBJECT_RECORD_TYPES.get('Dummy_Dentsply_Implants_Account'),
                                                        SOBJECT_RECORD_TYPES.get('Dummy_Wellspect_Account'),
                                                        SOBJECT_RECORD_TYPES.get('Lab_Customer_D'),
                                                        SOBJECT_RECORD_TYPES.get('Lab_Prospect_D'),
                                                        SOBJECT_RECORD_TYPES.get('Clinical_Customer_D'),
                                                        SOBJECT_RECORD_TYPES.get('Clinical_Prospect_D'),
                                                        SOBJECT_RECORD_TYPES.get('Competitor'),
                                                        SOBJECT_RECORD_TYPES.get('ERP_Account'),
                                                        SOBJECT_RECORD_TYPES.get('ERP_Distributor'),
                                                        SOBJECT_RECORD_TYPES.get('ERP_Lab_Account')}; 
        for(Account newAccount : newAccountList) {                                            
            // Update Volume SP Guides to No Usage
            if((newAccount.SP_Guides_Potential_Year__c == null || newAccount.SP_Guides_Potential_Year__c <= 0))
            {
                newAccount.Volume_Simplant__c = 'No Usage';
            }
            // Update Volume SP Guides to Low Usage
            if(newAccount.SP_Guides_Potential_Year__c > 0 && newAccount.SP_Guides_Potential_Year__c < 5)  {
                newAccount.Volume_Simplant__c = 'Low Usage';
            }
            // Update Volume SP Guides to Medium Usage
            if(newAccount.SP_Guides_Potential_Year__c >= 5 && newAccount.SP_Guides_Potential_Year__c < 15)  {
                newAccount.Volume_Simplant__c = 'Medium Usage';
            }
            // Update Volume SP Guides to High Usage
            if(newAccount.SP_Guides_Potential_Year__c >= 15)  {
                newAccount.Volume_Simplant__c = 'High Usage';
            }
            // Update Volume (Implants) to No usage
            if(newAccount.Implants_Potential_Year__c == null || newAccount.Implants_Potential_Year__c <= 0) {
                newAccount.Volume_Implants__c = 'No Usage';
            }
            // Update Volume (Implants) to Low
            if(newAccount.Implants_Potential_Year__c > 0 && newAccount.Implants_Potential_Year__c < 30) {
                newAccount.Volume_Implants__c = 'Low Usage';
            }
            // Update Volume (Implants) to Medium
            if(newAccount.Implants_Potential_Year__c >= 30 && newAccount.Implants_Potential_Year__c < 100) {
                newAccount.Volume_Implants__c = 'Medium Usage';
            }
            // Update Volume (Implants) to High
            if(newAccount.Implants_Potential_Year__c >= 100) {
                newAccount.Volume_Implants__c = 'High Usage';
            }                      
            // Update Volume (ATL ISUS) to No Usage for Labs if ATL ISUS Potential/year is 0
            if((newAccount.ATL_ISUS_Potential_Year__c == null || newAccount.ATL_ISUS_Potential_Year__c == 0)  
               && GlobalUtils.ifRecordTypeInList(SOBJECT_NAME, recordTypes1, newAccount.RecordTypeId)) {
                   newAccount.Volume_ATL_ISUS__c = 'No Usage';
            }
           // Update Volume (ATL ISUS) to Low
           if(GlobalUtils.ifRecordTypeInList(SOBJECT_NAME, recordTypes1, newAccount.RecordTypeId) 
               &&((newAccount.ISUS_Connection_potential_Year__c >= 1 && newAccount.ISUS_Connection_potential_Year__c <= 99 
                   && countriesSet1.contains(newAccount.Country__c))
                  ||(newAccount.ISUS_Connection_potential_Year__c >= 1 && newAccount.ISUS_Connection_potential_Year__c <= 24
                     && countriesSet2.contains(newAccount.Country__c))
                  ||(newAccount.ISUS_Connection_potential_Year__c >= 1 && newAccount.ISUS_Connection_potential_Year__c <= 49
                     && countriesSet3.contains(newAccount.Country__c)))) {
                     newAccount.Volume_ATL_ISUS__c = 'Low Usage';
            }
            // Update Volume (ATL ISUS) to Medium
            if((newAccount.ISUS_Connection_potential_Year__c >= 100 && newAccount.ISUS_Connection_potential_Year__c <= 299
                     && countriesSet1.contains(newAccount.Country__c))
              || (newAccount.ISUS_Connection_potential_Year__c >= 25 && newAccount.ISUS_Connection_potential_Year__c <= 99
                     && countriesSet2.contains(newAccount.Country__c)) 
              || (newAccount.ISUS_Connection_potential_Year__c >= 50 && newAccount.ISUS_Connection_potential_Year__c <= 199
                     && countriesSet3.contains(newAccount.Country__c))) {
                newAccount.Volume_ATL_ISUS__c = 'Medium Usage';
            }
            // Update Volume (ATL ISUS) to High
            if((newAccount.ISUS_Connection_potential_Year__c >= 300 && countriesSet1.contains(newAccount.Country__c))
              || (newAccount.ISUS_Connection_potential_Year__c >= 100 && countriesSet2.contains(newAccount.Country__c)) 
              || (newAccount.ISUS_Connection_potential_Year__c >= 200 && countriesSet3.contains(newAccount.Country__c))) {
                newAccount.Volume_ATL_ISUS__c = 'High Usage';
            }
            // Update Volume (ATL Abut) to No Usage
            if(newAccount.ATL_Abut_Potential_Year__c == 0) {
                newAccount.Volume_ATL_Abut__c = 'No Usage'; 
            }  
            // Update Volume (ATL Abut) to Low
            if(GlobalUtils.ifRecordTypeInList(SOBJECT_NAME, recordTypes2, newAccount.RecordTypeId)  
               && newAccount.ATL_Abut_Potential_Year__c >= 1
               &&((newAccount.ATL_Abut_Potential_Year__c <= 99 && countriesSet4.contains(newAccount.Country__c)) 
                  || (countriesSet3.contains(newAccount.Country__c) && newAccount.ATL_Abut_Potential_Year__c <= 49) 
                  ||( newAccount.ATL_Abut_Potential_Year__c <= 24 && (countriesSet2.contains(newAccount.Country__c))))) {
                  newAccount.Volume_ATL_Abut__c  = 'Low Usage';
            }
            // Update Volume (ATL Abut) to Medium
            if(( newAccount.ATL_Abut_Potential_Year__c >= 100 && newAccount.ATL_Abut_Potential_Year__c <= 299
               && countriesSet4.contains(newAccount.Country__c))
              ||( newAccount.ATL_Abut_Potential_Year__c >= 25 && newAccount.ATL_Abut_Potential_Year__c <= 99
               && countriesSet2.contains(newAccount.Country__c))
              ||( newAccount.ATL_Abut_Potential_Year__c >= 50 && newAccount.ATL_Abut_Potential_Year__c <= 199
               && countriesSet3.contains(newAccount.Country__c))) {
                newAccount.Volume_ATL_Abut__c = 'Medium Usage';
            }
            // Update Volume (ATL Abut) to High
            if(( newAccount.ATL_Abut_Potential_Year__c >= 300 && countriesSet4.contains(newAccount.Country__c))
              ||( newAccount.ATL_Abut_Potential_Year__c >= 100 && countriesSet2.contains(newAccount.Country__c))
              ||( newAccount.ATL_Abut_Potential_Year__c >= 200 && countriesSet3.contains(newAccount.Country__c))) {
                newAccount.Volume_ATL_Abut__c = 'High Usage';
            }
        }
    }

    /*------------------------------------------------------------ 
    Description:    Method migrated from  Workflows
                    WF-ACC-28 : 'Set Partner Account' (Created on 04/07/2016)
                    WF-ACC-29 : 'Set Non-ERP Lab Accounts' (Created on 04/07/2016)
                    WF-ACC-30 : 'Set Non-ERP Distributor' (Created on 04/07/2016)
                    WF-ACC-31 : 'Set Non-ERP Accounts' (Created on 04/07/2016)
                    WF-ACC-32 : 'Set ERP Account' (Created on 04/07/2016)
                    WF-ACC-33 : 'Set ERP Lab Accounts' (Created on 04/07/2016)
                    WF-ACC-34 : 'Set ERP Distributor' (Created on 04/07/2016)
                    WF-ACC-35 : 'Set Competitor Account' (Created on 04/07/2016)
                    WF-ACC-36 : 'Set Geographical Account' (Created on 04/07/2016)
    Inputs:         @param newAccount
    ------------------------------------------------------------*/
    public static void updateRecordsType(List<Account> newAccountList) {
        List<String> recordTypes3 = new List<String> {SOBJECT_RECORD_TYPES.get('DNA_Internal'), SOBJECT_RECORD_TYPES.get('DNA_Event'), 
                                                      SOBJECT_RECORD_TYPES.get('DNA_Distributor'), SOBJECT_RECORD_TYPES.get('DNA_EndUser')};
        for(Account newAccount: newAccountList)  {
            Boolean notInRecordTypesList =!GlobalUtils.ifRecordTypeInList(SOBJECT_NAME, recordTypes3, newAccount.RecordTypeId);
            
            // Used for ONE SFDC to check values in Account Type & ERP# fields and set the correct record type of the Account.
            if(newAccount.RecordTypeId != GlobalUtils.getRecordTypeId(SOBJECT_NAME,SOBJECT_RECORD_TYPES.get('CIM_Account')) 
               && (String.ISBLANK(newAccount.RecordTypeId) 
                    || newAccount.RecordTypeId != GlobalUtils.getRecordTypeId(SOBJECT_NAME,SOBJECT_RECORD_TYPES.get('Partner_DI')))  
               && 'Partner'.equals(newAccount.OneAccount_Type__c)) {
                newAccount.RecordTypeId = GlobalUtils.getRecordTypeId(SOBJECT_NAME,SOBJECT_RECORD_TYPES.get('Partner_DI'));
            }
            // Used for ONE SFDC to check values in Account Type & ERP# fields and set the correct record type of the Account.
            if(notInRecordTypesList 
                && newAccount.RecordTypeId != GlobalUtils.getRecordTypeId(SOBJECT_NAME,SOBJECT_RECORD_TYPES.get('CIM_Account'))
                && String.ISBLANK(newAccount.Movex__c)
                &&  (String.ISBLANK(newAccount.RecordTypeId) 
                     || newAccount.RecordTypeId != GlobalUtils.getRecordTypeId(SOBJECT_NAME,SOBJECT_RECORD_TYPES.get('Non_ERP_Lab_Account'))) 
                &&  'Dental Laboratory'.equals(newAccount.OneAccount_Type__c)) {
                    newAccount.RecordTypeId  = GlobalUtils.getRecordTypeId(SOBJECT_NAME,SOBJECT_RECORD_TYPES.get('Non_ERP_Lab_Account'));
            }
            // Used for ONE SFDC to check values in Account Type & ERP# fields and set the correct record type of the Account.
            if(notInRecordTypesList 
                && newAccount.RecordTypeId != GlobalUtils.getRecordTypeId(SOBJECT_NAME,SOBJECT_RECORD_TYPES.get('CIM_Account'))
                && String.ISBLANK(newAccount.Movex__c)
                &&  (String.ISBLANK(newAccount.RecordTypeId) 
                     || newAccount.RecordTypeId != GlobalUtils.getRecordTypeId(SOBJECT_NAME,SOBJECT_RECORD_TYPES.get('Non_ERP_Distributor')))
                &&  ('Wholesaler'.equals(newAccount.OneAccount_Type__c) 
                     || 'Distributor'.equals(newAccount.OneAccount_Type__c))) {
                    newAccount.RecordTypeId = GlobalUtils.getRecordTypeId(SOBJECT_NAME,SOBJECT_RECORD_TYPES.get('Non_ERP_Distributor'));
            }
            // Used for ONE SFDC to check values in Account Type & ERP# fields and set the correct record type of the Account.
            if(notInRecordTypesList
                && newAccount.RecordTypeId != GlobalUtils.getRecordTypeId(SOBJECT_NAME,SOBJECT_RECORD_TYPES.get('CIM_Account'))
                && String.ISBLANK(newAccount.Movex__c) 
                && (String.ISBLANK(newAccount.RecordTypeId) 
                    || newAccount.RecordTypeId != GlobalUtils.getRecordTypeId(SOBJECT_NAME,SOBJECT_RECORD_TYPES.get('Non_ERP_Account')))
                && ('Dental Clinic'.equals(newAccount.OneAccount_Type__c) || 'Hospital'.equals(newAccount.OneAccount_Type__c) 
                    || 'University'.equals(newAccount.OneAccount_Type__c) || 'Government'.equals(newAccount.OneAccount_Type__c) 
                    || 'Insurance Care Center'.equals(newAccount.OneAccount_Type__c) || 'Purchasing Group'.equals(newAccount.OneAccount_Type__c))) {
                    newAccount.RecordTypeId = GlobalUtils.getRecordTypeId(SOBJECT_NAME,SOBJECT_RECORD_TYPES.get('Non_ERP_Account'));
            }
            // Used for ONE SFDC to check values in Account Type & ERP# fields and set the correct record type of the Account.
            if(notInRecordTypesList 
                && newAccount.RecordTypeId != GlobalUtils.getRecordTypeId(SOBJECT_NAME, SOBJECT_RECORD_TYPES.get('CIM_Account'))
                && String.ISNOTBLANK(newAccount.Movex__c)
                &&  (String.ISBLANK(newAccount.RecordTypeId) 
                     || newAccount.RecordTypeId != GlobalUtils.getRecordTypeId(SOBJECT_NAME,SOBJECT_RECORD_TYPES.get('ERP_Account')))
                &&  ('Dental Clinic'.equals(newAccount.OneAccount_Type__c) || 'Hospital'.equals(newAccount.OneAccount_Type__c) 
                    || 'University'.equals(newAccount.OneAccount_Type__c) || 'Government'.equals(newAccount.OneAccount_Type__c) 
                    || 'Insurance Care Center'.equals(newAccount.OneAccount_Type__c) || 'Purchasing Group'.equals(newAccount.OneAccount_Type__c))) {
                newAccount.RecordTypeId = GlobalUtils.getRecordTypeId(SOBJECT_NAME,SOBJECT_RECORD_TYPES.get('ERP_Account'));
            }
            //Used for ONE SFDC to check values in Account Type & ERP# fields and set the correct record type of the Account.
            if(notInRecordTypesList
                && newAccount.RecordTypeId != GlobalUtils.getRecordTypeId(SOBJECT_NAME,SOBJECT_RECORD_TYPES.get('CIM_Account'))
                && (String.ISNOTBLANK(newAccount.Movex__c))  
                && (String.ISBLANK(newAccount.RecordTypeId) 
                     || newAccount.RecordTypeId != GlobalUtils.getRecordTypeId(SOBJECT_NAME,SOBJECT_RECORD_TYPES.get('ERP_Lab_Account')))
                &&  'Dental Laboratory'.equals(newAccount.OneAccount_Type__c)) {
                   newAccount.RecordTypeId = GlobalUtils.getRecordTypeId(SOBJECT_NAME,SOBJECT_RECORD_TYPES.get('ERP_Lab_Account'));
             }
            //  Used for ONE SFDC to check values in Account Type & ERP# fields and set the correct record type of the Account.
            if(notInRecordTypesList 
                && newAccount.RecordTypeId != GlobalUtils.getRecordTypeId(SOBJECT_NAME,SOBJECT_RECORD_TYPES.get('CIM_Account'))
                && (String.ISNOTBLANK(newAccount.Movex__c))  
                && (String.ISBLANK(newAccount.RecordTypeId) 
                    || newAccount.RecordTypeId != GlobalUtils.getRecordTypeId(SOBJECT_NAME,SOBJECT_RECORD_TYPES.get('ERP_Distributor')))  
                && ( 'Wholesaler'.equals(newAccount.OneAccount_Type__c) || 'Distributor'.equals(newAccount.OneAccount_Type__c))) {
                newAccount.RecordTypeId = GlobalUtils.getRecordTypeId(SOBJECT_NAME,SOBJECT_RECORD_TYPES.get('ERP_Distributor'));
            }
            // Used for ONE SFDC to check values in Account Type & ERP# fields and set the correct record type of the Account.
            if(notInRecordTypesList 
                && newAccount.RecordTypeId != GlobalUtils.getRecordTypeId(SOBJECT_NAME,SOBJECT_RECORD_TYPES.get('CIM_Account'))
                && String.ISBLANK(newAccount.Movex__c) 
                && (String.ISBLANK(newAccount.RecordTypeId) 
                    || newAccount.RecordTypeId != GlobalUtils.getRecordTypeId(SOBJECT_NAME,SOBJECT_RECORD_TYPES.get('Competitor')))  
                &&  'Competitor'.equals(newAccount.OneAccount_Type__c)) {
                newAccount.RecordTypeId = GlobalUtils.getRecordTypeId(SOBJECT_NAME,SOBJECT_RECORD_TYPES.get('Competitor'));
            }
            // Used for ONE SFDC to check values in Account Type & ERP# fields and set the correct record type of the Account.
            if(newAccount.RecordTypeId != GlobalUtils.getRecordTypeId(SOBJECT_NAME,SOBJECT_RECORD_TYPES.get('CIM_Account'))
               &&(String.ISBLANK(newAccount.RecordTypeId) 
                  || newAccount.RecordTypeId != GlobalUtils.getRecordTypeId(SOBJECT_NAME,SOBJECT_RECORD_TYPES.get('Geographical_Account')))  
               &&  ('Dealer Sell Out Data Region'.equals(newAccount.OneAccount_Type__c) || 'Zip/Postal Code'.equals(newAccount.OneAccount_Type__c)
                    || 'First letters of Zip/Postal Code'.equals(newAccount.OneAccount_Type__c)|| 'Region'.equals(newAccount.OneAccount_Type__c) 
                    || 'Country'.equals(newAccount.OneAccount_Type__c))) {
                newAccount.RecordTypeId = GlobalUtils.getRecordTypeId(SOBJECT_NAME,SOBJECT_RECORD_TYPES.get('Geographical_Account'));
            }
        }
    }
    /*------------------------------------------------------------ 
    Description:    Method migrated from  Workflows
                    WF-ACC-37 : 'Set product area = Dental' (Created on 12/01/2017)
                    WF-ACC-38 : 'Update Loss Type (D)' (Created on 04/02/2010)
                    WF-ACC-39 : 'Set Implant Segmentation N/A' (Created on 16/02/2015)  
                    WF-ACC-40 : 'Set AWO Approval Date' (Created on 06/07/2010)   
                    WF-ACC-41 : 'Override Custom Segmentation' (Created on 16/02/2015)  
    Inputs:         @param newAccount
    ------------------------------------------------------------*/
    public static void updateAccountsInfo(List<Account> newAccountList) {
        List<String> recordTypes4 = new List<String> {SOBJECT_RECORD_TYPES.get('Partner_DI'),
                                                        SOBJECT_RECORD_TYPES.get('ERP_Account'),
                                                        SOBJECT_RECORD_TYPES.get('ERP_Distributor'),
                                                        SOBJECT_RECORD_TYPES.get('ERP_Lab_Account'),
                                                        SOBJECT_RECORD_TYPES.get('Geographical_Account'),
                                                        SOBJECT_RECORD_TYPES.get('Non_ERP_Account'),
                                                        SOBJECT_RECORD_TYPES.get('Non_ERP_Distributor'),
                                                        SOBJECT_RECORD_TYPES.get('Non_ERP_Lab_Account')};
        for(Account newAccount: newAccountList) {                                                
            // Set product area = Dental
            if(!'Dental'.equals(newAccount.Product_Area__c)) {
               newAccount.Product_Area__c = 'Dental'; 
            }
            // States if this customer is replacing/is a replacement of an old Movex#.
            // If 0= Customer is replacing an old customer. This means this is not a "truly NEW" customer.
            // If 1 =  This customer is being replaced. This meas this is not a "truly LOST customer"
            if(newAccount.Movex_Reference_Reason__c == 1 
              && !GlobalUtils.ifRecordTypeInList(SOBJECT_NAME, recordTypes4, newAccount.RecordTypeId) ) {
                  newAccount.Loss_Type_D__c= 'Administrative Reason';
            }
            // Segmentation N/A will be selected automatically (Dominant rule) by the system when one of the following criteria is true:
            // Movex status is 90 or 10
            // Movex Product Area (OKHAFE) contains “X” such as “DX” for Movex countries 
            if(('10'.equals(newAccount.Status__c) || '90'.equals(newAccount.Status__c))
              && String.isNotBlank(newAccount.Movex_Product_Area_OKHAFE__c) && newAccount.Movex_Product_Area_OKHAFE__c.contains('x')
              && newAccount.RecordTypeId == GlobalUtils.getRecordTypeId(SOBJECT_NAME,'Clinical_Customer_D')) {
               newAccount.Custom_Segmentation__c  = 'Segmentation N/A';  
            }
            // Sets the date when the AWO was first Approved. If the AWO-field is disabled, this field 
            // will NOT be changed, which means that it shows the FIRST time the customer was approved.
            // Used for analysis and reporting
            if(newAccount.AWO_Approval_Date__c == null && newAccount.Atlantis_Web_Order_Customer__c) {
                newAccount.AWO_Approval_Date__c = Date.today() - 1;
            }
            //To guarantee the quality of Custom Segmentation , this rule validates the selection in that
            // field and deselect it if the criteria are not met. Refer to the training material for more details.
            if(('Segmentation N/A'.equals(newAccount.Custom_Segmentation__c)
                && (newAccount.Implants_Potential_Year__c > 0 || newAccount.Referral_Potential_Year__c >= 5) 
                && (String.ISBLANK(newAccount.Status__c) || '20'.equals(newAccount.Status__c)))   
                || 
                ('Educate'.equals(newAccount.Custom_Segmentation__c) && newAccount.Implants_Potential_Year__c > 0 
                 && (String.ISBLANK(newAccount.Status__c) || '20'.equals(newAccount.Status__c)))   
                || 
                ('Implants Starter'.equals(newAccount.Custom_Segmentation__c) 
                 && ('Medium Usage'.equals(newAccount.Volume_Implants__c) || 'High Usage'.equals(newAccount.Volume_Implants__c) 
                     || 'No Usage'.equals(newAccount.Volume_Implants__c)))) {
                newAccount.Custom_Segmentation__c  = '';
            }
        }
    }
    /*------------------------------------------------------------ 
    Description:        
    Inputs:         @param newAccount List
    ------------------------------------------------------------*/
    public static void updateAccountsStrategyIcon(List<Account> newAccountList) {
        List<String> recordTypes = new List<String> {SOBJECT_RECORD_TYPES.get('Non_ERP_Lab_Account'),
            SOBJECT_RECORD_TYPES.get('ERP_Account'),SOBJECT_RECORD_TYPES.get('ERP_Distributor'),
            SOBJECT_RECORD_TYPES.get('ERP_Lab_Account'),SOBJECT_RECORD_TYPES.get('Non_ERP_Account'),
            SOBJECT_RECORD_TYPES.get('Non_ERP_Distributor')};
                                                        
                                                   
        Map<String, String> accountStrategyImplantsMap = new Map<String, String> {'GET' => '01520000001F35r',
            'GROW' => '01520000001F35x', 'KEEP' => '01520000001F361', 'TIME MINIMISE' => '01520000001F36B',
            'EDUCATE' => '01520000001F35o', 'STARTER' => '01520000001F368', 'REFERRAL' => '01520000001F367'};
        Map<String, String> accountStrategyATLAbutMap = new Map<String, String> {'GET' => '01520000001F35p',
            'GROW' => '01520000001F35w','KEEP' => '01520000001F35z','TIME MINIMISE' => '01520000001F369'};
        Map<String, String> accountStrategyATLISUSMap = new Map<String, String> {'GET' => '01520000001F35s',
            'GROW' => '01520000001F35y','KEEP' => '01520000001F362','TIME MINIMISE' => '01520000001F36C'};
        Map<String, String> accountStrategySBUORTHMap = new Map<String, String> {'GET' => '01520000001F35t',
            'GROW' => '01520000003gXfm','KEEP' => '01520000001F363','TIME MINIMISE' => '01520000001F36D'};
        Map<String, String> accountStrategySBUPREVMap = new Map<String, String> {'GET' => '01520000001F35u',
            'GROW' => '01520000001F35l','KEEP' => '01520000001F364','TIME MINIMISE' => '01520000001F36E'};
        Map<String, String> accountStrategySBURESTMap = new Map<String, String> {'GET' => '01520000001F35v',
            'GROW' => '01520000001F35n','KEEP' => '01520000001F366','TIME MINIMISE' => '01520000001F36G'};
        Map<String, String> accountStrategySBUENDOMap = new Map<String, String> {'GET' => '01520000001F35q',
            'GROW' => '01520000001F35k','KEEP' => '01520000001F360','TIME MINIMISE' => '01520000001F36A'};       
        Map<String, String> accountStrategySBUPROSMap = new Map<String, String> {'GET' => '01520000001F35j',
            'GROW' => '01520000001F35m','KEEP' => '01520000001F365','TIME MINIMISE' => '01520000001F36F'};
        String defaultValue = '01520000001F4Er';
        for(Account account : newAccountList) {
            System.debug('hola ' + account.Name + ' ' + account.Account_Strategy_Implants__c) ;
            String result = '';
            if(GlobalUtils.ifRecordTypeInList(SOBJECT_NAME, recordTypes, account.RecordTypeId) ) {
                if(account.Owner.SF_Implementation_Level__c != null &&
                    account.Owner.SF_Implementation_Level__c.contains('Basic')) {
                    if(account.Account_Strategy_Implants_Basic__c != null 
                        && accountStrategyImplantsMap.containsKey(account.Account_Strategy_Implants_Basic__c)) {
                        result+= accountStrategyImplantsMap.get(account.Account_Strategy_Implants_Basic__c);
                    }else {
                        result+= defaultValue;
                    }
                }else {
                    if(account.Account_Strategy_Implants__c != null 
                        && accountStrategyImplantsMap.containsKey(account.Account_Strategy_Implants__c)) {
                        result+= accountStrategyImplantsMap.get(account.Account_Strategy_Implants__c);
                    }else {
                        result+= defaultValue;
                    }
                }
                if(account.Account_Strategy_ATL_Abut__c != null 
                   && accountStrategyATLAbutMap.containsKey(account.Account_Strategy_ATL_Abut__c)) {
                       result+= accountStrategyATLAbutMap.get(account.Account_Strategy_ATL_Abut__c);
                }else {
                    result+= defaultValue;
                }
                
                if(account.Account_Strategy_ATL_ISUS__c != null 
                   && accountStrategyATLISUSMap.containsKey(account.Account_Strategy_ATL_ISUS__c)) {
                       result+= accountStrategyATLISUSMap.get(account.Account_Strategy_ATL_ISUS__c);
                }else {
                    result+= defaultValue;
                }
                
                if(account.Account_Strategy_SBU_ORTH__c != null 
                   && accountStrategySBUORTHMap.containsKey(account.Account_Strategy_SBU_ORTH__c)) {
                       result+= accountStrategySBUORTHMap.get(account.Account_Strategy_SBU_ORTH__c);
                }else {
                    result+= defaultValue;
                }
                
                if(account.Account_Strategy_SBU_PREV__c != null 
                   && accountStrategySBUPREVMap.containsKey(account.Account_Strategy_SBU_PREV__c)) {
                       result+= accountStrategySBUPREVMap.get(account.Account_Strategy_SBU_PREV__c);
                }else {
                    result+= defaultValue;
                }
                
                if(account.Account_Strategy_SBU_REST__c != null 
                   && accountStrategySBURESTMap.containsKey(account.Account_Strategy_SBU_REST__c)) {
                       result+= accountStrategySBURESTMap.get(account.Account_Strategy_SBU_REST__c);
                }else {
                    result+= defaultValue;
                }
                
                if(account.Account_Strategy_SBU_ENDO__c != null 
                   && accountStrategySBUENDOMap.containsKey(account.Account_Strategy_SBU_ENDO__c)) {
                       result+= accountStrategySBUENDOMap.get(account.Account_Strategy_SBU_ENDO__c);
                }else {
                    result+= defaultValue;
                }
                
                if(account.Account_Strategy_SBU_PROS__c != null 
                   && accountStrategySBUPROSMap.containsKey(account.Account_Strategy_SBU_PROS__c)) {
                       result+= accountStrategySBUPROSMap.get(account.Account_Strategy_SBU_PROS__c);
                }else {
                    result+= defaultValue;
                }
                account.Acc_Strategy_Icons_HQ__c = result;
            }
        }
    }

    /*------------------------------------------------------------ 
    Description:    Method used for Account Sub Segmentation categorization in before insert and before update
                    Queries AccountSubSegmentationMatrix__mdt to determine logic
    Inputs:         @param newAccountList @param oldAccountMap
    ------------------------------------------------------------*/
    public static void setAccountSubSegmentation(List<Account> newAccountList, Map<Id, Account> oldAccountMap) {
        Set<String> countrySet = new Set<String>();
        // Loop through accounts and add their countries to a set
        for (Account accountRecord : newAccountList) {
            if (!String.isBlank(accountRecord.Country__c)) {
                countrySet.add(accountRecord.Country__c);
            } 
            if (null != oldAccountMap && !String.isBlank(oldAccountMap.get(accountRecord.Id).Country__c)) {
                countrySet.add(oldAccountMap.get(accountRecord.Id).Country__c);
            } 
        }
        // Use the account countrySet to filter accsubseg mdt
        List<AccountSubSegmentationMatrix__mdt> accSubSegList = new List<AccountSubSegmentationMatrix__mdt>([
            SELECT Country__c, ControllingField__c, TargetField__c, MediumThresholdMax__c, MediumThresholdMin__c, LowThresholdMIN__c
            FROM AccountSubSegmentationMatrix__mdt
            WHERE Country__c IN :countrySet
        ]);
        // Escape if no AccountSubSegmentationMatrix__mdt exists for the accounts
        if (accSubSegList.isEmpty()) return;
        // Put accsubseg mdt records in a map containing lists of mdt with country as key
        Map<String, List<AccountSubSegmentationMatrix__mdt>> countryAccSubSegMap = new Map<String, List<AccountSubSegmentationMatrix__mdt>>();
        for (AccountSubSegmentationMatrix__mdt accSubSegRecord : accSubSegList) {
            if (countryAccSubSegMap.containsKey(accSubSegRecord.Country__c)) {
                countryAccSubSegMap.get(accSubSegRecord.Country__c).add(accSubSegRecord);
            } else {
                countryAccSubSegMap.put(accSubSegRecord.Country__c, new List<AccountSubSegmentationMatrix__mdt>{accSubSegRecord});
            }
        }
        // Main logic
        for (Account accountRecord : newAccountList) {
            // Scrub old target fields if this is an update and Account.Country__c has changed
            if (null != oldAccountMap) {
                String oldAccountCountry = !String.isBlank(oldAccountMap.get(accountRecord.Id).Country__c) ? oldAccountMap.get(accountRecord.Id).Country__c : 'null';
                if (!oldAccountCountry.equals(accountRecord.Country__c) && null != countryAccSubSegMap.get(oldAccountCountry)) {
                    for (AccountSubSegmentationMatrix__mdt accSubSegRecord : countryAccSubSegMap.get(oldAccountCountry)) {
                        try {
                            accountRecord.put(accSubSegRecord.TargetField__c, null);
                        } catch (Exception e) {
                            DebugLog.addException(e, 'AccountTriggerHelper.setAccountSubSegmentation');
                        }
                    }
                }
            }
            // Do the main logic to set the target fields only if we have mdt for the Account.Country__c
            if (null == countryAccSubSegMap.get(accountRecord.Country__c)) continue;
            for (AccountSubSegmentationMatrix__mdt accSubSegRecord : countryAccSubSegMap.get(accountRecord.Country__c)) {
                Integer newAccControllingField = Integer.valueOf(accountRecord.get(accSubSegRecord.ControllingField__c));
                // Escape block
                if (null == oldAccountMap && null == newAccControllingField) {
                    continue;
                } else if (null != oldAccountMap && false == forceUpdate) {
                    Integer oldAccControllingField = Integer.valueOf(oldAccountMap.get(accountRecord.Id).get(accSubSegRecord.ControllingField__c));
                    String oldAccCountry = oldAccountMap.get(accountRecord.Id).Country__c;
                    if (newAccControllingField == oldAccControllingField && accountRecord.Country__c.equals(oldAccCountry)) continue;
                }
                // Main logic
                try {
                    if (null == newAccControllingField) {
                        accountRecord.put(accSubSegRecord.TargetField__c, null);
                    } else if (newAccControllingField < accSubSegRecord.LowThresholdMIN__c) {
                        accountRecord.put(accSubSegRecord.TargetField__c, 'N/A');
                    } else if (newAccControllingField > accSubSegRecord.MediumThresholdMAX__c) {
                        accountRecord.put(accSubSegRecord.TargetField__c, 'High');
                    } else if (newAccControllingField < accSubSegRecord.MediumThresholdMIN__c) {
                        accountRecord.put(accSubSegRecord.TargetField__c, 'Low');
                    } else {
                        accountRecord.put(accSubSegRecord.TargetField__c, 'Medium');
                    }
                } catch (Exception e) {
                    DebugLog.addException(e, 'AccountTriggerHelper.setAccountSubSegmentation');
                }
            }
        }
    }
    
    
    /*------------------------------------------------------------ 
    Description:    Method to update Turkish contacts that are having MailingAddress = Account.BillingAddress with the new BillingAddress from the related account  
    Inputs:         @param newAccount List
                    @param oldAccountMap Map
                    @param newAccountMap Map
    ------------------------------------------------------------*/
    public static void updateRelatedContactAddresses(List<Account> newAccountList, Map<Id, Account> oldAccountMap, Map<Id, Account> newAccountMap) {
        List<String> recordTypes = new List<String> {SOBJECT_RECORD_TYPES.get('Non_ERP_Lab_Account'),
            SOBJECT_RECORD_TYPES.get('ERP_Account'),SOBJECT_RECORD_TYPES.get('ERP_Distributor'),
            SOBJECT_RECORD_TYPES.get('ERP_Lab_Account'),SOBJECT_RECORD_TYPES.get('Non_ERP_Account'),
            SOBJECT_RECORD_TYPES.get('Non_ERP_Distributor')};                                             
        
        Map<Id, String> changedAccounts = new Map<Id, String>();
            
        for(Account account : newAccountList) {
            if(GlobalUtils.ifRecordTypeInList(SOBJECT_NAME, recordTypes, account.RecordTypeId) ){
                
                //Find all Turkish accounts where any part of the address has changed
                if('TR'.equals(account.Country__c) && 
                (account.BillingStreet != oldAccountMap.get(account.Id).BillingStreet ||
                account.BillingCity != oldAccountMap.get(account.Id).BillingCity ||
                account.BillingPostalCode != oldAccountMap.get(account.Id).BillingPostalCode ||
                account.BillingCountry != oldAccountMap.get(account.Id).BillingCountry ||
                account.BillingState != oldAccountMap.get(account.Id).BillingState)
                )
                {
                        changedAccounts.put(account.Id, account.Name);
                }
            }
        }
    
        //Find all contacts related to the previously found accounts
        List<Contact> contacts= [SELECT Id, Name, MailingCity, MailingStreet, MailingPostalCode, MailingCountry, MailingState, AccountId FROM Contact WHERE Account.Id IN: changedAccounts.keySet()];

        List<Contact> contactsToUpdate = new List<Contact>();

        for(Contact contact : contacts){
            if(
                //Only add contacts that had the exact same address as the account
                contact.MailingStreet == oldAccountMap.get(contact.AccountId).BillingStreet && 
                contact.MailingCity == oldAccountMap.get(contact.AccountId).BillingCity &&
                contact.MailingPostalCode == oldAccountMap.get(contact.AccountId).BillingPostalCode &&
                contact.MailingCountry == oldAccountMap.get(contact.AccountId).BillingCountry &&
                contact.MailingState == oldAccountMap.get(contact.AccountId).BillingState
            ){
                contact.MailingStreet = newAccountMap.get(contact.AccountId).BillingStreet;
                contact.MailingCity = newAccountMap.get(contact.AccountId).BillingCity;
                contact.MailingPostalCode = newAccountMap.get(contact.AccountId).BillingPostalCode;
                contact.MailingCountry = newAccountMap.get(contact.AccountId).BillingCountry;
                contact.MailingState = newAccountMap.get(contact.AccountId).BillingState;
                contactsToUpdate.add(contact);
            }
        }
        
        if(!contactsToUpdate.IsEmpty()){
            try{
                update contactsToUpdate;     
            }
            catch(DmlException e){
                DebugLog.addException(e, 'updateRelatedContactAddresses');
            }
        }
        
    }
    
    /*------------------------------------------------------------ 
    Description:    Method to create an entitlement for each newly created account. It uses a custom metadata to find the correct entitlement id for each country
    Inputs:         @param newAccount List
    ------------------------------------------------------------*/
    public static void createEntitlement(Account[] newAccs) {
        
        List <Entitlement> createEntitlement = new List <Entitlement> {};
        Map <Id,Entitlement> mapOfAccountIdToEntitlement = new Map <Id,Entitlement> ();
        Map <String,String> countrySLAMap = new Map <String,String> ();
        Map <String,Id> slaMap = new Map <String,Id> ();
        Set <String> countriesSet = new Set <String> ();
        
        for (Account acc: newAccs) {
            countriesSet.add(acc.Country__c);
        }
        
        List <CountrySLA__mdt> customData = [Select Entitlement_Process__c, Country__c from CountrySLA__mdt where Country__c IN: countriesSet];
        for (CountrySLA__mdt c: customData) {
            if (!customData.isEmpty()) {
                countrySLAMap.put(c.Entitlement_Process__c, c.Country__c);
            }
            else{
                return;
            }
        }
        
        List <SlaProcess> slaProcesses = [select name, id, VersionNumber from SlaProcess where name IN: countrySLAMap.keySet() and IsActive = true];
        for (SlaProcess s: slaProcesses) {
            if (!slaProcesses.isEmpty()) {
                slaMAp.put(countrySLAMap.get(s.name), s.Id);
            }
            else{
                return;
            }
        }
        
        List <Entitlement> entitlement = [Select AccountId From Entitlement Where AccountId in: newAccs];
        for (Entitlement et: entitlement) {
            if (!entitlement.isEmpty()) {
                mapOfAccountIdToEntitlement.put(et.AccountId, et);
            }
            else{
                return;
            }
        }
        
        // Check whether the account has an existing entitlement 
        for (Account acc: newAccs) {
            Boolean alreadyhasEntitlement = mapOfAccountIdToEntitlement.containsKey(acc.Id);
            if (!mapOfAccountIdToEntitlement.containsKey(acc.Id) && slaMAp.containsKey(acc.Country__c)) {            
                createentitlement.add(new Entitlement( Name = acc.name, /* Give a standard name*/
                                                      AccountId = acc.Id, /* Link the Entitlement to the account */
                                                      SlaProcessId = slaMAp.get(acc.Country__c), /* Link it to a defined entitlement process */
                                                      StartDate = system.Today(),
                                                      EndDate = system.today() + 1095, /* Set EndDate after 3 years */
                                                      Type = 'Phone Support'));
                
            }
        }
        try {
            insert createEntitlement;
        } catch (DMLException e) {
            DebugLog.addException(e, 'Error on Create Entitlement');
        }
        
    }
}