@isTest(SeeAllData=false)
public class OpportunityInsertTest {

    @TestSetup
    private static void makeData() {
        // Create bypass custom setting
        TestDataFactory.createBypassCustomSetting();
        List<User> userList = TestDataFactory.returnUsers(1, 'System Administrator');
        userList.get(0).User_Country__c = 'Thailand';
        userList.get(0).User_Type__c = 'Standard';
        insert userList;
        // Create global integration custom setting
        TestDataFactory.createGlobalIntegrationSettings(userList);
        // Create XSBU 2 orgs custom setting
        XSBU_2_orgs__c xsbu2Orgs = new XSBU_2_orgs__c();
        xsbu2Orgs.Name = 'Thailand';
        xsbu2Orgs.Country_Code_del__c = 'TH';
        xsbu2Orgs.Named_Credential__c = 'Salesforce_Org';
        xsbu2Orgs.Connection_Id_del__c = '04P0J0000005qmxUAA';
        xsbu2Orgs.Opportunity_RecordType_Id__c = '0121N0000016FfbQAE';
        insert xsbu2Orgs;
        // Create org level process builder bypass custom setting
        TestDataFactory.createDefaultOrgLevelBypassPB();
    }

    public static testMethod void testOpportunitySynch() {

        // Set mock callout class 
      	Test.setMock(HttpCalloutMock.class, new OpportunitySynchHttpCalloutMock()); 

        // Get test user from testSetup
        User u = [SELECT Id FROM User WHERE Alias = 'test1'][0];

        System.runAs(u) {          
            Account testAccount = TestDataFactory.createAccounts(1, 'Non_ERP_Account', u.Id)[0];   

	        Opportunity opp = new Opportunity();
            opp.AccountId = testAccount.Id;
            opp.Name = 'Test XSBU Synch';
            opp.StageName = 'Submitted';
            opp.CloseDate = System.today() + 5;
            Insert opp;
            System.Debug('Opp Created by: ' + opp.CreatedBy.User_Country__c);
            System.debug('Opp Id: ' + opp.Id);

            Questionnaire_Setup__c testQuestionnaire = new Questionnaire_Setup__c();
        	testQuestionnaire.Questionnaire_Type__c = 'xSBU';
        	testQuestionnaire.Country__c = 'TH';
        	testQuestionnaire.Name = 'Test';
        	testQuestionnaire.Product_Line__c = 'Imaging';
        	testQuestionnaire.Status__c = 'Active';
        	testQuestionnaire.Create_Opportunity__c = 'Sirona Opportunity';
        	testQuestionnaire.Owner_Of_Opportunity__c = 'Default User';
        	testQuestionnaire.Partner_Assignment__c = 'Auto';
        	testQuestionnaire.Default_User__c= UserInfo.getUserId();
        	testQuestionnaire.Show_contact_option__c = true;
            insert testQuestionnaire;
            
        	Q_A__c qa = new Q_A__c();
        	qa.Name = 'Test';
        	qa.Question__c = 'Test Question';
        	qa.Answer__c = 'Test Answer';
        	qa.Opportunity_Name__c = opp.Id;
            qa.Account_Name__c = testAccount.Id;
            qa.Questionnaire_setup__c = testQuestionnaire.Id;
            insert qa;

            Test.startTest();
            OpportunitySynch.SynchOpportunityInsert(opp.Id);
            Test.stopTest();
        }
    }
}