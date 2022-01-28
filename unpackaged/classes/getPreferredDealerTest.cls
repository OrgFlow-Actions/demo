@isTest
public with sharing class getPreferredDealerTest {    
    
@isTest
private static void getPreferredDealer_Test(){

        
        Account a = new Account(Name='Test account 1', CurrencyIsoCode = 'EUR', Country__c = 'NL');
        insert a;
        
        Account d1 = new Account(Name='Dealer account 1', CurrencyIsoCode = 'EUR', Country__c = 'NL', RecordTypeID = '01220000000ckje');
        insert d1;
        
        Account d2 = new Account(Name='Dealer account 2', CurrencyIsoCode = 'EUR', Country__c = 'NL', RecordTypeID = '01220000000ckje');
        insert d2;
        
        Preferred_dealer_item__c pd = new Preferred_dealer_item__c (Account__c=a.Id, Dealer__c = d1.Id, Default_dealer__c = true);
        insert pd;
        
        List<Preferred_dealer_item__c> opps = [SELECT Id, Name, Account__c, Dealer__c FROM Preferred_dealer_item__c Where Account__c =: a.id]; 
        
        //DateTime expected = DateTime.newInstance(2016, 4, 21, 8, 13, 16);
            
        ApexPages.currentPage().getParameters().put('id', a.id);     
        
        ApexPages.StandardSetController stdController = new ApexPages.StandardSetController(opps);   
        
        getPreferredDealers controller = new getPreferredDealers(stdController);
        
        controller.fetchRecords();
        
        system.assertNotEquals(null, controller.acc.id);
        
        system.assertNotEquals(null, controller.prfd.id);
        
        system.assertNotEquals(null, controller.getRadioValue);
        
        system.assertEquals(1, controller.pdeList.size());
        
        system.assertEquals(1, controller.dealerList.size());
        
        controller.addDealer();
        
        system.assertEquals(1, controller.pdeList.size());
        
        controller.dealerList[0].selected_pd = true;
        
        controller.addDealer();
        
        system.assertEquals(2, controller.pdeList.size());
              
        controller.pdeList[1].selected_pd = true;
        controller.pdeList[0].selected_pd = false;
        
        system.assertEquals(2, controller.getDealerOptions().size());
        
        controller.saveDealer();
        
        controller.pdeList[1].selected_pd = true;
        controller.pdeList[0].selected_pd = true;
        
        controller.saveDealer();
        
    } 
    
    
    }