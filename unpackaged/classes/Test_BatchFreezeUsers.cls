/*------------------------------------------------------------
Author: 		Miguel Coimbra (20201022)
Description:   	Test Class for BatchFreezeUSers.
                The batch execute method cannot be covered as it's not possible to create users with a Last Login Date in the past 
                the TC class will be 90% covered if users exist with a Last Login date below the value from the MDT
                The TC Class will be 50% covered if users don't exist witha Last Login date below the value from the MDT
History
<Date>      <Authors Name>     <Brief Description of Change>
------------------------------------------------------------*/

@isTest(seeAllData=false)
public without sharing class Test_BatchFreezeUsers {
    @testSetup
    private static void setup() {
        // AdinSettings values are visible to test methods even if seeAllData is set to false.
        TestDataFactory.createBypassCustomSetting();
        List<User> userList = TestDataFactory.returnUsers(1, 'System Administrator');
        insert userList;
        TestDataFactory.createGlobalIntegrationSettings(userList);
        TestDataFactory.createDefaultOrgLevelBypassPB();

    }
    @isTest
    private static void Test_BatchFreezeUsers() {
        User testUser = [SELECT Id FROM User WHERE Alias = 'test1' LIMIT 1];
        System.runAs(testUser) {
      
            Test.startTest();
            Id batchJobId = Database.executeBatch(new BatchFreezeUsers());
            Test.stopTest();
        }

    }
}