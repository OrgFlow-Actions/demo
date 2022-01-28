@isTest
public class DC_UT_AccountUpdateBatch {
	
    private static Account acc;
    private static Postal_Codes__c postalCodes;
    
    private static void beforeTest() {
		acc = DC_UT_TestUtils.createAccount();
        postalCodes = DC_UT_TestUtils.createPostalCodes();
    }
    
    private static testMethod void initAccountPostalCodeInfo() {
		beforeTest();
        postalCodes.DC_ETM_Code__c = 'ETM';
        update postalCodes;
        
        DC_AccountUpdateBatch accUpdateBatch = new DC_AccountUpdateBatch(new Id[] { postalCodes.Id });
        System.Test.startTest();
        Database.executeBatch(accUpdateBatch);
        system.Test.stopTest();
        
        Account updatedAccount = [select Postal_Code_Info__c, DC_ETM_Code__c from Account where Id =: acc.Id];
        system.assertEquals(postalCodes.Id, updatedAccount.Postal_Code_Info__c);
        system.assertEquals(postalCodes.DC_ETM_Code__c, updatedAccount.DC_ETM_Code__c);
        
    }
    
    private static testMethod void updateAccountETMandPostalCodeInfo() {
        beforeTest();
        
        acc.Postal_Code_Info__c = postalCodes.Id;
        update acc;
        
        postalCodes.DC_ETM_Code__c = 'ETM';
        update postalCodes;
        
        DC_AccountUpdateBatch accUpdateBatch = new DC_AccountUpdateBatch(new Id[] { postalCodes.Id });
        System.Test.startTest();
        Database.executeBatch(accUpdateBatch);
        system.Test.stopTest();
        
        Account updatedAccount = [select Postal_Code_Info__c, DC_ETM_Code__c from Account where Id =: acc.Id];
        system.assertEquals(postalCodes.Id, updatedAccount.Postal_Code_Info__c);
        system.assertEquals(postalCodes.DC_ETM_Code__c, updatedAccount.DC_ETM_Code__c);
	}
    
    private static testMethod void updateAccountETMCode() {
        beforeTest();
        postalCodes.DC_ETM_Code__c = postalCodes.Name;
        update postalCodes;
        
        acc.Postal_Code_Info__c = postalCodes.Id;
        acc.BillingPostalCode = postalCodes.Name;
        update acc;
        
        DC_AccountUpdateBatch accUpdateBatch = new DC_AccountUpdateBatch(new Id[] { postalCodes.Id });
        System.Test.startTest();
        Database.executeBatch(accUpdateBatch);
        system.Test.stopTest();
        
        Account updatedAccount = [select Postal_Code_Info__c, DC_ETM_Code__c from Account where Id =: acc.Id];
        system.assertEquals(postalCodes.Id, updatedAccount.Postal_Code_Info__c);
        system.assertEquals(postalCodes.DC_ETM_Code__c, updatedAccount.DC_ETM_Code__c);

    }
    
}