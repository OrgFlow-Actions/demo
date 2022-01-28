@isTest
public with sharing class TeamForce_CaseHierarchy_Test {

    @isTest
    private static void getCaseList_Test(){
        Project__c p = new Project__c();
        p.Name = 'Project';
        insert p;
        
        Deployment_Status_Phase__c pm = new Deployment_Status_Phase__c();
        pm.Project__c = p.Id;
        pm.Name = 'Project milestone';
        insert pm;
        
        Case c = new Case();
        c.Subject = 'Case';
        c.Project_Milestone__c = pm.Id;
        
        TeamForce_CaseHierarchy.getCaseList(p.Id);
        
        
    }   
    
}