//Author: Sergey Legostaev (slegostaev@mycervello.com) 
//Created: 8/17/2017
@isTest
public class DC_UT_PostalCodeProcessingBatch {
	
    private static Postal_Codes__c pc;
    
    private static void beforeTest() {
        DC_UT_TestUtils.createTerritorySettings();
        DC_TerritorySettings.resetSettings();
        
        final String currentUserId = System.UserInfo.getUserId();
        User currentUser = [select id, Movex_Uer_ID__c from User where Id = :currentUserId];
        currentUser.Movex_Uer_ID__c = 'TST';
        update currentUser;
        
        pc = DC_UT_TestUtils.createPostalCodes();
        pc.User_Territory_1__c = currentUser.Movex_Uer_ID__c;
        update pc;    
    }
    
    private static testMethod void initPostalCodesEtm() {
		beforeTest();
        Test.startTest();
        Database.executeBatch(new DC_PostalCodeProcessingBatch());
        Test.stopTest();
        
        pc = [select DC_ETM_Code__c, DC_ETM_Code_Last_Updated__c from Postal_Codes__c where id =:pc.Id];
        system.debug(pc);
    }
}