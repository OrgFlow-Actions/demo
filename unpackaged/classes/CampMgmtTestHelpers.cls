global class CampMgmtTestHelpers
{
    global static Account createTestAccount(String name)
    {
        Account testAccount = new Account();
        testAccount.Country__c = 'SE';
        testAccount.Name = name;
        insert testAccount;
        
        return testAccount;
    }    
    
    global static Contact createTestContact(ID accountId, String firstName, String lastName,String emailAddress)
    {
        Contact testContact = new Contact();
        testContact.AccountId = accountId;
        testContact.FirstName = firstName;
        testContact.LastName = lastName;
        testContact.InsertEmailMarketingConsentCollected__c= 'No';
        testContact.Email = emailAddress;
        insert testContact;
        
        return testContact;
    }

    global static Campaign createTestCampaign(String name, String recordTypeDeveloperName)	
    {
        RecordType recordType = [SELECT Id FROM RecordType WHERE DeveloperName = :recordTypeDeveloperName AND SObjectType = 'Campaign'];
 
        Campaign testCampaign = new Campaign();
        testCampaign.RecordTypeId = recordType.Id;
        testCampaign.Name = name;
        testCampaign.Strategy__c = 'GET';
        testCampaign.SBU_Focus__c = 'Implants';
        testCampaign.IsActive = true;
        insert testCampaign;

        return testCampaign;
    }

    global static Campaign createTestSession(ID campaignId, String name, String recordTypeDeveloperName)
    {
        RecordType recordType = [SELECT Id FROM RecordType WHERE DeveloperName = :recordTypeDeveloperName AND SObjectType = 'Campaign'];

        Campaign testSession = new Campaign();
        testSession.RecordTypeId = recordType.Id;
        testSession.Name = name;
        testSession.Parent_Event__c = campaignId;
        testSession.Strategy__c = 'GET';
        testSession.IsActive = true;
        insert testSession;  

        return testSession;     
    }

    global static CampaignMember createTestCampaignMember(ID campaignId, ID contactId, String status)
    {
         return createTestCampaignMember(campaignId, contactId, status, 'Participant');     
    } 

    global static CampaignMember createTestCampaignMember(ID campaignId, ID contactId, String status, String type)
    {
        CampaignMember testCampaignMember = new CampaignMember();
        testCampaignMember.CampaignId = campaignId;
        testCampaignMember.ContactId = contactId;
        testCampaignMember.Status = status;
        testCampaignMember.Type__c = type;
        insert testCampaignMember;  

        return testCampaignMember;     
    }    
}