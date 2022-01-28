public class ServiceCloud_Case {

    @AuraEnabled
    public static Case getCaseInfo(Id recordId){    
    Case cs = [SELECT Id, Subject, OwnerId, Order_Number__c, Return_Tracking_Number__c, Invoice_Number__c FROM Case WHERE Id=: recordId];
    return cs;    
    }
    
    @AuraEnabled
    public static List<Case> getMyOpenCases(){    
    List<Case> cs = [SELECT Id, CaseNumber, OwnerId, Status, Subject, RecordType.Name, IsClosed, Account.BillingAddress, ContactId, AccountId FROM Case WHERE OwnerId=: UserInfo.getUserId() LIMIT 10];
    return cs;    
    }
    
    @AuraEnabled
    public static List<Order> getOrders(Id accountId){
        List<Order> ordrs = [SELECT Id, Status, OrderNumber, EffectiveDate, ActivatedDate FROM Order WHERE AccountId =: accountId ORDER BY ActivatedDate DESC LIMIT 10];
      return ordrs;
    }
    
    @AuraEnabled
    public static Order findOrderDetails(Id orderId){
        Order ordr = [SELECT Id, OrderNumber, EffectiveDate, Status, ActivatedDate, TotalAmount FROM Order WHERE Id =: orderId];
      	return ordr;
    }
    
    @AuraEnabled
    public static List<OrderItem> findOrderRows(Id orderId){
        List<OrderItem> ordrRows = [SELECT Id, Article_Number__c, ListPrice, Total_Line_Item_Price__c, UnitPrice, Product2Id, Product2.Name, Product2.Article__c, OrderId, Quantity FROM OrderItem WHERE OrderId =: orderId];
      	return ordrRows;
    }
    
    /*@AuraEnabled
    public static List<Sales_History__c> findInvoiceRows(String orderNoMovex){
        List<Sales_History__c> salesRows = [SELECT Id, Article__c, Price__c, Name, Account__c, Account__r.Name, Tot_Price__c, Invoice_Number__c, Invoice_Date__c, Quantity__c, Order_Number__c FROM Sales_History__c WHERE Order_Number__c =: orderNoMovex];
      	return salesRows;
    }*/
    
    @AuraEnabled
    public static List<SC_Case_Questionnaire__mdt> findQuestions(){
        List<SC_Case_Questionnaire__mdt> Questions = [SELECT Label, Category__c, Credit_Rebill__c, New_or_Replacement_Order__c, Order_number__c, Item_number__c, Invoice_number__c, Tracking_number__c, Carrier__c, LOTnumber__c, Returnnumber__c, Softwarename__c, Timeofcontact__c, Expirationdate__c, Correctionofvalue__c, Amount__c 
                                                      FROM SC_Case_Questionnaire__mdt];
      	
        return Questions;
    }
    
        @AuraEnabled
    	public static List<SC_Case_Questionnaire__mdt> findSpecificQuestions(String Reason, String Category){
        List<SC_Case_Questionnaire__mdt> Questions = [SELECT Label, Category__c, Credit_Rebill__c, New_or_Replacement_Order__c, Order_number__c, Item_number__c, Invoice_number__c, Tracking_number__c, Carrier__c, LOTnumber__c, Returnnumber__c, Softwarename__c, Timeofcontact__c, Expirationdate__c, Correctionofvalue__c, Amount__c 
                                                      FROM SC_Case_Questionnaire__mdt WHERE Label =: Reason AND Category__c =: Category]; //AND Category__c =: Category
      	
        return Questions;
    }
     
}