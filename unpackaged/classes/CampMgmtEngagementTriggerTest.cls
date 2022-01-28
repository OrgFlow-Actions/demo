@isTest
private class CampMgmtEngagementTriggerTest
{
    static testmethod void insertTest01()
    {
        Campaign campaign = CampMgmtTestHelpers.createTestCampaign('Test Campaign 1', 'DI_Campaign');      
        Campaign session = CampMgmtTestHelpers.createTestSession(campaign.Id, 'Test Session 1', 'DI_Campaign_Session');
        Account account = CampMgmtTestHelpers.createTestAccount('Test Account 1');
        Contact contact = CampMgmtTestHelpers.createTestContact(account.Id, 'Testis', 'Testisson', 'email@email.com');
        
        enableTrigger();
        
        Engagement__c engagement = new Engagement__c();
        engagement.Name = 'Test Engagement 1';
        engagement.Session__c = session.Id;
        engagement.Speaker__c = contact.Id;
        insert engagement;

        // TODO: Assert something.
    }
    
    private static void enableTrigger()
    {
        BatchSettings__c settings = new BatchSettings__c();
        settings.Name = 'Default';
        settings.CampMgmtEngagementTriggerIsEnabled__c = true;
        insert settings;
    }
}