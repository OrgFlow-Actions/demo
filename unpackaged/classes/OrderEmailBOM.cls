public class OrderEmailBOM {

    public List<BOM__c> BOM_rows {get; set;}
    public List<BOM__c> BOM_total {get; set;}
    public Product_bundle__c ProdBundle2 {get; set;}
    public Order ordr {get; set;}
    public Id currentRecordId {get;set;}
    public List <Product_bundle__c> ProdBundList {get; set;}
    public List <Order_bundle__c> OrderBundList {get; set;}
    public Pricebook2 pb {get; set;}
    
    public OrderEmailBOM() {
        ProdBundList = new List <Product_bundle__c> ();
        OrderBundList = new List <Order_bundle__c> ();
        ordr = new Order ();
        
        currentRecordId  = ApexPages.CurrentPage().getparameters().get('related_To_id');
                
    }
    
    public List<Order_bundle__c> getOrdrBundList () {
    
    if(currentRecordId != null) {
        ordr = [SELECT Id, Pricebook2.Id, RecordType.Name FROM Order Where Id =: currentRecordId];
        OrderBundList = [SELECT Id, Product_Bundle__r.Id,Product_Bundle__r.Name, Total_price__c, Quantity__c, Order__r.CurrencyIsoCode FROM Order_bundle__c WHERE Order__r.Id =: currentRecordID];
        pb = [SELECT Id, Name, Indirect_orders_Show_prices__c, Direct_orders_Show_prices__c, Indirect_orders_Show_discount_field__c FROM Pricebook2 WHERE Id =: ordr.Pricebook2.Id];
    }
    return OrderBundList;
    }
       
    public List<BOM__c> getEmailBOM () {
         
        if (OrderBundList.size() > 0) {
        for (Order_bundle__c i: OrderBundList) {
        ProdBundle2 = [SELECT Id, Name FROM Product_Bundle__c WHERE Id =: i.Product_Bundle__r.Id];     
      
        If (ProdBundle2.Id != null){
        ProdBundList.add(prodBundle2);
        }
        
        }
        }
    
    
       
    Bom_total = new List<BOM__c>();
    if (ProdBundList.size() > 0 ) {
    for (Product_bundle__c j: ProdBundList) {
    BOM_rows = [select Id, Name, Product__c, Quantity__c, Product_bundle__c, Product_bundle__r.Id, Discount__c from BOM__c WHERE Product_bundle__r.Id =: j.Id];
    If(Bom_rows.size()>0){
    BOM_total.addAll(BOM_rows);
    }
    }
    }   
    return BOM_total;
    }
    
}