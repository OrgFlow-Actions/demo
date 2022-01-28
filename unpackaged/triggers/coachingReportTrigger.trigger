/*------------------------------------------------------------------------------------------------------------------------------------------------------
Trigger Name : coachingReportTrigger

Purpose : This trigger is used for sharing Coaching_Feedback_Report__c to Sales Reps and Sales Manager once 
            Coaching_Feedback_Report__c is created
---------------------------------------------------------------------------------------------------------------------------------------------------------*/
trigger coachingReportTrigger on Coaching_Feedback_Report__c (after insert) {

List<Coaching_Feedback_Report__share> reportShareList = new List<Coaching_Feedback_Report__share>();
    
    //Iterating created Coaching_Feedback_Report__c records
    
    for(Coaching_Feedback_Report__c reportRecord : Trigger.New){
    
        // Creation of Share Records only when Sales Rep / Sales Manager info is populated when coaching / feedback 
        // report is created
        if(reportRecord.Sales_Representative__c != Null || reportRecord.Sales_Manager__c != Null){
            Coaching_Feedback_Report__share reportShare = new Coaching_Feedback_Report__share();
            reportShare.ParentId = reportRecord.Id;
            reportShare.rowCause= 'Manual';
            reportShare.AccessLevel='Read';
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
                    reportShareForManager.AccessLevel='Read';
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
                 }  
                 else{
                     for(Database.Error err : sr.getErrors()){
                        System.debug('Error Message ----------'+err.getMessage()); 
                     }
                 } 
            }
    
    }

}