/*------------------------------------------------------------
Author: 		Richard Trum (Glimt) 2019-12-05
Description:   	Test Class for all KOLInfoTriggerHelper methods.
History
<Date>      <Authors Name>     <Brief Description of Change>
20191205 	Richard Trum		Created test class for the trigger framework for the KOL Information (Expert__c) object
								Based on the Test_AccountTrigger class from Salesforce
------------------------------------------------------------*/

@isTest(seeAllData=false)
public class Test_KOLInfoTrigger {

    /*-------------------------------------------------------------------------------------------------------
    Company: Salesforce
    Description: Setup one user for the test class
    History :
    --------------------------------------------------------------------------------------------------------*/
    @testSetup
    private static void setup() {
        TestDataFactory.createBypassCustomSetting();
        List<User> userList = TestDataFactory.createUsers(1, 'System Administrator');
    }

    @isTest
    private static void testSetup() {
        Test.startTest();
        List<User> testUserList = [SELECT Id FROM User WHERE Alias = 'test1'];
        Test.stopTest();

        System.assertEquals(1, testUserList.size(), 'Expected one user');
    }

    /*-------------------------------------------------------------------------------------------------------
    Company: Glimt
    Description: Test method for KOLInfoTriggerHelper.preventDuplicateKOLs()
    History :
    --------------------------------------------------------------------------------------------------------*/
    @isTest
    private static void testPreventDuplicateKOLs() {
        User testUser = [SELECT Id FROM User WHERE Alias = 'test1' LIMIT 1];

        List<Account> testAccountList = TestDataFactory.returnAccounts(1, 'Non_ERP_Account', testUser.Id);
        Account testAccount = testAccountList[0];
        
        Contact testContact = new Contact();
        testContact.FirstName ='Test';
        testContact.LastName = 'Contact';
        testContact.AccountId = testAccount.Id;
        insert testContact;
        
        Expert__c testKOL = new Expert__c();
        testKOL.Contact__c = testContact.Id;
        testKOL.Name = 'Test KOL';
        insert testKOL;
        
        Test.startTest();
        // Test inserting a second KOL Information record towards the same Contact
        Expert__c validateKOL = new Expert__c();
        validateKOL.Contact__c = testContact.Id;
        validateKOL.Name = 'Validating KOL duplication';
        
        try {
        	insert validateKOL;
        }
        catch(DmlException e){
            System.assertNotEquals(null, e.getDmlMessage(0));
        }
        Test.stopTest();

    }
    
    /*-------------------------------------------------------------------------------------------------------
    Company: Glimt
    Description: Test method for KOLInfoTriggerHelper.setExpertName
				 Migrated from the trigger setExpertName
    History :
    --------------------------------------------------------------------------------------------------------*/
    @isTest
    private static void testSetExpertName() {
        User testUser = [SELECT Id FROM User WHERE Alias = 'test1' LIMIT 1];

        List<Account> testAccountList = TestDataFactory.returnAccounts(1, 'Non_ERP_Account', testUser.Id);
        Account testAccount = testAccountList[0];
        
        Contact testContact = new Contact();
        testContact.FirstName ='Test';
        testContact.LastName = 'Contact';
        testContact.AccountId = testAccount.Id;
        insert testContact;
        
        testContact = [SELECT Id, FirstName, LastName FROM Contact WHERE Id =: testContact.Id];
        
        Expert__c testKOL = new Expert__c();
        testKOL.Contact__c = testContact.Id;
        testKOL.Name = 'Test KOL';
        insert testKOL;
                
        Test.startTest();
        
		testKOL.Designer__c = true;
        update testKOL;
        
        Test.stopTest();
		
		testKOL = [SELECT Id, Contact__c, Name FROM Expert__c WHERE Id =: testKOL.Id];
        System.assertEquals('Test Contact - KOL info', testKOL.Name);        

    } 
    
        /*-------------------------------------------------------------------------------------------------------
    Company: Glimt
    Description: Test method for KOLInfoTriggerHelper.setNonHCProfession
    History :
    --------------------------------------------------------------------------------------------------------*/
    @isTest
    private static void testSetNonHCProfession() {
        User testUser = [SELECT Id FROM User WHERE Alias = 'test1' LIMIT 1];

        List<Account> testAccountList = TestDataFactory.returnAccounts(1, 'Non_ERP_Account', testUser.Id);
        Account testAccount = testAccountList[0];
        
        Contact testContact = new Contact();
        testContact.FirstName ='Test';
        testContact.LastName = 'Contact';
        testContact.AccountId = testAccount.Id;
        insert testContact;
        
        testContact = [SELECT Id, FirstName, LastName FROM Contact WHERE Id =: testContact.Id];
        
        Expert__c testKOL = new Expert__c();
        testKOL.Contact__c = testContact.Id;
        testKOL.Name = 'Test KOL';
        insert testKOL;
                
        Test.startTest();
        
		testKOL.Profession__c = 'Non-Healthcare Provider';
        update testKOL;
        
        Test.stopTest();
		
		testKOL = [SELECT Id, Contact__c, Profession__c, Not_a_Healthcare_Professional__c, Name FROM Expert__c WHERE Id =: testKOL.Id];
        System.assertEquals(true, testKOL.Not_a_Healthcare_Professional__c);        

    }  
    
}