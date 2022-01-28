@IsTest
private class LightningAccountControllerTest {

    @IsTest
    private static void test_getAccountInfo() {
        
        Account account1 = DC_UT_DataUtils.generateAccount('Account1');
        insert account1;
        
        Contact contact1 = new Contact();
        contact1.AccountId = account1.Id;
        contact1.FirstName = 'Test';
        contact1.LastName = 'Testsson';
        insert contact1;
        
        String accountIdx = account1.Id;
        
        Account result = LightningAccountController.getAccountInfo(accountIdx);
        
        System.AssertEquals(result.Id, accountIdx);
        
        String saveResult = LightningAccountController.saveAccount(accountIdx, '10');
        
        List<Contact> conresult = LightningAccountController.getContacts(accountIdx);        
        
        System.AssertEquals(1, conresult.size());
        
    }
     
    @IsTest
    private static void test_UserClasses() {
                
        Boolean result = LightningAccountController.getUserAccess('Account_CFE_Summary');

        User SBUser = LightningAccountController.getUserSBUAccess('Account_CFE_Summary');
        
        User newUsr = LightningAccountController.getUserInfo(SBUser.Id);
        
        String userResult = LightningAccountController.saveUser(SBUser);
        
        List<SObject> TSres = LightningAccountController.getTeamSetup();
        
    }
    
    
}