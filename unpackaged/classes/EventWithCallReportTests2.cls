@isTest
private class EventWithCallReportTests2 {

    static testMethod void UpdateOwner_SetsUserCountry(){
        // arrange
        EventWithCallReport sut = getServiceUnderTest();
                
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User owner = new User(Country = 'France', Alias = 'standt', Email='standarduser@dentsplysirona.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', SBU_Ratio_ENDO__c = 100,
            LocaleSidKey='en_US', ProfileId = p.Id, Default_Event_Update_Calendar__c = True,
            TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@dentsply.com');
        
        insert owner;
        
        sut.Event.OwnerId = owner.Id;  
        
        // act 
        sut.onOwnerIdChanged();
        
        System.assertEquals('Endodontics', sut.Event.SBU__c);
        
        owner.SBU_Ratio_ENDO__c = 0;
        owner.SBU_Ratio_IMPL__c = 100;
        
        update owner;
        
        sut.Event.OwnerId = owner.Id;
        
        sut.onOwnerIdChanged();
        
        System.assertEquals('Implants', sut.Event.SBU__c);
        
        
        //Ortho
        
        owner.SBU_Ratio_IMPL__c = 0;
        owner.SBU_Ratio_ORTH__c = 100;
        
        update owner;
        
        sut.Event.OwnerId = owner.Id;
        
        sut.onOwnerIdChanged();
        
        System.assertEquals('Orthodontics', sut.Event.SBU__c);
        
        //Prev
        
        owner.SBU_Ratio_ORTH__c = 0;
        owner.SBU_Ratio_PREV__c = 100;
        
        update owner;
        
        sut.Event.OwnerId = owner.Id;
        
        sut.onOwnerIdChanged();
        
        System.assertEquals('Preventive', sut.Event.SBU__c);
        
        //Pros
        
        owner.SBU_Ratio_PREV__c = 0;
        owner.SBU_Ratio_PROS__c = 100;
        
        update owner;
        
        sut.Event.OwnerId = owner.Id;
        
        sut.onOwnerIdChanged();
        
        System.assertEquals('Prosthetics', sut.Event.SBU__c);
        
        //Rest
        
        owner.SBU_Ratio_PROS__c = 0;
        owner.SBU_Ratio_REST__c = 100;
        
        update owner;
        
        sut.Event.OwnerId = owner.Id;
        
        sut.onOwnerIdChanged();
        
        System.assertEquals('Restorative', sut.Event.SBU__c);
        

        // assert
        System.assertEquals(sut.Event.Call_report__r.Assigned_To_User_Country__c, owner.User_Country__c);
        
        System.assert(true);
    }
    
    static testMethod void UpdateOtherSBUsDiscussedOptions_DoesNotIncludeCurrentSBU(){
        // arrange
        EventWithCallReport sut = getServiceUnderTest();
        
        sut.Event.SBU__c = 'Endodontics';
        
        // act 
        sut.UpdateOtherSBUsDiscussedOptions();
        
        // assert
        for(SelectOption option : sut.OtherSBUsDiscussedOptions){
            System.assert(option.getValue() != sut.Event.SBU__c, 'The Event\'s current SBU should not be available in the list of Other SBUs');
        }
    }
    
    static testMethod void Save_Fake(){
         
        Account account1 = DC_UT_DataUtils.generateAccount('Account1');
        insert account1;
        
        Account dealer1 = DC_UT_DataUtils.generateAccount('Dealer1');
        insert dealer1;
        
        Contact contact1 = DC_UT_DataUtils.generateContact('Contact1');
        contact1.Account = account1;
        insert contact1;
        
        PageReference pageRef = ApexPages.currentPage();
        
        pageRef.getParameters().put('what_id',account1.id);
        // pageRef.getParameters().put('who_id',contact1.id);
        Test.setCurrentPage(pageRef);
        
        EventWithCallReport sut = getServiceUnderTest();
        
        System.AssertEquals(null, sut.Event.Id);  
        sut.Event.Dealer_customer__c = dealer1.Id;
        
        sut= getServiceUnderTest();
               
        sut.SaveCallReport();
        
        
        sut.OnOwnerIdChanged();
        sut.UpdateWhatId();
        sut.UpdateLocation();        
        sut.Event.Co_travel__c = 'Manager';
        sut.UpdateCoTravel();
        
        System.AssertNotEquals(null, sut.Event.WhatId);
        
        
      List<Schema.PicklistEntry> x;
        x = sut.UserCountriesPicklistValues;
        x = sut.CoTravelPicklistValues;
        x = sut.EventStatusPicklistValues;
        x = sut.ShowTimeAsPicklistValues;
        x = sut.EventSBUPicklistValues;
        //x = sut.SendMailingPicklistValues;
        //x = sut.WhichMailingPicklistValues;   
        
        ApexPages.currentPage().getParameters().put('evt4','04/04/2016');
        ApexPages.currentPage().getParameters().put('unplannedEvent','1');
        
        sut = getServiceUnderTest();
        System.Assert(true);
        
        System.AssertEquals(true, sut.WhoIdPickerState.IsParent);
        System.AssertNotEquals(null, sut.Event.OwnerId);

        sut.Event.Customer_Facing_Event__c = True;
        sut.onCFEChange();
        System.AssertEquals('In Person Meeting', sut.Event.Astra_Tech_Type__c);
        sut.Event.Customer_Facing_Event__c = False;
        sut.onCFEChange();
        System.AssertEquals('Absence or Holiday', sut.Event.Astra_Tech_Type__c);     
        
        sut.UpdateEventStatus();
        System.AssertEquals('Completed', sut.Event.Event_Status__c);
        System.AssertEquals(False, sut.Event.Send_Calendar_Invites__c);
        
        sut.SaveCallReport();
        System.AssertNotEquals(null, sut.Event.Id);
        
        sut.Event.SBU__c = '';
        sut.UpdateOtherSBUsDiscussedOptions();
        
        
    }
    
    Static testMethod void Save_Fake_Order_Indirect(){
        
        Account account1 = DC_UT_DataUtils.generateAccount('Account1');
		insert account1;
        
        Contact contact1 = DC_UT_DataUtils.generateContact('Contact1');
		contact1.Account = account1;
        insert contact1;
        
        PageReference pageRef = ApexPages.currentPage();
        
        pageRef.getParameters().put('who_id',contact1.id);
        pageRef.getParameters().put('retURL', '/');
        Test.setCurrentPage(pageRef);
        
        EventWithCallReport sut = getServiceUnderTest();
        
        System.AssertEquals(null, sut.Event.Id);
        System.AssertNotEquals(null, sut.StartDateString);
        System.AssertNotEquals(null, sut.StartTimeString);
        System.AssertNotEquals(null, sut.EndDateString);
        System.AssertNotEquals(null, sut.EndTimeString);
        
        
          
        sut.SaveCallReport();
        
        //sut.DeleteCallReport();
        
        sut.OnOwnerIdChanged();
        sut.UpdateWhatId();
        sut.UpdateLocation();
        sut.UpdateCoTravel();
        
        //System.AssertEquals(null, sut.Event.Id);
        
        //System.AssertNotEquals(null, sut.Event.WhatId);
        System.AssertNotEquals(null, sut.Event.WhoId);
        
        
      List<Schema.PicklistEntry> x;
        x = sut.UserCountriesPicklistValues;
        x = sut.CoTravelPicklistValues;
        x = sut.EventStatusPicklistValues;
        x = sut.ShowTimeAsPicklistValues;
        x = sut.EventSBUPicklistValues;
        //x = sut.SendMailingPicklistValues;
        //x = sut.WhichMailingPicklistValues;   
        
        ApexPages.currentPage().getParameters().put('evt4','04/04/2016');
        ApexPages.currentPage().getParameters().put('unplannedEvent','1');
        
        sut = getServiceUnderTest();
        System.Assert(true);
        
        System.AssertEquals(true, sut.WhoIdPickerState.IsParent);
        System.AssertNotEquals(null, sut.Event.OwnerId);

        sut.Event.Customer_Facing_Event__c = True;
        sut.onCFEChange();
        System.AssertEquals('In Person Meeting', sut.Event.Astra_Tech_Type__c);
        sut.Event.Customer_Facing_Event__c = False;
        sut.onCFEChange();
        System.AssertEquals('Absence or Holiday', sut.Event.Astra_Tech_Type__c);     
        
        sut.UpdateEventStatus();
        System.AssertEquals('Completed', sut.Event.Event_Status__c);
        System.AssertEquals(False, sut.Event.Send_Calendar_Invites__c);
        
        sut.CreateIndirectOrder();
        System.AssertNotEquals(null, sut.Event.Id);
        System.AssertEquals('Indirect', sut.OrderType);
        System.AssertNotEquals(null, sut.returnURL);
        
    }
    
        Static testMethod void Save_Fake_Order_Direct(){
        Account account1 = DC_UT_DataUtils.generateAccount('Account1');
		insert account1;
        
        Contact contact1 = DC_UT_DataUtils.generateContact('Contact1');
		contact1.Account = account1;
        insert contact1;
        
        PageReference pageRef = ApexPages.currentPage();
        
        pageRef.getParameters().put('who_id',contact1.id);
        pageRef.getParameters().put('retURL', '/');
        Test.setCurrentPage(pageRef);
        
        EventWithCallReport sut = getServiceUnderTest();
        
        System.AssertEquals(null, sut.Event.Id);
               
        sut.SaveCallReport();
        
        //sut.DeleteCallReport();
        
        sut.OnOwnerIdChanged();
        sut.UpdateWhatId();
        sut.UpdateLocation();
        sut.UpdateCoTravel();
        
        //System.AssertNotEquals(null, sut.Event.Id);
        
        //System.AssertNotEquals(null, sut.Event.WhatId);
        System.AssertNotEquals(null, sut.Event.WhoId);
        
        
      List<Schema.PicklistEntry> x;
        x = sut.UserCountriesPicklistValues;
        x = sut.CoTravelPicklistValues;
        x = sut.EventStatusPicklistValues;
        x = sut.ShowTimeAsPicklistValues;
        x = sut.EventSBUPicklistValues;
        //x = sut.SendMailingPicklistValues;
        //x = sut.WhichMailingPicklistValues;   
        
        ApexPages.currentPage().getParameters().put('evt4','04/04/2016');
        ApexPages.currentPage().getParameters().put('unplannedEvent','1');
        
        sut = getServiceUnderTest();
        System.Assert(true);
        
        System.AssertEquals(true, sut.WhoIdPickerState.IsParent);
        System.AssertNotEquals(null, sut.Event.OwnerId);

        sut.Event.Customer_Facing_Event__c = True;
        sut.onCFEChange();
        System.AssertEquals('In Person Meeting', sut.Event.Astra_Tech_Type__c);
        sut.Event.Customer_Facing_Event__c = False;
        sut.onCFEChange();
        System.AssertEquals('Absence or Holiday', sut.Event.Astra_Tech_Type__c);     
        
        sut.UpdateEventStatus();
        System.AssertEquals('Completed', sut.Event.Event_Status__c);
        System.AssertEquals(False, sut.Event.Send_Calendar_Invites__c);
        
        sut.CreateDirectOrder();
        System.AssertNotEquals(null, sut.Event.Id);
        System.AssertEquals('Direct', sut.OrderType);
        System.AssertNotEquals(null, sut.returnURL);
        
        System.AssertNotEquals(null, sut.DeleteCallReport());
        
    }
    
        
        
        Static testMethod void Save_Mobile(){
        Account account1 = DC_UT_DataUtils.generateAccount('Account1');
		insert account1;
        
        Contact contact1 = DC_UT_DataUtils.generateContact('Contact1');
		contact1.Account = account1;
        insert contact1;
        
        PageReference pageRef = ApexPages.currentPage();
        
        pageRef.getParameters().put('who_id',contact1.id);
        pageRef.getParameters().put('retURL', '/');
        Test.setCurrentPage(pageRef);
        
        EventWithCallReport sut = getServiceUnderTest();
        
        System.AssertEquals(null, sut.Event.Id);
        
        //sut.DeleteCallReport();
        
        sut.OnOwnerIdChanged();
        sut.UpdateWhatId();
        sut.UpdateLocation();
        sut.UpdateCoTravel();
        
        //System.AssertNotEquals(null, sut.Event.WhatId);
        System.AssertNotEquals(null, sut.Event.WhoId);
        
        
      List<Schema.PicklistEntry> x;
        x = sut.UserCountriesPicklistValues;
        x = sut.CoTravelPicklistValues;
        x = sut.EventStatusPicklistValues;
        x = sut.ShowTimeAsPicklistValues;
        x = sut.EventSBUPicklistValues;
        //x = sut.SendMailingPicklistValues;
        //x = sut.WhichMailingPicklistValues;   
        
        ApexPages.currentPage().getParameters().put('evt4','04/04/2016');
        ApexPages.currentPage().getParameters().put('unplannedEvent','1');
        
        sut = getServiceUnderTest();
        System.Assert(true);
        
        System.AssertEquals(true, sut.WhoIdPickerState.IsParent);
        System.AssertNotEquals(null, sut.Event.OwnerId);

        sut.Event.Customer_Facing_Event__c = True;
        sut.onCFEChange();
        System.AssertEquals('In Person Meeting', sut.Event.Astra_Tech_Type__c);
        sut.Event.Customer_Facing_Event__c = False;
        sut.onCFEChange();
        System.AssertEquals('Absence or Holiday', sut.Event.Astra_Tech_Type__c);     
        
        sut.UpdateEventStatus();
        System.AssertEquals('Completed', sut.Event.Event_Status__c);
        System.AssertEquals(False, sut.Event.Send_Calendar_Invites__c);
        
        
        List<string> whoIds = new List<string>();
        Call_Report__c Called = new Call_Report__c();
        
        whoIds.add(sut.Event.WhoId);
         
        System.AssertNotEquals(null, EventWithCallReport.SaveMobile(sut.Event, Called, whoIds));
        
    }   
   
    
    @isTest
    private static EventWithCallReport getServiceUnderTest(){
        Event e = new Event();
        ApexPages.StandardController standardController = new ApexPages.StandardController(e);

        return new EventWithCallReport(standardController);
    }
}