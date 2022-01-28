@isTest
public class ViewAllActivityHistoryTest {
    static testMethod void test() {
        Account account = new Account();

        account.Name = 'Test';
        insert account;
        
        ApexPages.StandardController ctrl = new ApexPages.StandardController(account);        
        ActivityHistoryControllerExtension ctrlExt = new ActivityHistoryControllerExtension(ctrl);
        Test.startTest();
        List<ActivityHistory> act = new List<ActivityHistory>();
        act = ctrlExt.getActivityHistory();
        ctrlExt.doCancel();
        ctrlExt.showMyActivities();
        Test.stopTest();
        System.assertNotEquals(null, act);
    }
}