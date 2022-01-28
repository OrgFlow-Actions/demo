//Author: Sergey Legostaev
//Date: 04/20/2017
public with sharing class DC_CampaignMembersDAO {
	
    public static List<CampaignMember> getActiveCampaignMembersByContactId(String contactId) {
        return [select Id, CampaignId, Campaign.Name, Status
                                        from CampaignMember where Campaign_End_Date__c >= :Date.today()
                                       		 and ContactId = :contactId and Campaign.IsActive = true];
        //and Campaign_Status__c = 'Confirmed'
        //and (Status = 'To Call' or Status = 'Call Back needed')
    }
    
    public static CampaignMember getCampaignMemberById(String id) {
        return [SELECT Name, Account__c, Contact.AccountId, Campaign.RecordType.Name,
                  ContactId, Contact.Account.Name, Contact.Name, Contact.Title,
                  Phone__c, Account__r.Phone, Account__r.Fax, Contact.Email	
                  FROM CampaignMember WHERE Id = :id];
    }
}