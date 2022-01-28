public class ServiceCloud_Contact {
   
    @AuraEnabled
    public static Contact getContactInfo(Id recordId){    
    Contact acc = [SELECT Id, Name FROM Contact WHERE Id=: recordId];
    return acc;    
    }
     
   @AuraEnabled
    public static List<Case> getOpenCases(Id recordId) {
     	List<Case> res = [Select Id, CaseNumber, RecordType.Name,CreatedDate, OwnerId, Owner.FirstName,Owner.LastName,Subject, Description, Status, IsClosed FROM Case WHERE ContactId =: recordId ORDER BY CreatedDate DESC LIMIT 50];
        return res;        
    }

    //Method to capture all labels from the case object
    
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