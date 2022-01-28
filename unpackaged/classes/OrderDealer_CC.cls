/*-------------------------------------------------------------------------------------------------------
Author:         Ahmed loudrassi (Salesforce) 20200304
Description:    OrderDealerCmp Controller Class
Test Class:     Test_OrderDealer_CC
History	
20190924 	Roberto Narbona Update sharing enforcement and update where statement for getDistributor query. (#TFUS1935)
----------------------------------------------------------------------------------------*/
public with sharing class OrderDealer_CC {
    // lookup max search results
    private final static Integer MAX_RESULTS = 5;
    
    /*------------------------------------------------------------  
    Description:    method to insert the dealers related list of the order Account
    Inputs:         @param distributors, @param orderId
    ------------------------------------------------------------*/
    @AuraEnabled
    public static List<Preferred_dealer_item__c> saveDealers(List<String> distributors,Id orderId) {
        try {
            Order currentOrder = [select Id, name, AccountId, Account.Name, Account.Country__c from Order where Id=:orderId];
            List<Preferred_dealer_item__c> cust = [Select Id, Name, Account__r.Id, Dealer__c, Dealer__r.Name, 
                                                Default_dealer__c, Dealer_email__c 
                                                FROM Preferred_dealer_item__c 
                                                WHERE (Account__r.Id=: currentOrder.Account.Id) 
                                                AND Dealer__r.OneAccount_Type__c='Distributor'];
            Map<Id,Preferred_dealer_item__c> pdMap= new Map<Id,Preferred_dealer_item__c>();
            for(Preferred_dealer_item__c pd:cust){
                pdMap.put(pd.Dealer__c, pd);
            }
            List <Preferred_dealer_item__c> prefDealerList = new  List <Preferred_dealer_item__c>();
            for(String distributor : distributors){
                if(!pdMap.containsKey(distributor)){
                    Preferred_dealer_item__c prefDealer= new Preferred_dealer_item__c();
                    prefDealer.Dealer__c = distributor;
                    prefDealer.Account__c = currentOrder.AccountId;
                    prefDealerList.add(prefDealer);
                    If (!cust.isEmpty()){
                        prefDealer.Default_dealer__c = false;
                    } else {
                        prefDealer.Default_dealer__c = true;
                    }
                }
            }
            insert prefDealerList;
            return getDealers(orderId);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());    
        }
    }
    /*------------------------------------------------------------  
    Description:    method to get the related dealers list of an order
    Inputs:         @param orderId
    ------------------------------------------------------------*/
    @AuraEnabled
    public static List<Preferred_dealer_item__c> getDealers(ID orderId){
        try {
            Order order = [Select Id, AccountId FROM Order Where Id =:orderId];
            return [Select Id, Name, Account__r.Id, Dealer__c,
                                                Dealer__r.ETM2_State_City__c, 
                                                Dealer__r.OneAccount_Type__c,
                                                Dealer__r.Name,Dealer__r.ShippingCity,
                                                Dealer__r.ShippingState,Dealer__r.ShippingPostalCode,
                                                Default_dealer__c, Dealer_email__c 
                                                FROM Preferred_dealer_item__c
                                                WHERE Account__c = :order.AccountId
                                                ORDER BY Dealer__r.Name];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());    
        }
    }
    /*------------------------------------------------------------  
    Description:    Method to set the order dealer and distributor lookup fields
    Inputs:         @param dealerId, @param orderId
    ------------------------------------------------------------*/
    @AuraEnabled
    public static String updateDealerInfo(Id dealerId,String orderId) {
        try{
            Preferred_dealer_item__c dealer = [SELECT id, name, Dealer__c, Dealer_email__c 
                                           FROM Preferred_dealer_item__c 
                                           WHERE Id=:dealerId];
            Order order = [SELECT Id, OrderNumber, Dealer__c, Distributor__c, Distributor_email__c FROM Order WHERE Id =:orderId];
            order.Dealer__c = dealer.Id;
            order.Distributor__c = dealer.Dealer__c;
            order.Distributor_email__c = dealer.Dealer_email__c;
            update order;
            return order.OrderNumber;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());    
        }
    }

    // Lookup Methods
    @AuraEnabled(Cacheable=true)
    public static List<LookupSearchResult> search(String searchTerm, List<String> selectedIds) {
        // Prepare query paramters
        searchTerm += '*';

        // Execute search query
        List<List<SObject>> searchResults = [
            FIND :searchTerm
            IN ALL FIELDS
            RETURNING
                Account(
                    Id, Name, OneAccount_Type__c, ETM2_State_City__c 
                    WHERE id NOT IN :selectedIds 
                        AND (
                            RecordTypeId = :GlobalUtils.getRecordTypeId('Account','ERP_Distributor')
                            OR RecordTypeId = :GlobalUtils.getRecordTypeId('Account','Non_ERP_Distributor')
                            OR (RecordTypeId = :GlobalUtils.getRecordTypeId('Account','CIM_Account') AND OneAccount_Type__c = 'Distributor')
                        )
                )
            LIMIT :MAX_RESULTS
        ];

        // Prepare results
        List<LookupSearchResult> results = new List<LookupSearchResult>();

        // Extract Accounts & convert them into LookupSearchResult
        String accountIcon = 'standard:account';
        Account[] accounts = (List<Account>) searchResults[0];
        for (Account account : accounts) {
            String stateCitySubString = String.isNotBlank(account.ETM2_State_City__c) ? ' • ' + account.ETM2_State_City__c : '';
            results.add(
                new LookupSearchResult(
                    account.Id,
                    'Account',
                    accountIcon,
                    account.Name,
                    account.OneAccount_Type__c + stateCitySubString
                )
            );
        }

        // Optionnaly sort all results on title
        results.sort();

        return results;
    }

    @AuraEnabled(Cacheable=true)
    public static List<LookupSearchResult> getRecentlyViewed() {
        List<LookupSearchResult> results = new List<LookupSearchResult>();
        // Get recently viewed records of type Account or Opportunity
        List<Account> recentRecords = [
            SELECT Id, Name, BillingCity
            FROM Account
            WHERE (
                RecordTypeId = :GlobalUtils.getRecordTypeId('Account','ERP_Distributor')
                OR RecordTypeId = :GlobalUtils.getRecordTypeId('Account','Non_ERP_Distributor')
                OR (RecordTypeId = :GlobalUtils.getRecordTypeId('Account','CIM_Account') AND OneAccount_Type__c = 'Distributor')
            )
            ORDER BY LastViewedDate DESC
            LIMIT 5
        ];
        // Convert recent records into LookupSearchResult
        for (Account recentRecord : recentRecords) {
            results.add(
                new LookupSearchResult(
                    recentRecord.Id,
                    'Account',
                    'standard:account',
                    recentRecord.Name,
                    'Account • ' + recentRecord.BillingCity
                )
            );
        }
        return results;
    }
}