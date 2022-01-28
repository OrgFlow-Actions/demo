trigger ContentDocTrigger on ContentDocument (before delete) { 
   Set<Id> contentDocId=new Set<Id>();
   Integer count;
    Map<Id, Integer> contDocLinkedMap = new Map<Id, Integer>();
    for ( ContentDocument cd : Trigger.old ) {
        contentDocId.add(cd.Id);
    }
    for(ContentDocumentLink cdl : [SELECT ContentDocumentId, LinkedEntityId FROM ContentDocumentLink WHERE ContentDocumentId IN : contentDocId]){
        if(contDocLinkedMap!=null && contDocLinkedMap.Containskey(cdl.LinkedEntityId)){
            contDocLinkedMap.put(cdl.LinkedEntityId,contDocLinkedMap.get(cdl.LinkedEntityId)+1);
        }
        else{
            count=1;
            contDocLinkedMap.put(cdl.LinkedEntityId,count);
        }
     }
    List<Coaching_Feedback_Report__c> coReportWithAttachment = new List<Coaching_Feedback_Report__c>([ SELECT Id, ( SELECT Id FROM ContentDocumentLinks) FROM Coaching_Feedback_Report__c WHERE Id IN : contDocLinkedMap.Keyset()]);
    List<Coaching_Feedback_Report__c> coReportWithCountToUpdate = new List<Coaching_Feedback_Report__c>();
   
    for ( Coaching_Feedback_Report__c cr : coReportWithAttachment ) {
      //Populate Count_Of_Attachments__c to Coaching_Feedback_Report__c record   
         cr.Count_Of_Attachments__c= cr.ContentDocumentLinks.size()-contDocLinkedMap.get(cr.Id); 
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
}