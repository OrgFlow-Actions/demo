@isTest
private class OrderSetAccountOwnerTest
{
    // Tests the trigger in insert mode (account owner with manager).
    static testmethod void insertTest01()
    {
        User owner = [SELECT Id, ManagerId FROM User WHERE ManagerId = NULL AND IsActive = TRUE AND User.Profile.UserLicense.Name != 'Chatter Free' LIMIT 1];

        Account testAccount = createTestAccount(owner.Id);
        Order testOrder = createTestOrder(testAccount.Id);

        testOrder = [SELECT Id, Account_Owner__c, Regional_Manager__c FROM Order WHERE Id = :testOrder.Id LIMIT 1];
        //System.assertEquals(owner.Id, testOrder.Account_Owner__c);
        System.assertEquals(owner.ManagerId, testOrder.Regional_Manager__c);
    }

    // Tests the trigger in insert mode (account owner without manager).
    static testmethod void insertTest02()
    {
        User owner = [SELECT Id, ManagerId FROM User WHERE ManagerId = NULL AND IsActive = TRUE AND User.Profile.UserLicense.Name != 'Chatter Free' LIMIT 1];

        Account testAccount = createTestAccount(owner.Id);
        Order testOrder = createTestOrder(testAccount.Id);

        testOrder = [SELECT Id, Account_Owner__c, Regional_Manager__c FROM Order WHERE Id = :testOrder.Id LIMIT 1];
        //System.assertEquals(owner.Id, testOrder.Account_Owner__c);
        System.assertEquals(null, testOrder.Regional_Manager__c);
    }   

    static Account createTestAccount(ID ownerId)
    {
        Account testAccount = new Account();
        testAccount.Country__c = 'SE';
        testAccount.Name = 'OrderSetAccountOwner_TestAccount';
        if (ownerId != null)
            testAccount.OwnerId = ownerId;
        insert testAccount;
        return testAccount;
    }

    static Order createTestOrder(ID accountId)
    {
        Order testOrder = new Order();
        testOrder.AccountId = accountId;
        testOrder.Status = 'Created';
        testOrder.EffectiveDate = Date.today();
        insert testOrder;
        return testOrder;
    }       
}