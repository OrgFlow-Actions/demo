@IsTest
public class SignatureCaptureCMPControllerTest {
    
    testmethod static void TestsaveSignatureToRecordMethod(){
        //Creating dummy account
        Account acc = new Account(Name = 'SF Dev');
        insert acc;
        
        string base64ImgData = 'xyz'; //Dummy value
        string fileName = null;
        
        /* Testing Exceptions */
        // 1. ContentVersion Creation Exception
        try{
        	SignatureCaptureCMPController.saveSignatureToRecord(NULL, base64ImgData, 'Throw CV Exception');
        }catch(Exception e){
            system.debug(e.getMessage());
            system.assert(e.getMessage().contains('SignatureCaptureCMPControllerException.saveSignatureToRecord Error: Insert failed.'));
        }
        
        // 2. Content Document Link creation exception
        try{
        	SignatureCaptureCMPController.saveSignatureToRecord(acc.Id, base64ImgData, 'Throw CD Exception');
        }catch(Exception e){
            system.debug(e.getMessage());
            system.assert(e.getMessage().contains('SignatureCaptureCMPControllerException.saveSignatureToRecord Error: Insert failed.'));
        }
        
        Test.startTest();
        	SignatureCaptureCMPController.saveSignatureToRecord(acc.Id, base64ImgData, fileName);
        	ContentDocumentLink[] cdl = [Select Id FROM ContentDocumentLink WHERE LinkedEntityId =:acc.Id];
        	system.assertEquals(1, cdl.size());
        Test.stopTest();
    }

}