/*Version History
 * Date: 20-Nov-2018
 * Class Name: OrderDealerSearchBox
 * Created By:Amit Pandey(amit.pandey@mindtree.com)
 * Related to: "Dealer Search Box" button
 * Related Test Class: OrderDealerSearchBoxTest.cls
 */
public with sharing class OrderDealerSearchBox {
    @AuraEnabled
    public static List<Preferred_dealer_item__c> saveDealer(List<Account> accList,Id orderId) {
        Order currentOrder=[select Id,name,Account.Id,	AccountId from Order where Id=:orderId];
        Account OrderAcc = [Select Id, Name, Country__c FROM Account WHERE Id =: currentOrder.Account.Id];
        //List<Preferred_dealer_item__c> =[Select Id, Name, Account__r.Id, Dealer__c, Dealer__r.Name, Default_dealer__c, Dealer_email__c FROM Preferred_dealer_item__c where Account__r.Id=: currentOrder.Account.Id];
        List<Preferred_dealer_item__c> cust = [Select Id, Name, Account__r.Id, Dealer__c, Dealer__r.Name, Default_dealer__c, Dealer_email__c FROM Preferred_dealer_item__c WHERE (Account__r.Id=: currentOrder.Account.Id) AND Dealer__r.OneAccount_Type__c='Distributor'];
        Map<Id,Preferred_dealer_item__c> pdMap= new Map<Id,Preferred_dealer_item__c>();
        for(Preferred_dealer_item__c pd:cust){
            pdMap.put(pd.Dealer__c, pd);
        }
        List <Preferred_dealer_item__c> prefDealerList= new  List <Preferred_dealer_item__c>();
        for(Account acc :accList){
            if(pdMap.containsKey(acc.Id)){
                continue;
            }
            Preferred_dealer_item__c prefDealer= new Preferred_dealer_item__c();
            prefDealer.Dealer__c=acc.Id;
            prefDealer.Account__c=OrderAcc.Id;
            //prefDealer.Dealer_email__c=acc.email
            prefDealerList.add(prefDealer);
            If (cust.size()>0){
                prefDealer.Default_dealer__c = false;
            } else {
                prefDealer.Default_dealer__c = true;
            }
        }
        System.debug('OrderAcc-->>>>'+OrderAcc);
        System.debug('prefDealerList---->>>'+prefDealerList); 
        if(prefDealerList.size()>0){
            insert prefDealerList;
        }
        return getAllPdeList(orderId);
    }
    @AuraEnabled
    public static Boolean CheckPermission(){
        if (Schema.sObjectType.Order.fields.Dealer__c.isUpdateable()) {
            return true;
        }
        else{
            return false;
        }
    }
    @AuraEnabled
    public static List<Preferred_dealer_item__c> getAllPdeList(Id orderId) {
        user currentUser = [select id, country from User where Id=:userInfo.getUserId()];
        Order ordr = [Select Id, Account.Id, Distributor__r.Id FROM Order Where Id =:orderId];
        List<Account> acc = [Select Id, Name, Country__c FROM Account WHERE Id =: ordr.Account.Id];
        System.debug('account for order--->>>'+acc);
        List<Preferred_dealer_item__c> cust = [Select Id, Name, Account__r.Id, Dealer__c, Dealer__r.Name,Dealer__r.ShippingCity,Dealer__r.ShippingState,Dealer__r.ShippingPostalCode, Default_dealer__c, Dealer_email__c FROM Preferred_dealer_item__c WHERE (Account__r.Id=: ordr.Account.Id) AND Dealer__r.OneAccount_Type__c='Distributor' ];
        System.debug('Preferred_dealer_item__c list ---->>>'+cust);
        return cust;
    }
    @AuraEnabled
    public static AccountDataTableWrapper fetchLookUpValues(Decimal pageNumber, Decimal pageSize,String searchKeyWord,Id orderId) {
        user currentUser = [select id, country from User where Id=:userInfo.getUserId()];
        Integer pSize = (Integer)pageSize;
        Integer pNumber = (Integer)pageNumber;
        String searchKey = searchKeyWord + '%';
        Integer offset = (pNumber - 1) * pSize;
        Order ordr = [Select Id, Account.Id, Distributor__r.Id FROM Order Where Id =:orderId];
        Account acc = [Select Id, Name, Country__c FROM Account WHERE Id =: ordr.Account.Id];
        //Total Records
        Integer totalRecords = [SELECT COUNT() from account 
                                where ( 
                                    Name LIKE: searchKey OR
                                    //BillingStreet LIKE: searchKey OR
                                    BillingCity LIKE: searchKey OR
                                    BillingState LIKE: searchKey OR
                                    BillingPostalCode LIKE: searchKey OR
                                    BillingCountry LIKE: searchKey )
                                AND OneAccount_Type__c = 'Distributor'
                                //AND (Country__c =:currentUser.Country)
                               ];
        Integer recordEnd = pSize * pNumber;
        List < Account > returnList = new List < Account > ();
        AccountDataTableWrapper objDT =  new AccountDataTableWrapper();  
        objDT.pageSize = pSize;
        objDT.pageNumber = pNumber;
        objDT.recordStart = offset + 1;
        objDT.recordEnd = totalRecords >= recordEnd ? recordEnd : totalRecords;
        objDT.totalRecords = totalRecords;
        system.debug('searchKey---->>> '+searchKey);
        objDT.accountList = [select id, Name,OneAccount_Type__c,BillingStreet, ShippingCity, ShippingState, ShippingPostalCode, BillingCity, BillingState, BillingPostalCode, BillingCountry from account 
                             where ( 
                                 Name LIKE: searchKey OR
                                 ShippingStreet LIKE: searchKey OR
                                 ShippingCity LIKE: searchKey OR
                                 ShippingState LIKE: searchKey OR
                                 ShippingPostalCode LIKE: searchKey OR
                                 ShippingCountry LIKE: searchKey )
                             AND OneAccount_Type__c = 'Distributor'
                             // AND (Country__c =:currentUser.Country)
                             LIMIT :pSize OFFSET :offset];
        return objDT;
    }
    @AuraEnabled
    public static String updateDealerInfo(Id dealerId,Order orderRec) {
       
        Preferred_dealer_item__c dealer=[Select id,name,Dealer__c,Dealer_email__c from Preferred_dealer_item__c where Id=:dealerId];
        system.debug('dealer in apex-----'+dealer);
        orderRec.Dealer__c = dealer.Id;
        orderRec.Distributor__c = dealer.Dealer__c;
        orderRec.Distributor_email__c = dealer.Dealer_email__c;
        try{
        	update orderRec;
        }
        catch(Exception e){
            throw new AuraHandledException('Exception thrown while updating Order : '+e.getMessage());
        }
        return orderRec.Id;
    }
    @AuraEnabled
    public static Order Initialize(Id recordId) {
        Order orderRecord=[Select id,name,Dealer__c,Distributor__c,Distributor_email__c,Status from Order where Id=:recordId LIMIT 1];
        system.debug('orderRecord initialize in apex :'+orderRecord);
        return orderRecord;
    }
    public class AccountDataTableWrapper {
        @AuraEnabled
        public Integer pageSize {get;set;}
        @AuraEnabled
        public Integer pageNumber {get;set;}
        @AuraEnabled
        public Integer totalRecords {get;set;}
        @AuraEnabled
        public Integer recordStart {get;set;}
        @AuraEnabled
        public Integer recordEnd {get;set;}
        @AuraEnabled
        public List<Account> accountList {get;set;}
    }
}