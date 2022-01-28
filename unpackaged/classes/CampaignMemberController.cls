/*------------------------------------------------------------	
Author: 	Richard Trum (Glimt) 2019-10-09 	
Description:   	Campaign Member handler class, used mainly for handling the LC CampaignMembersEdit
------------------------------------------------------------*/

public class CampaignMemberController {
	@AuraEnabled
    Public static List<CampaignMember> getMemberList(Id recordId){

        List<CampaignMember> conList = [SELECT Id, Full_Name__c, Account__r.Name, Phone, Email, CampaignId, Status 
                                        FROM CampaignMember 
                                        WHERE CampaignId =: recordId];
        return conList;
    }
    
    
}