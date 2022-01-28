@isTest
public class Test_SC_AutoRefresh {
    @testSetup
    private static void setup() {
        TestDataFactory.createBypassCustomSetting();
        List<User> userList = TestDataFactory.createUsers(1, 'System Administrator');
        List<User> userIntegrationList = TestDataFactory.insertIntegrationUsers(1, 'System Administrator');
        TestDataFactory.createGlobalIntegrationSettings(userIntegrationList);
    }
    @isTest 
    static void getUserPermissionTest(){
        Test.startTest();
		    Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
            User u = new User(Alias = 'standt', Email='user@avity.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='user@avity.com',
			Service_Cloud_Special_Permissions__c='Send Survey');
        
        	Profile p2 = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        	User u2 = new User(Alias = 'standt2', Email='user2@avity.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p2.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='user2@avity.com',
			Service_Cloud_Special_Permissions__c='Enable Auto Refresh Automatically');
        
            System.runAs(u) {
            // The following code runs as user 'u' 
            System.debug('Current User: ' + UserInfo.getUserName());
            System.debug('Current Profile: ' + UserInfo.getProfileId()); 
			SC_AutoRefresh.getUserPermission();
        }
        
           System.runAs(u2) {
            // The following code runs as user 'u' 
            System.debug('Current User: ' + UserInfo.getUserName());
            System.debug('Current Profile: ' + UserInfo.getProfileId()); 
			SC_AutoRefresh.getUserPermission();
        }
		Test.stopTest();
        
}
}