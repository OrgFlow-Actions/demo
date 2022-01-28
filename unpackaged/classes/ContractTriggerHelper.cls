/*-------------------------------------------------------------------------------------------------------
Author:         Kevin Do (Salesforce) 20190924
Description:    Contract Trigger Helper Class
Test Class:     
History:
20200205    Kevin Do            Bug fix on updateAllowedDiscount to recalculate formula fields 
20190924    Kevin Do            Created Class
20211206	Roberto Narbona		Uopdated SAQL query(TFUS-000003784)
----------------------------------------------------------------------------------------*/

global with sharing class ContractTriggerHelper {
    private static final String SOBJECT_NAME = 'Contract';
    
    /*------------------------------------------------------------  
    Description:    Method migrated from Contract_Default_Process_Builder: Contract: Set start parameters criteria node 
                    Containing Contract_Update_sales_history Flow and Contract_find_previous Flow
                    Should only be called before insert or from Update sales history button on Contract record page.
    Inputs:         @param newContractList
    ------------------------------------------------------------*/
    public static void setStartParameters(List<Contract> newContractList) {
        // Create a Set of AccountIds of the Contract AccountIds
        Set<Id> accountToQueryIdSet = new Set<Id>();
        Set<Contract> contractToUpdateSet = new Set<Contract>();
        for (Contract contractRecord : newContractList) {
            // Process Builder 'Contract: Set start parameters' condition 1
            // Only update Contracts with Record Type 'Pricing_contract'
            if (contractRecord.RecordTypeId == GlobalUtils.getRecordTypeId(SOBJECT_NAME, 'Pricing_contract')) {
                accountToQueryIdSet.add(contractRecord.AccountId);
                contractToUpdateSet.add(contractRecord);
            }
        }
         // Get related Account records
        Map<Id, Account> relatedAccountMap = new Map<Id, Account>([
            SELECT Id, OneSF_Id__c, Sales_L12M_D__c, Sold_Implants_L12M__c, Sales_L13_24M_D__c, Country__c,
                (SELECT Id, AccountId FROM Contracts ORDER BY CreatedDate DESC LIMIT 1)
            FROM Account
            WHERE Id IN :accountToQueryIdSet
        ]);

        for (Contract contractToUpdate: contractToUpdateSet) {
            // Process Builder 'Contract: Set start parameters' condition 2
            // Only update Contracts where Account.Country__c is 'DE'
            if ('DE'.equalsIgnoreCase(relatedAccountMap.get(contractToUpdate.AccountId).Country__c)) {
                Account relatedAccount = relatedAccountMap.get(contractToUpdate.AccountId);
                updateSaleshistory(contractToUpdate, relatedAccount);
                setPreviousContract(contractToUpdate, relatedAccount);
                setDiscountModel(contractToUpdate);
            }
        }
    }

    /*------------------------------------------------------------  
    Description:    Helper method for setStartParameters()
                    Method migrated from Contract_Default_Process_Builder (Update sales history)
                    Updates Contract sales fields based on its' Account fields
    Inputs:         @param contractToUpdate, @param relatedAccount
    ------------------------------------------------------------*/
    public static void updateSaleshistory(Contract contractToUpdate, Account relatedAccount) {
        
        BatchSettings__c settings = BatchSettings__c.getInstance('Default');        
        Boolean disabled = false;
        if(settings.DisableContractTriggerHelperUpdSales__c == true){
            disabled = true;
        }        
        if(disabled ==false){
            
        // Impl_comm_form Flow formula variable
        Double contractImplCommitPercInput = (null == contractToUpdate.Implant_commitment_perc_input__c) ? 0 : Double.valueOf(contractToUpdate.Implant_commitment_perc_input__c);             
        Double relatedAccountSoldImplL12M = (null == relatedAccount.Sold_Implants_L12M__c) ? 0 : relatedAccount.Sold_Implants_L12M__c;
        Decimal implCommFormula = ((contractImplCommitPercInput * relatedAccountSoldImplL12M) / 100);
        
        // Check_implant_commitment
        if (!(implCommFormula >= 30 && contractToUpdate.General_practitioner__c == false) || !(implCommFormula >= 10 && contractToUpdate.General_practitioner__c == true)) {
            contractToUpdate.Implant_commitment_perc_input__c = null;
            contractToUpdate.Abutment_commitment_pick__c = null;
            contractToUpdate.Pooled_order_commitment_perc_input__c = null;
        }
        // Assign Account fields to corresponding contract fields
        contractToUpdate.Sales_L12M__c = relatedAccount.Sales_L12M_D__c;
        contractToUpdate.Implant_volume_L12M__c = relatedAccount.Sold_Implants_L12M__c;
        contractToUpdate.Sales_L24M__c = relatedAccount.Sales_L12M_D__c + relatedAccount.Sales_L13_24M_D__c;
        
        }        
    }

    /*------------------------------------------------------------  
    Description:    Helper method for setStartParameters()
                    Method migrated from Contract_Default_Process_Builder (Find previous contract)
                    Updates Contract sales fields based on its' Account fields
    Inputs:         @param contractToUpdate, @param relatedAccount
    ------------------------------------------------------------*/
    public static void setPreviousContract(Contract contractToUpdate, Account relatedAccount) {
        // Contract_find_previous Flow: Set Contract.Previous_contract__c
        if (!relatedAccount.Contracts.isEmpty() && null == contractToUpdate.Previous_contract__c && relatedAccount.Contracts[0].Id != contractToUpdate.Id) {
            contractToUpdate.Previous_contract__c = relatedAccount.Contracts[0].Id;
        }
    }

    /*------------------------------------------------------------  
    Description:    Helper method for setStartParameters()
                    Method migrated from Contract_Default_Process_Builder (Set discount model)
                    Updates Contract sales fields based on its' Account fields
    Inputs:         @param contractToUpdate, @param relatedAccount
    ------------------------------------------------------------*/
    public static void setDiscountModel(Contract contractToUpdate) {
        // Set Discount model from Custom Settings
        if (null != DEDiscountModel__c.getInstance() && null == contractToUpdate.Discount_model__c) {
            contractToUpdate.Discount_model__c = DEDiscountModel__c.getInstance().DiscountModelID__c;
        }
    }

    /*------------------------------------------------------------  
    Description:    Method migrated from Contract_Default_Process_Builder: Contract: Update discounts criteria node.
                    Containing Contract_update_allowed_discount Flow.
                    Should only be called before insert/update.
    Inputs:         @param newContractList, @param oldContractMap
    ------------------------------------------------------------*/
    public static void updateAllowedDiscount(List<Contract> newContractList, Map<Id, Contract> oldContractMap) {
        Map<Id, Set<Contract>> discountModelIdToContractMap = new Map<Id, Set<Contract>>();
        Map<Id, Set<Contract>> accountIdToContractMap = new Map<Id, Set<Contract>>();
        // List of Contracts and clones that need to be kept in sync
        List<Contract> contractOriginalList = new List<Contract>();
        List<Contract> contractCloneList = new List<Contract>();
        for (Contract contractRecord : newContractList) {
            if (contractRecord.RecordTypeId != GlobalUtils.getRecordTypeId(SOBJECT_NAME, 'Pricing_contract')) continue;
            if (null == contractRecord.Discount_model__c) continue;
            if (contractRecord.StatusCode == 'Activated') continue;
            contractOriginalList.add(contractRecord);
            contractCloneList.add(contractRecord.clone());
        }
        
        if (!contractCloneList.isEmpty()) {
            Formula.recalculateFormulas(contractCloneList);
        }

        // Filter contracts on initial Node criteria for Record Type 'Pricing_contract' and create map Discount_model__c ==> Contract
        List<Contract> contractOriginalToUpdateList = new List<Contract>();
        List<Contract> contractCloneToUpdateList = new List<Contract>();
        Integer keyCounterContractClone = 0;
        for (Contract contractRecord : contractCloneList) {
            if (
                (null != oldContractMap
                && (
                    contractRecord.Revenue_basis_for_allowance__c == oldContractMap.get(contractRecord.getCloneSourceId()).Revenue_basis_for_allowance__c
                    && contractRecord.Implant_commitment_perc__c == oldContractMap.get(contractRecord.getCloneSourceId()).Implant_commitment_perc__c
                    && contractRecord.Abutment_commitment_perc__c == oldContractMap.get(contractRecord.getCloneSourceId()).Abutment_commitment_perc__c
                    && contractRecord.Pooled_order_commitment_perc__c == oldContractMap.get(contractRecord.getCloneSourceId()).Pooled_order_commitment_perc__c
                ))
            ) {
                continue;
            }
            if (discountModelIdToContractMap.containsKey(contractRecord.Discount_model__c)) {
                discountModelIdToContractMap.get(contractRecord.Discount_model__c).add(contractRecord);
            } else {
                discountModelIdToContractMap.put(contractRecord.Discount_model__c, new Set<Contract>{contractRecord});
            }
            if (accountIdToContractMap.containsKey(contractRecord.AccountId)) {
                accountIdToContractMap.get(contractRecord.AccountId).add(contractRecord);
            } else {
                accountIdToContractMap.put(contractRecord.AccountId, new Set<Contract>{contractRecord});
            }
            contractOriginalToUpdateList.add(contractOriginalList[keyCounterContractClone]);
            contractCloneToUpdateList.add(contractRecord);
            keyCounterContractClone++;
        }
        // Query related Discount rows
        Map<Id, Discount_row__c> relatedDiscountRowMap = new Map<Id, Discount_row__c>([
            SELECT Id, Discount_lever__c, Min__c, Max__c, Allowed_discount__c, Discount_Model__c, Max_perc__c, Min_perc__c, Equals__c
            FROM Discount_row__c
            WHERE Discount_Model__c IN :discountModelIdToContractMap.keySet()
            ORDER BY Discount_lever__c ASC
        ]);
        // Query related Accounts
        Map<Id, Account> relatedAccountMap = new Map<Id, Account>([
            SELECT Id, Payment_Terms_D_JP__c
            FROM Account
            WHERE Id IN :accountIdToContractMap.keySet()
        ]);
        // Do the main logic: Loop through each Discount row (max 144 existing, 200117) and evaluate each Contract in the same Discount Model
        // Nested loop is needed since there is no direct relationship between Discount_rows__c and Contract.
        // Both of the objects lookup to Discount_model__c and each Contract needs to be evaluated against each Discouunt_row__c.
        for (Discount_row__c discountRowRecord : relatedDiscountRowMap.values()) {
            Integer keyCounterTwoContractCloneToUpdate = 0;
            for (Contract contractRecord: contractCloneToUpdateList) {
                if (contractRecord.Discount_model__c == discountRowRecord.Discount_Model__c) {
                    updateContractDiscountFields(discountRowRecord, contractRecord, contractOriginalToUpdateList[keyCounterTwoContractCloneToUpdate], relatedAccountMap.get(contractRecord.AccountId));
                }
                keyCounterTwoContractCloneToUpdate++;
            }
        }
    }

    /*------------------------------------------------------------  
    Description:    Helper method for updateAllowedDiscount
                    Evaluates a Discount row to a Contract and updates the Contract according to the right criteria
    Inputs:         @param discountRowRecord, @param contractRecord, and @param accountRecord
    ------------------------------------------------------------*/
    private static void updateContractDiscountFields(Discount_row__c discountRowRecord, Contract contractClone, Contract contractRecord, Account accountRecord) {
        if ('Revenue: materials'.equalsIgnoreCase(discountRowRecord.Discount_lever__c)) {
            if (discountRowRecord.Max__c > contractClone.Revenue_basis_for_allowance__c && discountRowRecord.Min__c <= contractClone.Revenue_basis_for_allowance__c) {
                contractRecord.Allowed_discount_revenue_materials__c = discountRowRecord.Allowed_discount__c;
                contractRecord.Row_discount_rev_mat__c = discountRowRecord.Id;
            }
            return;
        }
        if ('Revenue: equipments & instruments'.equalsIgnoreCase(discountRowRecord.Discount_lever__c)) {
            if (discountRowRecord.Max__c > contractClone.Revenue_basis_for_allowance__c && discountRowRecord.Min__c <= contractClone.Revenue_basis_for_allowance__c) {
                contractRecord.Allowed_discount_revenue_equipments__c = discountRowRecord.Allowed_discount__c;
            }
            return;
        }
        if ('Implant: materials'.equalsIgnoreCase(discountRowRecord.Discount_lever__c)) {
            if (discountRowRecord.Max_perc__c > contractClone.Implant_commitment_perc__c && discountRowRecord.Min_perc__c <= contractClone.Implant_commitment_perc__c) {
                contractRecord.Allowed_discount_Implants_materials__c = discountRowRecord.Allowed_discount__c;
                contractRecord.Row_discount_impl_mat__c = discountRowRecord.Id;
            }
            return;
        }
        if ('Implants: equipments & instruments'.equalsIgnoreCase(discountRowRecord.Discount_lever__c)) {
            if (discountRowRecord.Max_perc__c > contractClone.Implant_commitment_perc__c && discountRowRecord.Min_perc__c <= contractClone.Implant_commitment_perc__c) {
                contractRecord.Allowed_discount_Implants_equipment__c = discountRowRecord.Allowed_discount__c;
            }
            return;
        }
        if ('Abutments: materials'.equalsIgnoreCase(discountRowRecord.Discount_lever__c)) {
            if (discountRowRecord.Max_perc__c > contractClone.Abutment_commitment_perc__c && discountRowRecord.Min_perc__c <= contractClone.Abutment_commitment_perc__c) {
                contractRecord.Allowed_discount_abutment_materials__c = discountRowRecord.Allowed_discount__c;
            }
            return;
        }
        if ('Abutments: equipments & instruments'.equalsIgnoreCase(discountRowRecord.Discount_lever__c)) {
            if (discountRowRecord.Max_perc__c > contractClone.Abutment_commitment_perc__c && discountRowRecord.Min_perc__c <= contractClone.Abutment_commitment_perc__c) {
                contractRecord.Allowed_discount_abutment_equipment__c = discountRowRecord.Allowed_discount__c;
            }
            return;
        }
        if ('Pooled implant order: Material'.equalsIgnoreCase(discountRowRecord.Discount_lever__c)) {
            if (discountRowRecord.Max_perc__c > contractClone.Pooled_order_commitment_perc__c && discountRowRecord.Min_perc__c <= contractClone.Pooled_order_commitment_perc__c) {
                contractRecord.Allowed_discount_pooling_materials__c = discountRowRecord.Allowed_discount__c;
            }
            return;
        }
        if ('Pooled implant order: Equipment'.equalsIgnoreCase(discountRowRecord.Discount_lever__c)) {
            if (discountRowRecord.Max_perc__c > contractClone.Pooled_order_commitment_perc__c && discountRowRecord.Min_perc__c <= contractClone.Pooled_order_commitment_perc__c) {
                contractRecord.Allowed_discount_pooling_equipment__c = discountRowRecord.Allowed_discount__c;
            }
            return;
        }
        if ('Payment type'.equalsIgnoreCase(discountRowRecord.Discount_lever__c) && discountRowRecord.Equals__c != null) {
            if (discountRowRecord.Equals__c.equalsIgnoreCase(accountRecord.Payment_Terms_D_JP__c)) {
                contractRecord.Payment_discount__c = String.valueOf(discountRowRecord.Allowed_discount__c.intValue());
            }
            return;
        }
    }

    /*------------------------------------------------------------  
    Description:    Helper method for updateSalesHistory
                    Performs a SAQL query towards Einstein Analytics/Tableau CRM
    Inputs:         @param accountId
    ------------------------------------------------------------*/
    @InvocableMethod(label='Get Pricing Contract Sales Data' description='Returns sales and implants quantity during the last 12 months for a specific account' category='Contract')
    public static List<ContractSalesDataResponse> updateSalesData(List<String> inputs){

        List<String> datasetDetails = findDatasetVersion('AccountSalesDetail');
        List<Decimal> salesData = new List<Decimal>{};
            
        List<ContractSalesDataResponse> resultList = new List<ContractSalesDataResponse>();    
	
        if(datasetDetails[0]!= null && datasetDetails[1] != null){
/*
            String query = 'q = load "' + datasetDetails[0] + '/' + datasetDetails[1] + '";';
            query = query + 'q = filter q by \'ac.Id\' matches "' + inputs[0] + '";'; //ERPNumber__c
            query = query + 'q = filter q by \'Product2Sales.Global.PG2_Code__c\' in ["II11", "II12", "II13", "II14","II15", "II16", "II17", "II18", "IR30", "IR31", "IR32", "ID85"];';
            query = query + 'q = filter q by date(\'Invoice_Date__c_Year\', \'Invoice_Date__c_Month\', \'Invoice_Date__c_Day\') in ["365 days ago".."1 day ago"];';
            query = query + 'q = foreach q generate \'Invoice_Date__c\' as \'Invoice_Date__c\', \'Product2Sales.Global.PG2_Code__c\' as \'Product2Sales.Global.PG2_Code__c\', \'Product2Sales.Article__c\' as \'Product2Sales.Article__c\', \'Price__c\' as \'Price__c\',  \'Product2Sales.List_Price__c\' as \'Product2Sales.List_Price__c\', \'Discount_Amount__c\' as \'Discount_Amount__c\', \'PriceEUR.ConversionRate\' as \'PriceEUR.ConversionRate\', \'Quantity__c\' as \'Quantity__c\', \'ImplantUnitsQty\' as \'ImplantUnitsQty\';';
            query = query + 'q = foreach q generate \'Invoice_Date__c\' as \'Invoice_Date__c\', \'Product2Sales.Global.PG2_Code__c\' as \'Product2Sales.Global.PG2_Code__c\', \'Product2Sales.Article__c\' as \'Product2Sales.Article__c\', \'Price__c\' as \'Price__c\', \'Price__c\' * \'PriceEUR.ConversionRate\' * \'Quantity__c\' as \'NetAmount\' , \'Product2Sales.List_Price__c\'as \'Product2Sales.List_Price__c\', \'Product2Sales.List_Price__c\' * \'PriceEUR.ConversionRate\' * \'Quantity__c\' as \'GrossAmount\', \'ImplantUnitsQty\' as \'ImplantUnitsQty\';';
            query = query + 'q = group q by all;';
            query = query + 'q = foreach q generate sum(\'NetAmount\') as \'NetAmount\', sum(\'GrossAmount\') as \'GrossAmount\', sum(\'GrossAmount\') - sum(\'NetAmount\') as \'DiscountAmount\', (sum(\'GrossAmount\') - sum(\'NetAmount\'))/sum(\'GrossAmount\') as \'DiscountPercent\', sum(\'ImplantUnitsQty\') as \'ImplantUnitsQty\';';
   */
            String query = 'q = load "' + datasetDetails[0] + '/' + datasetDetails[1] + '";';
            query = query + 'q = filter q by \'ac.Id\' matches "' + inputs[0] + '";'; //ERPNumber__c
            query = query + 'q = filter q by \'Product2Sales.Global.SBU_Code__c\' == "I";';
            query = query + 'q = filter q by date(\'Invoice_Date__c_Year\', \'Invoice_Date__c_Month\', \'Invoice_Date__c_Day\') in ["365 days ago".."1 day ago"];';
            query = query + 'q = group q by all;';
            query = query + 'q = foreach q generate sum(\'Total_Value__c\') as \'NetAmount\', sum(\'Total_Value__c\')+sum(\'Discount_Amount__c\') as \'GrossAmount\', sum(\'Discount_Amount__c\') as \'DiscountAmount\', sum(\'Discount_Amount__c\')/(sum(\'Discount_Amount__c\')+sum(\'Total_Value__c\')) as \'DiscountPercent\', sum(\'ImplantUnitsQty\') as \'ImplantUnitsQty\';';            
            
            String response = '';
            if (!Test.isRunningTest()) {
            	ConnectApi.LiteralJson queryresult =  ConnectApi.Wave.executeQuery(query);
            	response = queryresult.json;
            }
            else{
                response = '{"results":{"records":[{"NetAmount":3000, "ImplantUnitsQty":30},{"NetAmount":2000, "ImplantUnitsQty":40}]}, "id":"56789"}';   
            }
            Map<String,Object> results = (Map<String,Object>)JSON.deserializeUntyped(response);
            Object resultslist = results.get('results');
            
            Map<String,Object> tempMap = (Map<String,Object>)resultslist;
            List<Object> records = (List<Object>)tempMap.get('records');
            
            Decimal ImplantsQ = 0;
            Decimal SalesL12M = 0;
            
            if(!records.IsEmpty()){
            String recordJSON = JSON.serialize(records[0]);
            Map<String, Object> recordFields = (Map<String, Object>)JSON.deserializeUntyped(recordJSON);

            ImplantsQ = (Decimal)recordFields.get('ImplantUnitsQty');
            SalesL12M = (Decimal)recordFields.get('NetAmount');                
            
            }
            
            ContractSalesDataResponse result = new ContractSalesDataResponse();

            result.implantsResult = ImplantsQ;
            result.salesResult = SalesL12M;
            
            resultList.add(result);
                        
        }

        return resultList;
    }

    /*------------------------------------------------------------  
    Description:    Helper method for updateSalesHistory
                    Performs a callout to Einstein Analytics/Tableau CRM to collect the most recent version of a dataset
    Inputs:         @param datasetName
    ------------------------------------------------------------*/
    private static String[] findDatasetVersion(String datasetName){

        HttpRequest req = new HttpRequest();
        
        //Endpoint is built upon a Named Credential called Analytics
        String endpoint = 'callout:Analytics/services/data/v50.0/wave/datasets';
        endpoint = endpoint +'/'+datasetName;
        req.setEndpoint(endpoint);
        req.setHeader('Content-Type', 'application/json');

        //Auth token is collected from Auth. Provider called SalesforceAnalytics
        req.setHeader('Authorization', 'Bearer {!$SalesforceAnalytics.OAuthToken}'); 
        req.setMethod('GET');

        http http = new http();
        HttpResponse res = new HttpResponse();
        
        if (!Test.isRunningTest()) { 
         	res = http.send(req);
        }
        else{
            res.setHeader('Content-Type', 'application/json');
        	res.setStatusCode(200);
            res.setBody('{"currentVersionId":"12345", "id":"56789", "createdBy":{"id":"00520000001BhymAAC","name":"Force Flow","profilePhotoUrl":"https://dentsplysirona--geo--c.documentforce.com/profilephoto/005/T"}}');
        }     

        Integer calloutStatus = res.getStatusCode();
        List<String> result = new List<String>{};

        //Handle response
        if(calloutStatus == 200){
            Map<String, Object> results = (Map<String, Object>) 
            JSON.deserializeUntyped(res.getBody());
		    Map<String,Object> tempMap = (Map<String,Object>)results;

            String datasetId = String.valueOf(tempMap.get('id'));
            String versionId = String.valueOf(tempMap.get('currentVersionId'));

            result.add(datasetId);
            result.add(versionId);
        }
        else{
            System.debug(res.getStatus());
        }

        return result;

    }
    
    global class ContractSalesDataResponse {
        @InvocableVariable
        global Decimal salesResult;
        
        @InvocableVariable
        global Decimal implantsResult;       
    }


}