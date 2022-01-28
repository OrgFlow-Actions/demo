public with sharing class getPreferredDealers {

public getPreferredDealers(ApexPages.StandardSetController stdController) {
}

public List<Preferred_dealer_item__c> cust {get;set;}
public List<Account> dealers {get;set;}
public Preferred_dealer_item__c prfd {get; set;}
public List<Preferred_dealer_item__c> prfdList {get; set;}
public Account acc {get; set;}
public List<cDealer> pdeList {get; set;}
public List<cAccount> dealerList {get; set;}
public cDealer dealTest {get; set;}
public cAccount dealTest2 {get; set;}
Public String getRadioValue{get;set;}

public void fetchRecords(){
//prfd = [Select Id, Name, Account__c FROM Preferred_dealer_item__c WHERE Id =: ApexPages.currentPage().getParameters().get('id')];
acc = [Select Id, Name, Country__c FROM Account WHERE Id =: ApexPages.currentPage().getParameters().get('id')];
cust = [Select Id, Name, Account__r.Id, Dealer__c, Dealer__r.Name, Default_dealer__c FROM Preferred_dealer_item__c WHERE Account__r.Id=: acc.Id ORDER BY Dealer__r.Name ASC];

dealers = [Select Id, Name FROM Account WHERE (((RecordTypeId=:'01220000000ckje') OR (RecordTypeId=:'01220000000ckja') OR (RecordTypeId=:'0120J000000cmd3')) AND (Country__c =: acc.Country__c)) ORDER BY Name ASC];
this.createPdeList();
this.createDealerList();

if (cust.size() > 0) {
prfdList = [Select Id FROM Preferred_dealer_item__c WHERE (Default_dealer__c =: true AND Account__c =: acc.id)];

if (prfdList.size() > 0) {
prfd = prfdList[0];
getRadioValue = prfdList[0].Id;
}
}

}

public void createPdeList() {
    
    pdeList = new List<cDealer> ();
        
    for(Preferred_dealer_item__c pdTest: cust) {
        dealTest = new cDealer(pdTest);
        If (dealTest.pde!=null) {
        pdeList.add(dealTest);
        }
    }
    
    }
        
public void createDealerList() {
    
dealerList = new List<cAccount>();
Boolean checkDealer = false;
Integer ind = 0;        
    
    for(Account pdTest: dealers) {
        dealTest2 = new cAccount(pdTest);
        If (dealTest2.pde!=null) {
        dealerList.add(dealTest2);
        
        for (Preferred_dealer_item__c pdTest2 : cust) {
        If (pdTest2.Dealer__r.Id == pdTest.Id){
        dealerList.remove(ind);
        ind = ind-1;
        }
        }
        
        ind=ind+1;
        
        }        
    }
    }
    

public void addDealer() {

for(cAccount dealerSelect: dealerList) {

if (dealerSelect.selected_pd == true) {
Preferred_dealer_item__c newDealer = new Preferred_dealer_item__c();
newDealer.Account__c = acc.Id;
newDealer.Dealer__c = dealerSelect.pde.Id;
If (cust.size()>0){
newDealer.Default_dealer__c = false;
} else {
newDealer.Default_dealer__c = true;
}
insert newDealer;
this.fetchRecords();
}

}

}

public Integer DealerNo {get; set;}

public void saveDealer() {
DealerNo = 0;

for(cDealer dealerSelect: pdeList) {

If (dealerSelect.pde.id == getRadioValue){
dealerSelect.pde.Default_dealer__c = true;
update dealerSelect.pde;
//DealerNo = DealerNo +1;
}
else{
dealerSelect.pde.Default_dealer__c = false;
update dealerSelect.pde;
}
}

/*If (DealerNo < 2) {
for(cDealer dealerSelect: pdeList) {
update dealerSelect.pde;
}
}*/

}

public List<SelectOption> getDealerOptions() {

List<SelectOption> options = new List<SelectOption>();

for (cDealer dealerSelect : pdeList) {
options.add(new SelectOption(dealerSelect.pde.id, dealerSelect.pde.Dealer__r.Name));
}

return options;

}


Public class cDealer {
    public Preferred_dealer_item__c pde {get; set;}
    public Boolean selected_pd {get; set;}
    public String pde_link {get; set;}
    
        public cDealer(Preferred_dealer_item__c pd) {
        pde = pd;
        selected_pd = false;
        pde_link= '<a href="' + pde.id + '">'+pde.Name+'</a>';
    }
    }
    
  Public class cAccount {
    public Account pde {get; set;}
    public Boolean selected_pd {get; set;}
    
        public cAccount(Account pd) {
        pde = pd;
        selected_pd = false;
    }
    }


}