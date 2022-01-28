@IsTest
public class DC_UT_ActivityService {
    
    private static testMethod void accountNotFoundTest() {
        DC_ActivityService.getActivitiesByAccountId(null);
    }
	
    private static testMethod void getActivitiesByAccountIdTest() {
		Account acc = DC_UT_TestUtils.createAccount();
    	
        Event e = new Event();
        e.WhatId = acc.Id;
        e.DurationInMinutes = 10;
        e.ActivityDateTime = Datetime.now();
        e.SBU__c = 'Endodontics';
        insert e;
        
        DC_ActivityService.getActivitiesByAccountId(acc.Id);
    }
}