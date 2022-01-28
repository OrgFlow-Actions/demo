@isTest
public class scheduledIntegrationProgressTest {
    public static testMethod void test()
    {
        Test.StartTest();
        
        scheduledIntegrationProgress sh1 = new scheduledIntegrationProgress();
    
        String sch = '0 0 23 * * ?'; 
        system.schedule('TestIntegrationProgressCreateRecord', sch, sh1); 
    
        Test.stopTest(); 
    }
}