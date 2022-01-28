public with sharing class ProductProfilingBundle {
 
    // @AuraEnabled annotation exposes the methods to Lightning Components and Flows
    @AuraEnabled
    public String productId;
 
    @AuraEnabled
    public String productName;
 
    // Define the structure of the Apex-Defined Variable
    public ProductProfilingBundle(
            String productId,
            String productName
    ) {
        this.productId = productId;
        this.productName = productName;
    }
}