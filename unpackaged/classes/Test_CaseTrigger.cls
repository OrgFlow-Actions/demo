/*-------------------------------------------------------------------------------------------------------
Author:         NISREEN ALSALEH (support@avity.com) 25-March-2021
Description:    Case Trigger Helper Class
--------------------------------------------------------------------------------------------------------*/
@isTest(seeAllData = False)
public class Test_CaseTrigger {
    
     @testSetup
    private static void setup() {
        TestDataFactory.createBypassCustomSetting();
        List<User> userList = TestDataFactory.createUsers(1, 'System Administrator');
        List<User> userIntegrationList = TestDataFactory.insertIntegrationUsers(1, 'System Administrator');
        TestDataFactory.createGlobalIntegrationSettings(userIntegrationList);
    }
    
@isTest static void myUnitTest() {
        Account acc = new Account(Name='testacc', OneAccount_Type__c = 'Dental Clinic');
        acc.RecordTypeId=Schema.sObjectType.Account.getRecordTypeInfosByName().get('CIM Account').getRecordTypeId();
        insert acc;

        Contact con = new Contact(FirstName='john', LastName='doe', Email='john@doe.com', Profession__c= 'Consultant',InsertEmailMarketingConsentCollected__c = 'No',AccountId=acc.Id);
        con.RecordTypeId = Schema.sObjectType.Contact.getRecordTypeInfosByName().get('Contact Global').getRecordTypeId();
        insert con;

        Asset ass = new Asset(AccountId=acc.Id,ContactId=con.Id, Name='testing');
        insert ass;

        Entitlement ent = new Entitlement(Name='Testing', AccountId=acc.Id, StartDate=Date.valueof(System.now().addDays(-2)), EndDate=Date.valueof(System.now().addYears(2)), AssetId=ass.Id);
        insert ent;

        Entitlement ent2 = new Entitlement(Name='test2', AccountId=acc.Id, StartDate=Date.valueof(System.now().addDays(-10)), EndDate=Date.valueof(System.now().addYears(3)));
        insert ent2;

        EntitlementContact ec = new EntitlementContact(EntitlementId=ent.Id, ContactId=con.Id);
        insert ec;

        List<Case> listC = new list<Case>();
        List<Id> newCaseIds = new List<Id>();
        for(Integer i=0;i<20;i++){
            Case c = new Case(ContactId=con.Id, AccountId=con.AccountId, Subject='Test Subject'+i, Status='New', CaseType__c= 'General support/question',
                              Complaint_Category__c='Customer Interaction',Complaint_Reason2__c='General inquiry',SBU__c= 'IMPL',Product_Line__c='Implants');
            c.RecordTypeId = Schema.sObjectType.Case.getRecordTypeInfosByName().get('Service Complaint').getRecordTypeId();
            listC.add(c);
        }
        insert listC;   
        for (Case caseObj:listC) {
            newCaseIds.add(caseObj.Id);
        }

        List<Case> entls = [Select EntitlementId, AssetId, ContactId, AccountId From Case Where Id in :newCaseIds];

        for (Case caseObj:entls) {

            System.debug(caseObj.Id + ' here are the values ' + caseObj.EntitlementId + ' and here ent.Id ' + ent.Id);

            System.assertEquals(caseObj.EntitlementId, ent.Id);

        }
        Contact con2 = new Contact(FirstName = 'Jane',
        LastName = 'Doe',
        Email='jane@doe.com',
        Profession__c= 'Consultant',
        InsertEmailMarketingConsentCollected__c = 'No');
        con2.RecordTypeId = Schema.sObjectType.Contact.getRecordTypeInfosByName().get('Contact Global').getRecordTypeId();
        insert con2;
    
        Entitlement ent3 = new Entitlement(Name='Testing', AccountId=acc.Id, StartDate=Date.valueof(System.now().addDays(2)), EndDate=Date.valueof(System.now().addYears(2)), AssetId=ass.Id);
        insert ent3;

        EntitlementContact ec2 = new EntitlementContact(EntitlementId=ent3.Id, ContactId=con2.Id);
        insert ec2;
        Case c1 = new Case(ContactId=con2.Id, AccountId=con.AccountId, Subject='Test Subject',Status='New', CaseType__c= 'General support/question',
                              Complaint_Category__c='Customer Interaction',Complaint_Reason2__c='General inquiry',SBU__c= 'IMPL',Product_Line__c='Implants');
    	c1.RecordTypeId = Schema.sObjectType.Case.getRecordTypeInfosByName().get('Service Complaint').getRecordTypeId();
        Test.startTest();
            insert c1;
            update c1;
        Test.stopTest();
    }
    
    @isTest static void milestoneTestMethod(){
        Account acc = new Account();
        acc.Name = 'Test Acc';
        insert acc;
        
        Case c = new case();
        c.status = 'Active';
        c.AccountId = acc.Id;
        c.RecordTypeId = '01220000000AvOOAA0';
        c.SlaStartDate = system.now().addHours(-1); 
        Test.startTest();
            insert c;
            c.status = 'Closed';
            update c;
        Test.stopTest();

    }
    
}