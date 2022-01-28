public with sharing class ReportPackageController {

public ReportPackageController(ApexPages.StandardSetController stdController) {
}

public List<Report_Package__c> RepPac {get;set;}
public User UsName {get; set;}
public List<Report_Package_Line__c> ReportList {get; set;}

public void fetchRecords(){
UsName = [Select Id, Name, Report_Package__c FROM User WHERE Id =: UserInfo.getUserId()];
If (UsName.Report_Package__c != '') {
RepPac = [Select Id, Name From Report_Package__c WHERE Id =: UsName.Report_Package__c];
    if(!RepPac.IsEmpty()){
    	ReportList = [Select Id, Name, Link__c, Sort_order__c, Description__c FROM Report_Package_Line__c WHERE Report_Package__r.Id =: RepPac[0].Id ORDER BY Sort_order__c];
    }
}

}
         
}