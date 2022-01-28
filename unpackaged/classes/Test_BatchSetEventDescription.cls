/**
 * @description       : test class for BatchSetEventDescription
 * @author            : kdoruibin@salesforce.com
 * @group             : 
 * @last modified on  : 05-10-2021
 * @last modified by  : kdoruibin@salesforce.com
 * Modifications Log 
 * Ver   Date         Author                     Modification
 * 1.0   05-10-2021   kdoruibin@salesforce.com   Initial Version
**/
@IsTest
public class Test_BatchSetEventDescription {
    
    @TestSetup
    static void makeData(){
        TestDataFactory.createBypassCustomSetting();
        List<User> userList = TestDataFactory.createUsers(1, 'System Administrator');
        List<User> userIntegrationList = TestDataFactory.insertIntegrationUsers(1, 'System Administrator');
        TestDataFactory.createGlobalIntegrationSettings(userIntegrationList);
        List<Event> testEventList = TestDataFactory.returnEvents(2, userList.get(0).Id);
        for (Event testEvent : testEventList) {
            testEvent.Customer_Facing_Event__c = true;
        }
        insert testEventList;
    }

    @IsTest
    private static void testBatchSetEventDescription() {
        GlobalBypassProcessesSettings__c existingbypassSettings = [Select Id from GlobalBypassProcessesSettings__c LIMIT 1];
        existingbypassSettings.RunTriggers__c = false;
        existingbypassSettings.RunProcessBuilder__c = false;
        update existingbypassSettings;
        
        User testUser = [SELECT Id FROM User WHERE Alias = 'test1' LIMIT 1];
        for (List<Call_Report__c> callReportList : [SELECT Id, Call_Notes__c FROM Call_Report__c]) {
            for (Call_Report__c callReport : callReportList) {
                callReport.Call_Notes__c = 'Test123';
            }
            update callReportList;
        }

        Test.startTest();
        BatchSetEventDescription batchJob = new BatchSetEventDescription(String.valueOf(System.today().year()));
        Database.executeBatch(batchJob);
        Test.stopTest();

        for (Event eventToTest : [SELECT Description, Call_Report__r.Call_Notes__c FROM Event WHERE CreatedByid = :testUser.Id]) {
            System.assertEquals(eventToTest.Call_Report__r.Call_Notes__c, eventToTest.Description);
        }
    }
}