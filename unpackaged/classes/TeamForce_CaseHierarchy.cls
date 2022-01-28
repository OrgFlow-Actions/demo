public class TeamForce_CaseHierarchy {

    @AuraEnabled
    public static List<Deployment_Status_Phase__c> getCaseList(String recordId){
        List<Deployment_Status_Phase__c> caseList = new List<Deployment_Status_Phase__c>();
        caseList = [SELECT Id, Project__c, Status__c, Name, Meeting_date__c,
                    (SELECT Id, CaseNumber, Subject, Parent.CaseNumber, ParentId, Parent.Subject FROM Cases__r)
                    FROM Deployment_Status_Phase__c 
                    WHERE Project__r.Id =: recordId 
                    ORDER BY Meeting_date__c ASC];    
    return caseList;
    }
    
}