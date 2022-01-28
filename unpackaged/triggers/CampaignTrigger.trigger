/*------------------------------------------------------------
Author:         Ahmed LOUDRASSI (Salesforce) 2019-10-23
Description:    Generic Trigger for Campaign (Following Trigger Framework)
------------------------------------------------------------*/
trigger CampaignTrigger on Campaign (
        before insert
        , before update
        , before delete
        , after insert
        , after update
        , after delete
        , after undelete) {
    new CampaignTriggerHandler().run();
}