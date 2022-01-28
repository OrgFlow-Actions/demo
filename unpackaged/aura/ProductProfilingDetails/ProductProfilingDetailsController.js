({
    init: function (cmp, event, helper) {
        
        var productMap = {};
        var productWrapperList = cmp.get("v.selectedProductsWrapper");
                
        for(var product in productWrapperList){
            var productId = productWrapperList[product].productId;
            productMap[productId] = productWrapperList[product].productName;            
        }
        
        console.log('Product map: ' + JSON.stringify(productMap));
        
        var products = [];
        products = cmp.get("v.selectedProducts");
        
        for(var prod in products){
            var prodId = products[prod].Product_Name__c;
			console.log(productMap[prodId]);
            var productName = productMap[prodId];
            products[prod].productName =productName;
        }
        
        cmp.set('v.columns', [
            {label: 'Product', fieldName: 'Non_ERP_Product_Id__c', type: 'text'}
        ]);
        
        console.log('Products to show in detail section: ' + JSON.stringify(products));
        
        cmp.set("v.outputProducts", products);
        
    }
})