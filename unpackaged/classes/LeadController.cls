/*------------------------------------------------------------	
Author: 		Richard Trum (Glimt) 2019-11-28 	
Description:   	Class for handling CRUD calls related to the Lead__c and Field_Sales_Project__c objects
------------------------------------------------------------*/

public with sharing class LeadController {

    @AuraEnabled
    public static List<Field_Sales_Project__c> getInitiatives(){
        
        List<Field_Sales_Project__c> inits = [SELECT Id, Title__c, Category__c, Brand__c, Status__c FROM Field_Sales_Project__c WHERE (AllowUsersToAddNewLeads__c =: true AND Status__c=:'Active')];
    
        return inits;
        
    }
    
    @AuraEnabled
    public static List<LeadOpportunitySetting__mdt> getSalesLeadSettings(String category, String country){
        
        List<LeadOpportunitySetting__mdt> settings = [SELECT DeveloperName, Category__c, Country__c, ShowDistributor__c, IsTest__c FROM LeadOpportunitySetting__mdt WHERE (Category__c =:category AND Country__c =: country)];
        
        return settings;
    }

    @AuraEnabled
    public static List<Preferred_dealer_item__c> getPreferredDealers(String accountId){
        List<Preferred_dealer_item__c> dealerList = [SELECT Id, Account__c, Dealer__c, Dealer__r.Name FROM Preferred_dealer_item__c WHERE Account__c =: accountId];
        return dealerList;
    }
   
    /*------------------------------------------------------------  
    Description:    Method to select the Distributors Accounts list.
    Inputs:         @param keyword, @param orderId
    ------------------------------------------------------------*/
    @AuraEnabled
    public static List<Account> getDistributors(String keyword, ID orderId, String category) {
        try { 
            String searchCat = '%' + category + '%';
            List<Preferred_dealer_item__c> dealers = getDealers(orderId, searchCat);
            Set<ID> ids = new Set<ID>();
            for(Preferred_dealer_item__c dealer : dealers) {
                ids.add(dealer.Dealer__c);
            }
            keyword ='%' + keyword + '%';
            
            List<Account> records = [SELECT Id, Name, ETM2_State_City__c, OneAccount_Type__c,BillingStreet, ShippingCity, ShippingState,
                        ShippingPostalCode, BillingCity, BillingState, BillingPostalCode, BillingCountry 
                        FROM Account 
                        WHERE (Name LIKE :keyword 
                                OR ShippingStreet LIKE :keyword 
                                OR ShippingCity LIKE :keyword 
                                OR ShippingState LIKE :keyword 
                                OR ShippingPostalCode LIKE :keyword 
                                OR ShippingCountry LIKE :keyword)
                        AND (RecordTypeId = :GlobalUtils.getRecordTypeId('Account','ERP_Distributor')
                            OR RecordTypeId = :GlobalUtils.getRecordTypeId('Account','Non_ERP_Distributor')
                            OR (RecordTypeId = :GlobalUtils.getRecordTypeId('Account','CIM_Account') AND OneAccount_Type__c = 'Distributor' 
                 			AND ((NOT DistributorCategories__c LIKE :searchCat) OR DistributorCategories__c = null))
                            ) 
                        ]; //AND Id NOT IN :ids
            System.debug(records);
            return records;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());    
        }
    }

    /*------------------------------------------------------------  
    Description:    method to get the related dealers list of an order
    Inputs:         @param orderId
    ------------------------------------------------------------*/
    @AuraEnabled
    public static List<Preferred_dealer_item__c> getDealers(ID orderId, String category){
        String searchCat = '%' + category + '%';
        try {
            //Field_Sales_Project_Members__c order = [Select Id, Account__c FROM Field_Sales_Project_Members__c Where Id =:orderId];
            return [Select Id, Name, Account__r.Id, Dealer__c,
                                                Dealer__r.ETM2_State_City__c, 
                                                Dealer__r.OneAccount_Type__c,
                                                Dealer__r.Name,Dealer__r.ShippingCity,
                                                Dealer__r.ShippingState,Dealer__r.ShippingPostalCode,
                                                Default_dealer__c, Dealer_email__c 
                                                FROM Preferred_dealer_item__c
                                                WHERE Account__c = :orderId
                    							AND ((NOT Dealer__r.DistributorCategories__c LIKE :searchCat) OR Dealer__r.DistributorCategories__c =: null)
                   								];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());    
        }
    }
    
    private final static Integer MAX_RESULTS = 5;

    @AuraEnabled(Cacheable=true)
    public static List<LookupSearchResult> search(String searchTerm, List<String> selectedIds, String category) {
        // Prepare query parameters
        searchTerm += '*';
        System.debug(searchTerm);
        String searchCat = '%' + category + '%';

        // Execute search query
        List<List<SObject>> searchResults = [
            FIND :searchTerm
            IN ALL FIELDS
            RETURNING
                Account(Id, Name, ShippingCity WHERE id NOT IN :selectedIds AND 
                RecordTypeId = :GlobalUtils.getRecordTypeId('Account','CIM_Account') AND 
                OneAccount_Type__c = 'Distributor' AND 
                ((NOT DistributorCategories__c LIKE :searchCat) OR DistributorCategories__c = null)
                )
                
            LIMIT :MAX_RESULTS
        ];

        // Prepare results
        List<LookupSearchResult> results = new List<LookupSearchResult>();

        // Extract Accounts & convert them into LookupSearchResult
        String accountIcon = 'standard:account';
        Account[] accounts = (List<Account>) searchResults[0];
        for (Account account : accounts) {
            results.add(
                new LookupSearchResult(
                    account.Id,
                    'Account',
                    accountIcon,
                    account.Name,
                    'Account • ' + account.ShippingCity
                )
            );
        }

        // Optionally sort all results on title
        results.sort();

        return results;
    }

    @AuraEnabled(Cacheable=true)
    public static List<LookupSearchResult> getRecentlyViewed(String recordId, String category) {
        List<LookupSearchResult> results = new List<LookupSearchResult>();
        String searchCat = '%' + category + '%';
        // Get recently viewed records of type Account
        List<RecentlyViewed> recentRecords = [
            SELECT Id, Name, Type
            FROM RecentlyViewed
            WHERE Type = 'Account'
            ORDER BY LastViewedDate DESC
            LIMIT 5
        ];

        List<Preferred_dealer_item__c> prefDealers = [Select Id, Name, Account__r.Id, Dealer__c,
                                                Dealer__r.ETM2_State_City__c, 
                                                Dealer__r.OneAccount_Type__c,
                                                Dealer__r.RecordType.Name,      
                                                Dealer__r.Name,Dealer__r.ShippingCity,
                                                Dealer__r.ShippingState,Dealer__r.ShippingPostalCode,
                                                Default_dealer__c, Dealer_email__c 
                                                FROM Preferred_dealer_item__c
                                                WHERE Account__c = :recordId
                                                AND ((NOT Dealer__r.DistributorCategories__c LIKE :searchCat) OR Dealer__r.DistributorCategories__c =: null)     
                                                ];

        // Convert recent records into LookupSearchResult
        for (Preferred_dealer_item__c recentRecord : prefDealers) {
            
                results.add(
                    new LookupSearchResult(
                        recentRecord.Dealer__c,
                        'Account',
                        'standard:account',
                        recentRecord.Dealer__r.Name,
                        'Account • ' + recentRecord.Dealer__r.RecordType.Name
                    )
                );
        }
        return results;
    }

    
}