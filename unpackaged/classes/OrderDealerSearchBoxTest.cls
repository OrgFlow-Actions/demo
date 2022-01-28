/*Version History
 * Date: 13-Jan-2019
 * Class Name: OrderDealerSearchBoxTest
 * Created By:Amit Pandey(amit.pandey@mindtree.com)
 * Related to: "Dealer Search Box" button
 * Related Class: OrderDealerSearchBox.cls
 */

@isTest
public class OrderDealerSearchBoxTest {
@testSetup
    public static void createData(){
        //create test user
        User u = new User();
        //u.Name = 'testUser';
        u.LastName= 'testUser';
        u.Alias= 'testUser';
        u.TimeZoneSidKey= 'Asia/Taipei';
        u.LocaleSidKey= 'en_US';
        u.EmailEncodingKey= 'ISO-8859-1';
        u.LanguageLocaleKey = 'en_US';
        u.Username = 'Testorder@testuser.com';
        u.Email = 'Testtt@salesforce.com';
        u.ProfileId = [select id from profile where Name like '%Lightning Sales Rep%' Limit 1][0].Id;
        //LastName, Email, Alias, TimeZoneSidKey, LocaleSidKey, EmailEncodingKey, LanguageLocaleKey]: [LastName, Email, Alias, TimeZoneSidKey, LocaleSidKey, EmailEncodingKey, LanguageLocaleKey
        insert u;
        //create test Account
        System.runAs(u) {
            Account a = new Account();
            a.Name = 'TestAccount';
            a.OneAccount_Type__c = 'Distributor';
            a.RecordTypeId = [select id, developerName from RecordType where developerName Like '%CIM_Account%'][0].Id;
            insert a;
            //create test distributor Account
            Account da = new Account();
            da.Name = 'TestDistributorAccount';
            da.OneAccount_Type__c = 'Distributor';
            da.RecordTypeId = [select id, developerName from RecordType where developerName Like '%CIM_Account%'][0].Id;
            insert da;
            //create order
            Order o = new Order();
            o.AccountId = a.Id;
            o.Distributor__c = a.Id;
            o.Status = 'Created';
            o.EffectiveDate = System.Today();
            insert o;
            
             //create dealer Account
            Account dealer = new Account();
            dealer.General_Info_Email__c = 'dealer@test.com';
            dealer.Name = 'testdealer';
            dealer.OneAccount_Type__c = 'Distributor';
            dealer.RecordTypeId = [select id, developerName from RecordType where developerName Like '%CIM_Account%'][0].Id;
            insert dealer;
            //create Dealer
            Preferred_dealer_item__c pd = new Preferred_dealer_item__c();
            pd.Dealer__c = dealer.Id;
            pd.Account__c=a.Id;
            insert pd;
        }
       }
    
    @isTest
    public static void saveDealerTest(){
        User u = [select Id, Name from User where Username = 'Testorder@testuser.com'];
         Order o = [select Id from Order Limit 1];
        //System.runAs(u){
        List<Account> accList = [select Id from Account where Name Like '%TestAccount%'];
       
        List<Preferred_dealer_item__c> pdList=OrderDealerSearchBox.saveDealer(accList,o.Id);
        system.assertNotEquals(0, pdList.size());
   // }
    }
    
        @isTest
    public static void fetchLookUpValuesTest(){
        User u = [select Id, Name from User where Username = 'Testorder@testuser.com'];
         Order o = [select Id from Order Limit 1];
        //System.runAs(u){
       OrderDealerSearchBox.CheckPermission();
       OrderDealerSearchBox.AccountDataTableWrapper adtw = OrderDealerSearchBox.fetchLookUpValues(1,2,'TestDistributorAccount',o.Id);
        system.assertNotEquals(Null, adtw);
   // }
    }
    
      @isTest
    public static void updateDealerTest(){
        User u = [select Id, Name from User where Username = 'Testorder@testuser.com'];
        Order o = [select Id from Order Limit 1];
        //System.runAs(u){
            //updateDealer(Id dealerId,Id orderId)
        
         Preferred_dealer_item__c pd = [select Id from Preferred_dealer_item__c Limit 1];   
       OrderDealerSearchBox.updateDealerInfo(pd.Id,o);
        Order orderRecord=[Select id,name,Dealer__c,Distributor__c,Distributor_email__c from Order where Id=:o.Id];
        system.assertEquals('dealer@test.com', orderRecord.Distributor_email__c);
   // }
    }
}