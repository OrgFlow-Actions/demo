public class ServiceCloud_Account {
   
   @AuraEnabled
    public static Account getAccountInfo(Id recordId){    
    Account acc = [SELECT Id, Name, ShippingAddress, BillingAddress FROM Account WHERE Id=: recordId];
    return acc;    
    }
        
   @AuraEnabled
    public static List<Case> getOpenCases(Id recordId) {
     	List<Case> res = [Select Id, CaseNumber, RecordType.Name,CreatedDate, OwnerId, Owner.FirstName,Owner.LastName,Subject, Description, Status, IsClosed, Priority FROM Case WHERE AccountId =: recordId ORDER BY CreatedDate DESC LIMIT 50];
        return res;        
    }
    
    @AuraEnabled
    public static List<UserTerritory2Association> getTerritoryInfo(Id recordId) {

        List<ObjectTerritory2Association> res = [SELECT Id, Territory2Id FROM ObjectTerritory2Association WHERE ObjectId =: recordId];
        system.debug(res.size());
        if(res.size()>0){
        List<UserTerritory2Association> userTerritories = new List<UserTerritory2Association>();     
        for(Integer i=0; i<res.size(); i++){        
        userTerritories.addAll([SELECT Territory2Id, UserId, RoleInTerritory2, User.SmallPhotoUrl, User.Movex_Uer_ID__c, Territory2.Name, User.FirstName, User.LastName, User.Id, User.Profile.Name, User.UserRole.Name, User.UserRoleId, User.Email FROM UserTerritory2Association WHERE Territory2Id =: res[i].Territory2Id]);
        }
        return userTerritories;   
        }
        return null;
    	
    }
    @AuraEnabled
    public static Map<String, String> getCaseFieldLabels(){
		Schema.DescribeSObjectResult F = Case.SObjectType.getDescribe();
        Map<String, Schema.SObjectField> fieldsMapping = F.fields.getMap();
        
        Map<String, String> result = new Map<String, String>();
        
        for(String fiedName : fieldsMapping.keySet()){            
            Schema.DescribeFieldResult field = fieldsMapping.get(fiedName).getDescribe();
            String labelVar = field.getLabel();
            String nameVar = field.getName();
        	result.put(nameVar, labelVar);    
        }
        
        return result;       
    }

}