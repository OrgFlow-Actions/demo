@IsTest
public without sharing class Test_Flow_CheckObjectAccess {
    @TestSetup
    static void makeData(){
        TestDataFactory.createBypassCustomSetting();
        List<User> userList = TestDataFactory.returnUsers(1, 'System Administrator');
        userList[0].User_Country__c = 'Canada';
        insert userList;
        TestDataFactory.createGlobalIntegrationSettings(userList);
        TestDataFactory.createDefaultOrgLevelBypassPB();
    }

    @IsTest
    public static void testCheckObjectAccess() {
        User testUser = [SELECT Id FROM User WHERE Alias = 'test1' LIMIT 1];
        String testObject = 'Contact';
        Schema.DescribeSObjectResult describeResult = Schema.describeSObjects(new List<String>{testObject})[0];
        
        Test.startTest();
        List<Flow_CheckObjectAccess.ObjectAccessResult> accessResultList = Flow_CheckObjectAccess.checkObjectAccess(new List<String>{testObject});
        Test.stopTest();

        System.assertEquals(describeResult.isAccessible(), accessResultList[0].accessible);
        System.assertEquals(describeResult.isCreateable(), accessResultList[0].creatable);
        System.assertEquals(describeResult.isDeletable(), accessResultList[0].deletable);
    }
}