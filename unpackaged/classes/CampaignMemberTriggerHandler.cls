/*-------------------------------------------------------------------------------------------------------
Author:         Ahmed LOUDRASSI (Salesforce) 20191022
Description:    Campaign Member Trigger Handler Class
History
20191022   Ahmed LOUDRASSI   Migrated CampMgmtCampaignMemberTrigger and CampMgmtCampaignMemberTrigger2 triggers. (#)
20191022   Ahmed LOUDRASSI   Migrated CampaignMember Workflows. (#)
----------------------------------------------------------------------------------------*/
public class CampaignMemberTriggerHandler extends TriggerHandler {

    private List<CampaignMember> oldCampaignMemberList, newCampaignMemberList;
    private Map<Id, CampaignMember> oldCampaignMemberMap, newCampaignMemberMap;

    public CampaignMemberTriggerHandler() {
        oldCampaignMemberList = (List<CampaignMember>) Trigger.old;
        newCampaignMemberList = (List<CampaignMember>) Trigger.new;
        oldCampaignMemberMap = (Map<Id, CampaignMember>) Trigger.oldMap;
        newCampaignMemberMap = (Map<Id, CampaignMember>) Trigger.newMap;
    }
    protected override void beforeInsert() {
        CampaignMemberTriggerHelper.updateCampaignMemberAccount(newCampaignMemberList);
        CampaignMemberTriggerHelper.updateCampaignMembersInfo(newCampaignMemberList);
        CampaignMemberTriggerHelper.setInternationalSpeaker(newCampaignMemberList);
    }
    protected override void beforeUpdate() {
        CampaignMemberTriggerHelper.setInternationalSpeaker(newCampaignMemberList);
    }
    protected override void afterInsert() {
        CampaignMemberTriggerHelper.updateCampaignAndAccountIdCMList(newCampaignMemberList);
        CampaignMemberTriggerHelper.createOpportunities(newCampaignMemberList, oldCampaignMemberMap, false);
        //CampaignMemberTriggerHelper.createCFE(newCampaignMemberList, oldCampaignMemberMap);
    }
    protected override void afterUpdate() {
        CampaignMemberTriggerHelper.updateCampaignAndAccountIdCMList(newCampaignMemberList);
        CampaignMemberTriggerHelper.createOpportunities(newCampaignMemberList, oldCampaignMemberMap, false);
    }
}