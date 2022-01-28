public with sharing class updateContract {
public Contract contr {get;set;}
//public String currentRecordId {get;set;}

public updateContract(ApexPages.StandardController stdController) {
}

public String stepname {get; set;}

public void navFlow () {
stepname = 'FLOW';
}

/*public void navEnd () {
stepname = 'END';
}*/


}