/*------------------------------------------------------------
Author: 		Ahmed LOUDRASSI (Salesforce) 2019-10-21
Description:   	Test Class for the Opportunity Process Builder.
History
<Date>      <Authors Name>     <Brief Description of Change>
20210906    kdoruibin           Updated testLightningPipelineOpportunityNamingConvention to assert the default naming

------------------------------------------------------------*/

@isTest(seeAllData=false)
public class Test_OpportunityPB {
	/*-------------------------------------------------------------------------------------------------------
    Company: Salesforce
    Description: Setup one user for the test class
    History :
    --------------------------------------------------------------------------------------------------------*/
    @testSetup
    private static void setup() {
        TestDataFactory.createBypassCustomSetting();
        List<User> userList = TestDataFactory.createUsers(1, 'System Administrator');
        List<User> userIntegrationList = TestDataFactory.insertIntegrationUsers(1, 'System Administrator');
        TestDataFactory.createGlobalIntegrationSettings(userIntegrationList);
    }
    @isTest
    private static void testSetup() {
        Test.startTest();
        List<User> testUserList = [SELECT Id FROM User WHERE Alias = 'test1'];
        Test.stopTest();

        System.assertEquals(1, testUserList.size(), 'Expected one user');
    }
    @isTest
    public static void testSetOpportunityUserCountry() {
        User testUser = [SELECT Id, User_Country__c FROM User WHERE Alias = 'test1' LIMIT 1];
        List<Account> accounts1 = TestDataFactory.createAccounts(1, 'Geographical_Account', testUser.Id);
        List<Opportunity> opportunities = TestDataFactory.returnOpportunities(1, 'Account_Plan', testUser.Id);
        for(Opportunity opportunity : opportunities) {
            opportunity.AccountId = accounts1[0].Id;
        }
        Test.startTest();
        System.runAs(testUser) {
            insert opportunities;
        }
        Test.stopTest();
        System.assertEquals('Belgium', [SELECT Id, User_Country__c  FROM Opportunity LIMIT 1].User_Country__c );
    }
    @isTest
    public static void testGetImplantAPRestorativeSurgicalAndAtlantis () {
        User testUser = [SELECT Id, Name, User_Country__c FROM User WHERE Alias = 'test1' LIMIT 1];
        List<Account> accounts1 = TestDataFactory.createAccounts(1, 'Geographical_Account', testUser.Id);
        List<Opportunity> opportunities = TestDataFactory.returnOpportunities(1, 'Implant_GET_AP', testUser.Id);
        for(Opportunity opportunity : opportunities) {
            opportunity.AccountId = accounts1[0].Id;
        }
        Test.startTest();
        System.runAs(testUser) {
            insert opportunities;
        }
        Test.stopTest();
        System.assertEquals('Implant GET AP - ' +  accounts1[0].Name + ' - No Usage',
                            [SELECT Id, Name  FROM Opportunity LIMIT 1].Name);
    }
    @isTest
    public static void testImplantGrowAndKeepAPRestorativeSurgicalandAtlantis () {
        User testUser = [SELECT Id, Name, Full_Name__c, User_Country__c FROM User WHERE Alias = 'test1' LIMIT 1];
        List<Account> accounts1 = TestDataFactory.createAccounts(1, 'Geographical_Account', testUser.Id);
        List<Opportunity> opportunities = TestDataFactory.returnOpportunities(1, 'Implant_GROW_KEEP_AP', testUser.Id);
        for(Opportunity opportunity : opportunities) {
            opportunity.AccountId = accounts1[0].Id;
        }
        Test.startTest();
        System.runAs(testUser) {
            insert opportunities;
        }
        Test.stopTest();
        System.assertEquals('Implant GROW & KEEP AP - '+ accounts1[0].Name + ' -  Implants', 
                            [SELECT Id, Name  FROM Opportunity LIMIT 1].Name);
    }
    @isTest
    public static void testLightningPipelineOpportunityNamingConvention () {
        User testUser = [SELECT Id, Name, User_Country__c FROM User WHERE Alias = 'test1' LIMIT 1];
        List<Account> accounts1 = TestDataFactory.createAccounts(1, 'Geographical_Account', testUser.Id);
        List<Opportunity> opportunities = TestDataFactory.returnOpportunities(1, 'Lightning_Pipeline_Opportunity', testUser.Id);

        String categoryString = 'Implants';
        String brandString = 'Other';
        String typeString = 'New Business';
        String spacingString = ' - ';
        String closingDate = String.valueOf(Date.today()).left(10);

        for(Opportunity opportunity : opportunities) {
            opportunity.AccountId = accounts1[0].Id;
            opportunity.NA_Category__c = categoryString;
            opportunity.NA_Brand__c = brandString;
            opportunity.Type = typeString;
            opportunity.CloseDate = Date.today();
            opportunity.OwnerId = testUser.Id;
        }

        Test.startTest();
        System.runAs(testUser) {
            insert opportunities;
        }
        Test.stopTest();

        List<Object> namingParameters = new List<Object>{
            spacingString
            , categoryString
            , brandString
            , typeString
            , closingDate
            , testUser.Name
        };

        String nameTemplate = '{1}{0}{2}{0}{3}{0}{4}{0}{5}';
        String formattedName = String.format(nameTemplate, namingParameters);

        System.assertEquals(formattedName, [SELECT Id, Name FROM Opportunity LIMIT 1].Name);
    }
    @isTest
    public static void testUpdateOpportunityNameForAccountPlanRecordType () {
        User testUser = [SELECT Id, Name, User_Country__c FROM User WHERE Alias = 'test1' LIMIT 1];
        List<Account> accounts1 = TestDataFactory.createAccounts(1, 'Geographical_Account', testUser.Id);
        List<Opportunity> opportunities = TestDataFactory.returnOpportunities(1, 'Account_Plan', testUser.Id);
        for(Opportunity opportunity : opportunities) {
            opportunity.AccountId = accounts1[0].Id;
        }
        Test.startTest();
        System.runAs(testUser) {
            insert opportunities;
        }
        Test.stopTest();
        System.assertEquals('Account Plan - '+ accounts1[0].Name, 
                            [SELECT Id, Name  FROM Opportunity LIMIT 1].Name);
    }
    @isTest
    public static void testRedLightFocusApproval () {
        User testUser = [SELECT Id, Name, User_Country__c FROM User WHERE Alias = 'test1' LIMIT 1];
        List<Account> accounts1 = TestDataFactory.createAccounts(1, 'Geographical_Account', testUser.Id);
        List<Opportunity> opportunities = TestDataFactory.returnOpportunities(1, 'Implant_GET_AP', testUser.Id);
        for(Opportunity opportunity : opportunities) {
            opportunity.AccountId = accounts1[0].Id;
        }
        opportunities.get(0).GET_AP_Red_Light_Focus_Approval__c = 'No';
        Test.startTest();
        System.runAs(testUser) {
            insert opportunities;
        }
        Test.stopTest();
        
    }
    
    @isTest
    public static void testxSbuStages () {
        User testUser = [SELECT Id, Name, User_Country__c FROM User WHERE Alias = 'test1' LIMIT 1];
        List<Account> accounts1 = TestDataFactory.createAccounts(1, 'Geographical_Account', testUser.Id);
        List<Opportunity> opportunities = TestDataFactory.returnOpportunities(1, 'xsbu_prospecting', testUser.Id);
        for(Opportunity opportunity : opportunities) {
            opportunity.AccountId = accounts1[0].Id;
        }
        //opportunities.get(0).StageName = 'Customer Ordered';
        Test.startTest();
        System.runAs(testUser) {
            //insert opportunities;
        }
        Test.stopTest();
        //System.assertEquals(Date.today(), [SELECT Id, CloseDate  FROM Opportunity LIMIT 1].CloseDate);
    }
     @isTest
    public static void testUpdateCloseDateToDec () {
        User testUser = [SELECT Id, Name, User_Country__c FROM User WHERE Alias = 'test1' LIMIT 1];
        List<Account> accounts1 = TestDataFactory.createAccounts(1, 'Geographical_Account', testUser.Id);
        List<Opportunity> opportunities = TestDataFactory.returnOpportunities(1, 'GROW_Lab_Atlantis', testUser.Id);
        for(Opportunity opportunity : opportunities) {
            opportunity.AccountId = accounts1[0].Id;
        }
        opportunities.get(0).StageName = 'Closed Won';
        Test.startTest();
        System.runAs(testUser) {
            insert opportunities;
        }
        Test.stopTest();
        System.assertEquals(date.newInstance(Date.today().year() , 12, 31),
                            [SELECT Id, CloseDate  FROM Opportunity LIMIT 1].CloseDate);
    }
    
    @isTest
    public static void testSendDealerEmail () {
        User testUser = [SELECT Id, Name, User_Country__c FROM User WHERE Alias = 'test1' LIMIT 1];
        List<Account> accountsList = TestDataFactory.createAccounts(2, 'CIM_Account', testUser.Id);
        accountsList[0].Country__c = 'DE';
        accountsList[1].Country__c = 'DE';
        accountsList[1].OneAccount_Type__c = 'Distributor';      
        update accountsList;
        
        List<Contact> contactList = TestDataFactory.returnContacts(2, 'ContactGlobal', testUser.Id);
        contactList.get(0).AccountId = accountsList.get(0).Id;
        contactList.get(0).Email = 'test1.test@dentsplysirona.com.invalid';
        contactList.get(0).InsertEmailMarketingConsentCollected__c = 'No';
        contactList.get(1).AccountId = accountsList.get(1).Id;
        contactList.get(1).Email = 'test2.test@dentsplysirona.com.invalid';
        contactList.get(1).InsertEmailMarketingConsentCollected__c = 'No';
        insert contactList;
        
        List<AccountContactRelation> relations = [SELECT AccountId, ContactId, Specialty__c FROM AccountContactRelation WHERE AccountId =: accountsList.get(1).Id];
        
        for(AccountContactRelation rel : relations){
            rel.Specialty__c = 'Dealer Sales Rep (CEREC)';
        }
        update relations;

        List<Campaign> campaignList = TestDataFactory.returnCampaigns(1, 'Digital_Marketing_Campaign', testUser.Id);
        campaignList.get(0).Brands__c = 'Sinius';
        campaignList.get(0).Notify_Dealer_Sales_Rep_by_Email__c = 'Yes';
        insert campaignList;
        
        List<CampaignMember> campaignMembertList = TestDataFactory.returnCampaignMembers(1);

        campaignMembertList.get(0).ContactId = contactList.get(0).Id;
        campaignMembertList.get(0).CampaignId = campaignList.get(0).Id;
        campaignMembertList.get(0).Dealer__c = accountsList.get(1).Id;
        campaignMembertList.get(0).Status = 'Registered';

        //Hotfix
        List<Opportunity> opportunities = TestDataFactory.returnOpportunities(1, 'Lightning_Pipeline_Opportunity', testUser.Id);
        for(Opportunity opportunity : opportunities) {
            opportunity.AccountId = accountsList.get(0).Id;
            opportunity.Dealer__c = accountsList.get(1).Id;
            opportunity.CampaignId = campaignList.get(0).Id;
            opportunity.NA_Category__c = 'Equipment';
            opportunity.NA_Brand__c = 'Sinius';
        }
        insert opportunities;
        //--
        
        Test.startTest();
        System.runAs(testUser) {
                insert campaignMembertList;
        		campaignMembertList.get(0).Status = 'Responded';
        		update campaignMembertList;
        }
        Test.stopTest();

    }
    
    
    
}