/*------------------------------------------------------------
Author: 		unknown ?
Description:   	
History
<Date>      <Authors Name>     <Brief Description of Change>
12092019	Miguel				Added Custom Bypass CS Data data creation 
------------------------------------------------------------*/
@IsTest(SeeAllData=true) 
private class Test_postChattertoOpportunity{
    
     static testMethod void testPostChatter(){
        // setup() methods cannot be created because this test class is annotated with @IsTest(SeeAllData=true)as it's covering a Chatter post 
		// thus added methods in the testMethod itself 
        TestDataFactory.createBypassCustomSetting();
        List<User> userList = TestDataFactory.createUsers(1, 'System Administrator'); 
        TestDataFactory.createGlobalIntegrationSettings(userList);
        TestDataFactory.createDefaultOrgLevelBypassPB();
        TestDataFactory.createDefaultOrgLevelBypassPB();
         
         Account acc = new Account(Name='Test Acc');
         insert acc;
        RecordType recTyp= [SELECT Id, Name, DeveloperName, SobjectType FROM RecordType WHERE RecordType.DeveloperName = 'Implant_GET_AP'];

        Opportunity opp= new Opportunity(
            Name='Test Opp',
            StageName='In Progress', 
            Amount=9999, 
            RecordTypeId= recTyp.Id,    
            CloseDate=System.today(),
            AccountID=acc.Id);
        insert opp;
        Profile p = [SELECT Id FROM Profile WHERE Name='Lightning Sales Rep']; 
        User usr = new User(Alias = 'lngSlUsr', Email='lngSalesRepUsr@dentsplysirona.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='lngSalesRepUsr@tstdnsply.com');
        insert usr;
        
        OpportunityTeamMember oppTeam = new OpportunityTeamMember(OpportunityId=opp.Id,UserId=usr.Id,TeamMemberRole='Account Manager');
        insert oppTeam;
        List<id> oppTeamId = new List<id>();
        oppTeamId.add(oppTeam.Id);
        postChattertoOpportunity.postChatter(oppTeamId);
    }
}