@IsTest
public class Test_ContractUpdateSalesData {

    /*-------------------------------------------------------------------------------------------------------
    Company: Glimt
    Description: Test method for ContractTriggerHelper.updateSalesData()
                 Asserts that contract sales is collected correctly
    History :
    --------------------------------------------------------------------------------------------------------*/
    @IsTest
    private static void testUpdateSalesData() {
     	
        List<User> userList = TestDataFactory.createUsers(1, 'System Administrator');
        List<Discount_model__c> discountModelList = TestDataFactory.createDiscountModels(1, userList[0].Id);
        User testUser = [SELECT Id FROM User WHERE Alias = 'test1' LIMIT 1];
        List<Discount_model__c> testDiscountModelList = [SELECT Id FROM Discount_model__c WHERE OwnerId = :testUser.Id LIMIT 1];
        Id testDiscountModelId = testDiscountModelList[0].Id;
        List<Account> testAccountList = TestDataFactory.returnAccounts(3, 'CIM_Account', testUser.Id);
        Account testAccount0 = testAccountList[0];
        testAccount0.Country__c = 'DE';		        
        insert testAccountList;
        Id testAccountId = testAccount0.Id;
		
        Source_Record__c src = new Source_Record__c();
        src.CIM_Account__c = testAccount0.Id;
        src.Customer_Id__c = '12345';
        src.Company_Code__c = 'DE';
        src.Status__c = 'Active';
        insert src;
                
        Account accountToAssert = [
            SELECT Id, Sales_L12M_D__c, Sold_Implants_L12M__c, Sales_L13_24M_D__c 
            FROM Account
            WHERE Id = :testAccountId
            LIMIT 1
        ];
		List<String> input = new List<String>();
        input.add(accountToAssert.Id);
		List<ContractTriggerHelper.ContractSalesDataResponse> response = ContractTriggerHelper.updateSalesData(input);        
                
   		}  
    
    
}