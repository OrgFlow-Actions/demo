public class EinsteinOCRService {
    public static FINAL String  OCR_API         = 'https://api.einstein.ai/v2/vision/ocr';
    public static FINAL String  OCR_MODEL       = 'OCRModel';
    public static FINAL String  OCR_MODEL_TABEL = 'tabulatev2';
    
    public static void readBusinessCard(){
        String sample = 'https://www.sfdcpanther.com/wp-content/uploads/2020/07/BusinessCard.png';
        String result = EinsteinAPIService.imageOCR(OCR_API, sample, OCR_MODEL, false, true);
        EinsteinOCRResponse response = parseResponse(result);
    }
    
    @AuraEnabled
    public static AuraResponseWrapper readBusinessCardBase64(String sampleBusinessCard, String objectName, String recordId){
        String result = EinsteinAPIService.imageOCR(OCR_API, sampleBusinessCard, OCR_MODEL, true, true);
        EinsteinOCRResponse response = parseResponse(result);
        
        System.debug('Record Id: ' + recordId);
        
        //Assume that the record is a contact in case we send in account Id
        if(recordId !=null){
            objectName = 'Contact';
        }
        else{
            objectName = 'Lead';
        }
        
        SObject sobjectRecord = Schema.getGlobalDescribe().get(ObjectName).newSObject() ;
        if(recordId !=null){
            sobjectRecord.put('AccountId', recordId);
        }
        for(EinsteinOCRResponse.Probabilities prob : response.probabilities){
            System.debug('Prob: ' + prob);

            switch on prob.attributes.tag {
                when 'PERSON' {
                    
                    String fullName = prob.label;
                    List<String> nameList = fullName.split(' ');
                    String firstName = nameList[0];
                    String lastName = nameList[1];
                    
                    sobjectRecord.put('LastName',lastName);
                    sobjectRecord.put('FirstName', firstName);
                }
                when 'PHONE' {
                    sobjectRecord.put('Phone',prob.label);
                }
                when 'MOBILE_PHONE'{
                    sobjectRecord.put('MobilePhone',prob.label);
                }
                when 'EMAIL'{
                    sobjectRecord.put('EMAIL',prob.label);
                }
                when 'WEBSITE' {
                    if(objectName.equals('Lead')){
                        sobjectRecord.put('Website',prob.label);
                    }
                }
                when 'ADDRESS' {
                    if(objectName.equals('Contact')){
                        sobjectRecord.put('MailingStreet',prob.label);
                    }else{
                        sobjectRecord.put('Street',prob.label);
                    }
                }
                when 'ORG' {
                    if(objectName.equals('Lead')){
                        sobjectRecord.put('Company',prob.label);
                    }
                }
            }
        }
        //insert sobjectRecord;
        
        List<sObject> duplicates = new List<sObject>();
        
        if(recordId != null){
            
        Contact c = new Contact();
  
        c = (Contact)sObjectRecord;
        System.debug('Contact: ' + c);
        List<Contact> cList = new List<Contact>();
        cList.add(c);
        
        Datacloud.FindDuplicatesResult[] results = Datacloud.FindDuplicates.findDuplicates(cList);
        for (Datacloud.FindDuplicatesResult findDupeResult : results) {
  			for (Datacloud.DuplicateResult dupeResult : findDupeResult.getDuplicateResults()) {
    			for (Datacloud.MatchResult matchResult : dupeResult.getMatchResults()) {
      				for (Datacloud.MatchRecord matchRecord : matchResult.getMatchRecords()) {
          				System.debug('Duplicate Record: ' + matchRecord.getRecord());
                        duplicates.add(matchRecord.getRecord());
      				}
    			}
  			}
		}
            
        }
        //In case of Lead
        else{
          	Lead l = new Lead();
            l = (Lead)sObjectRecord;
            System.debug('Lead: ' + l);
            
            List<Lead> lList = new List<Lead>();
        	lList.add(l);
            /*
            //not needed since we do not have duplicate rules in Leads this is not needed
            //when we enabled duplicate rules we will need to uncomment this lines
            
            Datacloud.FindDuplicatesResult[] results = Datacloud.FindDuplicates.findDuplicates(lList);
            
            //Check for account matches
           	for (Datacloud.FindDuplicatesResult findDupeResult : results) {   
  				for (Datacloud.DuplicateResult dupeResult : findDupeResult.getDuplicateResults()) {
                    System.debug(dupeResult);  
    				for (Datacloud.MatchResult matchResult : dupeResult.getMatchResults()) {
      					for (Datacloud.MatchRecord matchRecord : matchResult.getMatchRecords()) {
          					System.debug('Duplicate Record: ' + matchRecord.getRecord());
                            System.debug('Match confidence: ' + matchRecord.getMatchConfidence());
                            System.debug(matchRecord);
                        	duplicates.add(matchRecord.getRecord());
      					}
    				}
  				}
			}
			*/

            
            
            
        }
        
        
        AuraResponseWrapper wrapper = new AuraResponseWrapper();
        wrapper.response = result;
        wrapper.objecttype = objectName;
        wrapper.record = sobjectRecord;
        wrapper.duplicates = duplicates;
        return wrapper;
    }
    
    public static void readTextFromImageByURL(){
        String sample = 'https://i1.wp.com/www.sfdcpanther.com/wp-content/uploads/2020/07/Day-1.png';
        String result = EinsteinAPIService.imageOCR(OCR_API, sample, OCR_MODEL, false, false);
        parseResponse(result);
    }
    
    @AuraEnabled
    public static String readTextFromImageByBase64(String sample){
        /*List<ContentDocumentLink> contentLink = [SELECT ContentDocumentId, LinkedEntityId  
                                                 FROM ContentDocumentLink where LinkedEntityId ='0010o00002KIY2SAAX'];
        if(!contentLink.isEmpty()){
            ContentVersion content = [SELECT Title,VersionData FROM 
                                      ContentVersion 
                                      where ContentDocumentId =: contentLink.get(0).ContentDocumentId 
                                      LIMIT 1];
            String sample = EncodingUtil.base64Encode(content.VersionData);
            String result = EinsteinAPIService.imageOCR(OCR_API, sample, OCR_MODEL, true, false);
            parseResponse(result);
        }*/
        String result = EinsteinAPIService.imageOCR(OCR_API, sample, OCR_MODEL, true, false);
        return result;
    }

    @AuraEnabled
    public static string logActivity(String recordId, String accountId){
        Task acty = new Task();
        //acty.WhoId = recordId;
        //acty.WhatId =  accountId;
        acty.WhoId = recordId != null ? recordId : null;
        acty.WhatId =  accountId != null ? accountId : null;
        acty.Status = 'Completed';
        acty.Subject = 'Business Card Scanned';
        
        try {
            insert acty;
            return acty.Id;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }

    }

    private static EinsteinOCRResponse parseResponse(String ressult){
        EinsteinOCRResponse response = (EinsteinOCRResponse)System.JSON.deserialize(ressult, EinsteinOCRResponse.class);
        return response;
    }

    public class AuraResponseWrapper{
        @AuraEnabled
        public string response { get; set; }
        @AuraEnabled
        public String objecttype { get; set; }
        @AuraEnabled
        public sObject record { get; set; }
		@AuraEnabled
        public List<sObject> duplicates { get; set; }
        
    }
}