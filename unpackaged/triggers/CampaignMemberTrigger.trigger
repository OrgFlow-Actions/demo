/*------------------------------------------------------------
Author:         Ahmed LOUDRASSI (Salesforce) 2019-10-22
Description:    Generic Trigger for CampaignMember (Following Trigger Framework)
------------------------------------------------------------*/
trigger CampaignMemberTrigger on CampaignMember (
        before insert
        , before update
        , before delete
        , after insert
        , after update
        , after delete
        , after undelete) {
    new CampaignMemberTriggerHandler().run();
}