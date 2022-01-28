global class scheduledIntegrationProgress implements Schedulable {
   global void execute(SchedulableContext SC) {

       createIntegrationProgressRecord('GDW Integration','EMEA');
       createIntegrationProgressRecord('Azure Calculation','EMEA');
       createIntegrationProgressRecord('Einstein Analytics','EMEA');

       createIntegrationProgressRecord('GDW Integration','US');
       createIntegrationProgressRecord('Azure Calculation','US');
       createIntegrationProgressRecord('Einstein Analytics','US');
    
       createIntegrationProgressRecord('GDW Integration','AU');
       createIntegrationProgressRecord('Azure Calculation','AU');
       createIntegrationProgressRecord('Einstein Analytics','AU');
   }

    private void createIntegrationProgressRecord(string step, string source) {
        Integration_Progress__c ip = new Integration_Progress__c();

        ip.Step__c = step;
        ip.Status__c = 'PENDING';
        ip.Source__c = source;
        ip.Estimated_Start_Date__c = Datetime.newInstance(Date.today(), Datetime.valueOf([SELECT Estimated_Start_Date__c FROM Integration_Progress_Setting__mdt WHERE Step__c = :step AND source__c = :source].Estimated_Start_Date__c).time());
        ip.Estimated_Finished_Date__c = Datetime.newInstance(Date.today(), Datetime.valueOf([SELECT Estimated_Finished_Date__c FROM Integration_Progress_Setting__mdt WHERE Step__c = :step AND source__c = :source].Estimated_Finished_Date__c).time());
        ip.External_Id__c = [SELECT Label FROM Integration_Progress_Setting__mdt WHERE Step__c = :step AND source__c = :source].Label + '-' + Datetime.now().format('yyyy-MM-dd');
        insert ip;
    }
}