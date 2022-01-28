public class ActivityHistoryControllerExtension {
    private final Account account;
    ApexPages.StandardController sc;
    public List<ActivityHistory> ActivityHistory{set;}
    public boolean btnClick ;
    public ActivityHistoryControllerExtension(ApexPages.StandardController stdController) {
        this.account = (Account)stdController.getRecord();
        sc = stdController;
        btnClick = false;
    }
    
    public PageReference doCancel()
    {  
        return sc.cancel();
    }
    public PageReference showMyActivities()
    { 
        btnClick = true;  
        getActivityHistory();
        return null;
    }
    public List<ActivityHistory> getActivityHistory() {
        List<ActivityHistory> activityHistory = new List<ActivityHistory>{};
        string uid = userinfo.getUserId();
        string country;
        user u = [select User_Country__c from user where Id =: uid limit 1];
        Map<String,Hide_Mass_email_from_view_all_activities__c> hide= Hide_Mass_email_from_view_all_activities__c.getall();
        
        if(btnClick == false){    
           if(account != null) {
               If(!hide.containsKey(u.User_Country__c)){
                for(Account a: [SELECT (SELECT Subject, Objective__c, What.Name, Owner.Name, ActivityDate, Event_Status__c, Status, Customer_Facing_Event__c, Description, Call_Report__r.Call_Notes__c from ActivityHistories ORDER BY ActivityDate DESC LIMIT 50) FROM Account WHERE Id = :account.Id]) {
                    for(ActivityHistory ah: a.ActivityHistories) {
                            activityHistory.add(ah);
                    }
            }
           }
               else{
                for(Account a: [SELECT (SELECT Subject, Objective__c, What.Name, Owner.Name, ActivityDate, Event_Status__c, Status, Customer_Facing_Event__c, Description, Call_Report__r.Call_Notes__c from ActivityHistories where Customer_Facing_Event__c = true ORDER BY ActivityDate DESC LIMIT 50) FROM Account WHERE Id = :account.Id]) {
                    for(ActivityHistory ah: a.ActivityHistories) {
                            activityHistory.add(ah);
                    }
            }   
               }
           }
           }
        if(btnClick == true){
            if(account != null) {
                If(!hide.containsKey(u.User_Country__c)){
                for(Account a: [SELECT (SELECT Subject, Objective__c, What.Name, Owner.Name, ActivityDate, Event_Status__c, Status, Customer_Facing_Event__c, Description, Call_Report__r.Call_Notes__c from ActivityHistories where Owner.Id= : uid ORDER BY ActivityDate DESC LIMIT 50) FROM Account WHERE Id = :account.Id]) {
                    for(ActivityHistory ah: a.ActivityHistories) {
                            activityHistory.add(ah);
                    }
                }
                }
            
            else{
                for(Account a: [SELECT (SELECT Subject, Objective__c, What.Name, Owner.Name, ActivityDate, Event_Status__c, Status, Customer_Facing_Event__c, Description, Call_Report__r.Call_Notes__c from ActivityHistories where Owner.Id= : uid and Customer_Facing_Event__c = true ORDER BY ActivityDate DESC LIMIT 50) FROM Account WHERE Id = :account.Id]) {
                    for(ActivityHistory ah: a.ActivityHistories) {
                            activityHistory.add(ah);
                    }
                }
            }
            }      
        }
        return activityHistory;
    } 
}