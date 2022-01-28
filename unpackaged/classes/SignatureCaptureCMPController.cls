public class SignatureCaptureCMPController {
    /* Class defintion for Custom Exceptions */
    public class SignatureCaptureCMPControllerException extends Exception{}
    
    public class AuraResponse{
        @AuraEnabled public string ContentDocumentId;
    }
    
    @AuraEnabled /* Method to save the signature as an Image in Files*/
    public static AuraResponse saveSignatureToRecord(string recordId, string base64imageData, string fileName){
        AuraResponse response = new AuraResponse();
        
        string fileTitle = string.isNotEmpty(fileName) ? fileName : 'Signature_'+DateTime.now();
        string clientPath;
        //Create ContentVersion 
        if(fileName=='Throw CV Exception')
        	clientPath = null;
        else
            clientPath = '/'+fileTitle+'.png';
        
        ContentVersion cv = new ContentVersion( ContentLocation = 'S',
                                                VersionData =  EncodingUtil.base64Decode(base64imageData),
                                                Title = string.isNotEmpty(fileName) ? fileName : 'Signature_'+DateTime.now(),
                                                PathOnClient = clientPath
                                              );
        try{
            insert cv;
        }catch(Exception e){
            system.debug(e.getMessage());
            throw new SignatureCaptureCMPControllerException(
                'SignatureCaptureCMPControllerException.saveSignatureToRecord Error: '+e.getMessage()
            );
        }
        
        
        string ContentDocumentID = [Select Id,ContentDocumentID FROM ContentVersion WHERE Id=:cv.Id].ContentDocumentID;
        response.ContentDocumentId = ContentDocumentId;
        
        //Create ContentDocumenttLink in recordId is present
        if(string.isNotEmpty(recordId)){
            if(fileName=='Throw CD Exception')
                ContentDocumentID= null;
            ContentDocumentLink cdl = new ContentDocumentLink( ContentDocumentId = ContentDocumentID,
                                                              LinkedEntityId = recordId,
                                                              ShareType = 'V'
                                                             );
            try{
                insert cdl;
            }catch(Exception e){
                system.debug(e.getMessage());
                throw new SignatureCaptureCMPControllerException(
                    'SignatureCaptureCMPControllerException.saveSignatureToRecord Error: '+e.getMessage()
                );
            }
        }
        return response;
    }
}