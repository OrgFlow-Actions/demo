@isTest
private class FakeTests {
    static testMethod void Fake_Test(){
        Campaign c = new Campaign(Name = 'Test Campaign');
		c.SBU_Focus__c = 'Implants';        
        insert c;
        
        Account a = new Account(Name = 'Test Account');        
        insert a;
        
        BatchException be = new BatchException();
        
        Contact contact = new Contact(FirstName = 'Test', LastName = 'Test'); 
        insert contact;
        Event e = new Event(
			Subject = 'Test', 
			StartDateTime = datetime.now(), 
			EndDateTime = datetime.now().addMinutes(60), 
			WhoId = contact.Id,
			SBU__c = 'Endodontics');

        insert e;        
        ApexPages.StandardController standardController = new ApexPages.StandardController(e);
        CallReport sut = new CallReport(standardController);        
        sut.CallReport = sut.CallReport;
        boolean x = sut.EventHasCallReport;
        
        
        InviteesController inviteesController = new InviteesController();
        inviteesController.EventId = e.Id;
        List<InviteesController.Invitee> invitees = inviteesController.Invitees;        
        
        inviteesController = new InviteesController();
        inviteesController.EventId = e.Id;
        inviteesController.SeedIDs = contact.Id;
        invitees = inviteesController.Invitees;  
        
        EventRelationPickerState erps = new EventRelationPickerState();
        erps.EventId = e.Id;
        erps.ForInvitees = true;
        erps.StringRepresentation = contact.Id;
        
        List<EventRelationPickerState.EventRelationVM> ervms = erps.EventRelationVMs;
        
        //erps.Save();
        
        
        ApexPages.currentPage().getParameters().put('who_id',contact.Id);
        EventWithCallReport ewcr = new EventWithCallReport(standardController);
        ewcr.Event = e;
        ewcr.InviteesPickerState = erps;
        ewcr.SaveCallReport();
    }
}