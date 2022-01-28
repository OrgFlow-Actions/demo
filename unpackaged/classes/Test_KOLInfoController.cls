/*------------------------------------------------------------	
Author: 		Richard Trum (Glimt) 2020-02-25 	
Description:   	Test class for testing the apex class KOLInfoController
------------------------------------------------------------*/

@isTest
private class Test_KOLInfoController {

    @IsTest
    private static void getKOLDataTest(){
        
        Account acc = new Account();
        acc.Name = 'Test account';
        acc.Country__c = 'IE';
        insert acc;
        
        Contact con = new Contact();
        con.FirstName ='Test';
        con.LastName = 'Test';
        con.AccountId = acc.Id;
        insert con;
        
        Expert__c KOL = new Expert__c();
        KOL.Contact__c = con.Id;
        KOL.Name = 'x';
        insert KOL;

        Test.startTest();
		Expert__c resKOL = KOLInfoController.getKOLdata(KOL.Id);
        System.assertNotEquals(resKOL, null);
        
        List<Expert__c> resKOLlist = KOLInfoController.getKOLlist();
        System.assertNotEquals(resKOLlist, null);
                
        Test.stopTest();

}
    
    @IsTest
    private static void getDeliverableTest(){
        
        Account acc = new Account();
        acc.Name = 'Test account';
        acc.Country__c = 'IE';
        insert acc;
        
        Contact con = new Contact();
        con.FirstName ='Test';
        con.LastName = 'Test';
        con.AccountId = acc.Id;
        insert con;
        
        Expert__c KOL = new Expert__c();
        KOL.Contact__c = con.Id;
        KOL.Name = 'x';
        insert KOL;
        
        KOL_Contract__c contr = new KOL_Contract__c();
        contr.Expert__c = KOL.Id;
        contr.Name = 'Test contract';
        insert contr;
        
        KOL_Contract_Deliverable__c del = new KOL_Contract_Deliverable__c();
        del.KOL_Contract__c = contr.Id;
        del.Name = 'Test deliverable';
        del.Date__c = date.today();
        insert del;

        Test.startTest();
		List<KOL_Contract_Deliverable__c> resDel = KOLInfoController.getDeliverables(del.Id);
        System.assertNotEquals(resDel, null);
                
        Test.stopTest();

	}
        
    @IsTest
    private static void getSpeakerEventTest(){
        
        Account acc = new Account();
        acc.Name = 'Test account';
        acc.Country__c = 'IE';
        insert acc;
        
        Contact con = new Contact();
        con.FirstName ='Test';
        con.LastName = 'Test';
        con.AccountId = acc.Id;
        insert con;
        
        Expert__c KOL = new Expert__c();
        KOL.Contact__c = con.Id;
        KOL.Name = 'x';
        insert KOL;

        CventEvents__Event__c ev = new CventEvents__Event__c();
        ev.ContractedSpeaker__c = 'Test Test';
        ev.CventEvents__pkg_Code__c = 'TEST012345';
        ev.CventEvents__pkg_Category__c = 'Webinar';
        ev.CventEvents__pkg_Status__c = 'Active';
        ev.CventEvents__pkg_EventStub__c = '012345';
        ev.CventEvents__pkg_Title__c = 'Test event 1';
        insert ev;
        
        CventEvents__Event__c ev2 = new CventEvents__Event__c();
        ev2.ContractedSpeaker__c = 'Test Test 2';
        ev2.CventEvents__pkg_Code__c = 'TEST0123456';
        ev2.CventEvents__pkg_Category__c = 'Webinar';
        ev2.CventEvents__pkg_Status__c = 'Active';
        ev2.CventEvents__pkg_EventStub__c = '0123456';
        ev2.CventEvents__pkg_Title__c = 'Test event 2';
        insert ev2;
        
        CventEvents__Event__c ev3 = new CventEvents__Event__c();
        ev3.ContractedSpeaker__c = 'Test Test 3';
        ev3.CventEvents__pkg_Code__c = 'TEST01234567';
        ev3.CventEvents__pkg_Category__c = 'Webinar';
        ev3.CventEvents__pkg_Status__c = 'Active';
        ev3.CventEvents__pkg_EventStub__c = '01234567';
        ev3.CventEvents__pkg_Title__c = 'Test event 3';
        insert ev3;
        
        CventEvents__Attendee__c att = new CventEvents__Attendee__c();
        att.CventEvents__Contact__c = con.Id;
        att.CventEvents__Event__c = ev2.Id;
        att.CventEvents__Status__c = 'Accepted';
		att.CventEvents__RegistrationType__c = 'Speaker';      
        insert att;
        
        KOL_Contract__c contr = new KOL_Contract__c();
        contr.Expert__c = KOL.Id;
        contr.Name = 'Test contract';
        insert contr;
        
        KOL_Contract_Deliverable__c del = new KOL_Contract_Deliverable__c();
        del.KOL_Contract__c = contr.Id;
        del.Name = 'Test deliverable';
        del.Date__c = date.today();
        del.CventEventUpd__c = ev3.Id;
        insert del;
        
        Test.startTest();
		List<CventEvents__Event__c> resEv = KOLInfoController.getSpeakerEvents(KOL.Id);
        System.assertNotEquals(resEv, null);
                
        Test.stopTest();

}
    
    @IsTest
    private static void getReportLinkTest(){
        
        CAHomeReportLink__c setting = new CAHomeReportLink__c();
        setting.ReportURL__c = 'http://www.dentsplysirona.com';
        insert setting;
        
        String result = KOLInfoController.getReportLink();
        
        System.assertEquals(result, 'http://www.dentsplysirona.com');
        
    }

    @IsTest
    private static void getMyCventEventTest(){
        
        // Create a unique UserName
        String uniqueUserName = 'standarduser' + DateTime.now().getTime() + '@testorg.com';
        // This code runs as the system user
        Profile p = [SELECT Id FROM Profile WHERE Name='#System: System Administrator'];
        User u = new User(Alias = 'standt', Email='invalid@dentsplysirona.com',
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
        LocaleSidKey='en_US', ProfileId = p.Id,
        TimeZoneSidKey='America/Los_Angeles',
        UserName=uniqueUserName);
        
        String userEmail = '';
        System.runAs(u) {
		 userEmail = UserInfo.getUserEmail();
          

        Account acc = new Account();
        acc.Name = 'Test account';
        acc.Country__c = 'IE';
        insert acc;
        
        Contact con = new Contact();
        con.FirstName ='Test';
        con.LastName = 'Test';
        con.AccountId = acc.Id;
        insert con;
        
        Expert__c KOL = new Expert__c();
        KOL.Contact__c = con.Id;
        KOL.Name = 'x';
        insert KOL;
        
        KOL_Contract__c contr = new KOL_Contract__c();
        contr.Name = 'x';
		contr.Expert__c = KOL.Id;
        insert contr;
        
        CventEvents__Event__c ev = new CventEvents__Event__c();
        ev.ContractedSpeaker__c = 'Test Test';
        ev.KOLManageremail__c = userEmail;
        ev.CventEvents__pkg_Code__c = 'TEST012345';
        ev.CventEvents__pkg_Category__c = 'Webinar';
        ev.CventEvents__pkg_Status__c = 'Active';
        ev.CventEvents__pkg_EventStub__c = '012345';
        ev.CventEvents__pkg_Title__c = 'Test event 1';    
        insert ev;
        
        KOL_Contract_Deliverable__c del = new KOL_Contract_Deliverable__c();
        del.KOL_Contract__c = contr.Id;
        del.CventEventUpd__c = ev.Id;
        del.Name = 'x';
        del.Date__c = Date.today();
        insert del;
        System.debug(del);
        
		CventEvents__Event__c ev2 = new CventEvents__Event__c();
        ev2.ContractedSpeaker__c = 'Test Test';
        ev2.KOLManageremail__c = userEmail;
        ev2.CventEvents__pkg_Code__c = 'TEST543210';
        ev2.CventEvents__pkg_Category__c = 'Webinar';
        ev2.CventEvents__pkg_Status__c = 'Active';
        ev2.CventEvents__pkg_EventStub__c = '543210';
        ev2.CventEvents__pkg_Title__c = 'Test event 2';   
        insert ev2;        
        
        Test.startTest();
        
		List<CventEvents__Event__c> resEv = KOLInfoController.getMyCventEvents();
        System.assertNotEquals(resEv, null);
               
        Test.stopTest();
        }
}    
    
    
}