/*------------------------------------------------------------
Author:     Richard Trum - Glimt (2020-09-24)
Description:     Test Class for the Contact Process Builder.
History
<Date>      <Authors Name>     <Brief Description of Change>

------------------------------------------------------------*/

@isTest(seeAllData=false)
public class Test_ContactPB {

    @testSetup
    private static void setup() {
        TestDataFactory.createBypassCustomSetting();
        List<User> userList = TestDataFactory.createUsers(1, 'System Administrator');
        List<User> userIntegrationList = TestDataFactory.insertIntegrationUsers(1, 'System Administrator');
        TestDataFactory.createGlobalIntegrationSettings(userIntegrationList);
    }
}