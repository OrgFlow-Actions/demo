//Author: Sergey Legostaev (slegostaev@mycervello.com) 
//Created: 8/16/2017
@isTest
public class DC_UT_PostCodeTrigger {
    
    private static Postal_Codes__c postalCodes;
	
    private static void beforeTest() {
        DC_UT_TestUtils.createTerritorySettings();
        postalCodes = DC_UT_TestUtils.createPostalCodes();
    }
    
    private static testMethod void disableTrigger() {
        beforeTest();
		DC_Postal_Codes_Triggers__c triggerSetting = DC_Postal_Codes_Triggers__c.getOrgDefaults();
        triggerSetting.Disable_Postal_Codes_Trigger__c = true;
        insert triggerSetting;
        
        postalCodes.City__c = 'test city';
        update postalCodes;  
    }
    
    private static testMethod void updateCode() {
        beforeTest();
        DC_TerritorySettings.resetSettings();
        
        
        final String currentUserId = System.UserInfo.getUserId();
        User currentUser = [select id, Movex_Uer_ID__c from User where Id = :currentUserId];
        currentUser.Movex_Uer_ID__c = 'TST';
        update currentUser;
        
        
        postalCodes.User_Territory_1__c = currentUser.Movex_Uer_ID__c;
        update postalCodes;
        
        final String fieldName = DC_TerritorySettings.fieldsMapping.get('User_Territory_1__c');
        final String query = 'select ' + fieldName + ' from Postal_Codes__c where id = \'' + postalCodes.Id + '\'';
        Postal_Codes__c updatedPostalCodes = Database.query(query);
        
        final object userId = (String)((sObject)updatedPostalCodes).get(fieldName);
        
        system.assertEquals(currentUserId, userId);
        
    }
}