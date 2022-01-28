public class Order_PDF_USC_TeleSales_extension {
    public Id oId; 
    public list<OrderItem> freeprod{get;set;}  
    public list<OrderItem> payprod{get;set;}  
    public Order_PDF_USC_TeleSales_extension(ApexPages.StandardController Controller) {
        oId = System.currentPageReference().getParameters().get('id');
        freeprod = [SELECT Id,Article_Number__c,Quantity,PriceBookEntry.Product2.Name,Offer_Code_dna__r.Name,UnitPrice,Total_Line_Item_Price__c,Order.CurrencyIsoCode  FROM OrderItem WHERE OrderId = : oId and Discount_Percent__c =100 ];
        payprod =  [SELECT Id,Article_Number__c,Quantity,PriceBookEntry.Product2.Name,Offer_Code_dna__r.Name,UnitPrice,Total_Line_Item_Price__c,Order.CurrencyIsoCode  FROM OrderItem WHERE OrderId = : oId and Discount_Percent__c !=100];
        system.debug(oId);
        system.debug(payprod);
        system.debug(freeprod);
    }
}