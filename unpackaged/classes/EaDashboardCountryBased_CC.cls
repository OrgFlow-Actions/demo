public class EaDashboardCountryBased_CC {
    
    @AuraEnabled
    public static EADashboardByCountryCS__mdt getHomeDashboardName(String fieldName, String filterFieldName) {
        try {
            User currentUser = GlobalUtils.getCurrentUser();
            String query = 'Select Id, ' + fieldName + ',' + filterFieldName + ' FROM EADashboardByCountryCS__mdt ' + 
                ' Where CountryCode__c = \'' + currentUser.User_Country__c + '\' LIMIT 1';
            List<EADashboardByCountryCS__mdt> eADashboardByCountryCSList = Database.query(query);
            if(eADashboardByCountryCSList.size() > 0) {
                return eADashboardByCountryCSList.get(0);
            }
            query = 'Select Id, ' + fieldName + ',' + filterFieldName + ' FROM EADashboardByCountryCS__mdt ' + 
                ' Where CountryFullName__c = \'' + currentUser.User_Country__c + '\' LIMIT 1';
            eADashboardByCountryCSList = Database.query(query);
            if(eADashboardByCountryCSList.size() > 0) {
                return eADashboardByCountryCSList.get(0);
            }
            query = 'Select Id, ' + fieldName + ',' + filterFieldName + ' FROM EADashboardByCountryCS__mdt ' + 
                'Where CountryCode__c =\'Default\' LIMIT 1';
            eADashboardByCountryCSList = Database.query(query);
            if(eADashboardByCountryCSList.size() > 0) {
                return eADashboardByCountryCSList.get(0);
            }
            query = 'Select Id, ' + fieldName + ',' + filterFieldName + ' FROM EADashboardByCountryCS__mdt ' + 
                'Where CountryFullName__c =\'Default\' LIMIT 1';
            return Database.query(query);
        } catch(Exception e){
            DebugLog.addException(e, e.getMessage());
            return null;
        } 
    }
    @AuraEnabled
    public static EADashboardByCountryCS__mdt getSObjectDashboardName(String fieldName, String filterFieldName, ID recordId, String sObjectFieldName) {
        try {
            String sObjectName = recordId.getSObjectType().getDescribe().getName();
            
            
            String sObjQuery = 'Select Id, '+ sObjectFieldName + 
                ' FROM ' + sObjectName + 
                ' Where Id =\'' + recordId + '\' LIMIT 1'; 
            Sobject sObj = Database.query(sObjQuery);
            
            string whereCountry = null;
            List<String> splitedSObjectFieldName = sObjectFieldName.split('\\.');
            if(splitedSObjectFieldName.size() == 1){
                whereCountry = (String) sObj.get(sObjectFieldName);
            } else{

                sObject sb  = sObj;
                for(integer i=0;i<splitedSObjectFieldName.size()-1;i++){
                    sb=sb.getSobject(splitedSObjectFieldName.get(i));   
                }
                whereCountry = string.valueof(sb.get(splitedSObjectFieldName[splitedSObjectFieldName.size()-1]));
            }
            String query = 'Select Id, ' + fieldName + ',' + filterFieldName + ' FROM EADashboardByCountryCS__mdt ' + 
                'Where CountryCode__c  = \'' + whereCountry + '\' LIMIT 1';
            List<EADashboardByCountryCS__mdt> eADashboardByCountryCSList = Database.query(query);
            if(eADashboardByCountryCSList.size() > 0) {
                return getDashbord(eADashboardByCountryCSList, filterFieldName, sObjectName, recordId);
            }
            query = 'Select Id, ' + fieldName + ',' + filterFieldName + ' FROM EADashboardByCountryCS__mdt ' + 
                'Where CountryFullName__c  = \'' + whereCountry + '\' LIMIT 1';
            eADashboardByCountryCSList = Database.query(query);
            if(eADashboardByCountryCSList.size() > 0) {
                return getDashbord(eADashboardByCountryCSList, filterFieldName, sObjectName, recordId);
            }
            query = 'Select Id, ' + fieldName + ',' + filterFieldName + ' FROM EADashboardByCountryCS__mdt ' + 
                'Where CountryFullName__c =\'Default\' LIMIT 1';
            eADashboardByCountryCSList = Database.query(query);
            if(eADashboardByCountryCSList.size() > 0) {
                return getDashbord(eADashboardByCountryCSList, filterFieldName, sObjectName, recordId);
            }
            query = 'Select Id, ' + fieldName + ',' + filterFieldName + ' FROM EADashboardByCountryCS__mdt ' + 
                'Where CountryCode__c =\'Default\' LIMIT 1';
            return Database.query(query);
        } catch(Exception e){
            DebugLog.addException(e, e.getMessage());
            return null;
        } 
    }
    public static EADashboardByCountryCS__mdt getDashbord(List<EADashboardByCountryCS__mdt> dashboardData, string filterFieldName, string sObjectName, ID recordId) { 
        string filterString =(string) dashboardData.get(0).get(filterFieldName);//AccountPlanFilters__c
        List<String> splitedFilterAPINameList =  filterString.split('#'); //second position contains filterAI name field API
        if(splitedFilterAPINameList.get(1) <> 'recordId'){
            String sObjFilterQuery = 'Select Id, '+ splitedFilterAPINameList.get(1) + 
                ' FROM ' + sObjectName + 
                ' Where Id =\'' + recordId + '\' LIMIT 1'; 
            Sobject sObjFilter = Database.query(sObjFilterQuery);
            String filterFieldIdValue = (String) sObjFilter.get(splitedFilterAPINameList.get(1));
            dashboardData.get(0).put(filterFieldName, filterString.replace('#' + splitedFilterAPINameList.get(1) + '#',filterFieldIdValue));
        }
        return dashboardData.get(0); 
    }
}