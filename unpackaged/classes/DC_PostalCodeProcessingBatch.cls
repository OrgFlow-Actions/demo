//Author: Denis Zhdanov (dzhdanov@mycervello.com)
//Editor: Sergey Legostaev (slegostaev@mycervello.com) (6/26/2017)
global class DC_PostalCodeProcessingBatch implements Database.Batchable<sObject>, Database.Stateful {
    
    private List<Id> updatedIds = new List<Id>();
    //private static final String testId = 'a064E000006PoT6';
    private static final String QUERY = 'select {0} FROM Postal_Codes__c WHERE DC_UpdateCode__c = true';
    private static final String MOVEX_UER_FIELD = 'Movex_Uer_ID__c';

    public DC_PostalCodeProcessingBatch() {}
    
    global Database.QueryLocator start(Database.BatchableContext bc) { 
        return Database.getQueryLocator(getQuery());
    }
    
    global void execute(Database.BatchableContext BC, List<Postal_Codes__c> scope) {
        system.debug('DC_PostalCodeProcessingBatch: scope: ' + scope);
        Set<String> codes = new Set<String>();
        for(Postal_Codes__c pc : scope) {
            for(String fieldName : DC_TerritorySettings.fieldsMapping.keySet()) {
                codes.add((String)pc.get(fieldName));
            }
        }
        
        if (codes.isEmpty() == false) {
            Map<String, User> usersByCodeMap = DC_UserDAO.getUsersMapByPostalCodesSortedByCode(codes);
            
            for(Postal_Codes__c pc : scope) {
                updateMappedFields(pc, usersByCodeMap);
                pc.DC_ETM_Code__c = getCodesString(pc);
                pc.DC_ETM_Code_Last_Updated__c = DateTime.now().addMinutes(10);
                updatedIds.add(pc.Id);
            }
        }
        
        //system.debug('DC_PostalCodeProcessingBatch: codes: ' + codes);
        //system.debug('DC_PostalCodeProcessingBatch: updated_scope: ' + scope);
        update scope;
    }
    
    global void finish(Database.BatchableContext BC) {
        //Database.executeBatch(new DC_AccountUpdateBatch(updatedIds));
        List<Id>update1 = new List<Id>();
        List<Id>update2 = new List<Id>();
        List<Id>update3 = new List<Id>();
        List<Id>update4 = new List<Id>();
        for(integer i=0; i<updatedIds.size(); i++){
            
            if(i<(updatedIds.size()/4)){
                update1.add(updatedIds[i]);
            } else if(i<(updatedIds.size()/4*2)){
                update2.add(updatedIds[i]);
            } else if(i<(updatedIds.size()/4*3)){
                update3.add(updatedIds[i]);            
            } else if(i<(updatedIds.size())){
                update4.add(updatedIds[i]);
            }
        
        }
        
        Database.executeBatch(new DC_AccountUpdateBatch(update1));
        Database.executeBatch(new DC_AccountUpdateBatch(update2));
        Database.executeBatch(new DC_AccountUpdateBatch(update3));
        Database.executeBatch(new DC_AccountUpdateBatch(update4));
    }
    
    private void updateMappedFields(Postal_Codes__c pc, Map<String, User> usersByCodeMap) {
        for(String fieldName : DC_TerritorySettings.fieldsMapping.keySet()) {
            final String fieldValue = (String) pc.get(fieldName);            
            final String mappedField = DC_TerritorySettings.fieldsMapping.get(fieldName);
             
            if (fieldValue == null) {
                pc.put(mappedField, null);
            } else {
                final String relationName = mappedField.replace('__c', '__r');
                sObject relatedUser = pc.getSobject(relationName);
                final String currentValue = (relatedUser == null ? null : (String)relatedUser.get(MOVEX_UER_FIELD));
                if (fieldValue != currentValue) {
                    User validUser = usersByCodeMap.get(fieldValue);
                    pc.put(mappedField, validUser == null ? null : validUser.Id);
                }
            }
            
        }
    }
    
    private String getCodesString(Postal_Codes__c pc) {
        String result = '';
        for(String fieldName : DC_TerritorySettings.fieldsMapping.keySet()) {
            result += screenNulls((String)pc.get(fieldName));
        }
        
        return result;        
    }
    
    private String screenNulls(String str) {
        return str == null ? '' : str + '#';
    }
    
    private String getQuery() {
        List<String> fields = new List<String>();

        for (String field : DC_TerritorySettings.fieldsMapping.keySet()) {
            String mappedField = DC_TerritorySettings.fieldsMapping.get(field);
            fields.add(field);
            fields.add(mappedField);
            fields.add(mappedField.replace('__c', '__r.') + MOVEX_UER_FIELD);
        }
        
        final String query = fields.isEmpty() ? null : String.format(QUERY, new String[] { String.join(fields, ',') });
        system.debug('DC_PostalCodeProcessingBatch: query: ' + query);
        return query;
    }


}