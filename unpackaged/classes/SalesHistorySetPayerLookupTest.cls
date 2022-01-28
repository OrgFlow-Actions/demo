@isTest
private class SalesHistorySetPayerLookupTest
{ 
    // Tests the trigger in insert mode.
    static testmethod void insertTest01()
    {
        Account testAccount1 = createTestAccount('XX12345');
        insert testAccount1;
        
        // Test an record with a valid and existing Payer_Movex_D_JP__c value.
        Sales_History__c testHistory1 = createTestHistory(testAccount1, testAccount1.Movex__c);
        
        // Test an record with a non-existing Payer_Movex_D_JP__c value.
        Sales_History__c testHistory2 = createTestHistory(testAccount1, 'XX67890');
  
        // Test an record with no Payer_Movex_D_JP__c value.
        Sales_History__c testHistory3 = createTestHistory(testAccount1, null);
                
        List<Sales_History__c> recordsToInsert = new List<Sales_History__c>();
        recordsToInsert.add(testHistory1);
        recordsToInsert.add(testHistory2);      
        recordsToInsert.add(testHistory3);   
        
        insert recordsToInsert;        
        
        testHistory1 = [SELECT Id, Payer_Lookup__c FROM Sales_History__c WHERE Id = :testHistory1.Id LIMIT 1];
        testHistory2 = [SELECT Id, Payer_Lookup__c FROM Sales_History__c WHERE Id = :testHistory2.Id LIMIT 1];
        testHistory3 = [SELECT Id, Payer_Lookup__c FROM Sales_History__c WHERE Id = :testHistory3.Id LIMIT 1];
        
        System.assertEquals(testAccount1.Id, testHistory1.Payer_Lookup__c);
        System.assertEquals(null, testHistory2.Payer_Lookup__c);
        System.assertEquals(null, testHistory3.Payer_Lookup__c);
    }
    
    static Account createTestAccount(String movex)
    {
        Account testAccount = new Account();
        testAccount.Country__c = 'SE';
        testAccount.Name = 'TotalSales_TestAccount';
        testAccount.Movex__c = movex;
        
        return testAccount;
    }
    
    static Sales_History__c createTestHistory(Account testAccount, string payerMovex)
    {
        Sales_History__c testHistory = new Sales_History__c();
        testHistory.Account__c = testAccount.Id;
        testHistory.Name = '12345';
        testHistory.Invoice_Date__c = Datetime.now().date();
        testHistory.Quantity__c = 5;
        testHistory.Price__c = 10;   
        testHistory.CurrencyIsoCode = 'SEK';
        testHistory.Payer_Movex_D_JP__c = payerMovex;
        
        return testHistory;
    }     
}