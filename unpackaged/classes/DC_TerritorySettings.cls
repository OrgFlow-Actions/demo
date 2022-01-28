//Author: Sergey Legostaev (slegostaev@mycervello.com) (6/26/2017)
public class DC_TerritorySettings {
    
    private static final String USER_TERRITORY = 'User_Territory_{0}__c';
    @TestVisible private static final Integer NUMBER_TERRITORY_FIELDS = 25;
    @TestVisible private static final String TERRITORY_SETTINGS_NAME = 'Territory Mapping';
    
    public static List<String> territoriesFields;
    public static Map<String, String> fieldsMapping;
    public static DC_User_Territory_Mapping__c territoryMapping;
    
    static {
    	resetSettings();
    }
    
    public static void resetSettings() {
		territoriesFields = new List<String>();
        fieldsMapping = new Map<String, String>();
        territoryMapping = DC_User_Territory_Mapping__c.getInstance(TERRITORY_SETTINGS_NAME);
        for (Integer i = 1; i <= NUMBER_TERRITORY_FIELDS; i++) {
            final String fieldName = String.format(USER_TERRITORY, new String[] { String.valueOf(i) });
            territoriesFields.add(fieldName);
            if (territoryMapping != null) {
                String value = (String)territoryMapping.get(fieldName);
                if (String.isNotBlank(value)) {
                    fieldsMapping.put(fieldName, value);
                }
            }
        }
    }
}