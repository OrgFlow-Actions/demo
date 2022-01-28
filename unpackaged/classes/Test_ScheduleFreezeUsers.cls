/*------------------------------------------------------------
Author: 		Miguel Coimbra (20201022)
Description:   	Test Class for ScheduleFreezeUsers.
History
<Date>      <Authors Name>     <Brief Description of Change>
------------------------------------------------------------*/
@isTest(seeAllData=false)
public without sharing class Test_ScheduleFreezeUsers {
    public Test_ScheduleFreezeUsers() {}
    @isTest
    private static void testScheduler(){
        SchedulableContext sc ;
        ScheduleFreezeUsers sfu = new ScheduleFreezeUsers();
        sfu.execute(sc);
        string schedule = '0 5 1-23 * * ?';
        Test.startTest();
     		system.schedule('Process ScheduleFreeze Users', schedule, sfu);
        Test.stopTest();
    }
}