@isTest
public class ServiceCloud_TestClass {

    @isTest
    private static void Case_Test(){
        
    	
        Account acc = new Account(Name='Test account 1', CurrencyIsoCode = 'EUR', Country__c = 'NL');
        insert acc;
        
        Contact con = new Contact(LastName='Testsson', Firstname='Test', Account = acc);
        insert con;
        
        Country__c country = new Country__c(name='australia',Country__c = 'AUS',Country_Name__c = 'Australia AUS');
        insert country;
        
        Case c = new Case(Subject='Test case', ContactId = con.Id, AccountId = acc.Id, OwnerId = UserInfo.getUserId(),Teamforce_Product__c= 'Events',related_Country__c=country.Id);
        insert c;       
        
        ApexPages.StandardController stdController = new ApexPages.StandardController(c);
         
        Case cInfo = ServiceCloud_Case.getCaseInfo(c.Id);
        
        System.AssertEquals(cInfo.OwnerId, UserInfo.getUserId());
        
        List<Case> cList = ServiceCloud_Case.getMyOpenCases();
        
        System.AssertEquals(cList.size(), 1);
        
        
        Pricebook2 p = new Pricebook2();
        p.Name = 'Test pricebook';
        p.CurrencyIsoCode = 'EUR';
        p.IsActive = true;
        
        insert p;
                
        System.AssertNotEquals(p.Id, null);
        
        
        Order order1 = DC_UT_DataUtils.generateOrder(acc.Id, Date.today(), 'EUR');        
        order1.Pricebook2Id = p.Id;
        insert order1;
        
        List<Order> oList = ServiceCloud_Case.getOrders(acc.Id);
        
        System.AssertEquals(oList.size(), 1);
        
        Order o = ServiceCloud_Case.findOrderDetails(order1.Id);
        
        System.AssertNotEquals(o.OrderNumber, '');
        
        
        Product2 prod = new Product2();
        prod.Article__c = 'Test_article';
        prod.Name = 'Test product';
        prod.Description = 'Description';
        prod.IsActive = true;
        prod.CurrencyIsoCode ='EUR';

        insert prod;        
        
        System.AssertNotEquals(prod.Id, null);
        
        PricebookEntry pStandard= new PricebookEntry();
        pStandard.Pricebook2Id = Test.getStandardPricebookId();
        pStandard.Product2Id = prod.Id;
        pStandard.UnitPrice = 100;
        pStandard.CurrencyIsoCode = 'EUR';
        pStandard.IsActive = true;
        
        insert pStandard;
        
        PricebookEntry pEntry= new PricebookEntry();
        pEntry.Pricebook2Id = p.Id;
        pEntry.Product2Id = prod.Id;
        pEntry.UnitPrice = 100;
        pEntry.CurrencyIsoCode = 'EUR';
        pEntry.IsActive = true;
        
        insert pEntry;
                
        System.AssertNotEquals(pEntry.Id, null);        
        
        OrderItem oItem = new OrderItem();        
        if(pEntry.Id != null){
        oItem.PricebookEntryId = pEntry.Id;
        oItem.OrderId = o.Id;
        oItem.UnitPrice = 100;
        oItem.Quantity = 1;
        
        insert oItem;
        }
            
        List<OrderItem> oDetails = ServiceCloud_Case.findOrderRows(o.Id);
        System.AssertEquals(oDetails.size(), 1);
        
        List<SC_Case_Questionnaire__mdt> questions= ServiceCloud_Case.findQuestions();
        System.AssertNotEquals(questions.size(), 0);
        
        List<SC_Case_Questionnaire__mdt> specQuestions= ServiceCloud_Case.findSpecificQuestions('Order Processing','Software Complaint');
        System.AssertNotEquals(questions.size(), 0);
    }
    
    
    //Tests of class ServiceCloud_Contact
    
    @isTest
    private static void Contact_Test(){
    
        Account acc = new Account(Name='Test account 1', CurrencyIsoCode = 'EUR', Country__c = 'NL');
        insert acc;
        
        Contact con = new Contact(LastName='Testsson', Firstname='Test', Account = acc);
        insert con;
        
        Country__c country = new Country__c(name='australia',Country__c = 'AUS',Country_Name__c = 'Australia AUS');
        insert country;
        
        Case c = new Case(Subject='Test case', ContactId = con.Id, AccountId = acc.Id, OwnerId = UserInfo.getUserId(),Teamforce_Product__c= 'Events',related_Country__c=country.Id);
        insert c;  
        
        ApexPages.StandardController stdController = new ApexPages.StandardController(c);
         
        Contact cInfo = ServiceCloud_Contact.getContactInfo(con.Id);
        
        System.AssertNotEquals(cInfo.Name, '');
        
        List<Case> openCases = ServiceCloud_Contact.getOpenCases(con.Id);
        
        System.assertEquals(openCases.size(), 1);
        
        Map<String, String> caseLabels = ServiceCloud_Contact.getCaseFieldLabels();
        
        System.assertNotEquals(caseLabels.size(), 0);
        
    }
    
    
    //Tests of class ServiceCloud_Account
    
    @isTest
    private static void Account_Test(){
            
        Account acc = new Account(Name='Test account 1', CurrencyIsoCode = 'EUR', Country__c = 'NL');
        insert acc;
        
        Contact con = new Contact(LastName='Testsson', Firstname='Test', Account = acc);
        insert con;
        
        Country__c country = new Country__c(name='australia',Country__c = 'AUS',Country_Name__c = 'Australia AUS');
        insert country;
        
        Case c = new Case(Subject='Test case', ContactId = con.Id, AccountId = acc.Id, OwnerId = UserInfo.getUserId(),Teamforce_Product__c= 'Events',related_Country__c=country.Id);
        insert c;      
         
        Account aInfo = ServiceCloud_Account.getAccountInfo(acc.Id);
        
        System.AssertNotEquals(aInfo.Name, '');
        
        List<Case> openCases = ServiceCloud_Account.getOpenCases(acc.Id);
        
        System.assertEquals(openCases.size(), 1); 
        
    }
    
    @isTest
    private static void Account_ETM_Test(){
        
        list<Territory2Type> terriType = [SELECT id, DeveloperName from Territory2Type];
        List<Territory2Model> terrModel = [SELECT Id, DeveloperName FROM Territory2Model WHERE State =: 'Active'];
        List<Territory2> terList = [SELECT Id, DeveloperName FROM Territory2 WHERE Territory2ModelId =: terrModel[0].Id AND Territory2TypeId =: terriType[0].Id];
        
        /*Territory2 ter = new Territory2();
        ter.DeveloperName = 'TestTerritory';
        ter.Territory2ModelId = terrModel[0].Id;
        ter.Name='TestTerritory';
        ter.Territory2TypeId=terriType[0].Id;        
        insert ter;*/

        Account acc = new Account(Name='Test account 1', CurrencyIsoCode = 'EUR', Country__c = 'NL');
        insert acc;
        
        List<UserTerritory2Association> user2ter0 = ServiceCloud_Account.getTerritoryInfo(acc.Id);
        
        System.assertEquals(user2ter0, null);
        
        ObjectTerritory2Association acc2ter = new ObjectTerritory2Association();
        acc2ter.ObjectId = acc.Id;
        acc2ter.Territory2Id = terList[0].Id;
        acc2ter.AssociationCause = 'Territory2Manual';
        insert acc2ter;
        
        List<UserTerritory2Association> user2ter = ServiceCloud_Account.getTerritoryInfo(acc.Id);
        /*user2ter.Territory2Id = terList[0].Id;
        user2ter.UserId = UserInfo.getUserId();
        insert user2ter;*/
        
    } 
    
    //Test of ServiceCloud_FlowLookupController
    
    @isTest
    private static void FlowLookup_Test(){
    
    String res = ServiceCloud_FlowLookupController.searchDB('User', 'Name', 'Id', 10, 'Name', '');           
            
    }
    
    
    @isTest
    private static void FlowLookup_Test_ver2(){
    
    String res = ServiceCloud_FlowLookupController_ver2.searchDB('User', 'Name', 'Id', 10, 'Name', '','Full_Name__c');           
    
    String resExact = ServiceCloud_FlowLookupController_ver2.searchDBexact('User', 'Name', 'Id', 10, 'Name', '','User_Country__c');
        
    }
    
    
    @isTest
    private static void Flow_Case_Test(){
    
        Account acc = new Account(Name='Test account 1', CurrencyIsoCode = 'EUR', Country__c = 'NL');
        insert acc;
        
        Contact con = new Contact(LastName='Testsson', Firstname='Test', Account = acc);
        insert con;
        
        Country__c country = new Country__c(name='australia',Country__c = 'AUS',Country_Name__c = 'Australia AUS');
        insert country;
        
        Case c = new Case(Subject='Test case', ContactId = con.Id, AccountId = acc.Id, OwnerId = UserInfo.getUserId(),Teamforce_Product__c= 'Events',related_Country__c=country.Id);
        insert c;
        
        Case res = ServiceCloud_FlowLookupController_ver2.getCaseInfo(c.Id);
        
    }    
    
}