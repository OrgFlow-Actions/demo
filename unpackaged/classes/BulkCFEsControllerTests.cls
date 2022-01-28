@istest
public class BulkCFEsControllerTests  {
	public static testmethod void ViewModelIsCreatedCorrectly(){
		CreateObjects();
      
        // Instantiate a new controller with all parameters in the page
        BulkCFEsController sut = new BulkCFEsController();

        // Verify that the model has been created correctly
        System.assertEquals(4, sut.Model.RouteEntries.size());
		for(BulkCFEsController.BulkCFERouteEntry entry : sut.Model.RouteEntries){
			System.assertEquals(60, entry.VisitDuration);
		}
	}

	public static testmethod void SaveCreatesEvents(){
		CreateObjects();
      
        // Instantiate a new controller with all parameters in the page
        BulkCFEsController sut = new BulkCFEsController();
		sut.saveRecords();
	}

	private static void CreateObjects(){
		//geopointe__GP_User_Settings__c userSettings = new geopointe__GP_User_Settings__c(
															//geopointe__Default_Route_Stop_Duration__c = 29,
															//ownerid = UserInfo.getUserId()
														//);
			
		//insert userSettings;
      
		Account acc1 = CreateAccount('Account 1');
		Account acc2 = CreateAccount('Account 2');

		Contact con1 = CreateContact('Contact 1');

		Opportunity opp1 = CreateOpportunity('Opportunity 1');

        // Add parameters to page URL
        ApexPages.currentPage().getParameters().put('idArray', acc1.Id + ',' + acc2.Id + ',' + con1.Id + ',' + opp1.Id);
	}
		
	private static Account CreateAccount(string name){
        Account acc = new Account(Name = name, BillingPostalCode = '1234');

        insert acc;
        return acc;
	}
		
	private static Contact CreateContact(string name){
        Contact con = new Contact(FirstName = 'Test', LastName = 'Contact');

        insert con;
        return con;
	}
		
	private static Opportunity CreateOpportunity(string name){
        Opportunity opp = new Opportunity(Name = name, StageName = name, CloseDate = Datetime.now().date());

        insert opp;
        return opp;
	}
}