//Author: Sergey Legostaev (slegostaev@mycervello.com) (6/26/2017)
trigger DC_PostalCodeTrigger on Postal_Codes__c (before update) {
    
    system.debug('DC_PostalCodeTrigger: start trigger');
    DC_Postal_Codes_Triggers__c triggerSetting = DC_Postal_Codes_Triggers__c.getOrgDefaults();
    if (triggerSetting.Disable_Postal_Codes_Trigger__c) {
        system.debug('DC_PostalCodeTrigger is disabled.');
        return;
    }
    
    
    private static DC_User_Territory_Mapping__c territoryMapping = DC_TerritorySettings.territoryMapping;

    if (territoryMapping == null) {
        system.debug('DC_PostalCodeTrigger: TerritoryMapping does not exist');
        return;
    }
    
    private static Map<String, Schema.SObjectField> fieldMap = Schema.SObjectType.Postal_Codes__c.fields.getMap();
    
    if (trigger.isBefore && trigger.isUpdate) {

        //map for relation a postal code and changed fields and values
        Map<Id, Map<String, String>> mappingCodes = new Map<Id, Map<String, String>>();
        
        //this list of new values for search users by code
        Set<String> codes = new Set<String>();
        
        for (Postal_Codes__c pCode : trigger.new) {
            //this set will be store field name and changed value        
            Map<String, String> changes = new Map<String, String>();

            Postal_Codes__c oldObject = trigger.oldMap.get(pCode.id);
            for (String fieldName : DC_TerritorySettings.territoriesFields) {
                //compare new value and old value for the field
                final String newValue = (String)pCode.get(fieldName);
                final String oldValue = (String)oldObject.get(fieldName);
                if (newValue != oldValue) {
                    changes.put(fieldName, newValue);
                    if (newValue != null) {
                        codes.add(newValue);
                    }
                }
            }
            mappingCodes.put(pCode.Id, changes);
        }
        
        
        
        //map of code and an user for the code
        Map<String, User> usersMap = null;
        if (codes.isEmpty() == false) {
            System.debug('codes'+codes);
            usersMap = DC_UserDAO.getUsersMapByPostalCodesSortedByCode(codes);
            System.debug('usersMap'+usersMap);
        }
        
        if (usersMap != null && usersMap.isEmpty() == false) {
            for (Postal_Codes__c pCode : trigger.new) {
                Map<String, String> changes = mappingCodes.get(pCode.Id);
                //get changed fields and values by one
                for (String fieldName: changes.keySet()) {
                    System.debug('fieldName: '+fieldName);
                    //get field name from custom setting by field name that was changed
                    final String fieldNameForUpdate = (String)territoryMapping.get(fieldName);
                    if (fieldNameForUpdate != null && isValidField(fieldNameForUpdate)) {
                        final String code = changes.get(fieldName);
                        System.debug('Debug String: '+String.isBlank(code));
                        User u = usersMap.get(code);
                        system.debug('DC_PostalCodeTrigger: u:' + u);
                        pCode.put(fieldNameForUpdate, String.isBlank(code) || u == null ? null : u.Id);
                    }
                }
            }
            
        }
    }
    
    
    
    private static boolean isValidField(String fieldName) {
        Schema.SObjectField fieldInfo = fieldMap.get(fieldName);
        if (fieldInfo != null) {
            Schema.DescribeFieldResult info = fieldInfo.getDescribe();
            Schema.DisplayType fieldType = info.getType();
            return fieldType == Schema.DisplayType.Reference;
        }
        return false;
    }
}