@isTest
public class ContactCardControllerExtensionTest {
    static testMethod void test() {
	    Contact testContact = new Contact();
        testContact.FirstName = 'Kalle';
        testContact.LastName = 'Karlsson';
        insert testContact;
        
        Test.startTest();
        ApexPages.StandardController ctrl = new ApexPages.StandardController(testContact);
        ContactCardControllerExtension ctrlExt = new ContactCardControllerExtension(ctrl);

        List<CampaignMember> campaign = ctrlExt.getCampaignMembers();
    	System.assertNotEquals(null, campaign);	

        List<Network__c> network = ctrlExt.getNetworks();
    	System.assertNotEquals(null, network);	
        
        List<Trackwise__c> trackwise = ctrlExt.getTrackwiseComplaints();
    	System.assertNotEquals(null, trackwise);	
        
        List<Case> cases = ctrlExt.getCases();
    	System.assertNotEquals(null, cases);	
        
        List<CampaignMember> cm = ctrlExt.getCampaignMembers();
    	System.assertNotEquals(null, cm);	
        
        List<Event> cfes = ctrlExt.getEvents3();
    	System.assertNotEquals(null, cfes);	

        List<Investigator__c> inv = ctrlExt.getInvestigator();
     	System.assertNotEquals(null, inv);	

        Test.stopTest();
    }
}