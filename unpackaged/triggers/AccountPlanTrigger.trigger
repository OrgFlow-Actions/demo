/**
 * @description       : Triger for AccountPlan2__c
 * @author            : kdoruibin@salesforce.com
 * @group             : 
 * @last modified on  : 10-12-2021
 * @last modified by  : kdoruibin@salesforce.com
**/
trigger AccountPlanTrigger on Account_Plan__c (
    before insert
    , before update
    , before delete
    , after insert
    , after update
    , after delete
    , after undelete
) {
    new AccountPlanTriggerHandler().run();
}