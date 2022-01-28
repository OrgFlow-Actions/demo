/*------------------------------------------------------------	
Author: 		Richard Trum (Glimt) 2019-11-28 	
Description:   	Test class related to the class ProductProfilingHierarchyController
------------------------------------------------------------*/

@isTest
private class Test_ProductProfilingHierarchyController {
	
    @testSetup
    private static void setup() {
        TestDataFactory.createBypassCustomSetting();
        List<User> userList = TestDataFactory.createUsers(1, 'System Administrator'); 
        TestDataFactory.createGlobalIntegrationSettings(userList);
        TestDataFactory.createDefaultOrgLevelBypassPB();
    }
    
    @isTest
    private static void testERPProducts(){
    
        User currentUser = TestDataFactory.createUsers(1, 'System Administrator')[0]; 
        system.runAs(currentUser){
            Account acc = new Account();
            acc.Name ='Test account';
            insert acc;
            
            Contact con = new Contact();
            con.FirstName = 'Test';
            con.LastName = 'Test';
            con.AccountId = acc.Id;
            insert con;
            
            SSIS_ERP_SKU_Metadata_Country_Connectio__c pmm = new SSIS_ERP_SKU_Metadata_Country_Connectio__c();
            pmm.Market__c = currentUser.Market__c;
            pmm.Active__c = true;
            insert pmm;
            
            Non_ERP_Products__c ERP = new Non_ERP_Products__c();
            ERP.Name = 'Test product';
            ERP.Competitor_Product__c = false;
            ERP.KeyProduct__c = true;
            ERP.Product_Category__c = 'Implants';
            ERP.Product_Market_Mapping__c = pmm.Id;
            insert ERP;
            
            Product_Profiling__c prodP = new Product_Profiling__c();
            prodP.Product_Name__c = ERP.Id;
            prodP.Account__c = acc.Id;
            prodP.Contact__c = con.Id;
            insert prodP;
            
            Test.startTest();
            
            List<ProductProfilingHierarchyController.HierarchyNode> res = ProductProfilingHierarchyController.getAllProducts(acc.Id);
            System.assertEquals(res.size(), 1);
            
            Map<Id, Product_Profiling__c> resMapAcc = ProductProfilingHierarchyController.getProductProfilingMap(acc.Id);
            System.assertNotEquals(resMapAcc, null);
            
            Map<Id, Product_Profiling__c> resMapCon = ProductProfilingHierarchyController.getProductProfilingMap(con.Id);
            System.assertNotEquals(resMapCon, null);
            
            List<Product_Profiling__c> resAcc = ProductProfilingHierarchyController.getProductProfiling(acc.Id);
            System.assertNotEquals(resAcc, null);
            
            List<Product_Profiling__c> resCon = ProductProfilingHierarchyController.getProductProfiling(con.Id);
            System.assertNotEquals(resCon, null);
            
            Test.stopTest();
        }
        
        
    }

    @isTest
    private static void testDistinctValues(){
    
        User currentUser = TestDataFactory.createUsers(1, 'System Administrator')[0]; 
        system.runAs(currentUser){
            Account acc = new Account();
            acc.Name ='Test account';
            insert acc;
            
            Contact con = new Contact();
            con.FirstName = 'Test';
            con.LastName = 'Test';
            con.AccountId = acc.Id;
            insert con;
            
            SSIS_ERP_SKU_Metadata_Country_Connectio__c pmm = new SSIS_ERP_SKU_Metadata_Country_Connectio__c();
            pmm.Market__c = currentUser.Market__c;
            pmm.Active__c = true;
            insert pmm;
            
            Non_ERP_Products__c ERP = new Non_ERP_Products__c();
            ERP.Name = 'Test product';
            ERP.Competitor_Product__c = false;
            ERP.KeyProduct__c = true;
            ERP.Product_Category__c = 'Implants';
            ERP.Product_Market_Mapping__c = pmm.Id;
            ERP.Manufacturer__c = 'DentsplySirona';
            insert ERP;
            
            Product_Profiling__c prodP = new Product_Profiling__c();
            prodP.Product_Name__c = ERP.Id;
            prodP.Account__c = acc.Id;
            prodP.Contact__c = con.Id;
            insert prodP;
            
            Test.startTest();
            
            List<String> res = ProductProfilingHierarchyController.getDistinctValues('Manufacturer__c', acc.Id);
            System.assertEquals(res.size(), 1);
            
            Boolean deleted = ProductProfilingHierarchyController.deleteProductProfilingRecord(prodP.Id);
                                    
            Test.stopTest();
        }
        
        
    }
    
    
    
}