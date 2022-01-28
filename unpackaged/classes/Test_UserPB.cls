/*------------------------------------------------------------
Author: 		Ahmed LOUDRASSI (Salesforce) 2019-11-26
Description:   	Test Class for the User Process Builder.
History
<Date>      <Authors Name>     <Brief Description of Change>

------------------------------------------------------------*/

@isTest(seeAllData=false)
public class Test_UserPB {
	/*-------------------------------------------------------------------------------------------------------
    Company: Salesforce
    Description: Setup one user for the test class
    History :
    --------------------------------------------------------------------------------------------------------*/
    @testSetup
    private static void setup() {
        TestDataFactory.createBypassCustomSetting();
    }
    @isTest
    private static void testInconsistentSBUFields() {
        system.runAs(new User(Id = Userinfo.getUserId())) {
        	List<User> userList1 = TestDataFactory.returnUsers(1, 'System Administrator');
            userList1.get(0).SBU_Ratio_IMPL__c = 20;
            userList1.get(0).Implants_User__c = False;
            Test.startTest();
            insert userList1;
            Test.stopTest();
            System.assertEquals(true, [SELECT Id,Implants_User__c FROM User WHERE Alias = 'test1'].Implants_User__c);
        }       
    }
    @isTest
    private static void testInconsistentSBUFields2() {
        system.runAs(new User(Id = Userinfo.getUserId())) {
        	List<User> userList1 = TestDataFactory.returnUsers(1, 'System Administrator');
            userList1.get(0).SBU_Ratio_IMPL__c = 0;
            userList1.get(0).Implants_User__c = False;
            Test.startTest();
            insert userList1;
            Test.stopTest();
            System.assertEquals(false, [SELECT Id,Implants_User__c FROM User WHERE Alias = 'test1'].Implants_User__c);
        }       
    }
}