/*-------------------------------------------------------------------------------------------------------
Author:         Ahmed LOUDRASSI (Salesforce) 20191022
Description:    Campaign Member Trigger Helper Class
History
20191022   Ahmed LOUDRASSI   Migrated CampMgmtCampaignMemberTrigger and CampMgmtCampaignMemberTrigger2 triggers. (#)
20191022   Ahmed LOUDRASSI   Migrated CampaignMember Workflows. (#)
20201222   Richard Trum		 Created method createOpportunities for creating and assigning Opportunities based on Eloqua campaigns
20210204   Richard Trum		 Updated method createOpportunities for creating and assigning Sales Leads based on Eloqua campaigns
20210318   Roberto Narbona	 Updated to send opp ID back into Sales Lead__c field for Campaign Members and have physical relationship. Story TFUS-000002828
20210720   Kevin Ruibin Do   Updated method createOpportunities to also populate Opportunity.ContactId so that an OpportunityContactRole will be created
20211208   Roberto Narbona	 Updated method createOpportunities to fix account relationship when convertion is from standard lead

----------------------------------------------------------------------------------------*/
public class CampaignMemberTriggerHelper {
    private static final String SOBJECT_CAMPAIGN = 'Campaign';
    private static final Map<String, String> CAMPAIGN_RECORD_TYPES =
        new Map<String, String> {'DI_Campaign' => 'DI_Campaign'};
            /*------------------------------------------------------------
Description:    Method migrated from  CampMgmtCampaignMemberTrigger

Inputs:         @param newCampaignMembers
------------------------------------------------------------*/
            public static void updateCampaignMemberAccount(List<CampaignMember> newCampaignMembers) {
                // Don't run unless configured to do so.
                BatchSettings__c settings = BatchSettings__c.getInstance('Default');
                if (Test.isRunningTest() || settings.CampMgmtCampaignMemberTriggerIsEnabled__c){
                    Set<ID> contactIdList = new Set<ID>();
                    for (CampaignMember cm : newCampaignMembers) {
                        if (cm.ContactId != null)
                            contactIdList.add(cm.ContactId);
                    }
                    
                    Map<ID, Contact> contactMap = new Map<ID, Contact>(
                        [SELECT Id, AccountId FROM Contact WHERE Id IN :contactIdList]);
                    
                    for (CampaignMember cm : newCampaignMembers) {
                        if (cm.ContactId != null) {
                            Contact c = contactMap.get(cm.ContactId);
                            cm.Account__c = c.AccountId;
                        }
                    }
                }
            }
    /*------------------------------------------------------------
Description:    Method migrated from  CampMgmtCampaignMemberTrigger2

Inputs:         @param newCampaignMembers
------------------------------------------------------------*/
    public static void updateCampaignAndAccountIdCMList(List<CampaignMember> newCampaignMembers) {
        // Don't run unless configured to do so.
        BatchSettings__c settings = BatchSettings__c.getInstance('Default');
        if (Test.isRunningTest() || settings.CampMgmtCampaignMemberTriggerIsEnabled__c) {
            Set<ID> campaignIdList = new Set<ID>();
            Set<ID> accountIdList = new Set<ID>();
            for (CampaignMember cm : newCampaignMembers) {
                if (cm.CampaignId != null)
                    campaignIdList.add(cm.CampaignId);
                if (cm.Account__c != null)
                    accountIdList.add(cm.Account__c);
            }
            
            Map<ID, Campaign> campaignMap = new Map<ID, Campaign>(
                [SELECT Id, CampaignMemberAccountIdList__c FROM Campaign WHERE Id IN :campaignIdList]);
            
            Map<ID, Account> accountMap = new Map<ID, Account>(
                [SELECT Id, ContactCampaignIdList__c FROM Account WHERE Id IN :accountIdList]);
            for (CampaignMember cm : newCampaignMembers) {
                if (cm.CampaignId != null) {
                    Campaign c = campaignMap.get(cm.CampaignId);
                    Set<String> accountIds = new Set<String>();
                    if (c.CampaignMemberAccountIdList__c != null)
                        accountIds.addAll(c.CampaignMemberAccountIdList__c.split(',', 0));
                    if (cm.Account__c != null && cm.Status == 'Confirmed' && cm.Type__c == 'Participant')
                        accountIds.add(String.valueOf(cm.Account__c).substring(0, 15));
                    
                    c.CampaignMemberAccountIdList__c = String.join(new List<String>(accountIds), ',');
                }
                
                if (cm.Account__c != null){
                    Account a = accountMap.get(cm.Account__c);
                    
                    Set<String> campaignIds = new Set<String>();
                    if (a.ContactCampaignIdList__c != null)
                        campaignIds.addAll(a.ContactCampaignIdList__c.split(',', 0));
                    
                    if (cm.CampaignId != null && cm.Status == 'Confirmed' && cm.Type__c == 'Participant')
                        campaignIds.add(String.valueOf(cm.CampaignId).substring(0, 15));
                    
                    a.ContactCampaignIdList__c = String.join(new List<String>(campaignIds), ',');
                }
            }
            try {
                if(!campaignMap.values().isEmpty()) {
                    update campaignMap.values();
                }
                if(!accountMap.values().isEmpty()) {
                    update accountMap.values();
                }
            } catch(DMLException e) {
                DebugLog.addError(e.getMessage());
            }
            
        }
    }
    /*------------------------------------------------------------
Description:    Method migrated from  Workflows
WF-CAMM-01 : 'Set Account Strategy and W/L status' (Created on 27/05/2014)
WF-CAMM-02 : 'Set DI Campaign Member Info Based On Campaign' (Created on 23/06/2013)
Inputs:         @param newCampaignMembers
------------------------------------------------------------*/
    public static void updateCampaignMembersInfo(List<CampaignMember> newCampaignMembers) {
        List<Id> campaignIds = new List<Id> ();
        for(CampaignMember campaignMember : newCampaignMembers) {
            campaignIds.add(campaignMember.CampaignId);
        }
        Map<Id,Campaign> campaigns =
            new Map<Id,Campaign> ([SELECT Id, RecordTypeId FROM  Campaign WHERE Id in :campaignIds]);
        for(CampaignMember campaignMember : newCampaignMembers) {
            // Set Account Strategy and W/L status
            if(campaigns.get(campaignMember.CampaignId).RecordTypeId  ==
               GlobalUtils.getRecordTypeId(SOBJECT_CAMPAIGN, CAMPAIGN_RECORD_TYPES.get('DI_Campaign'))) {
                   campaignMember.Account_Strategy_ATL_Abut__c = campaignMember.Current_Account_Strategy_ATL_Abut__c;
                   campaignMember.Account_Strategy_ATL_ISUS__c = campaignMember.Current_Account_Strategy_ATL_ISUS__c;
                   campaignMember.Account_Strategy_Implants__c = campaignMember.Current_Account_Strategy_Implants__c;
                   campaignMember.Account_Strategy_SIMPLANT__c = campaignMember.Current_Account_Strategy_SIMPLANT__c;
                   campaignMember.ATL_Abut_Won_Lost_Status__c = campaignMember.Current_Account_Strategy_ATL_Abut__c;
                   campaignMember.ATL_ISUS_Won_Lost_Status__c = campaignMember.Current_Account_Strategy_ATL_ISUS__c;
                   campaignMember.Implants_Won_Lost_Status__c = campaignMember.Current_Implants_Won_Lost_Status__c;
                   campaignMember.Simplant_Won_Lost_Status__c = campaignMember.Current_WonLostStatus_Simplant__c;
               }
            // Set DI Campaign Member Info Based On Campaign
            if('Participant'.equals(campaignMember.Type__c)
               && campaigns.get(campaignMember.CampaignId).RecordTypeId  ==
               GlobalUtils.getRecordTypeId(SOBJECT_CAMPAIGN, CAMPAIGN_RECORD_TYPES.get('DI_Campaign'))) {
                   if('Single Room'.equals(campaignMember.of_Guests_including_participant__c)) {
                       campaignMember.Rate_per_night__c = campaignMember.Campaign.Single_Room_Rate_Per_Night__c;
                   } else if('Double Room'.equals(campaignMember.of_Guests_including_participant__c)) {
                       campaignMember.Rate_per_night__c = campaignMember.Campaign.Double_Room_Rate_Per_Night__c;
                   } else {
                       campaignMember.Rate_per_night__c = null;
                   }
                   campaignMember.Course_Fee__c = campaignMember.Campaign.Standard_Participation_Fee__c;
                   campaignMember.VAT__c = campaignMember.Campaign.VAT__c;
               }
        }
    }
    /*------------------------------------------------------------
Description:    Method migrated from  Workflows
WF-CAMM-03 : 'Set international speaker field' (Created on 12/10/2015)
Inputs:         @param newCampaignMembers
------------------------------------------------------------*/
    public static void setInternationalSpeaker(List<CampaignMember> newCampaignMembers) {
        List<Id> contactIds = new List<Id> ();
        for(CampaignMember campaignMember : newCampaignMembers) {
            contactIds.add(campaignMember.ContactId);
        }
        Map<Id,Contact> contacts =
            new Map<Id,Contact> ([SELECT Id, International_Speaker__c FROM  Contact WHERE Id in :contactIds]);
        for(CampaignMember campaignMember : newCampaignMembers) {
            // Set international speaker
            if(campaignMember.ContactId <> null && contacts.get(campaignMember.ContactId).International_Speaker__c) {
                campaignMember.International_Speaker__c = true;
            }
        }
    }
    
    /*------------------------------------------------------------
Description:    Method for creating Opportunities based on Campaign Member related to Eloqua Campaigns (TFUS-[...]2201)
Inputs:         @param newCampaignMembers
------------------------------------------------------------*/
    
    public static void createOpportunities(List<CampaignMember> newCampaignMembers, Map<Id, CampaignMember> oldCampaignMemberMap, Boolean overrideHasResponded) {
        
        BatchSettings__c settings = BatchSettings__c.getInstance('Default');
        if (Test.isRunningTest() || settings.CampMgmtCampaignMemberTriggerIsEnabled__c){  
            System.debug(newCampaignMembers);
            List<RecordType> oppRT = [SELECT Id, Name FROM RecordType WHERE sObjectType='Opportunity' AND DeveloperName='Lightning_Pipeline_Opportunity'];
            List<RecordType> oppDealerRT = [SELECT Id, Name FROM RecordType WHERE sObjectType='Opportunity' AND DeveloperName='Dealer_Community'];
            
            Set<Id> campaignIds = new Set<Id>();
            Set<Id> contactIds = new Set<Id>();
            Set<Id> dealerIds = new Set<Id>();
            Set<Id> accountIds = new Set<Id>();
            Set<Id> stdLeadIds = new Set<Id>();
            
            for (CampaignMember te : newCampaignMembers) {
                if (te.CampaignId != null) {
                    campaignIds.add(te.CampaignId);
                }
                if(te.ContactId != null){
                    contactIds.add(te.ContactId);
                }
                if(te.Dealer__c != null){
                    dealerIds.add(te.Dealer__c);
                }
                if(te.LeadId != null){
                    stdLeadIds.add(te.LeadId);
                }
                //if(te.Account__c != null){
                //    accountIds.add(te.Account__c);
                //}
            }
            
            //Get all Campaigns related to the included Campaign Members 
            Map<Id, Campaign> campaigns = new Map<Id, Campaign>(
                [SELECT Id, RecordTypeId, Source_Origin__c, OwnerId, Brands__c, Convert_To__c, RecordType.DeveloperName, AssignRepFromDealer__c, Include_in_Dealer_Community__c, Notify_Dealer_Sales_Rep_by_Email__c from Campaign where Id in :campaignIds]
            );
            Boolean categoryOppDependencyRuleCheck = false;
            Boolean categorySalesLeadDependencyRuleCheck = false;
            Boolean recordTypeCheck = false;
            for(Campaign cmp : campaigns.values()){
                if(cmp.RecordType.DeveloperName == 'Digital_Marketing_Campaign' || cmp.RecordType.DeveloperName == 'InPersonEventCampaign'){
                    recordTypeCheck = true;
                    categoryOppDependencyRuleCheck = cmp.Convert_To__c == 'Opportunity' ? true : false ;
                    categorySalesLeadDependencyRuleCheck= cmp.Convert_To__c == 'Sales Lead' ? true : false ;
                }
            }
            //getting dependencyrules if needed
            Map<String,List<String>> dependentPicklistSalesLeadCountryCategoryMap = categorySalesLeadDependencyRuleCheck == true ? GlobalUtils.getDependentPicklistValues(Field_Sales_Project_Members__c.Category__c) : null;
            Map<String,List<String>> dependentPicklistSalesLeadCategoryBrandMap = categorySalesLeadDependencyRuleCheck == true ? GlobalUtils.getDependentPicklistValues(Field_Sales_Project_Members__c.Brand__c) : null;
            Map<String,List<String>> dependentPicklistOpportunityCountryCategoryMap = categoryOppDependencyRuleCheck == true ? GlobalUtils.getDependentPicklistValues(Opportunity.NA_Category__c) : null;
            Map<String,List<String>> dependentPicklistOpportunityCategoryBrandMap = categoryOppDependencyRuleCheck == true ? GlobalUtils.getDependentPicklistValues(Opportunity.NA_Brand__c) : null;

            
            if(recordTypeCheck == true){
                Map<Id, Lead> stdLeads = new Map<Id, Lead>();
                    
                //Get all Leads related to the included Campaign Members
                if(stdLeadIds != null){
                    for(Lead stdLead : [SELECT Id, ConvertedAccountId from Lead where Id in :stdLeadIds])
                        stdLeads.put(stdLead.Id, stdLead);
                } 
               
                
                //Get all Contacts related to the included Campaign Members
                Map<Id, Contact> contacts = new Map<Id, Contact>(
                    [SELECT Id, AccountId, Account.Country__c from Contact where Id in :contactIds]
                );
                
                //Add all related accounts to the accountIds set    
                for(Contact c : contacts.values()){
                    accountIds.add(c.AccountId);
                }     
                
                //Get all Dealers related to the included Campaign Members
                Map<Id, Account> dealers = new Map<Id, Account>(
                    [SELECT Id, Name, 
                     (SELECT AccountId, ContactId, IsActive, IsDirect, Roles, Specialty__c, Contact.Email, Contact.Legacy_ID__c FROM AccountContactRelations),
                     (SELECT AccountId, RoleInTerritory2, UserId FROM AccountUserTerritory2Views) 
                     FROM Account WHERE Id IN: dealerIds]
                );
                
                List<Id> dealerIdList = new List<Id>();
                dealerIdList.addAll(dealerIds);
                Map<Id, List<UserTerritory2Association>> dealerUserMap = new Map<Id, List<UserTerritory2Association>>();
                
                Map<Id, Id> externalDealerUserMap = new Map<Id, Id>();
                Set<Id> externalDealerContacts = new Set<Id>();    
                if(dealers.size()>0){
                    for(Account dealer : dealers.values()){
                        for(AccountContactRelation rel : dealer.AccountContactRelations){
                            externalDealerContacts.add(rel.ContactId);
                        }    
                    }
                    List<User> externalDealerUsers = new List<User>();    
                    if(externalDealerContacts!=null){    
                        externalDealerUsers = [SELECT Id, ContactId FROM User WHERE ContactId IN: externalDealerContacts];
                        for(User externalUser : externalDealerUsers){
                            externalDealerUserMap.put(externalUser.ContactId, externalUser.Id);
                        }        
                    }    
                    
                }    
                
                if(!Test.isRunningTest()){
                    dealerUserMap = UsersInAccountTerritories.getUsersFromMultipleAccounts(dealerIdList);
                }
                
                //Get all Customer Accounts related to the included Campaign Members
                Map<Id, Account> customers = new Map<Id, Account>(
                    [SELECT Id, Name, Country__c,
                     (SELECT AccountId, RoleInTerritory2, UserId FROM AccountUserTerritory2Views)
                     FROM Account WHERE Id IN: accountIds]
                );
                
                List<Id> accountIdList = new List<Id>();
                accountIdList.addAll(accountIds);
                Map<Id, List<UserTerritory2Association>> customerUserMap = new Map<Id, List<UserTerritory2Association>>(); 
                if(!Test.isRunningTest()){
                    customerUserMap = UsersInAccountTerritories.getUsersFromMultipleAccounts(accountIdList);
                }
                
                //Get all countries related to the included Campaign Members
                Set<String> countries = new Set<String>();
                for(Account customer : customers.values()){
                    countries.add(customer.Country__c);
                }
                
                //Get all open Opportunities related to each included account
                Map<Id, List<Opportunity>> oppMap = new Map<Id, List<Opportunity>>();
                
                List<Account> accOpps = [SELECT Id, (SELECT Id, Name, StageName, NA_Category__c, NA_Brand__c FROM Opportunities WHERE IsClosed = FALSE) FROM Account WHERE Id IN: accountIds];
                
                for(Account a : accOpps){
                    oppMap.put(a.Id, a.Opportunities);
                }
                
                //Get Custom Metadata records related to the previously queried countries
                LeadOpportunitySetting__mdt[] oppSettings = new LeadOpportunitySetting__mdt[]{};
                    if(Test.IsRunningTest()){
                        oppSettings = [SELECT DeveloperName, Category__c, Brands__c, BrandsList__c, Country__c, AssignOwnerFrom__c, UserRoles__c, IsTest__c FROM LeadOpportunitySetting__mdt WHERE IsTest__c =: true];
                    }
                else{
                    oppSettings = [SELECT DeveloperName, Category__c, Brands__c, BrandsList__c, Country__c, AssignOwnerFrom__c, UserRoles__c, IsTest__c FROM LeadOpportunitySetting__mdt WHERE Country__c IN: countries AND IsTest__c =: false];
                }
                
                List<OpportunityAssignment__c> pricebookSettingList = new List<OpportunityAssignment__c>();
                Map<String, String> pricebookSettingMap = new Map<String, String>();
                
                pricebookSettingList = [SELECT Country__c, PricebookId__c FROM OpportunityAssignment__c];
                for(OpportunityAssignment__c pbSetting : pricebookSettingList){
                    String countrySetting = pbSetting.Country__c;
                    String[] countryList = countrySetting.split(';');
                    for(String c : countryList){
                        pricebookSettingMap.put(c, pbSetting.PricebookId__c);
                    }
                }
                
                Map<String, LeadOpportunitySetting__mdt> settingsMap = new Map<String, LeadOpportunitySetting__mdt>();
                for(LeadOpportunitySetting__mdt setting: oppSettings){
                    if(setting.BrandsList__c != null){
                        String brands = setting.BrandsList__c;
                        String[] brandList = brands.split(';');
                        for(String brand : brandList){
                            settingsMap.put(brand, setting);
                        }
                    } 
                    else if(setting.Brands__c != null){
                        String brands = setting.Brands__c;
                        String[] brandList = brands.split(';');
                        for(String brand : brandList){
                            settingsMap.put(brand, setting);
                        }
                    }
                    else{
                        settingsMap.put(setting.Category__c, setting);
                    }    
                }
                
                Map<String, String> userCountryMap = new Map<String, String>();
                
                List<CountryCodeMap__mdt> countryCodes = [SELECT DeveloperName, Country_Code_2_digit__c, Campaign_Country__c FROM CountryCodeMap__mdt];
                
                for(CountryCodeMap__mdt country : countryCodes){
                    userCountryMap.put(country.Country_Code_2_digit__c, country.Campaign_Country__c);
                }
                
                List<oppWrapper> oppList = new List<oppWrapper>();
                //List<Field_Sales_Project_Members__c> leadList = new List<Field_Sales_Project_Members__c>();
                Map<Id,Field_Sales_Project_Members__c> memberIdWithLead =new Map<Id,Field_Sales_Project_Members__c>();
                
                for(CampaignMember campaignMember : newCampaignMembers) {
                    String recordType = campaigns.get(campaignMember.CampaignId).RecordType.DeveloperName;
                    String includeInCommunity = campaigns.get(campaignMember.CampaignId).Include_in_Dealer_Community__c;
                    String notifyDealerReps = campaigns.get(campaignMember.CampaignId).Notify_Dealer_Sales_Rep_by_Email__c;
                    String convertTo = campaigns.get(campaignMember.CampaignId).Convert_To__c;
                    Boolean assignFromDealer = campaigns.get(campaignMember.CampaignId).AssignRepFromDealer__c;
                    Boolean respondedBefore = false;
                    Boolean contactAdded = false;
                    
                    if(oldCampaignMemberMap != null){
                        if(oldCampaignMemberMap.containsKey(campaignMember.Id) == true){
                            respondedBefore = oldCampaignMemberMap.get(campaignMember.Id).HasResponded;
                            
                            if(oldCampaignMemberMap.get(campaignMember.Id).ContactId == null){
                                contactAdded = true;
                            }
                            
                        }
                    }
                    
                    //SALES LEAD CONVERSION
                    if(convertTo == 'Sales Lead' && (recordType == 'Digital_Marketing_Campaign' || recordType == 'InPersonEventCampaign')  && campaignMember.ContactId != null && campaignMember.HasResponded == true && (respondedBefore == false || overrideHasResponded == true)){ //&& (contacts.get(campaignMember.ContactId).Account.Country__c == 'US' || contacts.get(campaignMember.ContactId).Account.Country__c == 'CA')
                        Field_Sales_Project_Members__c lead = new Field_Sales_Project_Members__c();
                        lead.Status__c = 'New';
                        lead.Source__c = 'Email Campaign'; //campaigns.get(campaignMember.CampaignId).Source_Origin__c != null ? campaigns.get(campaignMember.CampaignId).Source_Origin__c : null;
                        
                        //Potentially comment out these lines in case no brand should be assigned
                        String brand = campaignMember.Brand__c;
                        
                        if(brand == null || brand == ''){                    
                            brand = campaigns.get(campaignMember.CampaignId).Brands__c;
                        }
                        
                        if(campaignMember.Dealer__c != null){
                            lead.Dealer__c = campaignMember.Dealer__c;
                        }
                        /*               
Boolean containsBrand = settingsMap.containsKey(brand);
if(containsBrand == false){
campaignMember.addError('A Sales Lead could unfortunately not be created. A matching setting seems to be missing for the selected Brand/Category.');                     	
}
*/
                        //Please note! This logic is now built around the CMDT CountryCodeMap__mdt
                        String accountCountry = contacts.get(campaignMember.ContactId).Account.Country__c;
                        String userCountry = userCountryMap.get(accountCountry);
                        
                        if(userCountry != null){
                            lead.UserCountry__c = userCountry;
                        }
                        
                        /*if(contacts.get(campaignMember.ContactId).Account.Country__c == 'US' || contacts.get(campaignMember.ContactId).Account.Country__c == 'CA'){
lead.UserCountry__c = 'USA';   dependentPicklistCountryCategoryMap
}*/
                        Lead.Category__c =  GlobalUtils.getCategoryFromBrand(userCountry ,brand ,dependentPicklistSalesLeadCountryCategoryMap,dependentPicklistSalesLeadCategoryBrandMap);
                        
                        //lead.Category__c = settingsMap.get(brand).Category__c;
                        Lead.Brand__c = brand;
                        lead.Account__c = campaignMember.LeadId == null ? contacts.get(campaignMember.ContactId).AccountId : stdLeads.get(campaignMember.LeadId).ConvertedAccountId;
                        lead.Contact__c = campaignMember.ContactId;
                        lead.Campaign__c = campaignMember.CampaignId;
                        lead.CustomerNotes__c = campaignMember.Description__c;
                        
                        Set<String> roleMap = new Set<String>();
                        if(settingsMap != null && settingsMap.get(brand) != null && settingsMap.get(brand).UserRoles__c != null){
                            String roleList = settingsMap.get(brand).UserRoles__c;
                            String[] roles = roleList.split(';');
                            for(String role:roles){
                                roleMap.add(role);
                            }
                        }
                        
                        List<UserTerritory2Association> accUsers = new List<UserTerritory2Association>();
                        
                        if(Test.isRunningTest()){
                            UserTerritory2Association accUser = new UserTerritory2Association();
                            accUser.RoleInTerritory2 = 'Sales Rep (CERC)'; 
                            accUsers.add(accUser);
                        }
                        else{
                            accUsers = customerUserMap.get(lead.Account__c);
                        }
                        if(accUsers != null){
                            for(UserTerritory2Association user:accUsers){
                                if(roleMap.contains(user.RoleInTerritory2)){
                                    lead.Sales_Rep__c = user.UserId;
                                }
                            }    
                        }
                        
                        if(lead.Sales_Rep__c == null){
                            lead.Sales_Rep__c = campaigns.get(campaignMember.CampaignId).OwnerId;
                        }
                        
                        //leadList.add(lead);
                        memberIdWithLead.put(campaignMember.Id,lead);
                        
                    }
                    
                    //OPPORTUNITY CONVERSION
                    if(convertTo == 'Opportunity' && (recordType == 'Digital_Marketing_Campaign' || recordType == 'InPersonEventCampaign') && campaignMember.ContactId != null && campaignMember.HasResponded == true && (respondedBefore == false || overrideHasResponded == true)){
                        String brand = campaignMember.Brand__c;
                        If(brand == null){
                            brand = campaigns.get(campaignMember.CampaignId).Brands__c;
                        }
                        
                        /*Boolean containsBrand = settingsMap.containsKey(brand);
                        if(containsBrand == false){
                            campaignMember.addError('An Opportunity could unfortunately not be created. A matching setting seems to be missing for the selected Brand.');                     	
                        }
                        else{*/
                            
                            Opportunity opp = new Opportunity();
                            if(includeInCommunity == 'Yes'){
                                opp.RecordTypeId = oppDealerRT[0].Id;
                                opp.StageName = 'Registered'; 
                            }
                            else{
                                opp.RecordTypeId = oppRT[0].Id;
                                opp.StageName = '1. Needs analysis';    
                            }                
                            
                            opp.LeadSource = 'Email Campaign'; //campaigns.get(campaignMember.CampaignId).Source_Origin__c != null ? campaigns.get(campaignMember.CampaignId).Source_Origin__c : null;
                            opp.CampaignId = campaignMember.CampaignId;
                            opp.CloseDate = Date.today().addMonths(3);
                            opp.Primary_Contact__c = campaignMember.ContactId;    
                            opp.ContactId = campaignMember.ContactId;
                            opp.CustomerNotes__c = campaignMember.Description__c;
                            
                            //Please note! This logic is now built around the CMDT CountryCodeMap__mdt
                            String accountCountry = contacts.get(campaignMember.ContactId).Account.Country__c;
                            String userCountry = userCountryMap.get(accountCountry);
                            if(userCountry != null){
                                opp.User_Country__c = userCountry;
                            }
                            
                            
                            opp.NA_Brand__c = campaignMember.Brand__c;
                            //The dealer assignment need to be collected from the Campaign Member
                            if(campaignMember.Dealer__c != null){
                                opp.Dealer__c = campaignMember.Dealer__c;
                            }
                            
                            String pricebookId = '';
                            pricebookId = pricebookSettingMap.get(contacts.get(campaignMember.ContactId).Account.Country__c);
                            
                            if(pricebookId != ''){
                                opp.Pricebook2Id = pricebookId;
                            }
                            
                            //In case the Brand field is empty on the Campaign Member, collect it from the Campaign instead
                            if(opp.NA_Brand__c == null || opp.NA_Brand__c == ''){                    
                                opp.NA_Brand__c = campaigns.get(campaignMember.CampaignId).Brands__c;
                            }
                            
                            opp.AccountId = campaignMember.LeadId == null ? contacts.get(campaignMember.ContactId).AccountId  : stdLeads.get(campaignMember.LeadId).ConvertedAccountId;

                            List<AccountContactRelation> dealerContacts = new List<AccountContactRelation>();
                            if(dealers!= null){
                                Account dealerAcc = dealers.get(opp.Dealer__c);                    
                                if(dealerAcc != null){
                                    dealerContacts =  dealers.get(opp.Dealer__c).AccountContactRelations;
                                }    
                            }
                            
                            Map<Id, OpportunityTeamMember> oppMembers = new Map<Id, OpportunityTeamMember>();
                            String assignment = '';
                            if(settingsMap.get(opp.NA_Brand__c) != null){
                                //opp.NA_Category__c = settingsMap.get(opp.NA_Brand__c).Category__c;    
                                
                                //Check assignment based on category
                                assignment = settingsMap.get(opp.NA_Brand__c).AssignOwnerFrom__c;
                            }
                            opp.NA_Category__c = GlobalUtils.getCategoryFromBrand(userCountry ,brand ,dependentPicklistOpportunityCountryCategoryMap , dependentPicklistOpportunityCategoryBrandMap);
                            Set<String> roleMap = new Set<String>();
                        	if(settingsMap.get(opp.NA_Brand__c) != null && settingsMap.get(opp.NA_Brand__c).UserRoles__c != null){
                                String roleList = settingsMap.get(opp.NA_Brand__c).UserRoles__c;
                            	String[] roles = roleList.split(';');
                           		for(String role:roles){
                                	roleMap.add(role);
                                }
                            }
                            
                            
                            
                            //Check internal sales reps assigned through the customer account's territories
                            List<UserTerritory2Association> accUsers = new List<UserTerritory2Association>();
                            
                            if(Test.isRunningTest()){
                                UserTerritory2Association accUser = new UserTerritory2Association();
                                accUser.RoleInTerritory2 = 'Sales Rep (CERC)'; 
                                accUsers.add(accUser);
                            }
                            else{
                                accUsers = customerUserMap.get(opp.AccountId);
                            }
                            
                            //Check internal users assigned through the customer's ETM    
                            if(accUsers != null && assignFromDealer != true){
                                for(UserTerritory2Association user:accUsers){
                                    if(roleMap.contains(user.RoleInTerritory2)){
                                        OpportunityTeamMember omAcc = new OpportunityTeamMember();
                                        opp.OwnerId = user.UserId;
                                        omAcc.UserId = user.UserId;
                                        omAcc.TeamMemberRole = 'Sales Representative';
                                        omAcc.OpportunityAccessLevel = 'Edit';
                                        oppMembers.put(omAcc.UserId, omAcc);
                                    }
                                }    
                            }   
                            
                            //Check internal sales reps assigned through the dealer account's territories
                            List<UserTerritory2Association> dealerUsers = new List<UserTerritory2Association>();
                            if(dealers != null && assignFromDealer == true){
                                
                                if(Test.isRunningTest()){
                                    UserTerritory2Association dealerUser = new UserTerritory2Association();
                                    dealerUser.RoleInTerritory2 = 'Sales Rep (CERC)'; 
                                    dealerusers.add(dealerUser);
                                }
                                else{
                                    dealerUsers = dealerUserMap.get(opp.Dealer__c);
                                }
                            }
                            
                            if(dealerUsers != null && assignFromDealer == true){
                                for(UserTerritory2Association user:dealerUsers){    
                                    if(roleMap.contains(user.RoleInTerritory2)){
                                        OpportunityTeamMember omDealerInt = new OpportunityTeamMember();
                                        opp.OwnerId = user.UserId;
                                        omDealerInt.UserId = user.UserId;
                                        omDealerInt.TeamMemberRole = 'Sales Representative';
                                        omDealerInt.OpportunityAccessLevel = 'Edit';
                                        oppMembers.put(omDealerInt.UserId, omDealerInt);
                                    }
                                }              
                            }
                            
                            if(includeInCommunity == 'Yes'){
                                if(dealerContacts != null){ 
                                    for(AccountContactRelation rel : dealerContacts){
                                        if(rel.Specialty__c != null){
                                            if(roleMap.contains(rel.Specialty__c)){
                                                
                                                OpportunityTeamMember omDealerExt = new OpportunityTeamMember();
                                                
                                                omDealerExt.UserId = externalDealerUserMap.get(rel.ContactId);
                                                omDealerExt.OpportunityAccessLevel = 'Edit';
                                                omDealerExt.TeamMemberRole = 'Dealer Sales Rep';
                                                System.debug(omDealerExt);
                                                if(omDealerExt.UserId != null){
                                                    opp.OwnerId = externalDealerUserMap.get(rel.ContactId);
                                                    oppMembers.put(omDealerExt.UserId, omDealerExt);
                                                }
                                                
                                            }
                                        }
                                    }
                                }
                                else{
                                    opp.OwnerId = campaigns.get(campaignMember.CampaignId).OwnerId;
                                }      
                            }
                            
                            
                            //Assign opportunities to the Campaign owner in case of exceptions
                            if(opp.OwnerId == null){
                                opp.OwnerId = campaigns.get(campaignMember.CampaignId).OwnerId;
                            }
                            
                            OppWrapper oppRecord = new OppWrapper();
                            oppRecord.opp = opp;
                            
                            oppRecord.oppMembers = oppMembers.values();
                            oppRecord.CampaignMemberIdUpdate = campaignMember.Id;
                            oppList.add(oppRecord);
                            
                        //}
                    }
                }
                
                
                
                List<CampaignMember>  campaignMemberToUpdateList=new List<CampaignMember>();
                
                //Sales Lead creation    
                if(!memberIdWithLead.values().isempty()){	
                    
                    //Check if any open opportunities exist for each account/category combination
                    
                    Map<Id, Field_Sales_Project_Members__c> salesLeadsToInsert = new Map<Id, Field_Sales_Project_Members__c>();
                    Map<Id, String> campaignMembersWithExistingOpp = new Map<Id, String> ();
                    
                    for(String cmId : memberIdWithLead.keySet()){
                        Field_Sales_Project_Members__c salesLead = memberIdWithLead.get(cmId);
                        List<Opportunity> accOppList = new List<Opportunity>();
                        accOppList = salesLead.Account__c != null &&  oppMap != null ? oppMap.get(salesLead.Account__c): null;
                        
                        if(accOppList != null && !accOppList.isempty()){
                            system.debug('aqui4:'+ salesLead.Brand__c);
                            Boolean matchFound = false;
                            for(Opportunity o : accOppList){
                                if(o.NA_Brand__c == salesLead.Brand__c){
                                    matchFound = true;
                                    campaignMembersWithExistingOpp.put(cmId, o.Id);
                                }
                            }
                            
                            if(matchFound == false){
                                salesLeadsToInsert.put(cmId, salesLead);
                            }
                        }
                        else{
                            salesLeadsToInsert.put(cmId, salesLead);
                        }
                    }
                    
                    try{
                        Insert salesLeadsToInsert.values();
                    }
                    catch(Exception e){
                        DebugLog.addException(e, 'CampaignMemberTriggerHelper.createOpportunities. Sales Lead not created.');
                        //DebugLog.addError(e.getMessage());
                    }
                    
                    for(CampaignMember campaignMemberToUpdate :[SELECT ID, SalesLead__c FROM CampaignMember WHERE Id IN: salesLeadsToInsert.keySet()]){
                        campaignMemberToUpdate.SalesLead__c = salesLeadsToInsert.get(campaignMemberToUpdate.Id).Id;
                        campaignMemberToUpdateList.add(campaignMemberToUpdate);
                    }
                    
                    if(!campaignMembersWithExistingOpp.isEmpty()){
                        for(CampaignMember campaignMemberToUpdate : [SELECT Id, Opportunity__c FROM CampaignMember WHERE Id IN: campaignMembersWithExistingOpp.keySet()]){
                            campaignMemberToUpdate.Opportunity__c = campaignMembersWithExistingOpp.get(campaignMemberToUpdate.Id);
                            campaignMemberToUpdateList.add(campaignMemberToUpdate);
                        }
                    }
                }    
                
                
                
                
                if(!campaignMemberToUpdateList.isempty()){	
                    try{
                        update campaignMemberToUpdateList;
                    }
                    catch(Exception e){
                        DebugLog.addError(e.getMessage());
                    }
                }  
                
                
                
                //Opportunity creation
                
                if(oppList.size()>0){
                    OpportunityInsertAsynch oppInsert = new OpportunityInsertAsynch(oppList);
                    ID jobID = System.enqueueJob(oppInsert);
                }
            }    
        }
        
    }
    
    public class oppWrapper{        
        public Opportunity opp;
        public List<OpportunityTeamMember> oppMembers;
        public String CampaignMemberIdUpdate;
    }
    
    /*------------------------------------------------------------
Description:    Method for creating CFEs based on Campaign Member related to Physical/Virtual Event Campaigns (TFUS-[...]3395)
Inputs:         @param newCampaignMembers
------------------------------------------------------------*/
    
    /*public static void createCFE(List<CampaignMember> newCampaignMembers, Map<Id, CampaignMember> oldCampaignMemberMap) {

BatchSettings__c settings = BatchSettings__c.getInstance('Default');
if (Test.isRunningTest() || settings.CampMgmtCampaignMemberTriggerIsEnabled__c){  

Set<Id> campaignIds = new Set<Id>();
Set<Id> contactIds = new Set<Id>();

for (CampaignMember te : newCampaignMembers) {
if (te.CampaignId != null) {
campaignIds.add(te.CampaignId);
}
if(te.ContactId != null){
contactIds.add(te.ContactId);
}

Map<Id, Campaign> campaigns = new Map<Id, Campaign>(
[SELECT Id, Name, RecordTypeId, OwnerId, Brands__c, Convert_To__c, RecordType.DeveloperName from Campaign where Id in :campaignIds]
);

Boolean recordTypeCheck = false;
for(Campaign cmp : campaigns.values()){
if(cmp.RecordType.DeveloperName == 'InPersonEventCampaign'){
recordTypeCheck = true;
}
}        

if(recordTypeCheck == true){

Map<Id, Contact> contacts = new Map<Id, Contact>(
[SELECT Id, AccountId, Account.Country__c from Contact where Id in :contactIds]
);

List<Task> cfeList = new List<Task>();


for (CampaignMember cm : newCampaignMembers) {

Task cfe = new Task();
cfe.WhoId = cm.ContactId;
cfe.WhatId = cm.CampaignId;
cfe.Subject = 'Attended ' + campaigns.get(cm.CampaignId).Name;
cfe.ActivityDate = Date.today();
cfe.Status = 'Completed';
cfeList.add(cfe);

}    

try{
insert cfeList;
}
catch(DmlException e){
System.debug(e);
}




}

}
}
}*/
    
}