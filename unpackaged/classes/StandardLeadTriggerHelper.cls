global with sharing class StandardLeadTriggerHelper {
    
    private static final String SOBJECT_NAME = 'Lead';
    
    public static void updateCampaignMembers(List<Lead> newLeadList){
        Set<Id> leadIdSet = new Set<Id>();
        
        for(Lead l : newLeadList){        	
            if(l.IsConverted == true){
                leadIdSet.add(l.ConvertedContactId);
            }
        }
        
        //Find all Campaign Members related to the converted leads
        if(leadIdSet.size()>0){
        	List<CampaignMember> cmList = [SELECT Id, LeadId, Description__c, HasResponded, ContactId, Brand__c, CampaignId, Dealer__c, Campaign.Brand__c FROM CampaignMember WHERE ContactId IN: leadIdSet AND Campaign.RecordType.DeveloperName =: 'Digital_Marketing_Campaign'];
        	Map<Id, CampaignMember> cmMap = new Map<Id, CampaignMember>(cmList);        
       		CampaignMemberTriggerHelper.createOpportunities(cmList, cmMap, true);
        }
    }

}