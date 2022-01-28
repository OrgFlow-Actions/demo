@isTest
public class ContentDocumentLinkTriggerTest{
 
  static testMethod void ContentDocumentLinkTriggerTest() {
      
      Coaching_Feedback_Report__c coreport= new Coaching_Feedback_Report__c();
      coreport.Name='Coaching Report test1';
      coreport.Report_Type__c='Coaching/Co-Travel';
      coreport.Date_of_Meeting__c=Date.newInstance(2019, 12, 9);
        
      insert coreport;
     
         
        string before = 'Testing base 64 encode';            
         Blob beforeblob = Blob.valueOf(before);
        
      //Insert contentdocument data
         ContentVersion cv = new ContentVersion();
         cv.title = 'test content trigger';      
         cv.PathOnClient ='test';           
         cv.VersionData =beforeblob;          
         insert cv;         
                                                
         ContentVersion testContent = [SELECT id, ContentDocumentId FROM ContentVersion where Id = :cv.Id];
          
        //insert new ContentDocumentLink
        ContentDocumentLink newFileShare = new ContentDocumentLink();
        newFileShare.contentdocumentid = testcontent.contentdocumentid;
        newFileShare.LinkedEntityId = coreport.Id;
        newFileShare.ShareType= 'V';
      insert newFileShare;
      
      Coaching_Feedback_Report__c cr= [ SELECT Id, ( SELECT Id FROM ContentDocumentLinks) FROM Coaching_Feedback_Report__c WHERE Id =: coreport.Id ];
      System.assertEquals(1,cr.ContentDocumentLinks.size());
      
      //Get Content Documents
      List<ContentDocument> cdList = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
      System.assertEquals(cdList.size(), 1);
      delete cdList;
      
      Coaching_Feedback_Report__c cr1= [ SELECT Id, ( SELECT Id FROM ContentDocumentLinks) FROM Coaching_Feedback_Report__c WHERE Id =: coreport.Id ];
      System.assertEquals(0,cr1.ContentDocumentLinks.size());
   }
}