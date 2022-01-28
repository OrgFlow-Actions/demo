@isTest
public class DC_EventNoticesUtilsTests{
    
    public testmethod static void selectEventsForNoticesWhenCreating_ShouldIncludeAllEventsWhenNotFromTrigger(){
        setIdsOfEventRTsForNotices();
        
        List<Event> result = DC_EventNoticesUtils.selectEventsForNoticesWhenCreating(getTestEvents(), false);
        
        System.AssertEquals(7, result.Size());
    }
    
    
    public testmethod static void selectEventsForNoticesWhenCreating_ShouldIncludeCorrectEventsWhenFromTrigger(){
        setIdsOfEventRTsForNotices();
        
        List<Event> result = DC_EventNoticesUtils.selectEventsForNoticesWhenCreating(getTestEvents(), true);
        
        System.AssertEquals(5, result.Size());
    }
    
    private static void setIdsOfEventRTsForNotices(){
        DC_EventNoticesUtils.idsOfEventRTsForNotices = new Set<Id>();       
        
        DC_EventNoticesUtils.idsOfEventRTsForNotices.Add(null);
    }
    
    private static List<Event> getTestEvents(){
        // 1 null, 2 true, 4 false - bitwise
        List<Event> testEvents = new List<Event>{
            new Event(Send_Calendar_Invites__c = true, Bypass_Auto_Invites_When_Creating__c = null),
            new Event(Send_Calendar_Invites__c = true, Bypass_Auto_Invites_When_Creating__c = true),
            new Event(Send_Calendar_Invites__c = true, Bypass_Auto_Invites_When_Creating__c = true),
            new Event(Send_Calendar_Invites__c = true, Bypass_Auto_Invites_When_Creating__c = false),
            new Event(Send_Calendar_Invites__c = true, Bypass_Auto_Invites_When_Creating__c = false),
            new Event(Send_Calendar_Invites__c = true, Bypass_Auto_Invites_When_Creating__c = false),
            new Event(Send_Calendar_Invites__c = true, Bypass_Auto_Invites_When_Creating__c = false)
        };
        
        return testEvents;
    }

}