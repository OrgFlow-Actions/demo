public with sharing class UserToReportPackage {

public User UsName {get; set;}
public Report_Package__c CurrentReportPackage {get; set;} 
public List<Report_Package__c> ReportList {get; set;}
Public String getRadioValue{get;set;}
public PageReference UserLink {get; set;}

public UserToReportPackage(ApexPages.StandardController stdController) {
}

public void fetchRecords(){
UsName = [Select Id, Name, Report_Package__c,Market__c FROM User WHERE Id =: apexPages.currentPage().getParameters().get('id')];

if (UsName.Report_Package__c<>null) {
CurrentReportPackage = [SELECT ID, Name FROM Report_Package__c WHERE Id =: UsName.Report_Package__c];
getRadioValue = CurrentReportPackage.Id;
}

ReportList = [Select Id, Name FROM Report_Package__c WHERE Market__c=:UsName.Market__c LIMIT 50];
this.getDealerOptions();

}

public List<SelectOption> getDealerOptions() {

List<SelectOption> options = new List<SelectOption>();

for (Report_package__c dealerSelect : ReportList) {
options.add(new SelectOption(dealerSelect.id, dealerSelect.Name));
}

return options;

}

public PageReference saveReport() {

for(Report_Package__c ReportSelect: ReportList) {

If (ReportSelect.id == getRadioValue){
UsName.Report_Package__c = ReportSelect.id; 
update UsName;
}
}

UserLink = new PageReference('/' + UsName.id + '?noredirect=1&isUserEntityOverride=1');
return UserLink;

}


         
}