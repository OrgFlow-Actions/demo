/*------------------------------------------------------------
Author: 		Kevin Do (Salesforce) 2020-03-10
Description:   	Test Class for all BatchSetAccountSubSegmentation.
History
<Date>      <Authors Name>     <Brief Description of Change>
20200310 	Kevin Do			Created Class (#TFUS-000001698)
------------------------------------------------------------*/

@isTest(seeAllData=false)
public class Test_BatchSetAccountSubSegmentation {
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
        List<Account> accountList = TestDataFactory.returnAccounts(200, 'Non_ERP_Account', userList[0].Id);
        for (Account accountRecord : accountList) {
            accountRecord.Name = 'INSERT ' + accountRecord.Name;
            accountRecord.Country__c = 'NL';
        }
        insert accountList;
    }

    @isTest
    private static void testSetup() {
        System.assertEquals(200, [SELECT Count() FROM Account WHERE Name LIKE 'INSERT%']);
    }

    /*-------------------------------------------------------------------------------------------------------
    Company: Salesforce
    Description: Assert that 200 records were updated via apex batch job
    History :
    --------------------------------------------------------------------------------------------------------*/
    @isTest
    private static void testBatchSetAccountSubSegmentation() {
        Datetime prevLastModifiedDate = [SELECT LastModifiedDate FROM Account ORDER BY LastModifiedDate LIMIT 1].LastModifiedDate;
        
        Test.startTest();
        BatchSetAccountSubSegmentation batchJob = new BatchSetAccountSubSegmentation('NL');
        Database.executeBatch(batchJob);
        Test.stopTest();

        System.assertEquals(200, [SELECT Count() FROM Account WHERE LastModifiedDate > :prevLastModifiedDate]);
    }
}