public with sharing class LightningCompSetup {

   @AuraEnabled
    public static List<SObject> loadRelatedRecord(String fullName, String fields) {
        List<String> fullNameParts = fullName.split('\\.');
        List<SObject> records = Database.query('select ' + fields + ' from ' + fullNameParts[0] + '__mdt');      
        if(records.size()==0) {
            throw new AuraHandledException('Record not found');
        }
        records.sort();
        return records;
    }
    
   @AuraEnabled
    public static String upsertCmp(String record, String Descr, String Status, String Manager) {        
        return CustomMetadata.Operations
            .callback(
                MetadataDeployment__e.getSObjectType(),
                MetadataDeployment__e.DeploymentId__c, 
                MetadataDeployment__e.Result__c)
            .enqueueUpsertRecords(
                Lightning_Component__mdt.getSObjectType(),
                
                new List<Map<SObjectField, Object>> {
            
            	// Custom Metadata record
            	new Map<SObjectField, Object> {
                Lightning_Component__mdt.DeveloperName => record,
                Lightning_Component__mdt.Label => record,
                Lightning_Component__mdt.Status__c => Status,
                Lightning_Component__mdt.Description__c => Descr,
                Lightning_Component__mdt.Managed_by__c => Manager    
                   
                    } } )    
            .deployId;
    }
    
       @AuraEnabled
    public static String upsertTeam(String record, String Country, String Descr, String Status) {        
        return CustomMetadata.Operations
            .callback(
                MetadataDeployment__e.getSObjectType(),
                MetadataDeployment__e.DeploymentId__c, 
                MetadataDeployment__e.Result__c)
            .enqueueUpsertRecords(
                Team_setup__mdt.getSObjectType(),
                
                new List<Map<SObjectField, Object>> {
            
            	// Custom Metadata record
            	new Map<SObjectField, Object> {
                Team_setup__mdt.DeveloperName => record,
                Team_setup__mdt.Label => record,
                Team_setup__mdt.Country__c => Country,
                Team_setup__mdt.Description__c => Descr,
                Team_setup__mdt.Status__c => Status    
                    } } )    
            .deployId;
    }
    
    @AuraEnabled
    public static List<String> getPickListValuesIntoList(String CmpName, String fldName){
       List<String> pickListValuesList= new List<String>();
		Schema.SObjectField SObjField = Schema.getGlobalDescribe().get(CmpName).getDescribe().fields.getMap().get(fldName);        
        Schema.DescribeFieldResult fieldResult = SObjField.getDescribe();        
		List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
		for( Schema.PicklistEntry pickListVal : ple){
			pickListValuesList.add(pickListVal.getLabel());
		}     
		return pickListValuesList;
    }
    
    @AuraEnabled
    public static List<User> getUserList(String searchStr, String Country, String Team){  
       List<User> rawUserList = new List<User>();
        searchStr = searchStr.replace('*', '%');
        if(searchStr == ''){
            searchStr = '%';            
        }
        if(Country ==''){
            		Country = '%';
            
                    if(Team == '') {
        			Team = '%';        
        			rawUserList = [SELECT Id, FirstName, LastName, Full_Name__c, Profile__c, Team_Setup_ID__c, User_Country__c, IsActive FROM User 
                       WHERE (Full_Name__c LIKE: searchStr) 
                       AND IsActive=true 
                       AND ((User_Country__c LIKE: Country) OR User_Country__c = null) 
                       AND ((Team_Setup_Id__c LIKE: Team) OR (Team_Setup_Id__c = null)) 
                       LIMIT 100];    
        				}
       				else{
                 		rawUserList = [SELECT Id, FirstName, LastName, Full_Name__c, Profile__c, Team_Setup_ID__c, User_Country__c, IsActive FROM User 
                      	WHERE (Full_Name__c LIKE: searchStr) 
                      	AND IsActive=true 
                      	AND ((User_Country__c LIKE: Country) OR User_Country__c = null) 
                      	AND (Team_Setup_Id__c LIKE: Team) 
                      	LIMIT 100];                        
                            }  
        }
        else{
                  if(Team == '') {
        			Team = '%';        
        			rawUserList = [SELECT Id, FirstName, LastName, Full_Name__c, Profile__c, Team_Setup_ID__c, User_Country__c, IsActive FROM User 
                       WHERE (Full_Name__c LIKE: searchStr) 
                       AND IsActive=true 
                       AND (User_Country__c LIKE: Country)
                       AND ((Team_Setup_Id__c LIKE: Team) OR (Team_Setup_Id__c = null)) 
                       LIMIT 100];    
        				}
       				else{
                 		rawUserList = [SELECT Id, FirstName, LastName, Full_Name__c, Profile__c, Team_Setup_ID__c, User_Country__c, IsActive FROM User 
                      	WHERE (Full_Name__c LIKE: searchStr) 
                      	AND IsActive=true 
                      	AND (User_Country__c LIKE: Country) 
                      	AND (Team_Setup_Id__c LIKE: Team) 
                      	LIMIT 100];                        
                            }   
                   
        }
        return rawUserList;        
    }
    
    
    @AuraEnabled
    public static String updateUser(User Usr2Upd, String Team2Upd) {
    	
        Usr2Upd.Team_Setup_Id__c = Team2Upd;
        String result = 'Start';
        try{
            update Usr2Upd;
            result='Updated';
        }
        catch (Exception e){
            String errorMessage = 'Error: ' + e.getMessage() + ' ' + e.getStackTraceString();
            system.debug(errorMessage);
            result='error';
        } 
        
    return result;    
    }
    
   /* @AuraEnabled
    public static String DetectAppName() {
        List<CustomApplication> TestApp = new CustomApplication ();
        TestApp = [SELECT FullName, DeveloperName, Label FROM CustomApplication]
        String result = 'Hej';
        return result;
    }*/
    
    @AuraEnabled
    public static String getCurrentApplication()
    {
        // Get tab set describes for each app
        List<Schema.DescribeTabSetResult> tabSetDesc = Schema.describeTabs();        
        List<UserAppInfo> Test2 = [SELECT UserId, Id, AppDefinitionId FROM UserAppInfo WHERE UserId =: UserInfo.getUserId()];
        String result = '';
        List<AppDefinition> Test = new List<AppDefinition>();
        for(UserAppInfo tsr : Test2) {
            Test = [SELECT Id, DurableId, DeveloperName FROM AppDefinition WHERE DurableId =: tsr.AppDefinitionId];
            result = 'You are now logged into the ' + Test[0].DeveloperName +' app';
        }
        return result;
    }
    
    
    
}