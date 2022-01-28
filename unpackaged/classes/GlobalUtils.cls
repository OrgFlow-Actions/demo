/*------------------------------------------------------------  
Author:         Ahmed LOUDRASSI (Salesforce) 2019-09-30   
Description:    Global Utils. 
History 
20190930    Ahmed LOUDRASSI    create getRecordTypeId and getCurrentUser. (#TFUS-000001032)
20211011	Roberto Narbona	   create GetDependentPicklistValues and GetCategoryFromBrand. (TFUS-000003578)
2021118		Roberto Narbona	   update GetCategoryFromBrand removed reference to GetDependentPicklistValues 
							   method and improve performance(TFUS-000003722)

------------------------------------------------------------*/
public class GlobalUtils {
	private static User currentUser;
    private static Map<String,ID> recordTypes = new Map<String,ID> ();
    /*------------------------------------------------------------  
    Description:    Method to retrieve recordTypeId of a SObject by SObjectName
					and RecordTypeApiName
    Inputs:         @param SObjectName and @param recordTypeApiName
    ------------------------------------------------------------*/
    public static Id getRecordTypeId(String SObjectName, String recordTypeApiName){
        String key = SObjectName+recordTypeApiName;
        if(!recordTypes.containsKey(key)) {
            recordTypes.put(key, Schema.getGlobalDescribe()
                                        .get(SObjectName)
                                        .getDescribe()
                                        .getRecordTypeInfosByDeveloperName()
                                        .get(recordTypeApiName)
                                        .getRecordTypeId());
        }
        return recordTypes.get(key);
    }
    /*------------------------------------------------------------  
    Description:    Method to verify if a recordTypeId is in a list of RecordTypes
    Inputs:         @param SObjectName and @param recordTypeApiName and @param recordTypeId
    ------------------------------------------------------------*/
    public static Boolean ifRecordTypeInList(String SObjectName, List<String> recordTypesApiNames,Id recordTypeId){
       for(String recordTypeApiName : recordTypesApiNames) {
          if(getRecordTypeId(SObjectName, recordTypeApiName) == recordTypeId)
              	return true;
       }
        return false;
    }
    public static User getCurrentUser() {
        if(currentUser == null) {
            currentUser = [Select Id, User_Country__c, Full_Name__c, UserRole.Name
                           FROM User
                           WHERE Id =: UserInfo.getUserId()];
        }
        return currentUser;
    }
    /*------------------------------------------------------------  
    Description:    Method to get Category field value from Brand and country values.
    Inputs:         @param country and @param brand and @param categoryField and @param brandField
    ------------------------------------------------------------*/
    public static String getCategoryFromBrand(string country, string brand, Map<String,List<String>> categoryField, Map<String,List<String>> brandField) {
            //Map<String,List<String>> dependentPicklistCountryCategoryMap = getDependentPicklistValues(categoryField);
            //Map<String,List<String>> dependentPicklistCategoryBrandMap = getDependentPicklistValues(brandField);
            for(String countryCategory : categoryField.get(country)){
                if(brandField.get(countryCategory).contains(brand) == true){
                    return(countryCategory);
                }
            }
            return null;
        }
    
    /*------------------------------------------------------------  
    Description:    Method to get dependant picklist values. All credits to:
					https://salesforceprofs.com/how-to-get-dependent-picklist-values-in-apex/
    Inputs:         @param dependToken
    ------------------------------------------------------------*/
    public static Map<String, List<String>> getDependentPicklistValues(Schema.sObjectField dependToken) {
        Schema.DescribeFieldResult depend = dependToken.getDescribe();
        Schema.sObjectField controlToken = depend.getController();
        if (controlToken == null) {
            return new Map<String, List<String>>();
        }
        
        Schema.DescribeFieldResult control = controlToken.getDescribe();
        List<Schema.PicklistEntry> controlEntries;
        if(control.getType() != Schema.DisplayType.Boolean) {
            controlEntries = control.getPicklistValues();
        }
        
        String base64map = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
        Map<String,List<String>> dependentPicklistValues = new Map<String,List<String>>();
        for (Schema.PicklistEntry entry : depend.getPicklistValues()) {
            if (entry.isActive() && String.isNotEmpty(String.valueOf(((Map<String,Object>) JSON.deserializeUntyped(JSON.serialize(entry))).get('validFor')))) {
                List<String> base64chars =
                    String.valueOf(((Map<String,Object>) JSON.deserializeUntyped(JSON.serialize(entry))).get('validFor')).split('');
                for (Integer index = 0; index < (controlEntries != null ? controlEntries.size() : 2); index++) {
                    Object controlValue =
                        (controlEntries == null
                         ?   (Object) (index == 1)
                         :   (Object) (controlEntries[index].isActive() ? controlEntries[index].getValue() : null)
                        );
                    Integer bitIndex = index / 6;
                    if (bitIndex > base64chars.size() - 1) {
                        break;
                    }
                    Integer bitShift = 5 - Math.mod(index, 6);
                    if  (controlValue == null || (base64map.indexOf( base64chars[ bitIndex ] ) & (1 << bitShift)) == 0)
                        continue;
                    if (!dependentPicklistValues.containsKey((String) controlValue)) {
                        dependentPicklistValues.put((String) controlValue, new List<String>());
                    }
                    dependentPicklistValues.get((String) controlValue).add(entry.getValue());
                }
            }
        }
        return dependentPicklistValues;
    }



	

}