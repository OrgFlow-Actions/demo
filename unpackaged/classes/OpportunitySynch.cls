public class OpportunitySynch  {
    @future(callout=true)
    static public void SynchOpportunityInsert(String oppId) {
        Opportunity opp2;
        String sironaOppId;
        
        // Select opp from db to be able to calculate formula fields.
        opp2 = [SELECT Xsbu_Account_address__c, 
                xsbu_Primary_Contact_name__c,
                Primary_Contact_s_Email_Address__c,
                Primary_Contact_s_Mobile__c,
                Primary_Contact_s_Phone__c,
                Product_Line_Interested_In__c,
                Xsbu_Prospect_Sender__c,
                Xsbu_Account_name__c,
                Source_opp_ID__c,
                User_Country__c,
                xsbu_Dealer_s_Sales_Rep__c,
                xsbu_dealer_name__c,
                Name,
//                CurrencyIsoCode,
                Description,
                Lost_Opportunity_Reason__c,
                Amount,
                StageName,
                Sub_Stage__c,
                CloseDate,
                CreatedBy.User_Country__c
                FROM Opportunity WHERE Id = :oppId];

        system.debug('Opp User Country: ' + opp2.CreatedBy.User_Country__c);
        
        XSBU_2_orgs__c XSBUConfig = XSBU_2_orgs__c.getValues(opp2.CreatedBy.User_Country__c);
        //XSBU_2_orgs__c XSBUConfig = XSBU_2_orgs__c.getValues(opp2.User_Country__c);

        system.debug('XSBUConfig: ' + XSBUConfig);        
        
        //XSBU_2_orgs__c XSBUConfig = XSBU_2_orgs__c.getValues('Thailand');
		String XSBUNamedCredential = XSBUConfig.Named_Credential__c;
        String OpportunityRecordTypeIdTheirOrg = XSBUConfig.Opportunity_RecordType_Id__c;
        
//        String XSBUNamedCredential = 'Salesforce_Org';
//        String OpportunityRecordTypeIdTheirOrg = '012W000000093KLIAY';
        
        System.debug('XSBU Config - Named Credential: ' + XSBUNamedCredential);
        
        OpportunityXsbu synchOpp = new OpportunityXsbu();
        
        synchOpp.Xsbu_Account_address = opp2.Xsbu_Account_address__c;
        synchOpp.Primary_Contact_s_Email_Address = opp2.xsbu_Primary_Contact_name__c;
        synchOpp.Primary_Contact_s_Email_Address = opp2.Primary_Contact_s_Email_Address__c;
        synchOpp.Primary_Contact_s_Mobile = opp2.Primary_Contact_s_Mobile__c;
        synchOpp.Primary_Contact_s_Phone = opp2.Primary_Contact_s_Phone__c;
        synchOpp.Product_Line_Interested_In = opp2.Product_Line_Interested_In__c;
        synchOpp.Xsbu_Prospect_Sender = opp2.Xsbu_Prospect_Sender__c;
       //synchOpp.Q_A = opp2.Q_A__c;
        synchOpp.Xsbu_Customer_name = opp2.Xsbu_Account_name__c;
        //synchOpp.S2S_Product_Line_Interested_In = opp2.Product_Line_Interested_In__c;
        synchOpp.Source_opp_ID = opp2.Source_opp_ID__c;
        synchOpp.User_Country = opp2.User_Country__c;
        //synchOpp.xsbu_Dealer_s_Sales_Rep = opp2.xsbu_Dealer_s_Sales_Rep__c; NOT EXIST
        //synchOpp.xsbu_dealer_name = opp2.xsbu_dealer_name__c; NOT EXIST
        synchOpp.Name = opp2.Name;
//        synchOpp.CurrencyIsoCode = opp2.CurrencyIsoCode;
        synchOpp.Description = opp2.Description;
        synchOpp.Lost_Opportunity_Reason = opp2.Lost_Opportunity_Reason__c;
        synchOpp.Amount = opp2.Amount;
        synchOpp.StageName = opp2.StageName;
        synchOpp.Sub_Stage = opp2.Sub_Stage__c;
        synchOpp.CloseDate = opp2.CloseDate;    
		synchOpp.RecordTypeId = OpportunityRecordTypeIdTheirOrg;        
        
        String serializedOpp = JSON.serialize(synchOpp);
        
        serializedOpp = serializedOpp.replace('Xsbu_Account_address','Xsbu_Customer_Address__c');
/*added*/		serializedOpp = serializedOpp.replace('Primary_Contact_s_Name','xsbu_Primary_Contact_name__c');
        serializedOpp = serializedOpp.replace('Primary_Contact_s_Email_Address','Xsbu_Primary_Contact_s_Email_Address__c');
        serializedOpp = serializedOpp.replace('Primary_Contact_s_Mobile','xsbu_Primary_Contact_s_Mobile__c');
        serializedOpp = serializedOpp.replace('Primary_Contact_s_Phone','xsbu_Primary_Contact_s_Phone__c');
        serializedOpp = serializedOpp.replace('Product_Line_Interested_In','xsbu_Product_Line_Interested_In__c');
        serializedOpp = serializedOpp.replace('Xsbu_Prospect_Sender','Xsbu_Prospect_Sender__c');
       //no need of this serializedOpp = serializedOpp.replace('Q_A','Q_A__c');
        serializedOpp = serializedOpp.replace('Xsbu_Customer_name','Xsbu_Customer_name__c');
       //no need of this serializedOpp = serializedOpp.replace('S2S_Product_Line_Interested_In','S2S_Product_Line_Interested_In__c');
        serializedOpp = serializedOpp.replace('Source_opp_ID','xsbu_Source_opp_ID__c');
        serializedOpp = serializedOpp.replace('User_Country','Country__c');
        //serializedOpp = serializedOpp.replace('xsbu_Dealer_s_Sales_Rep','xsbu_Dealer_s_Sales_Rep__c'); NOT EXIST.
        //serializedOpp = serializedOpp.replace('xsbu_dealer_name','xsbu_dealer_name__c'); NOT EXIST.
        //serializedOpp = serializedOpp.replace('Name','Name');
        //serializedOpp = serializedOpp.replace('CurrencyIsoCode','Currency__c');
        //serializedOpp = serializedOpp.replace('Description','Description');
        serializedOpp = serializedOpp.replace('Lost_Opportunity_Reason','Lost_Opportunity_Reason__c');
        //serializedOpp = serializedOpp.replace('Amount','Amount');
        //serializedOpp = serializedOpp.replace('StageName','StageName');
        serializedOpp = serializedOpp.replace('Sub_Stage','xsbu_Sub_Stage__c');
        //serializedOpp = serializedOpp.replace('CloseDate','CloseDate');            
        
        // Callout with changes to DentsplySirona Org and create Opportunity.
        HttpRequest feedRequest = new HttpRequest();
        
        //feedRequest.setEndpoint('callout:Salesforce_Org/services/data/v32.0/sobjects/Opportunity/');
        feedRequest.setEndpoint('callout:' + XSBUNamedCredential + '/services/data/v32.0/sobjects/Opportunity/');
        
        feedRequest.setHeader('content-type', 'application/json');
        feedRequest.setMethod('POST');
        
        feedRequest.setBody(serializedOpp);
        
        Http http = new Http();
        HTTPResponse feedResponse = http.send(feedRequest);
        System.debug(feedResponse.getBody());
        System.debug(feedResponse.getStatusCode());
        
        if(feedResponse.getStatusCode() > 204) {
            throw new CalloutException(feedResponse.getBody());
        } else {
            //OpportunityResult oppResult = (OpportunityResult) JSON.deserializeUntyped(feedResponse.getBody());
            //sironaOppId = oppResult.id;

            Map<String,Object> responsemap = (Map<String,Object>) JSON.deserializeUntyped(feedResponse.getBody());
            sironaOppId = (String)responsemap.get('id');
        }
        
	    feedRequest.setEndpoint('callout:' + XSBUNamedCredential + '/services/data/v32.0/sobjects/Q_A__c/');

		List<Q_A__c> QAList = [SELECT Name, Question__c, Answer__c, Opportunity_Name__c, Source_Id__c FROM Q_A__c WHERE Opportunity_Name__c = : oppId];

		for(Q_A__c QA : QAList) {
            QAXsbu qaxsbu = new QAXsbu();
            
            qaxsbu.Name = QA.Name;
			qaxsbu.Opportunity_Name = sironaOppId;
			qaxsbu.Question = QA.Question__c;
			qaxsbu.Answer = QA.Answer__c;
			qaxsbu.Source_Id = QA.Source_Id__c;

            String serializedQaxsbu = JSON.serialize(qaxsbu);
        
        	serializedQaxsbu = serializedQaxsbu.replace('Opportunity_Name','Opportunity_Name__c');
        	serializedQaxsbu = serializedQaxsbu.replace('Question','Question__c');
        	serializedQaxsbu = serializedQaxsbu.replace('Answer','Answer__c');
        	serializedQaxsbu = serializedQaxsbu.replace('Source_Id','Source_Id__c');

            feedRequest.setBody(serializedQaxsbu);

			http = new Http();
			feedResponse = http.send(feedRequest);
			System.debug(feedResponse.getBody());
			System.debug(feedResponse.getStatusCode());
        
			if(feedResponse.getStatusCode() > 204) {
				throw new CalloutException(feedResponse.getBody());
			}
		}
    }

    public class OpportunityResult {
        public String id;
        public List<String> errors;
        public Boolean success;
	}    
    
/*    @future(callout=true)
    static public void SynchOpportunityUpdate(String oppId, String serializedOpp) {
		HttpRequest feedRequest = new HttpRequest();

		feedRequest.setEndpoint('callout:Salesforce_Org/services/data/v32.0/sobjects/Opportunity/' + oppId + '?_HttpMethod=PATCH');
           
		feedRequest.setHeader('content-type', 'application/json');
		feedRequest.setMethod('POST');

		feedRequest.setBody(serializedOpp);

	    Http http = new Http();
	    HTTPResponse feedResponse = http.send(feedRequest);
		System.debug(feedResponse.getBody());
	    System.debug(feedResponse.getStatusCode());
        
		if(feedResponse.getStatusCode() > 204) {
			throw new CalloutException(feedResponse.getBody());
		}
	} */

    public class CalloutException extends Exception{}    
}