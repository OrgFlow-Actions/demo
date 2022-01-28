public class ContactCardControllerExtension {
	private final Contact contact;
	
    public Boolean bolPrintableView {get;set;}
    
    public ContactCardControllerExtension(ApexPages.StandardController stdController) {
        this.contact = (Contact)stdController.getRecord();
    }

	public void init() {
 		String strPrintableView = ApexPages.currentPage().getParameters().get('print');
 		bolPrintableView = (strPrintableView == '1');
	}    
    
 /*   public class Cfe {
		Event e;

        public Cfe(Event event) {
            e = event;
        }
        public Event getEvent() {
            return e;
        }
        public String getObjective() {
            if (e.Objective__c != null)
                return e.Objective__c;
            else
                return e.Description;
        }
    } */
   
    public List<Network__c> getNetworks() {
        List<Network__c> network = new List<Network__c>();
        
        if(contact != null) {
	        network = [select Id, Name, Description__c, Network_Type__c from Network__c where Hub_Account__c = :contact.AccountId LIMIT 5];
        }
        return network;
    }

    public List<Trackwise__c> getTrackwiseComplaints() {
        List<Trackwise__c> trackwise = new List<Trackwise__c>();
        
        if(contact != null) {
	        trackwise = [select Id, Customer_Complaint_Code__c, Created_date__c from Trackwise__c where Account__c = :contact.AccountId LIMIT 5];
        }
        return trackwise;
    }

    public List<Case> getCases() {
        List<Case> cases = new List<Case>();
        
        if(contact != null) {
	        cases = [select Id, CaseNumber, Subject, Description, Type, Status from Case where Account.Id = :contact.AccountId LIMIT 5];
        }
        return cases;
    }

    
    public List<CampaignMember> getCampaignMembers() {
        List<CampaignMember> cm = new List<CampaignMember>();
        
        if(contact != null) {
	        cm = [select Id, Name, Type, Campaign.Name, Campaign.StartDate, Campaign.Type, Status, Type__c from CampaignMember where Contact.Id =  :contact.Id and Type__c = 'Speaker' order by Campaign.StartDate DESC LIMIT 5];
        }
        return cm;
 	}

/*    public List<Cfe> getEvents() {
	    List<Cfe> cfes = new List<Cfe>{};
		String contactId = String.valueOf(contact.Id).substring(0, 15);     
        
        if(contact != null) {
            cfes.clear();
            for (Event c: [select Objective__c, Event_Status__c, Owner.Name, Description, Subject, ActivityDate from Event where Contact_Id__c = :contactId ORDER BY ActivityDate DESC LIMIT 5]) {
                	cfes.add(new Cfe(c));
            }
        }
        return cfes;
 	}

    public List<Cfe> getEvents2() {
        List<Cfe> cfes = new List<Cfe>{};

        if(contact != null) {
            for (Event c: [select Objective__c, Description, Subject from Event where Contact_Id__c = :contact.Id]) {
                	cfes.add(new Cfe(c));
            }
        }
        return cfes;
 	} */

    public List<Event> getEvents3() {
        List<Event> cfes = new List<Event>{};
            
        String contactId = String.valueOf(contact.Id).substring(0, 15);     
                
        if(contact != null) {
            cfes = [select Id, ActivityDate, Subject from Event where Contact_Id__c = :contactId ORDER BY ActivityDate DESC LIMIT 5];
        }
        return cfes;
 	}
    
    public List<Investigator__c> getInvestigator() {
        List<Investigator__c> investigators = new List<Investigator__c>();

        if(contact != null) {
            investigators = [select Account__c, Contact__r.Name, Investigator_Role__c, Research_Activity__c, Study_Status__c, Study_Type__c from Investigator__c where Contact__c = :contact.Id LIMIT 15];
        }
        return investigators;
    }
}