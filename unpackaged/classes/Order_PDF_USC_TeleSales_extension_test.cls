@isTest

public class Order_PDF_USC_TeleSales_extension_test {
    private static final String EURO_CODE = 'EUR';
    
    public static testMethod void Order_PDF_USC_TeleSales() {
        //- create account and order
        Account account1 = DC_UT_DataUtils.generateAccount('Account1');
        insert account1;
       
        //    order1.Order_Discount__c = 0;
        //    update order1;
        
        //- create test pricebooks (pricebook1 is a standard real pricebook)
        Pricebook2 pricebook1 = new Pricebook2(Id = Test.getStandardPricebookId());
        Pricebook2 pricebook2 = DC_UT_DataUtils.generatePricebook('Pricebook2', EURO_CODE);
        insert pricebook2;
        Order order1 = DC_UT_DataUtils.generateOrder(account1.Id, Date.today(), EURO_CODE);
        order1.Pricebook2Id=pricebook2.id;
        insert order1;
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
        //- create test pricebook entries
        //pricebook1
        PricebookEntry[] entries1 = DC_UT_DataUtils.generatePricebookEntries(
            pricebook1.Id, products, 1000, EURO_CODE);
        insert entries1;
        //pricebook2
        PricebookEntry[] entries2 = DC_UT_DataUtils.generatePricebookEntries(
            pricebook2.Id, products, 1000, EURO_CODE);
        insert entries2;
        orderItem it1 = new orderItem(OrderId=order1.Id, PricebookEntryId=entries2[0].Id, Quantity=1, UnitPrice=1,Discount_Percent__c=100);
        insert it1;
        orderItem it2 = new orderItem(OrderId=order1.Id, PricebookEntryId=entries2[1].Id, Quantity=1, UnitPrice=1,Discount_Percent__c=10);
        Test.startTest(); //switch to testing context
                PageReference pageRef = Page.Order_PDF_USC_TeleSales; //create a page reference to our Visualforce page
                pageRef.getparameters().put('Id', order1.Id); 
                Test.setCurrentPage(pageRef);
                
                Apexpages.StandardController sc = new Apexpages.StandardController(order1);
                Order_PDF_USC_TeleSales_extension ext = new  Order_PDF_USC_TeleSales_extension(sc);
        test.stopTest();
    }
    //system.debug(entries2);
    
}