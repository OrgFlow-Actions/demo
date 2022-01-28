/** Nishi Jain (nishi.jain@mindtree.com)
 * Added for Classic CFE related to Lightning Sync Project 
 * Used as controller class for EventAttendeesPage vf page
 */

public class EventAttendeesController {
    public Id recId; 
    public List<EventAttendees__c> evAttendee{get;set;}
    public List<EventRelation> hasntResp{get;set;}
    public List<EventRelation> acceptd{get;set;}
    public List<EventRelation> declind{get;set;}
    public Boolean showEvAttendee {get;set;}
    public Boolean showHasntResp {get;set;}
    public Boolean showAcceptd {get;set;}
    public Boolean showDeclind {get;set;}
    public String type {get;set;}
    public EventAttendeesController(ApexPages.StandardController controller) {
        showEvAttendee = false;
        showHasntResp = false;
        showAcceptd= false;
        showDeclind = false;
        type ='User';
        evAttendee = new List<EventAttendees__c> ();
        hasntResp = new List<EventRelation> ();
        acceptd = new List<EventRelation> ();
        declind = new List<EventRelation> ();
        recId = System.currentPageReference().getParameters().get('id');
        evAttendee = [SELECT Name, Status__c,RelationId__r.Name from EventAttendees__c WHERE EventId__c = :recId];
        if(evAttendee.size() > 0){
            showEvAttendee = true;
        } 
        hasntResp = [SELECT Relation.Name,Status,Response FROM EventRelation WHERE EventId = :recId AND Status = 'New'];
        if(hasntResp.size() > 0){
            showHasntResp  = true;
        }
        
        acceptd = [SELECT Relation.Name,Status,Response FROM EventRelation WHERE EventId = :recId AND Status = 'Accepted'];
        if(acceptd.size() > 0){
            showAcceptd = true;
        }
        declind = [SELECT Relation.Name,Status,Response FROM EventRelation WHERE EventId = :recId AND Status = 'Declined'];
        if(declind.size() > 0){
            showDeclind = true;
        } 
    }


}