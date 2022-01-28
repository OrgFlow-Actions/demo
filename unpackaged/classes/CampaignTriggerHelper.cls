/*-------------------------------------------------------------------------------------------------------
Author:         Ahmed LOUDRASSI (Salesforce) 20191023
Description:    Campaign  Trigger Helper Class
History
20191023   Ahmed LOUDRASSI   Migrated  CampMgmtCampaignSessionTrigger, CampMgmtCampaignTrigger, CampMgmtCampaignTrigger2, CampMgmtCampaignSharingTrigger triggers. (#)
20191023   Ahmed LOUDRASSI   Migrated Campaign Workflows. (#)
20200102    Miguel           Bug fix setCampaignMemberStatus + Do not create sharing record if Owner  <> Approver (TFUS-000001389)
20210817    Richard          Added details for new Campaign record type 'In-person & Virtual Event Campaign' 
----------------------------------------------------------------------------------------*/
public with sharing class CampaignTriggerHelper {
    /*------------------------------------------------------------
    Description:    Method migrated from  CampMgmtCampaignSessionTrigger

    Inputs:         @param newCampaignList
    ------------------------------------------------------------*/
    public  static void setCampaignSessionsDefaultValues(List<Campaign> newCampaignList)  {
        BatchSettings__c settings = BatchSettings__c.getInstance('Default');
        if (Test.isRunningTest() || settings.CampMgmtCampaignSessionTriggerIsEnabled__c){
            RecordType rtDiCampaignSession = [SELECT Id FROM RecordType WHERE DeveloperName = 'DI_Campaign_Session' AND SObjectType = 'Campaign'];
            Set<ID> campaignIdList = new Set<ID>();
            for (Campaign session : newCampaignList) {
                if (session.RecordTypeId == rtDiCampaignSession.Id && session.Parent_Event__c != null)
                    campaignIdList.add(session.Parent_Event__c);
            }

            Map<ID, Campaign> campaignMap = new Map<ID, Campaign>(
                [SELECT Id, StartDate, EndDate, Strategy__c, Profession__c, Brand__c, Target_Group__c, Target_Type__c
                FROM Campaign
                WHERE Id IN :campaignIdList]);
            for (Campaign session : newCampaignList) {
                if (session.RecordTypeId == rtDiCampaignSession.Id) {
                    Campaign campaign = campaignMap.get(session.Parent_Event__c);
                    if (session.Session_Start_Date_Time__c == null && campaign.StartDate != null)
                        session.Session_Start_Date_Time__c = campaign.StartDate;
                    if (session.Session_End_Date_Time__c == null && campaign.EndDate != null)
                        session.Session_End_Date_Time__c = campaign.EndDate;
                    if (session.Strategy__c == null && campaign.Strategy__c != null)
                        session.Strategy__c = campaign.Strategy__c;
                    if (session.Profession__c == null && campaign.Profession__c != null)
                        session.Profession__c = campaign.Profession__c;
                    if (session.Brand__c == null && campaign.Brand__c != null)
                        session.Brand__c = campaign.Brand__c;
                    if (session.Target_Group__c == null && campaign.Target_Group__c != null)
                        session.Target_Group__c = campaign.Target_Group__c;
                    if (session.Target_Type__c == null && campaign.Target_Type__c != null)
                        session.Target_Type__c = campaign.Target_Type__c;
                }
            }
        }
    }
    /*------------------------------------------------------------
    Description:    Method migrated from  CampMgmtCampaignTrigger

    Inputs:         @param newCampaignMap
    ------------------------------------------------------------*/
    public  static void setCampaignMemberStatus(Map<Id, Campaign> newCampaignMap)  {
        BatchSettings__c settings = BatchSettings__c.getInstance('Default');
        if (Test.isRunningTest() || settings.CampMgmtCampaignTriggerIsEnabled__c) {
            List<CampaignMemberStatus> statiTempInsert = new List<CampaignMemberStatus>();
            List<CampaignMemberStatus> statiDelete = new List<CampaignMemberStatus>();
            List<CampaignMemberStatus> statiInsert = new List<CampaignMemberStatus>();
            List<Id> campaignIds = new List<Id>();
            Map<String, String> includedRecordTypes = new Map<String, String> {'DI_Campaign' => 'DI_Campaign', 
                'NA_Activity_Request_Form' => 'NA_Activity_Request_Form', 
                'NATradeShow' => 'NATradeShow',
                'NA_Sponsorship' => 'NA_Sponsorship', 
                'DI_Mailing' => 'DI_Mailing', 
                'DNA_Campaign' => 'DNA_Campaign', 
                'Inside_Sales_Campaign' => 'Inside_Sales_Campaign',
                'Digital_Marketing_Campaign' => 'Digital_Marketing_Campaign',
                'CventCampaign' => 'CventCampaign',
                'InPersonEventCampaign' => 'InPersonEventCampaign'};
            Map<String, String> rtDiCampaignList = new Map<String, String> {'DI_Campaign' => 'DI_Campaign',
                'NA_Activity_Request_Form' => 'NA_Activity_Request_Form', 
                'NATradeShow' => 'NATradeShow', 'NA_Sponsorship' => 'NA_Sponsorship', 'CventCampaign' => 'CventCampaign'};

            for(Campaign campaign : newCampaignMap.values()) {
                CampaignMemberStatus status;
                campaignIds.add(campaign.Id);
                if (GlobalUtils.ifrecordTypeInList('Campaign', rtDiCampaignList.values(), campaign.RecordTypeId)) {
                    statiTempInsert.add(returnCampaignMemberStatus(campaign.Id,'Temporary', 99, true, true));
                    statiInsert.add(returnCampaignMemberStatus(campaign.Id,'Suggested', 3, true, false));
                    statiInsert.add(returnCampaignMemberStatus(campaign.Id,'Invited', 4, false, false));
					statiInsert.add(returnCampaignMemberStatus(campaign.Id,'Confirmed', 5, false, true));
					statiInsert.add(returnCampaignMemberStatus(campaign.Id,'Waiting List', 6, false, false));
					statiInsert.add(returnCampaignMemberStatus(campaign.Id,'Cancelled', 7, false, false));
					statiInsert.add(returnCampaignMemberStatus(campaign.Id,'Did Not Attend', 8, false, false));
					statiInsert.add(returnCampaignMemberStatus(campaign.Id,'Campaign Was Cancelled', 9, false, false));
                } else if (campaign.RecordTypeId.equals(GlobalUtils.getRecordTypeId('Campaign', 'DI_Mailing'))) {
                    statiTempInsert.add(returnCampaignMemberStatus(campaign.Id,'Temporary', 99, true, true));
                    statiInsert.add(returnCampaignMemberStatus(campaign.Id,'Suggested', 3, true, false));
                    statiInsert.add(returnCampaignMemberStatus(campaign.Id,'Sent', 4, false, false));
					statiInsert.add(returnCampaignMemberStatus(campaign.Id,'Responded', 5, false, true));
					statiInsert.add(returnCampaignMemberStatus(campaign.Id,'Completed', 6, false, true));
					statiInsert.add(returnCampaignMemberStatus(campaign.Id,'Campaign Was Cancelled', 7, false, false));
                } else if (campaign.RecordTypeId.equals(GlobalUtils.getRecordTypeId('Campaign', 'DNA_Campaign'))) {
                    statiTempInsert.add(returnCampaignMemberStatus(campaign.Id,'Temporary', 99, true, true));
                    statiInsert.add(returnCampaignMemberStatus(campaign.Id,'To Call', 3, true, false));
                    statiInsert.add(returnCampaignMemberStatus(campaign.Id,'In Progress', 4, false, false));
					statiInsert.add(returnCampaignMemberStatus(campaign.Id,'Busy', 5, false, false));
					statiInsert.add(returnCampaignMemberStatus(campaign.Id,'No Answer', 6, false, false));
					statiInsert.add(returnCampaignMemberStatus(campaign.Id,'Left Message', 7, false, false));
                    statiInsert.add(returnCampaignMemberStatus(campaign.Id,'Call Back Later', 8, false, false));
					statiInsert.add(returnCampaignMemberStatus(campaign.Id,'Call Completed', 9, false, true));
					statiInsert.add(returnCampaignMemberStatus(campaign.Id,'Not Completed', 10, false, false));
					statiInsert.add(returnCampaignMemberStatus(campaign.Id,'Bounced', 11, false, false));
                    statiInsert.add(returnCampaignMemberStatus(campaign.Id,'Sent', 12, false, true));
                    statiInsert.add(returnCampaignMemberStatus(campaign.Id,'Failure', 13, false, false));
                } else if (campaign.RecordTypeId.equals(GlobalUtils.getRecordTypeId('Campaign', 'Inside_Sales_Campaign'))) {
                    statiTempInsert.add(returnCampaignMemberStatus(campaign.Id,'Temporary', 99, true, true));
                    statiInsert.add(returnCampaignMemberStatus(campaign.Id,'To Call', 3, true, false));
                    statiInsert.add(returnCampaignMemberStatus(campaign.Id,'In Progress', 4, false, false));
                    statiInsert.add(returnCampaignMemberStatus(campaign.Id,'Busy', 5, false, false));
                    statiInsert.add(returnCampaignMemberStatus(campaign.Id,'No Answer', 6, false, false));
                    statiInsert.add(returnCampaignMemberStatus(campaign.Id,'Left Message', 7, false, false));
                    statiInsert.add(returnCampaignMemberStatus(campaign.Id,'Call Back Later', 8, false, false));
                    statiInsert.add(returnCampaignMemberStatus(campaign.Id,'Call Completed', 9, false, true));
                    statiInsert.add(returnCampaignMemberStatus(campaign.Id,'Not Completed', 10, false, false));
                 	statiInsert.add(returnCampaignMemberStatus(campaign.Id,'Bounced', 11, false, false));
					statiInsert.add(returnCampaignMemberStatus(campaign.Id,'Sent', 12, false, true));
					statiInsert.add(returnCampaignMemberStatus(campaign.Id,'Failure', 13, false, false));
                } else if (campaign.RecordTypeId.equals(GlobalUtils.getRecordTypeId('Campaign', 'Digital_Marketing_Campaign'))) {
                    statiTempInsert.add(returnCampaignMemberStatus(campaign.Id,'Temporary', 99, true, true));
                    statiInsert.add(returnCampaignMemberStatus(campaign.Id,'Registered', 3, true, false));
                    statiInsert.add(returnCampaignMemberStatus(campaign.Id,'Responded', 4, false, true));
                    statiInsert.add(returnCampaignMemberStatus(campaign.Id,'To be Reconciled', 5, false, false));
                    statiInsert.add(returnCampaignMemberStatus(campaign.Id,'Assigned to Sales', 6, false, false));
                    statiInsert.add(returnCampaignMemberStatus(campaign.Id,'Sales Lead Cancelled', 7, false, false));
                    statiInsert.add(returnCampaignMemberStatus(campaign.Id,'Opportunity Created', 8, false, false));
                    statiInsert.add(returnCampaignMemberStatus(campaign.Id,'Opportunity Closed Won', 9, false, false));
                    statiInsert.add(returnCampaignMemberStatus(campaign.Id,'Opportunity Closed Lost', 10, false, false));
                    statiInsert.add(returnCampaignMemberStatus(campaign.Id,'Removed From Campaign', 11, false, false));
                }
                else if (campaign.RecordTypeId.equals(GlobalUtils.getRecordTypeId('Campaign', 'InPersonEventCampaign'))) {
                    statiTempInsert.add(returnCampaignMemberStatus(campaign.Id,'Temporary', 99, true, true));
                    statiInsert.add(returnCampaignMemberStatus(campaign.Id,'Invitation Pending', 3, true, false));
                    statiInsert.add(returnCampaignMemberStatus(campaign.Id,'Accepted', 4, false, false));
                    statiInsert.add(returnCampaignMemberStatus(campaign.Id,'Declined', 5, false, false));
                    statiInsert.add(returnCampaignMemberStatus(campaign.Id,'Visited', 6, false, true));
                    statiInsert.add(returnCampaignMemberStatus(campaign.Id,'Waitlisted', 7, false, false));
                    statiInsert.add(returnCampaignMemberStatus(campaign.Id,'Assigned to Sales', 8, false, false));
                    statiInsert.add(returnCampaignMemberStatus(campaign.Id,'Sales Lead Cancelled', 9, false, false));
                    statiInsert.add(returnCampaignMemberStatus(campaign.Id,'Opportunity Created', 10, false, false));
                    statiInsert.add(returnCampaignMemberStatus(campaign.Id,'Opportunity Closed Won', 11, false, false));
                    statiInsert.add(returnCampaignMemberStatus(campaign.Id,'Opportunity Closed Lost', 12, false, false));
                    statiInsert.add(returnCampaignMemberStatus(campaign.Id,'Removed From Campaign', 13, false, false));
                }
                //Cvent attendee statuses:
                // - No response
                // - Accepted
                // - Declined
                // - Visited
                // - Waitlisted
                // - Cancelled
                // - Pending Approval
                // - Denied Approval
                // - Invitation Not Sent
                // - Invitation Pending
                // - Nomination Pending
                // - Nomination Approved
                // - Nomination Denied
                // - Registration Pending
                
            if(GlobalUtils.ifrecordTypeInList('Campaign', includedRecordTypes.values(), campaign.RecordTypeId)){
            	statiDelete = [SELECT Id FROM CampaignMemberStatus WHERE CampaignId IN :campaignIds];
            }
                                
            }
                        
            try {
                if(!statiTempInsert.isEmpty()){
                     insert statiTempInsert;// Insert temporary default stati while we clear out the rest.
                }
                if(!statiDelete.isEmpty()){
                     delete statiDelete; // Delete all old stati that were there before the operation.
                }
                if(!statiInsert.isEmpty()){
                     insert statiInsert; // Insert all new stati that should be there after the operation.
                }
                if(!statiTempInsert.isEmpty()){
                     delete statiTempInsert; // Delete temporary default stati again.
                }
            } catch (DmlException e) {
                    DebugLog.addException(e, 'Method: CampaignTriggerHandler.setCampaignMemberStatus'); 
            }
        }
    }
    /*------------------------------------------------------------
    Description:    Method migrated from  CampMgmtCampaignTrigger2

    Inputs:         @param newCampaignMap, oldCampaignMap
    ------------------------------------------------------------*/
    public  static void deactivateCampaignSessions(Map<Id, Campaign> newCampaignMap, Map<Id, Campaign> oldCampaignMap)  {
        BatchSettings__c settings = BatchSettings__c.getInstance('Default');
        if (Test.isRunningTest() || settings.CampMgmtCampaignTriggerIsEnabled__c) {
            Id[] campaignIdList = new Id[] {};
            for (Campaign campaign : newCampaignMap.values()) {
                Campaign oldCampaign = oldCampaignMap.get(campaign.Id);
                if (campaign.RecordTypeId.equals(GlobalUtils.getRecordTypeId('Campaign', 'DI_Campaign')) 
                    && !campaign.IsActive && oldCampaign.IsActive)
                    campaignIdList.add(campaign.Id);
            }

            Campaign[] sessionList = [SELECT Id, IsActive FROM Campaign
                                                            WHERE RecordTypeId = :GlobalUtils.getRecordTypeId('Campaign', 'DI_Campaign_Session')
                                                            AND Parent_Event__c IN :campaignIdList];

            for (Campaign session : sessionList)
                session.IsActive = false;

            try {
                if(!sessionList.isEmpty()){
                     update sessionList;
                }
            } catch (DmlException e) {
                    DebugLog.addException(e, 'deactivateCampaignSessions'); 
            }
        }
    }
    /*------------------------------------------------------------
    Description:    Method migrated from  CampMgmtCampaignSharingTrigger

    Inputs:         @param newCampaignMap, oldCampaignMap
    ------------------------------------------------------------*/
    public  static void campaignSharing(Map<Id, Campaign> newCampaignMap, Map<Id, Campaign> oldCampaignMap) {
        BatchSettings__c settings = BatchSettings__c.getInstance('Default');
        if (Test.isRunningTest() || settings.CampMgmtCampaignSharingTriggerIsEnabled__c){
            List<CampaignShare> sharesUpsert = new List<CampaignShare>();
            List<CampaignShare> sharesDelete = new List<CampaignShare>();
            List<Id> campaignsIds =  new List<Id>();

            for (Campaign newCampaign : newCampaignMap.values()) {
                if (newCampaign.RecordTypeId.equals(GlobalUtils.getRecordTypeId('Campaign', 'DI_Campaign'))) {
                    Boolean approverHasChanged = false;
                    if (Trigger.isUpdate) {
                        Campaign oldCampaign = newCampaignMap.get(newCampaign.Id);
                        if (oldCampaign != null && oldCampaign.Campaign_Approver__c != newCampaign.Campaign_Approver__c)
                            approverHasChanged = true;

                        if (approverHasChanged) {
                            campaignsIds.add(oldCampaign.Id);
                        }
                    }

                    if (Trigger.isInsert || approverHasChanged) {
                        if (newCampaign.Campaign_Approver__c != null && (newCampaign.Campaign_Approver__c <> newCampaign.OwnerId)) {
                            CampaignShare share = new CampaignShare();
                            share.CampaignId = newCampaign.Id;
                            share.UserOrGroupId = newCampaign.Campaign_Approver__c;
                            share.CampaignAccessLevel = 'Edit';
                            sharesUpsert.add(share);
                        }
                    }
                }
            }
            List<CampaignShare> oldShareList = [SELECT Id FROM CampaignShare WHERE CampaignId IN :campaignsIds AND RowCause = :Schema.CampaignShare.RowCause.Manual];
            for (CampaignShare oldShare : oldShareList) {
                if(oldShare.UserOrGroupId == oldCampaignMap.get(oldShare.Id).Campaign_Approver__c){
                         sharesDelete.add(oldShare);
                }
            }
            try {
                if(!sharesDelete.isEmpty()){
                     delete sharesDelete;
                }
                if(!sharesUpsert.isEmpty()){
                    upsert sharesUpsert;
               }
            } catch (DmlException e) {
                    DebugLog.addException(e, 'campaignSharing'); 
            }
        }
    }
    private static CampaignMemberStatus returnCampaignMemberStatus(ID campaignId, String label, Integer sortOrder, Boolean isDefault, Boolean hasResponded) {
        return new CampaignMemberStatus(CampaignId = campaignId,
                                        Label = label,
                                        SortOrder = sortOrder,
                                        IsDefault = isDefault,
                                        HasResponded = hasResponded);
    }

    /* keeping country fields aligned before update and before insert*/

    public static void setAlignmentOnCountryFields(List<Campaign> newCampaignList,Map<Id, Campaign> newCampaignMap, Map<Id, Campaign> oldCampaignMap){
        Map<String, CountryCodeMap__mdt> countryNameMapping = new Map<String, CountryCodeMap__mdt>();
        Map<String, CountryCodeMap__mdt> countryCodeMapping = new Map<String, CountryCodeMap__mdt>();
        List<CountryCodeMap__mdt> countryList = [SELECT Campaign_Country__c, Country_Code_3_digit__c FROM CountryCodeMap__mdt];
        for (CountryCodeMap__mdt country : countryList) {
            countryNameMapping.put(country.Campaign_Country__c, country);
            countryCodeMapping.put(country.Country_Code_3_digit__c, country);
        }
        if(newCampaignMap == null){
            /*when it is before insert*/
            for (Campaign newCampaign : newCampaignList) {
            if (
                String.isBlank(newCampaign.Campaign_Country__c)
                && 
                String.isBlank(newCampaign.Country_Code_3_digit__c)
            ) {
                continue;
            }
            if (String.isNotBlank(newCampaign.Campaign_Country__c)) {
                // TODO: Update the other country field with the new value
                    newCampaign.Country_Code_3_digit__c = countryNameMapping.get(newCampaign.Campaign_Country__c).Country_Code_3_digit__c;
            } else if (String.isNotBlank(newCampaign.Country_Code_3_digit__c)) {
                // TODO: Update the other country field with the new value
                newCampaign.Campaign_Country__c = countryCodeMapping.get(newCampaign.Country_Code_3_digit__c).Campaign_Country__c;
            }
        }
        } else {
            /*when it is before update*/
            for (Campaign newCampaign : newCampaignMap.values()) {
            if (
                newCampaign.Campaign_Country__c == oldCampaignMap.get(newCampaign.Id).Campaign_Country__c
                && newCampaign.Country_Code_3_digit__c == oldCampaignMap.get(newCampaign.Id).Country_Code_3_digit__c
            ) {
                continue;
            }
            if (newCampaign.Campaign_Country__c != oldCampaignMap.get(newCampaign.Id).Campaign_Country__c) {
                // TODO: Update the other country field with the new value
                if (String.isBlank(newCampaign.Campaign_Country__c)) {
                    newCampaign.Country_Code_3_digit__c = null;
                } else {
                    newCampaign.Country_Code_3_digit__c = countryNameMapping.get(newCampaign.Campaign_Country__c).Country_Code_3_digit__c;
                }
            } else if (newCampaign.Country_Code_3_digit__c != oldCampaignMap.get(newCampaign.Id).Country_Code_3_digit__c) {
                // TODO: Update the other country field with the new value
                if (String.isBlank(newCampaign.Country_Code_3_digit__c)) {
                    newCampaign.Campaign_Country__c = null;
                } else {
                    newCampaign.Campaign_Country__c = countryCodeMapping.get(newCampaign.Country_Code_3_digit__c).Campaign_Country__c;
                }
            }
        }
        }
    }
    
}