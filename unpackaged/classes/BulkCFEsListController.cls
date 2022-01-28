public with sharing class BulkCFEsListController
{
	private Map<Id, SObject> SelectedObjects { get; set; }
	boolean isNonIndianAccExist = false;
    public BulkCFEsListController(ApexPages.StandardSetController controller)
    {
        SelectedObjects = new Map<Id, SObject>(controller.getSelected());
    }

	public PageReference Redirect(){
        List<Id> selectedIds = new List<Id>(SelectedObjects.keySet());
        List<Account> accountList = [SELECT Id,Country__c FROM Account where Id IN: selectedIds];
        for(Account acc: accountList)
        {
            if(acc.Country__c != 'IN'){
                isNonIndianAccExist = true;
            }
        }
        if(isNonIndianAccExist) {   
        	ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,Label.BulkCFEs_Error_for_non_IN_Acc ));
            return null;
        }else{   
		string idArray = String.join(selectedIds, ',');
		PageReference redirectPage = new PageReference('/apex/BulkCFEs?idArray=' + idArray);
		redirectPage.setRedirect(true);
 		
		return redirectPage;
       }
	}
}