@isTest
private class Test_PushAmountToOpportunities
{
    static testMethod void testPushAmountToOpportunities ()
    { 
        // Create account and related opp with record type GROW Lab Atlantis.
        Account AtlAcc = new Account(Name='Test Atl Acc', Est_ATL_Sales_CY__c=99, Est_Sales_CY__c=321);
        insert AtlAcc;
        
        Date CDate = date.newinstance(date.today().year(), 12, 31);
        
        // If we're past the cutoff date, create the opp for next year.
        Date cutOffDate = date.newinstance(date.today().year(), 12, 31); // <- MICHAEL CHANGE HERE!
        if (date.today() > cutOffDate)
            CDate = CDate.addYears(1);
        
        RecordType rtGrowLabAtlantis = [SELECT Id, Name, DeveloperName, SobjectType FROM RecordType WHERE RecordType.DeveloperName = 'GROW_Lab_Atlantis'];

        Opportunity AtlOpp = new Opportunity(
            Name='Test Atl Op',
            StageName='In Progress', 
            RecordTypeId=rtGrowLabAtlantis.Id,
            Amount=9999, 
            CurrencyISOCode='SEK',
            CloseDate=CDate,
            AccountID=AtlAcc.Id);
        
        insert AtlOpp;
        
        AtlAcc.Est_ATL_Sales_CY__c = 1234;
        update AtlAcc;      
        
        //Retrieve the opportunity - should now be updated.
        Opportunity checkOpp = [select id, Amount from opportunity where id=:AtlOpp.id];
        
        /*RecordType rtGrowSurgical = [SELECT Id, Name, DeveloperName, SobjectType FROM RecordType WHERE RecordType.DeveloperName = 'GROW_Surgical'];

        //Now test that "Est Sales CY" in sync with "Amount" on OPEN Opportunities with Record Type "GROW Surgical" or "GROW Restorative". 
        Opportunity GrowSurgicalOpp = new Opportunity(
            Name='Test Atl Op',
            StageName='In Progress', 
            RecordTypeId=rtGrowSurgical.Id,
            Amount=9999, 
            CurrencyISOCode='SEK',
            CloseDate=CDate,
            AccountID=AtlAcc.Id);
        
        insert GrowSurgicalOpp ;
        
        AtlAcc.Est_Sales_CY__c = 1234;
        update AtlAcc;
        
        test.stopTest();
        
        checkOpp = [select id, Amount from opportunity where id=:GrowSurgicalOpp.id];*/
    }
}