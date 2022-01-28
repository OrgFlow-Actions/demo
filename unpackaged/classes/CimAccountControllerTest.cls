@isTest
public class CimAccountControllerTest {
   static testMethod void test() {

	ApexPages.currentPage().getParameters().put('NAME','TestAccount');
    //ApexPages.currentPage().getParameters().put('CIMID','12345');

    ApexPages.currentPage().getParameters().put('FAX','112233');
    ApexPages.currentPage().getParameters().put('PHONE','445566');
        
    ApexPages.currentPage().getParameters().put('BILLINGSTREET','Bstreet');
    ApexPages.currentPage().getParameters().put('BILLINGZIPCODE','Bzipcode');
    ApexPages.currentPage().getParameters().put('BILLINGCITY','Bcity');
    ApexPages.currentPage().getParameters().put('BILLINGSTATE','bstate');
    ApexPages.currentPage().getParameters().put('BILLINGCOUNTRY','Bcountry');
        
    ApexPages.currentPage().getParameters().put('VISITINGSTREET','Vstreet');
    ApexPages.currentPage().getParameters().put('VISITINGCITY','Vcity');
    ApexPages.currentPage().getParameters().put('VISITINGZIPCODE','Vzipcode');
    ApexPages.currentPage().getParameters().put('VISITINGSTATE','Vstate');
    ApexPages.currentPage().getParameters().put('VISITINGCOUNTRY','Vcountry');

    ApexPages.currentPage().getParameters().put('COUNTRY','US');
    ApexPages.currentPage().getParameters().put('ACCOUNTTYPE','Zip/Postal Code');

    Test.startTest();
    CimAccountController ctrl = new CimAccountController();
	
       try {
           ctrl.Save();
       } catch (DmlException e) {
           system.debug(e);
       }
	

    Test.stopTest();
    }
    
    private static List<String> getPickListValuesIntoList(){
       List<String> pickListValuesList= new List<String>();
		Schema.DescribeFieldResult fieldResult = Account.OneAccount_Type__c.getDescribe();
		List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
		for( Schema.PicklistEntry pickListVal : ple){
			pickListValuesList.add(pickListVal.getLabel());
		}     
		return pickListValuesList;
    }
}