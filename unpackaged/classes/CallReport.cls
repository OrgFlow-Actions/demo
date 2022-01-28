public with sharing class CallReport {

    public CallReport(ApexPages.StandardController controller) {        
        string eventId = controller.getRecord().Id;
        
        if(eventId != null){
            List<Call_Report__c> callReports = [SELECT Id,
                                                    Call_Notes__c,
                                                    Met_with_Assistant__c,
                                                    Met_with_Decision_Maker__c,
                                                    Other_SBU_Products_Discussed__c,
                                                    Placed_Order__c,
                                                    Products_Discussed__c
                                                FROM Call_Report__c 
                                                WHERE event_id__c = :eventId 
                                                ORDER BY Id]; // order by to ensure that the order is deterministic
            
            if(!callReports.isEmpty()){
                CallReport = callReports[0];
            }            
        }
    }
    
    public boolean EventHasCallReport { get { return CallReport != null; } }
    public Call_Report__c CallReport { get; set; }
}