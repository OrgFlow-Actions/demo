/*------------------------------------------------------------  
Author:         Richard Trum (Glimt) 2019-11-27     
Description:    Controller handling custom lightning components related to Product Profiling
------------------------------------------------------------*/

public with sharing class ProductProfilingHierarchyController {
    
    /*------------------------------------------------------------  
    Description:    AuraEnabled method to collect Non-ERP products and related child records 
                    that are related to the user's assigned market
                    Output is stored as a map
    Inputs:         
    ------------------------------------------------------------*/    
    /*@AuraEnabled
    public static Map<Id,HierarchyNode> getHierarchies() {
    
    List<Non_ERP_Products__c> allProducts = [SELECT Id, ParentProduct__c, Name, SBU__c, Competitor_Product__c, KeyProduct__c, 
                                             (SELECT Id, ParentProduct__c, Name, SBU__c, Competitor_Product__c, KeyProduct__c
                                             FROM Non_ERP_products__r) 
                                             FROM Non_ERP_Products__c WHERE (ParentProduct__c =: '' AND Valid_in_my_Market__c =: true)];
        
    Map<Id,HierarchyNode> nodes = new Map<Id,HierarchyNode>();
 
    for (Non_ERP_Products__c a : allProducts) { 
        nodes.put(a.Id, new HierarchyNode(a, false));        
    }
        
    System.debug(nodes);
        
    return nodes;
    */
    
    
    /*------------------------------------------------------------  
    Description:    AuraEnabled method to collect all Non-ERP products 
                    that are related to the user's assigned market
    Inputs:         
    ------------------------------------------------------------*/ 

    @AuraEnabled
    public static List<HierarchyNode> getAllProducts(String recordId) {
    
    String country = '';    
        if(recordId.left(3) == '003'){
            Contact con = [SELECT Id, Account.Country__c FROM Contact WHERE Id =: recordId];
        	country = con.Account.Country__c;
        }
        else{
            Account acc = [SELECT Id, Country__c FROM Account WHERE Id =: recordId];
            country = acc.Country__c;
        }
    	        
    List<Non_ERP_Products__c> allProducts = [SELECT Id, Name, Countries__c, SBU__c, Competitor_Product__c, KeyProduct__c, Product_Category__c, Manufacturer__c, ProductGroupText__c, QuantityUnitOfMeasure__c 
                                             FROM Non_ERP_Products__c WHERE Inactive__c = false AND (Countries__c INCLUDES (:country) OR Valid_in_my_Market__c =: true)];
        
    List<HierarchyNode> nodes = new List<HierarchyNode>();
 
    for (Non_ERP_Products__c a : allProducts) { 
        nodes.add(new HierarchyNode(a, false));        
    }
        
    return nodes;
    }
    
    
    /*------------------------------------------------------------  
    Description:    AuraEnabled method to collect all Product Profiling records 
                    related to either an account or a contact
    Inputs:         @param recordId - The account's or contact's recordId
    ------------------------------------------------------------*/ 
    
    @AuraEnabled
    //public static Map<Id, Product_Profiling__c> getProductProfiling(String recordId) {
    public static List<Product_Profiling__c> getProductProfiling(String recordId){
    List<Product_Profiling__c> profilings = new List<Product_Profiling__c>();
        
        if(recordId.startsWith('003')){
            profilings = [SELECT Id, Product_Name__c, Quantity__c, Product_Category__c, Product_Name__r.Id, Product_Name__r.Manufacturer__c, Product_Name__r.Product_Category__c, Product_Name__r.Name, Product_Name__r.SBU__c, Product_Name__r.Competitor_Product__c, Product_Name__r.KeyProduct__c, Product_Name__r.ProductGroupText__c, Product_Name__r.QuantityUnitOfMeasure__c, Status__c, Account__c, Contact__c, Contact__r.FirstName, Contact__r.LastName FROM Product_Profiling__c WHERE Contact__c =: recordId AND Product_Name__c!= null];    
        }
        else{
            profilings = [SELECT Id, Product_Name__c, Quantity__c, Product_Category__c, Product_Name__r.Id, Product_Name__r.Manufacturer__c, Product_Name__r.Product_Category__c, Product_Name__r.Name, Product_Name__r.SBU__c, Product_Name__r.Competitor_Product__c, Product_Name__r.KeyProduct__c, Product_Name__r.ProductGroupText__c, Product_Name__r.QuantityUnitOfMeasure__c, Status__c, Account__c, Contact__c, Contact__r.FirstName, Contact__r.LastName FROM Product_Profiling__c WHERE Account__c =: recordId  AND Product_Name__c!= null ORDER BY Contact__c ASC NULLS FIRST]; // AND Contact__c =:''    
        }
    
    /*Map<Id, Product_Profiling__c> profilingMap = new Map<Id, Product_Profiling__c>();
           
    For(Product_Profiling__c p : profilings)
        {
            profilingMap.put(p.Product_Name__c, p);
        }*/
     
    return profilings;//profilingMap;
        
    }
    
    /*------------------------------------------------------------  
    Description:    AuraEnabled method to collect all Product Profiling records 
                    related to either an account or a contact
    Inputs:         @param recordId - The account's or contact's recordId
    ------------------------------------------------------------*/ 
    
    @AuraEnabled
    public static Map<Id, Product_Profiling__c> getProductProfilingMap(String recordId) {
    List<Product_Profiling__c> profilings = new List<Product_Profiling__c>();
        
        if(recordId.startsWith('003')){
            profilings = [SELECT Id, Product_Name__c, Quantity__c, Product_Category__c, Product_Name__r.Id, Product_Name__r.Manufacturer__c, Product_Name__r.Product_Category__c, Product_Name__r.Name, Product_Name__r.SBU__c, Product_Name__r.Competitor_Product__c, Product_Name__r.KeyProduct__c, Product_Name__r.ProductGroupText__c, Product_Name__r.QuantityUnitOfMeasure__c, Status__c, Account__c, Contact__c, Contact__r.FirstName, Contact__r.LastName FROM Product_Profiling__c WHERE Contact__c =: recordId AND Product_Name__c != null];    
        }
        else{
            profilings = [SELECT Id, Product_Name__c, Quantity__c, Product_Category__c, Product_Name__r.Id, Product_Name__r.Manufacturer__c, Product_Name__r.Product_Category__c, Product_Name__r.Name, Product_Name__r.SBU__c, Product_Name__r.Competitor_Product__c, Product_Name__r.KeyProduct__c, Product_Name__r.ProductGroupText__c, Product_Name__r.QuantityUnitOfMeasure__c, Status__c, Account__c, Contact__c, Contact__r.FirstName, Contact__r.LastName FROM Product_Profiling__c WHERE Account__c =: recordId AND Product_Name__c != null];    
        }
    
    Map<Id, Product_Profiling__c> profilingMap = new Map<Id, Product_Profiling__c>();
           
    For(Product_Profiling__c p : profilings)
        {
            profilingMap.put(p.Product_Name__c, p);
        }
     
    return profilingMap;
        
    }    
    
    @AuraEnabled
    public static String[] getDistinctValues(String field_name, String recordId) {
        Set<String> valList = new Set<String>();
        
            String country = '';    
        if(recordId.left(3) == '003'){
            Contact con = [SELECT Id, Account.Country__c FROM Contact WHERE Id =: recordId];
        	country = con.Account.Country__c;
        }
        else{
            Account acc = [SELECT Id, Country__c FROM Account WHERE Id =: recordId];
            country = acc.Country__c;
        }
                
    	List<Non_ERP_Products__c> records = [SELECT Id, Name, Countries__c, SBU__c, Manufacturer__c, Competitor_Product__c, KeyProduct__c, Product_Category__c, ProductGroupText__c 
                                             FROM Non_ERP_Products__c WHERE Inactive__c = false AND (Countries__c INCLUDES (:country) OR Valid_in_my_Market__c =: true) ];
		
        for(Non_ERP_Products__c so : records){
            String fieldValue = (String) so.get(field_name);
            valList.add(fieldValue);
            System.debug(fieldValue);
        }
        
        List<String> results = new List<String>();
        
        for(String s : valList){
          results.add(s);  
        }
        
        return results;
        
    }
    
    @AuraEnabled
    public static Boolean deleteProductProfilingRecord(String recordId) {
			
        Product_Profiling__c ppRecord = [SELECT Id, Name FROM Product_Profiling__c WHERE Id =: recordId];
        Boolean success = true;
        try{
            delete ppRecord;
        }catch(Exception e){
            System.debug('An error occured when trying to delete a Product Profiling record: ' + e);
            success = false;    
        }
		
        return success;
        
    }

    public class HierarchyNode {
    @AuraEnabled public Non_ERP_Products__c node;
    @AuraEnabled public String nodeName;    
    @AuraEnabled public List<HierarchyNode> children;
    @AuraEnabled public Boolean isProfiled;
    HierarchyNode(Non_ERP_Products__c acc, Boolean isProfiling) {
        node = acc;
        nodeName = acc.Name;
        children = new List<HierarchyNode>();
        isProfiled = isProfiling;
    }        
	}
    
        /*public class ProductProfilingBundle {
 		
    	@AuraEnabled public String productId;         
     	@AuraEnabled public String productName;
        
  	}*/
}