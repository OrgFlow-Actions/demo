/*------------------------------------------------------------------------------------------------------------------------------------------------------
Trigger Name : ContentDocumentLinkTrigger

Purpose : This trigger is used to count number of attachments and update Count_Of_Attachments__c to Coaching_Feedback_Report__c record

History: 
20200928 	Miguel Coimbra		#TFUS 2032 Removed the code as not in use, so that I can fix a salesforce limit bug with OrgFlow when creating new sandnoxes

---------------------------------------------------------------------------------------------------------------------------------------------------------*/

trigger ContentDocumentLinkTrigger on ContentDocumentLink ( after insert) {
/*
    Set<Id> parentIds=new Set<Id>();
    for (ContentDocumentLink cdl : Trigger.new ) {
        parentIds.add( cdl.LinkedEntityId );
    }
    //Query Coaching_Feedback_Report__c records based on attachment's LinkedEnitityId    
    List<Coaching_Feedback_Report__c> coReportWithAttachment = new List<Coaching_Feedback_Report__c>([ SELECT Id, ( SELECT Id FROM ContentDocumentLinks) FROM Coaching_Feedback_Report__c WHERE Id IN :parentIds ]);
    List<Coaching_Feedback_Report__c> coReportWithCountToUpdate = new List<Coaching_Feedback_Report__c>();
    
    for ( Coaching_Feedback_Report__c cr : coReportWithAttachment ) {
      //Populate Count_Of_Attachments__c to Coaching_Feedback_Report__c record   
         cr.Count_Of_Attachments__c= cr.ContentDocumentLinks.size(); 
         coReportWithCountToUpdate.add(cr);
    }
    
    if(!coReportWithCountToUpdate.isEmpty()){
       Database.saveresult[] saveResult=Database.update(coReportWithCountToUpdate,false);
          for(Database.saveresult sr:saveResult)
            {
                if(sr.isSuccess()){
                    System.debug('Successfully updated Report Record'+sr.getId());
                 }  
                 else{
                     for(Database.Error err : sr.getErrors()){
                        System.debug('Error Message ----------'+err.getMessage()); 
                     }
                 } 
            }
    }
*/
}