/*-------------------------------------------------------------------------------------------------------
Author:         Kevin Do (Salesforce) 20200326
Description:    Class dummy updates all accounts with Account.Country__c = countryCode
Test Class:     Test_BatchSetAccountSubSegmentation
History 
20200326    Kevin Do            Created class. (#TFUS-000001698)
----------------------------------------------------------------------------------------*/

global class BatchSetAccountSubSegmentation implements Database.Batchable<SObject>, Database.Stateful {
    private String countryCode;
    public BatchSetAccountSubSegmentation(String countryCode) {
        this.countryCode = countryCode;
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        String query = 'SELECT Id FROM Account WHERE Country__c = \'' + countryCode +'\'';
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext bc, List<Account> scope) {
        AccountTriggerHelper.forceUpdate = true;
        try {
            update scope;
        } catch (DmlException e) {
            DebugLog.addException(e, 'Trying dummy update from BatchSetAccountSubSegmentation');
        }
    }

    global void finish(Database.BatchableContext bc) {
        DebugLog.addinfo('This is the BatchSetAccountSubSegmentation JobId:', bc.getJobId());
    }
}