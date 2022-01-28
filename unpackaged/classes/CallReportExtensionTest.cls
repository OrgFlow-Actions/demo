/**
 * @description       : Updated the test class with system.runAs()
 * @author            : kdoruibin@salesforce.com
 * @group             : 
 * @last modified on  : 09-09-2021
 * @last modified by  : kdoruibin@salesforce.com
**/
@isTest
public class CallReportExtensionTest {

    @TestSetup
    static void makeData(){
        TestDataFactory.createBypassCustomSetting();
        List<User> userList = TestDataFactory.createUsers(1, 'System Administrator');
        List<User> userIntegrationList = TestDataFactory.insertIntegrationUsers(1, 'System Administrator');
        TestDataFactory.createGlobalIntegrationSettings(userIntegrationList);
        TestDataFactory.createEvents(1, userList.get(0).Id); 
    }

    static testMethod void CallReportExtension() {
        User testUser = [SELECT Id FROM User WHERE Alias = 'test1' LIMIT 1];

        System.runAs(testUser) {
            Account acc = new Account(Name = 'test');
            insert acc;
            Event ev = new Event(DurationInMinutes=5,subject='test',ActivityDate=date.today(), ActivityDateTime=datetime.now(),SBU__c='Preventive',Customer_Facing_Event__c=true, Event_Status__c='Completed',Whatid=acc.Id);
            Call_Report__c callreport = new Call_Report__c(Call_Notes__c='test',Met_with_Decision_Maker__c= true, Met_with_Assistant__c= true);
            insert callreport;
            ev.Call_Report__c = callreport.Id;
            insert ev;
            Test.StartTest();
            PageReference pageRef = Page.CallReport;
            pageRef.getparameters().put('id', ev.id);  
            Test.setCurrentPage(pageRef);
            CallReportExtension  testev = new CallReportExtension(new ApexPages.StandardController(ev));
            Test.StopTest();
        }
    }
}