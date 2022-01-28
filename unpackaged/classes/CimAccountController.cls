public with sharing class CimAccountController {
    public Account account{get; set;}
    public String OneSfId = '';

    public CimAccountController(){
        
        String OneSfId = ApexPages.currentPage().getParameters().get('ONESFID');
        
        if (OneSfId != null) {
            account = [SELECT OneSF_Id__c FROM Account where OneSF_Id__c = :OneSfId];
        }
        else {
            account = new Account();

            String name = ApexPages.currentPage().getParameters().get('NAME');
            String cimId = ApexPages.currentPage().getParameters().get('CIMID');
    
            String fax = ApexPages.currentPage().getParameters().get('FAX');
            String phone = ApexPages.currentPage().getParameters().get('PHONE');
            
            String shippingStreet = ApexPages.currentPage().getParameters().get('BILLINGSTREET');
            
            if(shippingStreet != null) {
                shippingStreet = EncodingUtil.urlDecode(shippingStreet , 'ASCII');
            }
            
            String shippingZipCode = ApexPages.currentPage().getParameters().get('BILLINGZIPCODE');
            String shippingCity = ApexPages.currentPage().getParameters().get('BILLINGCITY');
            String shippingState = ApexPages.currentPage().getParameters().get('BILLINGSTATE');
            String shippingCountry = ApexPages.currentPage().getParameters().get('BILLINGCOUNTRY');
            
            String billingStreet = ApexPages.currentPage().getParameters().get('VISITINGSTREET');
            
            if(billingStreet != null) {
                billingStreet = EncodingUtil.urlDecode(billingStreet , 'ASCII');
            }

            String billingCity = ApexPages.currentPage().getParameters().get('VISITINGCITY');
            String billingZipCode = ApexPages.currentPage().getParameters().get('VISITINGZIPCODE');
            String billingState = ApexPages.currentPage().getParameters().get('VISITINGSTATE');
            String billingCountry = ApexPages.currentPage().getParameters().get('VISITINGCOUNTRY');
    
            String country = ApexPages.currentPage().getParameters().get('COUNTRY');
            String accountType = ApexPages.currentPage().getParameters().get('ACCOUNTTYPE');
            
            account.Name = name;
            account.CimId__c = cimId;
            account.Fax = fax;
            account.Phone = phone;
            if(billingStreet != null) {
                account.BillingStreet = billingStreet.replace('||', '\r\n');
            }
            account.BillingPostalCode = billingZipCode;
            account.BillingCity = billingCity;
            account.BillingState = billingState;
            account.BillingCountry = billingCountry;
            if(shippingStreet != null) {
                account.shippingStreet = shippingStreet.replace('||', '\r\n');
            }
            account.shippingPostalCode = shippingZipCode;
            account.shippingCity = shippingCity;
            account.shippingState = shippingState;
            account.shippingCountry = shippingCountry;
    
            if(country != null) {
                account.country__c = country;
            }
    
            if(accountType != null) {
                account.OneAccount_Type__c = accountType;
            }
        }
    }

    public PageReference redirectToAccount() {

        if(account.OneSF_Id__c != null) {
            System.debug('Redirect to OneSfId: ' + OneSfId);
            string accountId = [select Id from Account where OneSF_Id__c = :account.OneSF_Id__c].Id;
            
            PageReference reRend = new PageReference('/'+ accountId);
            reRend.setRedirect(true);
            System.debug('Redirect to: ' + accountId);
            return reRend;
        }
        else {
            return null;
        }
    }
    
    public PageReference save(){
        upsert account;
        
        OneSfId = [SELECT OneSF_Id__c FROM Account WHERE Id = :account.Id].OneSF_Id__c;

        System.debug('SFDCId: ' + account.Id + ' CIMId: ' + account.CimId__c + ' OneSfId: ' + OneSfId);
        If(account.CimId__c != null) {
            UpdateCim(OneSfId, account.CimId__c);
        }

        ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM,'Record Created Successfully!'));

        PageReference reRend = new PageReference('/'+account.Id);
        reRend.setRedirect(true);
        return reRend;
    }    

    @future(callout=true)
    private static void UpdateCim(string accountId, string cimId) {
        tempuriOrg.BasicHttpsBinding_IService service = new tempuriOrg.BasicHttpsBinding_IService();
        
        service.inputHttpHeaders_x = new Map<String, String>();
        
        // Retrieve custom setting
        List<CIMConnection__c> cimConnection = CIMConnection__c.getall().values();

        //Blob headerValue = Blob.valueOf('dscim013' + ':' + 'C52#mn7xNQdG');
        Blob headerValue = Blob.valueOf(cimConnection[0].CIMUserId__c + ':' + cimConnection[0].CIMPassword__c);
        String authorizationHeader = 'BASIC '+ EncodingUtil.base64Encode(headerValue);
        service.inputHttpHeaders_x.put('Authorization', authorizationHeader);
        service.inputHttpHeaders_x.put('Content-Type', 'text/xml');        
        
        
        schemasMicrosoftCom200310Serializat.ArrayOfstring params = new schemasMicrosoftCom200310Serializat.ArrayOfstring();
        
        params.string_x = new List<String> {accountId, cimId, 'SFDC'};

        System.debug('AccountId: ' + accountId);
        System.debug('CimId: ' + cimId);
        System.debug('AuthorizationHeader: ' + authorizationHeader);
        
        //tempuriOrg.useStoredProcsResponse_useStoredProcsResult_element result = new tempuriOrg.useStoredProcsResponse_useStoredProcsResult_element();
        //tempuriOrg.useStoredProcsStringsResponse_element result = new tempuriOrg.useStoredProcsStringsResponse_element();
        tempuriOrg.useStoredProcsStringsResponse_element result = new tempuriOrg.useStoredProcsStringsResponse_element();
        
        result.useStoredProcsStringsResult = service.useStoredProcsStrings('usp_CIM_Interface_Create_CIM_SFDC_Record',params);
        //service.useStoredProcs('usp_CIM_Interface_Create_CIM_SFDC_Record',params);
        
        System.debug('WEBSERVICE_RESULT: ' + result.useStoredProcsStringsResult);
        
/*        for(schemasMicrosoftCom200310Serializat.ArrayOfstring s: result.useStoredProcsStringsResult)
        {
            System.Debug('Return value:' + s.string_x);
        } */
    }
}