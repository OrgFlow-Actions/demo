@isTest
private class EventAttendeesControllerTest{

    @TestSetup
    static void makeData() {
        TestDataFactory.createBypassCustomSetting();
        List<User> userList = TestDataFactory.returnUsers(2, 'System Administrator');
        userList.get(0).User_Country__c = 'Germany';
        insert userList;
        TestDataFactory.createGlobalIntegrationSettings(userList);
        TestDataFactory.createDefaultOrgLevelBypassPB();
    }

    static testMethod void testEventAttendees (){ 
        List<User> testUserList = [SELECT Id FROM User WHERE Alias = 'test1'];
        System.debug('testUserList::'+testUserList);
        User u1 = testUserList[0];
        User u2 = testUserList[1];
        System.runAs(u1) {
            Id recTypeId= Schema.SObjectType.Event.getRecordTypeInfosByDeveloperName().get('Event_Global').getRecordTypeId();
            Event e = new Event();
            e.Customer_Facing_Event__c = true;
            e.StartDateTime = System.Now();
            e.EndDateTime= System.Now();
            e.Send_Calendar_Invites__c = true;
            e.RecordTypeId = recTypeId;
            insert e;
            EventRelation er = new EventRelation();
            er.EventId = e.ID;
            er.RelationId = u2.Id;
            er.Status ='New';
            insert er;
            EventAttendees__c ea = new EventAttendees__c();
            ea.Name='test';
            ea.RelationId__c = u2.Id;
            ea.EventId__c = e.Id;
            insert ea;
            PageReference pageRef = Page.EventAttendeesPage;
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('id',e.id);
            ApexPages.StandardController sc = new ApexPages.standardController(e);
            EventAttendeesController ev1 = new EventAttendeesController (sc);
            er.Status='Accepted';
            update er;
            EventAttendeesController ev2 = new EventAttendeesController (sc);
            er.Status='Declined';
            update er;
            EventAttendeesController ev3 = new EventAttendeesController (sc);
        }
    }
}