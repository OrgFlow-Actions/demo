/*------------------------------------------------------------
Author:         Roberto Narbona
Description:    Test Class for all ContactTriggerHelper methods.
History
<Date>      <Authors Name>      <Brief Description of Change>
20200401    Roberto Narbona     New tests mwthod to cover ContactTriggerHelper.showNoDeleteError TFUS-000002832
------------------------------------------------------------*/

@isTest(seeAllData=false)
public class ContactTriggerTest {

    /*-------------------------------------------------------------------------------------------------------
    Company: 
    Description: Setup one user for the test class
    History : TFUS-000002832
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



    /*-------------------------------------------------------------------------------------------------------
    Company: 
    Description: Test method for ContactTriggerHelper.showNoDeleteError
    History : TFUS-000002832
    --------------------------------------------------------------------------------------------------------*/
    
    @isTest
    private static void testNoDeleteKOLError() {
        User testUser = [SELECT Id FROM User WHERE Alias = 'test1' LIMIT 1];
        List<Account> testAccountList = TestDataFactory.createAccounts(1, 'Non_ERP_Account', testUser.Id);
        List<Contact> testContactList = TestDataFactory.returnContacts(202, 'ContactGlobal', testUser.Id);
        for(Integer i = 0; i <=  testContactList.size()-1; i++){
            testContactList[i].AccountId = testAccountList[0].Id;
            testContactList[i].Country__c = 'IE';
        }
        insert testContactList;
        system.debug(testContactList);
        List<Expert__c> testKOLList = TestDataFactory.createExperts(1, testContactList);
        System.runAs(testUser) {
            Test.startTest();
               try{
                    delete testContactList;
                }catch(DMLexception e){
                    system.assert(e.getMessage().contains(Label.KOLDeleteError),Label.KOLDeleteError);                       
                }
            Test.stopTest(); 
        }  
    }

    /*-------------------------------------------------------------------------------------------------------
    Company: 
    Description: Test method for ContactTriggerHelper.
    History : 
    --------------------------------------------------------------------------------------------------------*/
    @isTest
    private static void setValuesbeforeInsert() {
        User testUser = [SELECT Id FROM User WHERE Alias = 'test1' LIMIT 1];
        List<Account> testAccountList = TestDataFactory.returnAccounts(3, 'Non_ERP_Account', testUser.Id);
        testAccountList[0].Country__c = 'US';
        testAccountList[1].Country__c = 'BR';
        insert testAccountList;
        List<Contact> testContactList = TestDataFactory.returnContacts(202, 'ContactGlobal', testUser.Id);
        for(Integer i = 0; i <=  testContactList.size()-1; i++){
            testContactList[i].AccountId = testAccountList[0].Id;
            //testContactList[i].Country__c = 'IE';
        }
        testContactList[1].AccountId = testAccountList[1].Id;
        testContactList[2].Inactive__c = true;
        testContactList[3].Email = 'test@test.is';
        testContactList[3].InsertEmailMarketingConsentCollected__c = 'Yes';
        System.runAs(testUser) {
            Test.startTest();
                insert testContactList;
                system.debug(testAccountList[0].Country__c);
                system.debug(testContactList[0].Country__c);
                system.debug(testContactList[0].Account.Country__c);
                //system.assert( testContactList[0].country__c,'Ireland');
            Test.stopTest(); 
        }  
    }

    @isTest
    private static void setValuesbeforeUpdate() {
        User testUser = [SELECT Id FROM User WHERE Alias = 'test1' LIMIT 1];
        List<Account> testAccountList = TestDataFactory.returnAccounts(3, 'Non_ERP_Account', testUser.Id);
        testAccountList[0].Country__c = 'US';
        testAccountList[1].Country__c = 'BR';
        insert testAccountList;
        List<Contact> testContactList = TestDataFactory.returnContacts(202, 'ContactGlobal', testUser.Id);
        for(Integer i = 0; i <=  testContactList.size()-1; i++){
            testContactList[i].AccountId = testAccountList[0].Id;
            //testContactList[i].Country__c = 'IE';
        }
        testContactList[1].AccountId = testAccountList[1].Id;
        testContactList[2].Inactive__c = true;
        testContactList[3].Email = 'test@test.is';
        testContactList[3].InsertEmailMarketingConsentCollected__c = 'Yes';
        insert testContactList;
        testContactList[3].Email = null;
        testContactList[3].HasOptedOutOfEmail = false;
        testContactList[4].Email = 'test@test.is';
        testContactList[4].InsertEmailMarketingConsentCollected__c = 'Yes';
        System.runAs(testUser) {
            Test.startTest();
                update testContactList;
                system.debug(testAccountList[0].Country__c);
                system.debug(testContactList[0].Country__c);
                system.debug(testContactList[0].Account.Country__c);
                //system.assert( testContactList[0].country__c,'Ireland');
            Test.stopTest(); 
        }  
    }
}