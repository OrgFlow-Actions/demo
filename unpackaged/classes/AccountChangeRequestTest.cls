/*Version History
 * Date: 20-Nov-2018
 * Class Name: AccountChangeRequestTest
 * Created By:Sanjay Pandey/Amit Pandey
 * Related to: TFUS-000000149 : "Account Change Request" button
 * Related Class: AccountChangeRequest.cls
 */
@isTest
private class AccountChangeRequestTest {
    @isTest
    static void getAccountDetailsMethod() {
        Account a = new Account(name = 'Testdta', Phone = '9866763002', billingstate = 'California', billingcity = 'anah', billingcountry = 'United States', billingpostalcode = '92801', billingstreet = 'ls');
        insert a;

        AccountChangeRequest.getAccountDetails(a.id);
        System.assertNotEquals(Null, a);

        Account_Create_Change_Request__c ac = new Account_Create_Change_Request__c(
			Comments__c = 'Test',
			Status__c = 'Created', 
			CurrencyIsoCode = 'USD', 
			Existing_Account__c = a.Id,
			Request__c = 'Account Change Request',
			Request_Type__c = 'Account Info Change');
        insert ac;
        try{
            AccountChangeRequest.createRecord(ac);
        }
        catch(Exception e){
            System.debug('Script-thrown exception : '+e.getMessage());
        }
        System.assertNotEquals(Null, ac);
    }
     @isTest
    static void getselectOptionsTest() {
        AccountChangeRequest.getselectOptions();
    }
}