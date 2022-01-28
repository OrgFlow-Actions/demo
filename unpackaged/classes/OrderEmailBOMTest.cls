@isTest
public with sharing class OrderEmailBOMTest {    
    
@isTest
private static void OrderEmailBOM_Test(){

        //PageReference pageRef = Component.OrderEmailBOMs;
        //Test.setCurrentPage(pageRef);
        
        Account a = new Account(Name='Test account 1', CurrencyIsoCode = 'EUR', Country__c = 'NL');
        insert a;
        
        Contact c = new Contact(LastName='Testsson', Firstname='Test', Account = a);
        insert c;
        
        Pricebook2 p = new Pricebook2(Name = 'Test pricebook 1');
        insert p;
        
        Order o = DC_UT_DataUtils.generateOrder(a.id, Date.today(), a.CurrencyIsoCode);
        o.Pricebook2Id = p.id;
        insert o;
       
        DateTime expected = DateTime.newInstance(2016, 4, 21, 8, 13, 16);
            
        ApexPages.currentPage().getParameters().put('related_to_id', o.id);              
        
        OrderEmailBOM controller = new OrderEmailBOM();
        
        controller.currentRecordId = o.id;
                
            //- create test products
    
        Product2 product1 = DC_UT_DataUtils.generateProduct('Product1', 'Brand1',
          'Line1', 'L4_GD_P1');
        product1.SBU_Name__c = 'Prevention';
        Product2 product2 = DC_UT_DataUtils.generateProduct('Product2', 'Brand1',
          'Line1', 'L4_GD_P2');
        Product2 product3 = DC_UT_DataUtils.generateProduct('Product3', 'Brand2',
          'Line2', 'L4_GD_P3');
        Product2[] products = new Product2[] {product1, product2, product3};
        insert products;  
        
        //- create test bundle
        Product_bundle__c bundle1 = DC_UT_DataUtils.generateBundle('Bundle1', p.Id, p.CurrencyIsoCode);
        insert bundle1;
    
        BOM__c bundleProduct1 = DC_UT_DataUtils.generateBOM(product1.Name, bundle1.id, 2);
        insert bundleProduct1;
    
        BOM__c bundleProduct2 = DC_UT_DataUtils.generateBOM(product2.Name, bundle1.id, 1);
        insert bundleProduct2;
        
        Order_bundle__c bundle1_order = new Order_bundle__c();
        bundle1_order.Product_bundle__c = bundle1.Id;
        bundle1_order.Order__c = o.Id;
        bundle1_order.Quantity__c = 1;
        insert bundle1_order;

        controller.getOrdrBundList();       
 
        System.AssertNotEquals(null, controller.currentRecordID);
        System.AssertEquals(controller.ordr.Id, controller.currentRecordID);
        System.AssertNotEquals(0, controller.OrderBundList.size());
             
        controller.getEmailBOM();        
        System.AssertNotEquals(0, controller.BOM_total.size());
                        
    }
    
    @isTest
private static void OrderPdfBOM_Test(){

        //PageReference pageRef = Component.OrderEmailBOMs;
        //Test.setCurrentPage(pageRef);
        
        Account a = new Account(Name='Test account 1', CurrencyIsoCode = 'EUR', Country__c = 'NL');
        insert a;
        
        Contact c = new Contact(LastName='Testsson', Firstname='Test', Account = a);
        insert c;
        
        Pricebook2 p = new Pricebook2(Name = 'Test pricebook 1');
        insert p;
        
        Order o = DC_UT_DataUtils.generateOrder(a.id, Date.today(), a.CurrencyIsoCode);
        o.Pricebook2Id = p.id;
        insert o;
       
        DateTime expected = DateTime.newInstance(2016, 4, 21, 8, 13, 16);
            
        ApexPages.currentPage().getParameters().put('id', o.id);              
        
        OrderPdfBOM controller = new OrderPdfBOM();
        
        controller.currentRecordId = o.id;
                
            //- create test products
    
        Product2 product1 = DC_UT_DataUtils.generateProduct('Product1', 'Brand1',
          'Line1', 'L4_GD_P1');
        product1.SBU_Name__c = 'Prevention';
        Product2 product2 = DC_UT_DataUtils.generateProduct('Product2', 'Brand1',
          'Line1', 'L4_GD_P2');
        Product2 product3 = DC_UT_DataUtils.generateProduct('Product3', 'Brand2',
          'Line2', 'L4_GD_P3');
        Product2[] products = new Product2[] {product1, product2, product3};
        insert products;  
        
        //- create test bundle
        Product_bundle__c bundle1 = DC_UT_DataUtils.generateBundle('Bundle1', p.Id, p.CurrencyIsoCode);
        insert bundle1;
    
        BOM__c bundleProduct1 = DC_UT_DataUtils.generateBOM(product1.Name, bundle1.id, 2);
        insert bundleProduct1;
    
        BOM__c bundleProduct2 = DC_UT_DataUtils.generateBOM(product2.Name, bundle1.id, 1);
        insert bundleProduct2;
        
        Order_bundle__c bundle1_order = new Order_bundle__c();
        bundle1_order.Product_bundle__c = bundle1.Id;
        bundle1_order.Order__c = o.Id;
        bundle1_order.Quantity__c = 1;
        insert bundle1_order;

        controller.getOrdrBundList();       
 
        System.AssertNotEquals(null, controller.currentRecordID);
        System.AssertEquals(controller.ordr.Id, controller.currentRecordID);
        System.AssertNotEquals(0, controller.OrderBundList.size());
             
        controller.getEmailBOM();        
        System.AssertNotEquals(0, controller.BOM_total.size());
                        
    }

    
    
     
    
    }