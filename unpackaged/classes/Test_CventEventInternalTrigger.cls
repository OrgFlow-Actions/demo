/*------------------------------------------------------------
Author: 		Richard Trum (Glimt) 2020-03-04
Description:   	Test Class for all CventEventInternalTrigger methods.
History
<Date>      <Authors Name>     <Brief Description of Change>
20200304 	Richard Trum		Created test class for the trigger framework for the Cvent Event object
------------------------------------------------------------*/

@isTest(seeAllData=false)
public class Test_CventEventInternalTrigger {

    /*-------------------------------------------------------------------------------------------------------
    Company: Salesforce
    Description: Setup one user for the test class
    History :
    --------------------------------------------------------------------------------------------------------*/
    @testSetup
    private static void setup() {
        TestDataFactory.createBypassCustomSetting();
        List<User> userList = TestDataFactory.createUsers(1, 'System Administrator');
    }

    @isTest
    private static void testSetup() {
        Test.startTest();
        List<User> testUserList = [SELECT Id FROM User WHERE Alias = 'test1'];
        Test.stopTest();

        System.assertEquals(1, testUserList.size(), 'Expected one user');
    }

    /*-------------------------------------------------------------------------------------------------------
    Company: Glimt
    Description: Test method for CventEventInternalTriggerHelper.createCampaign()
    History :
    --------------------------------------------------------------------------------------------------------*/
    @isTest
    private static void testCreateCampaign() {
        User testUser = [SELECT Id FROM User WHERE Alias = 'test1' LIMIT 1];
        
        //Create necessary custom settings
        CVENT_CampaignEventMapping__c statusMap = new CVENT_CampaignEventMapping__c();
        statusMap.CampaignStatus__c = 'Pending';
        statusMap.CventEventStatus__c = 'Active';
        statusMap.Name = 'Active';
        insert statusMap;
        
        CVENT_CampaignAttendeeMapping__c cmStatusMap = new CVENT_CampaignAttendeeMapping__c();
        cmStatusMap.CampaignStatus__c = 'Confirmed';
        cmStatusMap.Name = 'Accepted';
        cmStatusMap.CVENTAtteendeStatus__c = 'Accepted';
        insert cmStatusMap;
		
        //Create Cvent event
		CVENT__Cvent_Event__c ev = new CVENT__Cvent_Event__c();
        ev.Name = 'Test event';
        ev.CVENT__Country_Name__c = 'Sweden';
        ev.CVENT__CurrencyCode__c = 'SEK';
        ev.CVENT__StartDate__c = Date.today();
        ev.CVENT__EndDate__c = Date.today();
        ev.CVENT__Event_Address_City__c = 'Stockholm';
        ev.CVENT__Event_Status__c = 'Active';
        

        Test.startTest();
        
        try {
        	insert ev;
        }
        catch(DmlException e){
            System.assertNotEquals(null, e.getDmlMessage(0));
        }
        
        CVENT__Cvent_Event__c createdEvent = [SELECT Id, CVENT__Campaign__c FROM CVENT__Cvent_Event__c WHERE Id =: ev.Id];
        
        System.assertNotEquals(null, createdEvent.CVENT__Campaign__c);
        
        Test.stopTest();

    }
    
    /*-------------------------------------------------------------------------------------------------------
    Company: Glimt
    Description: Test method for CventEventInternalTriggerHelper.setEventOwner()
    History :
    --------------------------------------------------------------------------------------------------------*/
    @isTest
    private static void testSetEventOwner() {
        
        //Create necessary custom settings
        CVENT_CampaignEventMapping__c statusMap = new CVENT_CampaignEventMapping__c();
        statusMap.CampaignStatus__c = 'Pending';
        statusMap.CventEventStatus__c = 'Active';
        statusMap.Name = 'Active';
        insert statusMap;
        
        CVENT_CampaignAttendeeMapping__c cmStatusMap = new CVENT_CampaignAttendeeMapping__c();
        cmStatusMap.CampaignStatus__c = 'Confirmed';
        cmStatusMap.Name = 'Accepted';
        cmStatusMap.CVENTAtteendeStatus__c = 'Accepted';
        insert cmStatusMap;
              
        //Create Cvent event
		CVENT__Cvent_Event__c ev = new CVENT__Cvent_Event__c();
        ev.Name = 'Test event';
        ev.Email_of_Meeting_Planner_KOL_Manager__c = 'invalid@dentsplysirona.com';
        ev.CVENT__Country_Name__c = 'Sweden';
        ev.CVENT__CurrencyCode__c = 'SEK';
        ev.CVENT__StartDate__c = Date.today();
        ev.CVENT__EndDate__c = Date.today();
        ev.CVENT__Event_Address_City__c = 'Stockholm';
        ev.CVENT__Event_Status__c = 'Active';
        
        // Create a unique UserName
        String uniqueUserName = 'standarduser' + DateTime.now().getTime() + '@testorg.com';
        // This code runs as the system user
        Profile p = [SELECT Id FROM Profile WHERE Name='#System: System Administrator'];
        User u1 = new User(Alias = 'standt', Email='invalid1@dentsplysirona.com',
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
        LocaleSidKey='en_US', ProfileId = p.Id,
        TimeZoneSidKey='America/Los_Angeles',
        UserName=uniqueUserName);
		insert u1;        
	
        String uniqueUserName2 = 'standarduser2' + DateTime.now().getTime() + '@testorg.com';
        User u2 = new User(Alias = 'standt', Email='invalid@dentsplysirona.com',
        EmailEncodingKey='UTF-8', LastName='Testing 2', LanguageLocaleKey='en_US',
        LocaleSidKey='en_US', ProfileId = p.Id,
        TimeZoneSidKey='America/Los_Angeles',
        UserName=uniqueUserName2);
		insert u2;        

        Test.startTest();
        
        try {
        	insert ev;
        }
        catch(DmlException e){
            System.assertNotEquals(null, e.getDmlMessage(0));
			System.debug('Error occured at insert of Cvent Event: ' + e);            
        }
        
        List<CVENT__Cvent_Event__c> updatedEvents = new List<CVENT__Cvent_Event__c>();
        
        try{
        	updatedEvents = [SELECT Id, OwnerId FROM CVENT__Cvent_Event__c];
        }
        catch(exception e){
            System.debug(e);
        }
            
        System.assertEquals(updatedEvents[0].OwnerId, u2.Id);
        
        Test.stopTest();

    }    
    
        
    

}