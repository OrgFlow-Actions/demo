Public Class CoachingReportShare {

@InvocableMethod
public static void CoachingReportToShare(List<Id> CreatedCoachingRecordIds){

List<Coaching_Feedback_Report__share> reportShareList = new List<Coaching_Feedback_Report__share>();
List<Id> shareRecordIds=new List<Id>();
    
    List<Coaching_Feedback_Report__c> CreatedCoachingRecordsList= [Select Id,Sales_Manager__c,Sales_Representative__c from Coaching_Feedback_Report__c Where Id IN:CreatedCoachingRecordIds];
    //Iterating created Coaching_Feedback_Report__c records
    System.debug('CreatedCoachingRecordsList%%%%%%%%%%%%%%%%5'+CreatedCoachingRecordsList);
    for(Coaching_Feedback_Report__c reportRecord : CreatedCoachingRecordsList){
    
         System.debug('CreatedCoachingRecordsList %%%%%%%%%%%%%%%%5'+reportRecord.Sales_Representative__c);
          System.debug('CreatedCoachingRecordsList %%%%%%%%%%%%%%%%5'+reportRecord.Sales_Manager__c);
        // Creation of Share Records only when Sales Rep / Sales Manager info is populated when coaching / feedback 
        // report is created
        if(reportRecord.Sales_Representative__c != Null || reportRecord.Sales_Manager__c != Null){
            Coaching_Feedback_Report__share reportShare = new Coaching_Feedback_Report__share();
            reportShare.ParentId = reportRecord.Id;
            reportShare.rowCause= 'Manual';
            reportShare.AccessLevel='Edit';
            if(reportRecord.Sales_Representative__c != Null && reportRecord.Sales_Manager__c == Null){
                reportShare.UserOrGroupId = reportRecord.Sales_Representative__c;
                  reportShareList.add(reportShare);
             }
             else if(reportRecord.Sales_Manager__c != Null && reportRecord.Sales_Representative__c == Null){
                reportShare.UserOrGroupId = reportRecord.Sales_Manager__c;
                  reportShareList.add(reportShare);
             }   
             else if(reportRecord.Sales_Representative__c != Null && reportRecord.Sales_Manager__c != Null && 
                        reportRecord.Sales_Representative__c != reportRecord.Sales_Manager__c  ){
                reportShare.UserOrGroupId = reportRecord.Sales_Representative__c;
                   reportShareList.add(reportShare);
                Coaching_Feedback_Report__share reportShareForManager =new Coaching_Feedback_Report__share();
                    reportShareForManager.ParentId = reportRecord.Id;
                    reportShareForManager.rowCause= 'Manual';
                    reportShareForManager.AccessLevel='Edit';
                    reportShareForManager.UserOrGroupId = reportRecord.Sales_Manager__c;
                       reportShareList.add(reportShareForManager);
             }
        }
    }
    system.debug('reportShareList%%%%%%%%%%5'+reportShareList);
    if(!reportShareList.isEmpty()){
         Database.saveresult[] saveResult=Database.insert(reportShareList,false);
            
            for(Database.saveresult sr:saveResult)
            {
                if(sr.isSuccess()){
                    System.debug('Successfully created share record'+sr.getId());
                    shareRecordIds.add(sr.getId());
                 }  
                 else{
                     for(Database.Error err : sr.getErrors()){
                        System.debug('Error Message ----------'+err.getMessage()); 
                     }
                 } 
            }
    
    }
   
}

}