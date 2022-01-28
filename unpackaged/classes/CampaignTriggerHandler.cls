/*-------------------------------------------------------------------------------------------------------
Author:         Ahmed LOUDRASSI (Salesforce) 20191023
Description:    Campaign  Trigger Handler Class
History
20191023   Ahmed LOUDRASSI   Migrated  CampMgmtCampaignSessionTrigger, CampMgmtCampaignTrigger, CampMgmtCampaignTrigger2, CampMgmtCampaignSharingTrigger triggers. (#)
20191023   Ahmed LOUDRASSI   Migrated Campaign Workflows. (#)
----------------------------------------------------------------------------------------*/
public with sharing class CampaignTriggerHandler extends TriggerHandler{
    private List<Campaign> oldCampaignList, newCampaignList;
    private Map<Id, Campaign> oldCampaignMap, newCampaignMap;

    public CampaignTriggerHandler() {
        oldCampaignList = (List<Campaign>) Trigger.old;
        newCampaignList = (List<Campaign>) Trigger.new;
        oldCampaignMap = (Map<Id, Campaign>) Trigger.oldMap;
        newCampaignMap = (Map<Id, Campaign>) Trigger.newMap;
    }
    protected override void beforeInsert() {
        CampaignTriggerHelper.setCampaignSessionsDefaultValues(newCampaignList);
        CampaignTriggerHelper.setAlignmentOnCountryFields(newCampaignList,newCampaignMap, oldCampaignMap);
    }
    protected override void beforeUpdate() {
        CampaignTriggerHelper.setAlignmentOnCountryFields(newCampaignList,newCampaignMap, oldCampaignMap);
    }
    protected override void afterInsert() {
        CampaignTriggerHelper.setCampaignMemberStatus(newCampaignMap);
        CampaignTriggerHelper.campaignSharing(newCampaignMap, oldCampaignMap);
    }
    protected override void afterUpdate() {
        CampaignTriggerHelper.deactivateCampaignSessions(newCampaignMap, oldCampaignMap);
        CampaignTriggerHelper.campaignSharing(newCampaignMap, oldCampaignMap);
    }
}