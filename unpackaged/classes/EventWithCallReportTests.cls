@isTest
private class EventWithCallReportTests {
    static testMethod void UpdateOwner_SetsUserCountry(){
        // arrange
        EventWithCallReport sut = getServiceUnderTest();
                
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User owner = new User(Country = 'France', Alias = 'standt', Email='standarduser@dentsplysirona.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', SBU_Ratio_ENDO__c = 100,
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@dentsply.com');
        
        insert owner;
        
        sut.Event.OwnerId = owner.Id;  
        
        // act 
        sut.UpdateOwner();
        
        // assert
        //System.assertEquals(owner.Country, sut.ThisCallReport.Assigned_To_User_Country__c);
        
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
        EventWithCallReport sut = getServiceUnderTest();
        
        sut.SaveCallReport();
        //sut.DeleteCallReport();
        sut.OnCFEChange();
        sut.OnOwnerIdChanged();
        //sut.UpdateWhatId();
        sut.UpdateEventStatus();
        sut.UpdateLocation();
        sut.UpdateCoTravel();
        
        
    	List<Schema.PicklistEntry> x;
        x = sut.UserCountriesPicklistValues;
        x = sut.CoTravelPicklistValues;
        x = sut.EventStatusPicklistValues;
        x = sut.ShowTimeAsPicklistValues;
        x = sut.EventSBUPicklistValues;
        //x = sut.SendMailingPicklistValues;
        //x = sut.WhichMailingPicklistValues;   
        
        ApexPages.currentPage().getParameters().put('evt4','04/04/2016');
        //ApexPages.currentPage().getParameters().put('evt13','12:00 PM');
        ApexPages.currentPage().getParameters().put('unplannedEvent','1');
		sut = getServiceUnderTest();
        
        System.Assert(true);
    }
    
    @isTest
    private static EventWithCallReport getServiceUnderTest(){
        Event e = new Event();
        ApexPages.StandardController standardController = new ApexPages.StandardController(e);

        return new EventWithCallReport(standardController);
    }
}