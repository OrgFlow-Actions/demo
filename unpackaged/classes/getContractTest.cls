@isTest
public with sharing class getContractTest {    
    
/* @isTest
public static void doActionTest(){

        //PageReference pageRef = Page.Contract_updsales;
        //Test.setCurrentPage(pageRef);
        
        Account a = new Account(Name='Test account 1', TS_CY_D_AllPLs_AllPCs_AllBrands__c = 49214, TQ_CY_D_DI_Implants_AllBrands__c = 209);
        insert a;
        
        Contract c = new Contract(Name='Test contract 1', AccountID=a.Id, Implant_commitment__c=200);
        insert c;
        
        ApexPages.currentPage().getParameters().put('id', c.id);
             
        ApexPages.StandardController stdController = new ApexPages.StandardController(c);
        
        updateContract controller = new updateContract(stdController);
         
        system.assertEquals(null,c.Sales_L12M__c);
        
        controller.navFlow();
        
        system.assertEquals('FLOW',controller.stepname);
        
    }

@isTest
public static void ContractFlowTest(){

        //PageReference pageRef = Page.Contract_Flow;
        //Test.setCurrentPage(pageRef);
        
        Account a = new Account(Name='Test account 1', TS_CY_D_AllPLs_AllPCs_AllBrands__c = 49214, TQ_CY_D_DI_Implants_AllBrands__c = 209);
        insert a;
        
        Contract c = new Contract(Name='Test contract 1', AccountID=a.Id, Implant_commitment__c=200);
        insert c;
        
        ApexPages.currentPage().getParameters().put('id', c.id);
        
        ApexPages.StandardController stdController = new ApexPages.StandardController(c);
        
        getContract controller = new getContract(stdController);
        
        controller.doAction();
         
        system.assertEquals(null,c.Sales_L12M__c);
        

    } */
    
/*@isTest
public static void ContractDiscountSimulationTest(){

        //PageReference pageRef = Page.Contract_Discount_simulation;
        //Test.setCurrentPage(pageRef);
        
        Account a = new Account(Name='Test account 1', TS_CY_D_AllPLs_AllPCs_AllBrands__c = 49214, TQ_CY_D_DI_Implants_AllBrands__c = 209);
        insert a;
        
        Contract c = new Contract(Name='Test contract 1', AccountID=a.Id, Implant_commitment__c=200);
        
        ApexPages.currentPage().getParameters().put('id', c.id);
        
        ApexPages.StandardController stdController = new ApexPages.StandardController(c);
        
        getContract controller = new getContract(stdController);
        
        system.assertEquals(180,c.Implant_commitment__c);
        
        system.assertEquals(false, controller.hasM);
        
        controller.save();
        
        system.assertEquals(true, controller.hasM);
        
    }*/
@isTest    
public static void ContractSalesHistoryTest(){
        
        Account a = new Account(Name='Test account 1', TS_CY_D_AllPLs_AllPCs_AllBrands__c = 49214, TQ_CY_D_DI_Implants_AllBrands__c = 209);
        insert a;
        
        Contract c = new Contract(Name='Test contract 1', AccountID=a.Id, Implant_commitment__c=200);
        insert c;
        
        ApexPages.currentPage().getParameters().put('id', c.id);
        
        ApexPages.StandardController stdController = new ApexPages.StandardController(c);
        
        getContract controller = new getContract(stdController);
        
        Product2 product2 = DC_UT_DataUtils.generateProduct('Product2', 'Brand1','Line1', 'L4_GD_P2');
        product2.PG2_Code__c = 'II12';
        upsert product2;
        
        Product2 product1 = DC_UT_DataUtils.generateProduct('Product1', 'Brand1', 'Line1', 'L4_GD_P1');        
        product1.List_Price__c = 110;
        product1.GlobalSKUMapping__c = product2.id;
        upsert product1;
 
        Product2 product4 = DC_UT_DataUtils.generateProduct('Product4', 'Brand1','Line1', 'L4_GD_P2');
        product4.PG2_Code__c = 'ID85';
        upsert product4;
 
        Product2 product3 = DC_UT_DataUtils.generateProduct('Product3', 'Brand2', 'Line2', 'L4_GD_P3'); 
        product3.List_Price__c = 110;
        product3.GlobalSKUMapping__c = product4.Id;
        upsert product3;
        
        Date Date17 = Date.newInstance(System.Today().year(), 2, 17);
        Date Date16 = Date.newInstance(System.Today().year()-1, 2, 17);
        Date Date15 = Date.newInstance(System.Today().year()-2, 2, 17);
        Date Date14 = Date.newInstance(System.Today().year()-3, 2, 17);
        
        Sales_history__c sales14 = new Sales_history__c(Account__c= a.id, Quantity__c = 2, Contract__c = c.id, Product__c=product1.id, Price__c=100, Invoice_Date__c=Date14); //, Discount_Amount__c = 20
        insert sales14;
        sales14 = [SELECT Id, Account__c, Quantity__c, Contract__c, Product__c, Gross_price__c, Price__c, Tot_price__c, Invoice_date__c, Product__r.GlobalSKUMapping__r.PG2_Code__c FROM Sales_history__c WHERE Id =: sales14.Id];
        
        Sales_history__c sales15 = new Sales_history__c(Account__c= a.id, Quantity__c = 2, Contract__c = c.id, Product__c=product1.id, Price__c=100, Invoice_Date__c=Date15); //, Discount_Amount__c = 20
        insert sales15;
        
        Sales_history__c sales16 = new Sales_history__c(Account__c= a.id, Quantity__c = 2, Contract__c = c.id, Product__c=product1.id, Price__c=100, Invoice_Date__c=Date16); //, Discount_Amount__c = 20
        insert sales16;
        
        Sales_history__c sales17 = new Sales_history__c(Account__c= a.id, Quantity__c = 2, Contract__c = c.id, Product__c=product1.id, Price__c=100, Invoice_Date__c=Date17); //, Discount_Amount__c = 20
        insert sales17;
                
        Sales_history__c sales14_EI = new Sales_history__c(Account__c= a.id, Quantity__c = 2, Contract__c = c.id, Product__c=product3.id, Price__c=100, Invoice_Date__c=Date14); //, Discount_Amount__c = 20
        insert sales14_EI;
        sales14_EI = [SELECT Id, Account__c, Quantity__c, Contract__c, Product__c, Gross_price__c, Price__c, Tot_price__c, Invoice_date__c, Product__r.GlobalSKUMapping__r.PG2_Code__c FROM Sales_history__c WHERE Id =: sales14.Id];
        
        Sales_history__c sales15_EI = new Sales_history__c(Account__c= a.id, Quantity__c = 2, Contract__c = c.id, Product__c=product3.id, Price__c=100, Invoice_Date__c=Date15); //, Discount_Amount__c = 20
        insert sales15_EI;
        
        Sales_history__c sales16_EI = new Sales_history__c(Account__c= a.id, Quantity__c = 2, Contract__c = c.id, Product__c=product3.id, Price__c=100, Invoice_Date__c=Date16); //, Discount_Amount__c = 20
        insert sales16_EI;
        
        Sales_history__c sales17_EI = new Sales_history__c(Account__c= a.id, Quantity__c = 2, Contract__c = c.id, Product__c=product3.id, Price__c=100, Invoice_Date__c=Date17); //, Discount_Amount__c = 20
        insert sales17_EI;
        
        
        system.assertEquals(null, controller.Sales_CY_C);
        system.assertEquals(null, controller.Sales_LY_C);
        system.assertEquals(null, controller.Sales_L2Y_C);
        system.assertEquals(null, controller.Sales_L3Y_C);
        
        system.assertEquals(null, controller.Sales_CY_M_C);
        system.assertEquals(null, controller.Sales_LY_M_C);
        system.assertEquals(null, controller.Sales_L2Y_M_C);
        system.assertEquals(null, controller.Sales_L3Y_M_C);
        
        system.assertEquals(null, controller.Sales_CY_EI_C);
        system.assertEquals(null, controller.Sales_LY_EI_C);
        system.assertEquals(null, controller.Sales_L2Y_EI_C);
        system.assertEquals(null, controller.Sales_L3Y_EI_C);
        
        system.assertEquals(null, controller.Discount_CY_C);
        system.assertEquals(null, controller.Discount_LY_C);
        system.assertEquals(null, controller.Discount_L2Y_C);
        system.assertEquals(null, controller.Discount_L3Y_C);
        
        system.assertEquals(null, controller.Discount_CY_M_C);
        system.assertEquals(null, controller.Discount_LY_M_C);
        system.assertEquals(null, controller.Discount_L2Y_M_C);
        system.assertEquals(null, controller.Discount_L3Y_M_C);
        
        system.assertEquals(null, controller.Discount_CY_EI_C);
        system.assertEquals(null, controller.Discount_LY_EI_C);
        system.assertEquals(null, controller.Discount_L2Y_EI_C);
        system.assertEquals(null, controller.Discount_L3Y_EI_C);
        
        system.assertEquals(null, controller.Implants_CY_C);
        system.assertEquals(null, controller.Implants_LY_C);
        system.assertEquals(null, controller.Implants_L2Y_C);
        system.assertEquals(null, controller.Implants_L3Y_C);
               
        controller.getSales_CY();
    
        system.assertEquals(400, controller.Sales_CY_C);
        system.assertEquals(400, controller.Sales_CY_C);
        system.assertEquals(400, controller.Sales_L2Y_C);
        system.assertEquals(400, controller.Sales_L3Y_C);
        
        system.assertEquals(200, controller.Sales_CY_M_C);
        system.assertEquals(200, controller.Sales_LY_M_C);
        system.assertEquals(200, controller.Sales_L2Y_M_C);
        system.assertEquals(200, controller.Sales_L3Y_M_C);
        
        system.assertEquals(200, controller.Sales_CY_EI_C);
        system.assertEquals(200, controller.Sales_LY_EI_C);
        system.assertEquals(200, controller.Sales_L2Y_EI_C);
        system.assertEquals(200, controller.Sales_L3Y_EI_C);
        
        system.assertEquals(40, controller.Discount_CY_C);
        system.assertEquals(40, controller.Discount_LY_C);
        system.assertEquals(40, controller.Discount_L2Y_C);
        system.assertEquals(40, controller.Discount_L3Y_C);
        
        system.assertEquals(20, controller.Discount_CY_M_C);
        system.assertEquals(20, controller.Discount_LY_M_C);
        system.assertEquals(20, controller.Discount_L2Y_M_C);
        system.assertEquals(20, controller.Discount_L3Y_M_C);
        
        system.assertEquals(20, controller.Discount_CY_EI_C);
        system.assertEquals(20, controller.Discount_LY_EI_C);
        system.assertEquals(20, controller.Discount_L2Y_EI_C);
        system.assertEquals(20, controller.Discount_L3Y_EI_C);
        
        system.assertEquals(0, controller.Implants_CY_C);
        system.assertEquals(0, controller.Implants_LY_C);
        system.assertEquals(0, controller.Implants_L2Y_C);
        system.assertEquals(0, controller.Implants_L3Y_C);
        
        system.assertEquals(8, controller.Sales_Account.size());
    
    
    	controller.getContractStatus();
    	system.AssertEquals(0, controller.ContractImplantsSalesActivation);
        
    }
    
    
    }