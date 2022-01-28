/*-------------------------------------------------------------------------------------------------------
Author:         Ahmed LOUDRASSI (Salesforce) 20191113
Description:    Event Trigger Helper Class
History 
20191113    Ahmed LOUDRASSI         OrderSetAccountOwner triggers. (#)
12092019    Miguel                  Added GDW Integration User creation into the setup method
--------------------------------------------------------------------------------------------------------*/

@isTest(seeAllData=false)

public class AccountMergeRequestTrigger_Test {
    //public AccountMergeRequestTrigger_Test() {
        /*-------------------------------------------------------------------------------------------------------
    Company: Salesforce
    Description: Setup one user for the test class
    History :
    --------------------------------------------------------------------------------------------------------*/
        
    @testSetup
    private static void setup() {
        TestDataFactory.createBypassCustomSetting();
        List<User> userList = TestDataFactory.createUsers(1, 'System Administrator');
        List<User> userIntegrationList = TestDataFactory.insertIntegrationUsers(1, 'System Administrator');
        TestDataFactory.createGlobalIntegrationSettings(userIntegrationList);
    }

    @isTest
    private static void testSetup() {
        Test.startTest();
        List<User> testUserList = [SELECT Id FROM User WHERE Alias = 'test1'];
        Test.stopTest();

        System.assertEquals(1, testUserList.size(), 'Expected one user');
    }



    @isTest
    private static void testAccountMergeProcess1() {
        User testUser = [SELECT Id, Personal_Order_Account__c FROM User WHERE Alias = 'test1'];
        List<Account> accounts = TestDataFactory.returnAccounts(2, 'CIM_Account', testUser.Id);
        insert accounts;        
        
        List<String> accountsOneSFDCId = new List<String>();
        For( account acc:accounts){
            accountsOneSFDCId.add(acc.Id);
        }
        List<Account> oneSFIds = [SELECT Id, OneSF_Id__c FROM Account WHERE Id IN :accountsOneSFDCId];
        accounts[0].ParentId = accounts[1].Id;
        update accounts[0];

        List<case> caseRecord = TestDataFactory.returnCases(1, 'Service_Complaint', testUser.Id);
        caseRecord[0].AccountId = accounts[1].Id;
        insert caseRecord;

        List<Contact> contactRecord = TestDataFactory.returnContacts(2, 'ContactGlobal', testUser.Id);
        contactRecord[0].AccountId = accounts[1].Id;
        contactRecord[1].AccountId = accounts[0].Id;
        insert contactRecord;

        List<Opportunity> opportunityRecord = TestDataFactory.returnOpportunities(1, 'Account_Plan', testUser.Id);
        opportunityRecord[0].AccountId = accounts[1].Id;
        insert opportunityRecord;

        List<Event> eventRecord = TestDataFactory.returnEvents(1, testUser.Id);
        eventRecord[0].WhatId = accounts[1].Id;
        insert eventRecord;

        List<AccountContactRelation> AccountContactRelation = TestDataFactory.returnAccountContactRelationhip(1);
        AccountContactRelation[0].AccountId = accounts[0].Id;
        AccountContactRelation[0].ContactId = contactRecord[0].Id;
        insert AccountContactRelation;

        


        List<AccountMergeRequest__c> mergeRequest = TestDataFactory.returnAccountMergeRequests(1, testUser.Id);

        mergeRequest[0].Child_OneSFID__c = oneSFIds[1].OneSF_Id__c;
        mergeRequest[0].Master_OneSFID__c = oneSFIds[0].OneSF_Id__c;
        
        
        System.runAs(testUser) {
            Test.startTest();
            insert mergeRequest;
            Test.stopTest(); 
        }  
        System.assertEquals(1, [SELECT Id FROM Account LIMIT 1].size()); //one account expected after merge
    }

    @isTest
    private static void testAccountMergeProcess2() {
        User testUser = [SELECT Id, Personal_Order_Account__c FROM User WHERE Alias = 'test1'];
        List<Account> accounts = TestDataFactory.returnAccounts(2, 'CIM_Account', testUser.Id);
        insert accounts;        
        
        List<String> accountsOneSFDCId = new List<String>();
        For( account acc:accounts){
            accountsOneSFDCId.add(acc.Id);
        }
        List<Account> oneSFIds = [SELECT Id, OneSF_Id__c FROM Account WHERE Id IN :accountsOneSFDCId];
        accounts[0].ParentId = accounts[1].Id;
        update accounts[0];

        List<Contact> contactRecord = TestDataFactory.returnContacts(2, 'ContactGlobal', testUser.Id);
        contactRecord[0].AccountId = accounts[1].Id;
        contactRecord[1].AccountId = accounts[0].Id;
        insert contactRecord;

        List<AccountContactRelation> AccountContactRelation = TestDataFactory.returnAccountContactRelationhip(1);
        AccountContactRelation[0].AccountId = accounts[1].Id;
        AccountContactRelation[0].ContactId = contactRecord[1].Id;
        insert AccountContactRelation;

        List<AccountMergeRequest__c> mergeRequest = TestDataFactory.returnAccountMergeRequests(1, testUser.Id);
        mergeRequest[0].Child_OneSFID__c = oneSFIds[1].OneSF_Id__c;
        mergeRequest[0].Master_OneSFID__c = oneSFIds[0].OneSF_Id__c;
        
        
        System.runAs(testUser) {
            Test.startTest();
            insert mergeRequest;
            Test.stopTest(); 
        }  
        System.assertEquals(1, [SELECT Id FROM Account LIMIT 1].size()); //one account expected after merge
    }

    @isTest
    private static void testAccountMergeProcess3() {
        User testUser = [SELECT Id, Personal_Order_Account__c FROM User WHERE Alias = 'test1'];
        List<Account> accounts = TestDataFactory.returnAccounts(3, 'CIM_Account', testUser.Id);
        insert accounts;        
        
        List<String> accountsOneSFDCId = new List<String>();
        For( account acc:accounts){
            accountsOneSFDCId.add(acc.Id);
        }
        List<Account> oneSFIds = [SELECT Id, OneSF_Id__c FROM Account WHERE Id IN :accountsOneSFDCId];
        
        List<AccountMergeRequest__c> mergeRequest = TestDataFactory.returnAccountMergeRequests(1, testUser.Id);
        mergeRequest[0].Child_OneSFID__c = oneSFIds[1].OneSF_Id__c;
        mergeRequest[0].Master_OneSFID__c = oneSFIds[0].OneSF_Id__c;
        insert mergeRequest;
        mergeRequest[0].Child_OneSFID__c = oneSFIds[2].OneSF_Id__c;
        
        System.runAs(testUser) {
            Test.startTest();
            update (mergeRequest);
            Test.stopTest(); 
        }  
        System.assertEquals(1, [SELECT Id FROM Account LIMIT 1].size()); //one account expected after merge
    }
    
    @isTest
    private static void testAccountMergeProcess4() {
        User testUser = [SELECT Id, Personal_Order_Account__c FROM User WHERE Alias = 'test1'];
        List<AccountMergeRequest__c> mergeRequest = TestDataFactory.returnAccountMergeRequests(150, testUser.Id);
        try{
            insert mergeRequest ;
        }
        catch(DmlException ex){
            System.assert(ex.getMessage().contains('Cannot process merge request because the batch size is too large.'));
            return;
        }
        System.assert(false); // If we've got this far then the test has failed
    }
}