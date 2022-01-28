@isTest
private class EventWithCallReportServiceTests {
	static testmethod void Tokens_BadTokenLeftInPlace(){
		assertTokenResolution('Test: {||ThisTokenDoesNotExist||}', null, null, 'Test: {||ThisTokenDoesNotExist||}');
	}

	static testmethod void Tokens_PrefixAppliedIfNotNull(){
		Account a = new Account(name = 'Account ABC');
		upsert a;

		assertTokenResolution('{Hello ||RelatedToName||}', null, a.Id, 'Hello Account ABC');
	}

	static testmethod void Tokens_PrefixNotAppliedIfNull(){
		assertTokenResolution('Test: {Hello ||RelatedToName||}', null, null, 'Test: ');
	}

	static testmethod void Tokens_SuffixAppliedIfNotNull(){
		Account a = new Account(name = 'Account ABC');
		upsert a;

		assertTokenResolution('{||RelatedToName|| World}', null, a.Id, 'Account ABC World');
	}

	static testmethod void Tokens_SuffixNotAppliedIfNull(){
		assertTokenResolution('Test: {||RelatedToName|| World}', null, null, 'Test: ');
	}

	static testmethod void Tokens_PrefixAndSuffixAppliedIfNotNull(){
		Account a = new Account(name = 'Account ABC');
		upsert a;

		assertTokenResolution('Hello {||RelatedToName|| World}', null, a.Id, 'Hello Account ABC World');
	}

	static testmethod void Tokens_PrefixAndSuffixNotAppliedIfNull(){
		assertTokenResolution('Test: {Hello ||RelatedToName|| World}', null, null, 'Test: ');
	}

	static testmethod void Tokens_EventType(){
		assertTokenResolution('{||EventType||}', null, null, 'In Person Meeting');
	}

	static testmethod void Tokens_WhoName_Contact(){
		Contact who = new Contact(lastName = 'Contact DEF');
		upsert who;

		assertTokenResolution('{||WhoName||}', who.Id, null, 'Contact DEF');
	}

	static testmethod void Tokens_WhoName_Lead(){
		Lead who = new Lead(lastName = 'Lead 123');
		upsert who;

		assertTokenResolution('{||WhoName||}', who.Id, null, 'Lead 123');
	}

	static testmethod void Tokens_RelatedToName_Account(){
		Account what = new Account(name = 'Account ABC');
		upsert what;

		assertTokenResolution('{||RelatedToName||}', null, what.Id, 'Account ABC');
	}

	static testmethod void Tokens_ComplexFormat(){
		Account what = new Account(name = 'Account ABC');
		upsert what;
		
		Lead who = new Lead(lastName = 'Lead 123');
		upsert who;

		assertTokenResolution('{Chris\'s ||EventType||}{ with ||WhoName||}{ about ||RelatedToName||.}', who.Id, what.Id, 'Chris\'s In Person Meeting with Lead 123 about Account ABC.');
	}

	static testmethod void Tokens_ComplexFormat2(){
		Account what = new Account(name = 'Account ABC');
		upsert what;
        //amit prabhat added on 01-July-2019 for Increasing code coverage
        EventWithCallReportService callrep = new EventWithCallReportService();
        callrep.getErpNumberFromAccount(what.Id);
		assertTokenResolution('{Chris\'s ||EventType||}{ with ||WhoName||}{ about ||RelatedToName||.}', null, what.Id, 'Chris\'s In Person Meeting about Account ABC.');
	}

	static testmethod void Tokens_ComplexFormat3(){		
		Lead who = new Lead(lastName = 'Lead 123');
		upsert who;

		assertTokenResolution('{Chris\'s ||EventType||}{ with ||WhoName||}{ about ||RelatedToName||.}', who.Id, null, 'Chris\'s In Person Meeting with Lead 123');
	}

	private static void assertTokenResolution(string subject, id whoId, id whatId, string expectedValue) {
		EventWithCallReportService sut = new EventWithCallReportService();
		
		Event e = new Event(subject = subject, Astra_Tech_Type__c = 'In Person Meeting', Customer_Facing_Event__c = true, whoId = whoId, whatId = whatId);

		sut.ResolveSubjectTokens(e);

		System.assertEquals(expectedValue, e.Subject);
	}
}