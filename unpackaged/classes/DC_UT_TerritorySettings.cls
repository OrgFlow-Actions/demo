//Author: Sergey Legostaev (slegostaev@mycervello.com) 
//Created: 8/15/2017
@isTest
public class DC_UT_TerritorySettings {
	
    private static void beforeTest() {
		DC_UT_TestUtils.createTerritorySettings();
    }
    
    private static testMethod void readSettingsTest() {
        beforeTest();
        DC_TerritorySettings.resetSettings();
        List<String> fields = DC_TerritorySettings.territoriesFields;
        System.assertEquals(DC_TerritorySettings.NUMBER_TERRITORY_FIELDS, fields.size());
        
        Map<String, String> mapping = DC_TerritorySettings.fieldsMapping;
        System.assert(mapping.size() > 0, 'Mapping should be more 0');
        
        DC_User_Territory_Mapping__c settings = DC_TerritorySettings.territoryMapping;
        System.assertEquals(DC_TerritorySettings.TERRITORY_SETTINGS_NAME, settings.Name);
	}
}