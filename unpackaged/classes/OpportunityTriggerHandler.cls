/*------------------------------------------------------------  
Author:         Richard Trum (Glimt) 2020-09-07    
Description:    Opportunity Trigger Handler Class. 
History 
<Date>      <Authors Name>     <Brief Description of Change>
20200907    Richard Trum       Created trigger framework for Opportunities
------------------------------------------------------------*/

public class OpportunityTriggerHandler extends TriggerHandler {
    private List<Opportunity> oldOpportunityList, newOpportunityList;
    private Map<Id, Opportunity> oldOpportunityMap, newOpportunityMap;
    
    public OpportunityTriggerHandler() {
        oldOpportunityList = (List<Opportunity>) Trigger.old;
        newOpportunityList = (List<Opportunity>) Trigger.new;
        oldOpportunityMap = (Map<Id, Opportunity>) Trigger.oldMap;
        newOpportunityMap = (Map<Id, Opportunity>) Trigger.newMap;
    }
    
    protected override void beforeInsert() {
        OpportunityTriggerHelper.setOpportunityName(newOpportunityList);
    }
    
    protected override void beforeUpdate() {
        OpportunityTriggerHelper.setOpportunityName(newOpportunityList);
    }
    
    protected override void afterInsert() {
        OpportunityTriggerHelper.sendDealerEmail(newOpportunityList);
    }
}