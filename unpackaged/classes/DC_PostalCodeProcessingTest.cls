@isTest
public class DC_PostalCodeProcessingTest {
    
    static TestMethod void runTest()
    {        
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User u = new User(Alias = 'standt', Email='standarduser@dentsplysirona.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@dentsplysirona.com',
                          Movex_Uer_ID__c = 'C202');
        insert u;   
        DC_UT_TestUtils.createTerritorySettings();
        DC_TerritorySettings.resetSettings();
        Postal_Codes__c pc = new Postal_Codes__c(Name = 'TEST', Territory_6_User__c = u.Id);
        insert pc;
        
        Account a = new Account(Name='TestAccount', Postal_Code_Info__c = pc.Id, BillingPostalCode = 'TEST1');
        insert a;
        
        DC_PostalCodeProcessingController contr = new DC_PostalCodeProcessingController();
        contr.startJob();
        
        DC_PostalCodeProcessingController contr2 = new DC_PostalCodeProcessingController();
        
        a.BillingPostalCode = 'TEST';
        update a;
        
        a.Postal_Code_Info__c = null;
        update a;
        
    }
}