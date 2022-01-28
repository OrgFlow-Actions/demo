/*Version History
 * Date: 14-Nov-2018
 * Class Name: AccountChangeRequest
 * Created By: Sanjay Pandey/ Amit Prabhat
 * Related to: TFUS-000000149 : "Account Change Request" button
 * Related Test Class: AccountChangeRequestTest.cls
 */
public with Sharing class AccountChangeRequest {
    @AuraEnabled
    public static Account getAccountDetails(String accountid) {
        Account acc = [SELECT Name, BillingStreet, BillingCountry, BillingCity, BillingPostalCode, BillingState, Postal_Code_Info__c, Phone FROM Account where id =: accountid];
        return acc;
    }

    @AuraEnabled
    public static Id createRecord(Account_Create_Change_Request__c accountcreate) {
        try {
            //System.debug('Create Record@123'+accountcreate);
            if (accountcreate != null) {
                insert accountcreate;
             }
        } catch (Exception ex) {
            throw new AuraHandledException('Exception During Creating AccountCreateChangeRequest Record:');
        }
     return accountcreate.id;
    }
    @AuraEnabled
     public static List < String > getselectOptions() {
  
  
  List < String > allOpts = new list < String > ();
  // Get the object type of the SObject.
  Schema.sObjectType objType = Account_Create_Change_Request__c.getSObjectType();
 
  // Describe the SObject using its object type.
  Schema.DescribeSObjectResult objDescribe = objType.getDescribe();
 
  // Get a map of fields for the SObject
  map < String, Schema.SObjectField > fieldMap = objDescribe.fields.getMap();
 
  // Get the list of picklist values for this field.
  list < Schema.PicklistEntry > values =
   fieldMap.get('Status__C').getDescribe().getPickListValues();
 
  // Add these values to the selectoption list.
  for (Schema.PicklistEntry a: values) {
   allOpts.add(a.getValue());
  }
  system.debug('allOpts ---->' + allOpts);
  //allOpts.sort();
  return allOpts;
 }
    
}