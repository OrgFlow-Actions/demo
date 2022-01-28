@isTest
public with sharing class OrderGlobal_CancelTest {    
    
@isTest
private static void OrderGlobal_Cancel_Test(){

        
        Account a = new Account(Name='Test account 1', CurrencyIsoCode = 'EUR', Country__c = 'NL');
        insert a;

        Pricebook2 p = new Pricebook2(Name = 'Test pricebook 1');
        insert p;
        
        Order o = DC_UT_DataUtils.generateOrder(a.id, Date.today(), a.CurrencyIsoCode);
        o.Pricebook2Id = p.id;
        insert o;        
            
        ApexPages.currentPage().getParameters().put('id', o.id);      
        
        ApexPages.StandardController stdController = new ApexPages.StandardController(o);   
        
        OrderGlobal_Cancel controller = new OrderGlobal_Cancel(stdController);
      
        controller.save();
        
        System.AssertEquals('Rejected', controller.CurRec.Status);
        
    } 
    
    
    }