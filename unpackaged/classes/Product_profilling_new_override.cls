public class Product_profilling_new_override {
    private final Product_Profiling__c pp; 
    public Contact c{get;set;}     
    
    public Product_profilling_new_override(ApexPages.StandardController standardPageController) {
        pp = (Product_Profiling__c)standardPageController.getRecord();
        // Get Parameters that correspond to those passed by related list
        
        Id contactId = ApexPages.currentPage().getParameters().get('conid');
        c = [select id ,AccountId from Contact where id =: contactId ];
        system.debug(contactId);
        // Assign values to Record
        pp.Account__c = c.AccountId;
        pp.Contact__c = c.Id;        
    }
    
    public PageReference save1(){
        insert pp;
        PageReference pr = new PageReference('/' + c.id);
        return pr;
    }
    public PageReference cancel1(){
        PageReference pr = new PageReference('/' + c.id);
        return pr;
    }
}