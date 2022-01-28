public class CallReportExtension {
public Id evId; 
public Event Ev{get;set;}  
    public CallReportExtension(ApexPages.StandardController Controller) {
        evId = System.currentPageReference().getParameters().get('id');
        system.debug(evId);
        ev = [SELECT Id, SBU__c, Subject, Call_Report__c,Call_Report__r.track_event__c, Call_Report__r.Call_Notes__c,Call_Report__r.Met_with_Decision_Maker__c, Call_Report__r.Met_with_Assistant__c, Call_Report__r.Placed_Order__c, Call_Report__r.Left_Sample__c, Call_Report__r.Courses__c, Call_Report__r.Products_discussed_ENDO__c, Call_Report__r.Products_discussed_IMPL__c,Call_Report__r.Products_discussed_ORTH__c,Call_Report__r.Products_discussed_PREV__c, Call_Report__r.Products_discussed_PROS__c,Call_Report__r.Products_discussed_REST__c,Call_Report__r.Products_discussed_CDCM__c, Call_Report__r.Products_discussed_INST__c,Call_Report__r.Products_discussed_TRCE__c,Call_Report__r.Products_discussed_IMAG__c,Call_Report__r.Other_SBU_discussed__c,Call_Report__r.Other_SBU_notes__c FROM Event WHERE Id = :evId LIMIT 1 ALL ROWS];
        
        system.debug(ev.Call_Report__r.Call_Notes__c);
    }
}