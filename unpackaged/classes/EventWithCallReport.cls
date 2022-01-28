global with sharing class EventWithCallReport {
    private final ApexPages.StandardController baseController;
     
    public EventRelationPickerState InviteesPickerState { get; set; }
    public EventRelationPickerState WhoIdPickerState { get; set; }
    
    public EventRecurrenceState EventRecurrenceState { get; set; }

    public String OrderType {get;set;}
    
    public Event Event { get ; set; }
    
    public User Owner { get ; set; }
    public User Manager { get ; set; }
    
    public string WhatName { get ; set; }    
    public string WhatType { get ; set; }
    
    public string DealerName { get ; set; }
    
    public Decimal EventLengthInMinutes { get; set; }
    
    public list<SelectOption> OtherSBUsDiscussedOptions { get; set; }
    public list<SelectOption> EventStatusOptions { get; set; }
    
    public boolean EventIsPlanned { get; set; }
    public string ReturnUrl { get; set; }
	
    public boolean IsXHRRequest { get; set; }
    public boolean IsGeopointe { get; set; }
    public boolean ShowHeader { get; set; }
    public boolean ShowSidebar { get; set; }
    
    public boolean ShowRecurrencePanel { 
        get {
            return Event.Id == null || IsRecurrenceInstance || IsRecurrenceSeries;
        }        
    }
    
    public boolean IsRecurrenceInstance { 
        // true if the event is a recurrence, and if the event is not a series
        get {
            return Event.RecurrenceActivityId != null && !IsRecurrenceSeries;
        }        
    }
    
    public boolean IsRecurrenceSeries { 
        // true if the event is a recurrence, and the event id matches the recurrence activity id 
        get {
            return Event.RecurrenceActivityId != null && Event.RecurrenceActivityId == Event.Id;
        }        
    }
    
    public List<Schema.PicklistEntry> UserCountriesPicklistValues { get { return GetPicklistValues('Call_Report__c', 'Assigned_To_User_Country__c'); } }    
    public List<Schema.PicklistEntry> CoTravelPicklistValues { get { return GetPicklistValues('event', 'Co_travel__c'); } }  
    public List<Schema.PicklistEntry> EventStatusPicklistValues { get { return GetPicklistValues('event', 'Event_Status__c'); } }  
    public List<Schema.PicklistEntry> ShowTimeAsPicklistValues { get { return GetPicklistValues('event', 'ShowAs'); } }    
    public List<Schema.PicklistEntry> EventSBUPicklistValues { get { return GetPicklistValues('event', 'SBU__c'); } }    
    //public List<Schema.PicklistEntry> SendMailingPicklistValues { get { return GetPicklistValues('event', 'Send_Mailing__c'); } }    
    //public List<Schema.PicklistEntry> WhichMailingPicklistValues { get { return GetPicklistValues('event', 'NA_Which_mailing_should_be_sent__c'); } }  
    public List<Schema.PicklistEntry> BusinessInitiativeValues { get { return GetPicklistValues('event', 'Business_Initiative__c'); } }  
    public List<Schema.PicklistEntry> EventSubtypeValues { get { return GetPicklistValues('event', 'Activity_Subtype__c'); } }  
    
    public string DateTimeOffset{
        get{
            DateTime now = DateTime.now();
            Long offset = DateTime.newInstance(now.date(), now.time()).getTime() - DateTime.newInstance(now.dateGmt(), now.timeGmt()).getTime();
           
            return string.ValueOf(offset / (60 * 60 * 1000));
        }
    }
    
    public string StartDateString { get { return Event.StartDateTime.Format('yyyy-MM-dd'); } }
    public string StartTimeString { get { return Event.StartDateTime.Format('HH:mm'); } }
    public string EndDateString { get { return Event.EndDateTime.Format('yyyy-MM-dd'); } }
    public string EndTimeString { get { return Event.EndDateTime.Format('HH:mm'); } }
    
    public DateTimePickerVM StartTimePicker { get; set; }
    public DateTimePickerVM EndTimePicker { get; set; }

    public EventWithCallReport(ApexPages.StandardController extendedController) {
        system.debug('Entering constructor.');
        
        baseController = extendedController;
        
        if(IsXHRRequest == null){ IsXHRRequest = false; }   
        if(IsGeopointe == null){ IsGeopointe = false; }   
        if(ShowHeader == null){ ShowHeader = true; }   
        if(ShowSidebar == null){ ShowSidebar = true; }   
        
        EventIsPlanned = !(ApexPages.currentPage().getParameters().get('unplannedEvent') == '1');
        ReturnUrl = ApexPages.currentPage().getParameters().get('retURL');

		if(ApexPages.currentPage().getParameters().get('context') == 'geopointe') {
			IsGeopointe = true;
			ShowHeader = false;
			ShowSidebar = false;
		}
        
        Event = (Event)baseController.getRecord();
		User currentUser = getCurrentUser();
        
        EventRecurrenceService eventRecurrenceService = new EventRecurrenceService();
        EventRecurrenceState = eventRecurrenceService.GetEventRecurrenceState(Event);

        system.debug('IsRecurrence: ' + Event.IsRecurrence);
        
        if(InviteesPickerState == null){
            system.debug('Initializing InviteesPickerState');
            
            InviteesPickerState = new EventRelationPickerState();        
            InviteesPickerState.ForInvitees = true;     
            InviteesPickerState.IsParent = false;        
            InviteesPickerState.EventId = Event.Id;        
            InviteesPickerState.PopulateEventRelationsFromDatabase();
        }

        if(WhoIdPickerState == null){
            system.debug('Initializing WhoIdPickerState');
            
            WhoIdPickerState = new EventRelationPickerState();        
            WhoIdPickerState.ForInvitees = false;            
            WhoIdPickerState.IsParent = true;        
            WhoIdPickerState.EventId = Event.Id;
        }  
        
        boolean populateWhoIdFromDB = true;
        
        if(Event.Id == null) {           
            system.debug('Base controller event ID is null. Creating instance of event with default values.');      
            
            Event.OwnerId = UserInfo.getUserId(); 
            Event.Customer_Facing_Event__c = true;
            Event.Location_Was_Automatically_Calculated__c = true;
            Event.Astra_Tech_Type__c = 'In Person Meeting';
            
            Event.ShowAs = (string) GetDefaultValue('event', 'showAs');
               
            EventLengthInMinutes = currentUser.Default_Activity_Length_In_Minutes__c;
            
            if(EventLengthInMinutes == null){
                EventLengthInMinutes = 60;
            }
            
            UpdateSBU();
            SeedEventTimes();
            
            Event.Send_Calendar_Invites__c = EventIsPlanned && currentUser.Default_Event_Update_Calendar__c;
            
            if(!EventIsPlanned){
                Event.Event_Status__c = 'Completed';
                Event.Astra_Tech_Type__c = 'Cold Call';
            }
            
            string referringWhoId = ApexPages.currentPage().getParameters().get('who_id');
            string referringWhatId = ApexPages.currentPage().getParameters().get('what_id');
            
            if(referringWhatId != null){     
                Event.WhatId = referringWhatId;
                
                UpdateLocation();
            }                 
            if(referringWhoId != null){                        
                Event.WhoId = referringWhoId;
                WhoIdPickerState.StringRepresentation = referringWhoId;
                WhoIdPickerState.SetEventRelationsFromString();
                
                populateWhoIdFromDB = false;
                
                if (referringWhatId == null) UpdateWhatId();
            }
        }  
        else{ // event id is not null
            long eventLengthInMilliseconds = Event.EndDateTime.getTime() - Event.StartDateTime.getTime();
            EventLengthInMinutes = eventLengthInMilliseconds/1000/60;
            
            if(Event.IsAllDayEvent){
                Date activityDate = Event.ActivityDate;
                DateTime allDayStartDate = DateTime.NewInstance(activityDate.Year(), activityDate.Month(), activityDate.Day());
                
                Event.StartDateTime = allDayStartDate;
                // Need to take 1,440 minutes (one day) off the end duration so that the date makes sense in the UI
                // eg All Day Event on 26th Oct will end at midnight 27th Oct, but the UI should show 26th Oct for both start date and end date
                Event.EndDateTime = allDayStartDate.AddMinutes(Event.DurationInMinutes - 1440); 
            }
        }
            
        if(Event.Call_Report__r == null){
            System.debug('Call Report is null');
            Event.Call_Report__r = (Call_Report__c)Call_Report__c.sObjectType.newSObject(null, true);
        }
        
        UpdateOwner();   
        UpdateCoTravel();
        
        UpdateOtherSBUsDiscussedOptions(); 
        
        if(Event.WhoId != null){            
            // This is just a hint to the VF component so that it can place the primary value at the top of the list
            WhoIdPickerState.PrimaryValue = Event.WhoId;
        }
        
        if(Event.WhatId != null){
            WhatType = Event.WhatId.getSObjectType().getDescribe().getName();
            WhatName = getNameFromId(Event.WhatId);
        }
        
        if(Event.Dealer_Customer__c != null){
            DealerName = getNameFromId(Event.Dealer_Customer__c);
        }
        
        StartTimePicker = new DateTimePickerVM(Event.StartDateTime);
        EndTimePicker = new DateTimePickerVM(Event.EndDateTime);        
        
        if(populateWhoIdFromDB){
            WhoIdPickerState.PopulateEventRelationsFromDatabase();
        }
        
        if(IsRecurrenceInstance){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, Label.Recurrence_InstanceWarning));
        }
        
        if(IsRecurrenceSeries){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, Label.Recurrence_SeriesWarning));
        }
        
        UpdateEventStatusOptions();
    }
    
    public PageReference SaveCallReport(){               
        system.debug('Entering SaveCallReport');
        
        if(!StartTimePicker.IsValid()){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'The value of "'+ StartTimePicker.StringValue +'" is not valid for the event start time'));
        }
        
        if(!EndTimePicker.IsValid()){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'The value of "'+ EndTimePicker.StringValue +'" is not valid for the event end time'));
        }
        
        if(!StartTimePicker.IsValid() || !EndTimePicker.IsValid()){
            return null;
        }
            
        Event.StartDateTime = StartTimePicker.Value;
        Event.EndDateTime = EndTimePicker.Value;
        
        EventWithCallReportService eventWithCallReportService = new EventWithCallReportService();
        EventRecurrenceService eventRecurrenceService = new EventRecurrenceService();
                    
        system.debug('Setting event recurrence...');
        system.debug('IsRecurrence before setting: ' + Event.IsRecurrence);
        Event = eventRecurrenceService.SetEventRecurrenceFromState(Event, EventRecurrenceState);
        system.debug('IsRecurrence after setting: ' + Event.IsRecurrence);
		                
        try{            
          system.debug('Saving...');
            system.debug('IsRecurrence: ' + Event.IsRecurrence);
			eventWithCallReportService.Save(Event, Event.Call_Report__r, WhoIdPickerState, InviteesPickerState, Event.Send_Calendar_Invites__c);            
        }
        catch(DmlException ex){
            ApexPages.addMessages(ex);
            
          //return ApexPages.currentPage();
            return null;
        }

		if(IsGeopointe){
            return new PageReference('/apex/GeopointeCloseAction');
		}
        
        if(returnURL != null){            
            if(OrderType == 'Direct'){
                returnURL= ('/apex/orderManagementVF?recordId=' + Event.Id);
            }
            
            if(OrderType == 'Indirect'){
                returnURL= ('/apex/Order_Indirect_CFE?id=' + Event.Id);
            } 
            
            return new PageReference(returnURL);
        }
        
        return ApexPages.currentPage();
    }

    public PageReference saveNewCallReport(){               
        system.debug('Entering SaveNewCallReport');
        
        if(!StartTimePicker.IsValid()){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'The value of "'+ StartTimePicker.StringValue +'" is not valid for the event start time'));
        }
        
        if(!EndTimePicker.IsValid()){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'The value of "'+ EndTimePicker.StringValue +'" is not valid for the event end time'));
        }
        
        if(!StartTimePicker.IsValid() || !EndTimePicker.IsValid()){
            return null;
        }
            
        Event.StartDateTime = StartTimePicker.Value;
        Event.EndDateTime = EndTimePicker.Value;
        
        EventWithCallReportService eventWithCallReportService = new EventWithCallReportService();
        EventRecurrenceService eventRecurrenceService = new EventRecurrenceService();
                    
        system.debug('Setting event recurrence...');
        system.debug('IsRecurrence before setting: ' + Event.IsRecurrence);
        Event = eventRecurrenceService.SetEventRecurrenceFromState(Event, EventRecurrenceState);
        system.debug('IsRecurrence after setting: ' + Event.IsRecurrence);
		                
        try{            
          system.debug('Saving...');
            system.debug('IsRecurrence: ' + Event.IsRecurrence);
			eventWithCallReportService.Save(Event, Event.Call_Report__r, WhoIdPickerState, InviteesPickerState, Event.Send_Calendar_Invites__c);            
        }
        catch(DmlException ex){
            ApexPages.addMessages(ex);
            
          //return ApexPages.currentPage();
            return null;
        }
    
    string referringWhoId = ApexPages.currentPage().getParameters().get('who_id');
    string referringWhatId = ApexPages.currentPage().getParameters().get('what_id');		
        
        if(referringWhatId != null){           
            PageReference pr = new PageReference('/apex/callreportevent');        
            pr.setRedirect(true);
            pr.getParameters().put('what_id',Event.WhatId);
            pr.getParameters().put('retUrl',Event.WhatId);
            return pr;
        }
            else if (referringWhoId != null){
                PageReference pr = new PageReference('/apex/callreportevent');        
            pr.setRedirect(true);
            pr.getParameters().put('who_id',Event.WhoId);
            pr.getParameters().put('retUrl',Event.WhoId);
            return pr;
            }
        else {
            if(Event.WhoId != null && Event.WhatId != null) {
            PageReference pr = new PageReference('/apex/callreportevent');        
            pr.setRedirect(true);
            pr.getParameters().put('who_id',Event.WhoId);
            pr.getParameters().put('what_id',Event.WhatId);
            pr.getParameters().put('retUrl',Event.WhoId);
            return pr;  
            }
            else if(Event.WhatId != null) {
            PageReference pr = new PageReference('/apex/callreportevent');        
            pr.setRedirect(true);
            pr.getParameters().put('what_id',Event.WhatId);
            pr.getParameters().put('retUrl',Event.WhatId);
            return pr;  
            }
            else if(Event.WhoId != null) {
            PageReference pr = new PageReference('/apex/callreportevent');        
            pr.setRedirect(true);
            pr.getParameters().put('who_id',Event.WhoId);
            pr.getParameters().put('retUrl',Event.WhoId);
            return pr;  
            }
            else {
            PageReference pr = new PageReference('/apex/callreportevent');        
            pr.setRedirect(true);
            return pr;  
            }
        }
            
        return ApexPages.currentPage();
    }

    public PageReference CreateDirectOrder(){
        OrderType ='Direct';
        return SaveCallReport();
    }
    
    public PageReference CreateIndirectOrder(){
        OrderType ='Indirect';
        return SaveCallReport();
    }
    
    @RemoteAction
    global static MobileApiResult SaveMobile(Event eventToSave, 
                            Call_Report__c callReportToSave, 
                            List<string> whoIds)
    {                        
        MobileApiResult apiResult = new MobileApiResult();
        
        EventWithCallReportService eventWithCallReportService = new EventWithCallReportService();        
        EventRelationPickerState whoIdPickerState = null;
        
        if(whoIds != null && !whoIds.IsEmpty()){
            whoIdPickerState = new EventRelationPickerState();
            whoIdPickerState.StringRepresentation = string.join(whoIds, ',');
            whoIdPickerState.IsParent = true;
            whoIdPickerState.ForInvitees = false;
        }
        
        try{
            eventWithCallReportService.Save(eventToSave, callReportToSave, whoIdPickerState, null, eventToSave.Send_Calendar_Invites__c);
          apiResult.evnt= eventToSave;  
          apiResult.WasSuccessful = true;
        }
        catch(DmlException ex){            
            ApexPages.addMessages(ex);
            
            for(integer i = 0; i < ex.getNumDML(); i++){
                //ex.getDmlFieldNames(i)[0],  
                apiResult.Errors.Add(ex.getDMLMessage(i));
            }
                      
          apiResult.WasSuccessful = false;
        }     
        
        return apiResult;
    }
    
    public PageReference DeleteCallReport(){
        list<EventRelation> ersToDelete = [select id from EventRelation where eventid = :Event.Id];        
        delete ersToDelete;
        
        delete Event;
        
        return new PageReference('/00U/c');
    }
        
    public void OnCFEChange(){
        if(Event.Customer_Facing_Event__c){
            Event.Astra_Tech_Type__c = 'In Person Meeting';
        }
        else{
            Event.Astra_Tech_Type__c = 'Absence or Holiday';
        }
        
        UpdateEventStatus();
    }
    
    public void OnOwnerIdChanged(){
        UpdateOwner();        
        UpdateSBU();
        UpdateOtherSBUsDiscussedOptions();
    }
        
    public void UpdateWhatId(){   
        List<Contact> contacts = [SELECT accountid FROM contact WHERE id = :Event.WhoId];
        
        if(contacts.size() == 1) {        
            Event.WhatId = contacts[0].AccountId;
            
            UpdateLocation();
        }
    }
    
    public void UpdateSBU(){
        EventWithCallReportService eventWithCallReportService = new EventWithCallReportService();

		eventWithCallReportService.SetDefaultSBUs(Event);
    }
    
    public void UpdateEventStatus(){
        Event.Event_Status__c = 'Completed';
    }
    
    public void UpdateLocation(){    
        // only update location if the event location was automatically calculated
        if(!Event.Location_Was_Automatically_Calculated__c){    
            system.debug('Location not set because it has been manually entered');

            return;
        }
        EventWithCallReportService eventWithCallReportService = new EventWithCallReportService();

		Event.Location = eventWithCallReportService.GetEventLocation(Event);
    }
    
    public void UpdateCoTravel(){  
        if(Owner != null){
            Manager = getUserById(Owner.ManagerId);
            
            if(Event.Co_travel__c == 'Manager'){            
                Event.Co_Travel_Manager__c = Owner.ManagerId;
            }
        }
    }
    
    public void UpdateOtherSBUsDiscussedOptions(){        
        DescribeFieldResult fieldResult = Call_Report__c.Other_SBU_Discussed__c.getDescribe();
        list<PicklistEntry> picklistValues = fieldResult.getPicklistValues();   
        
        OtherSBUsDiscussedOptions = new list<SelectOption>();
        OtherSBUsDiscussedOptions.Add(new SelectOption('', '- - None - -'));
        
        if(Event.SBU__c == null){
            return;
        }
        
        for(PicklistEntry picklistEntry : picklistValues){
            if(!Event.SBU__c.contains(picklistEntry.getValue())){
                OtherSBUsDiscussedOptions.Add(new SelectOption(picklistEntry.GetValue(), picklistEntry.GetLabel()));
            }
        }
    }
    
    public void UpdateOwner(){           
        Owner = getUserById(Event.OwnerId);
        if(Owner == null){
            return;
        }
        
        Event.Call_Report__r.Assigned_To_User_Country__c = Owner.User_Country__c;
    }
    
    private User getCurrentUser(){
        return [SELECT id, 
                       User_Country__c, 
                       Default_Activity_Length_In_Minutes__c,
             Default_Event_Update_Calendar__c,
             Default_Event_Subject__c               
                FROM user 
                WHERE id = :UserInfo.getUserId()
        Limit 1];
    }
    
    private void seedEventTimes(){                    
        // pull start time from url (if provided)        
        string dateString = ApexPages.currentPage().getParameters().get('evt4');
        string timeString = ApexPages.currentPage().getParameters().get('evt13');
        
        if(dateString == null){
            seedStartTimeToNow();
            
            return;
        }
        
        if(timeString != null){
            Event.StartDateTime = DateTime.parse(dateString + ' ' + timeString);
            seedEndTime();
            
            return;
        }
        
        Date datePart;
        
        try{
            datePart = Date.Parse(dateString);
        }
        catch(Exception ex){
            seedStartTimeToNow();
            
            return;
        }
        
        Time timePart;
        Integer hours = DateTime.Now().AddHours(1).hour(); // default to on the hour of the next hour
        Integer minutes = 0;
        
        if(timeString != null){            
            String[] timeParts= timeString.Split(':');
            
            if(timeParts.Size() >= 1 && timeParts[0].IsNumeric()){
                hours = Integer.ValueOf(timeParts[0]);
            }
            
            if(timeParts.Size() >= 2 && timeParts[1].IsNumeric()){
                minutes= Integer.ValueOf(timeParts[1]);
            }
            
            timePart = Time.NewInstance(hours, minutes, 0, 0);
        }   
            
        timePart = Time.NewInstance(hours, minutes, 0, 0);     
        
        Event.StartDateTime = DateTime.NewInstance(datePart, timePart);    

        seedEndTime();      
    }
    
    private void seedStartTimeToNow(){
        if(EventIsPlanned){
            Event.StartDateTime = DateTime.Now().AddHours(1);  
            Event.StartDateTime = Event.StartDateTime.AddMinutes(-Event.StartDateTime.Minute());
            
            seedEndTime();
        }
        else{
            Event.EndDateTime = DateTime.Now().AddHours(-1);  
            Event.EndDateTime = Event.EndDateTime.AddMinutes(-Event.EndDateTime.Minute());
        
            Event.StartDateTime = Event.EndDateTime.AddMinutes(-EventLengthInMinutes.IntValue());
        }
    }
    
    private void seedEndTime(){             
        // add default meeting length to start time in order to determine end time
        Event.EndDateTime = Event.StartDateTime.AddMinutes(EventLengthInMinutes.IntValue());
    }
    
    private User getUserById(string userId){
        List<User> owners = [SELECT managerId,
                                 Sales_Business_Unit_SBU__c,
                                 User_Country__c,
                                 Name,
                                 Id
                             FROM user
                             WHERE id = :userId];
                             
        if(owners.IsEmpty()){        
            return null;
        }
        
        return owners[0];
    }    
    
    private string getNameFromId(Id objectId){
        string objectType = objectId.getSObjectType().getDescribe().getName();
        
        if(objectType == 'Contact'){
            return [select name from contact where id = :objectId limit 1].Name;
        }
        
        if(objectType == 'Lead'){
            return [select name from lead where id = :objectId limit 1].Name;
        }
        
        if(objectType == 'Account'){
            return [select name from account where id = :objectId limit 1].Name;
        }
        
        if(objectType == 'Opportunity'){
            return [select name from Opportunity where id = :objectId limit 1].Name;
        }
        
        if(objectType == 'Field_Sales_Project_Members__c'){
            return [select name from Field_Sales_Project_Members__c where id = :objectId limit 1].Name;
        }
        
        return null;
    }
    
    private void setDefaultEventSubject(){
        // Set the subject in the correct locale based on event type and related contacts/ accounts
        String subject = getLocalisedEventType(Event);
        list<Contact> contacts = [SELECT name FROM contact WHERE id = :Event.WhoId LIMIT 1];
        list<Account> accounts= [SELECT name FROM account WHERE id = :Event.WhatId LIMIT 1];
        
        if(!contacts.isEmpty()){
            string contactName = contacts[0].Name;
            
            if(!string.isBlank(contactName)){
                subject += ' - ' + contactName;
            }
        }
        
        if(!accounts.isEmpty()){
            string accountName = accounts[0].Name;
            
            if(!string.isBlank(accountName)){
                subject += ' - ' + accountName;
            }
        }
        
        Event.Subject = subject;   
    }
    
    private string getLocalisedEventType(Event eventInstance){        
        List<Schema.PicklistEntry> picklistEntries = Schema.getGlobalDescribe().get('event').getDescribe().fields.getMap().get('Astra_Tech_Type__c').getDescribe().getPicklistValues(); 
        Map<String, String> fieldTranslations = new Map<String, String>(); 
        
        for(Schema.PicklistEntry ple : picklistEntries){
            fieldTranslations.put(ple.value, ple.label); 
        }
        
        system.debug('Event Type is: ' + eventInstance.Astra_Tech_Type__c);
        system.debug(fieldTranslations);
        
        return fieldTranslations.get(eventInstance.Astra_Tech_Type__c);
    }
    
    private List<Schema.PicklistEntry> GetPicklistValues(string objectType, string fieldName){
            return Schema.getGlobalDescribe().get(objectType).getDescribe().fields.getMap().get(fieldName).getDescribe().getPicklistValues();
    }
    
    private object GetDefaultValue(string objectType, string fieldName){
            return Schema.getGlobalDescribe().get(objectType).getDescribe().fields.getMap().get(fieldName).getDescribe().getDefaultValue();
    }

    private void UpdateEventStatusOptions(){        
        
        EventStatusOptions = new list<SelectOption>();
        
        for(PicklistEntry picklistEntry : EventStatusPicklistValues){
          String picklistEntryValue = picklistEntry.getValue();
    
            if((IsRecurrenceSeries && picklistEntryValue == 'Completed') || picklistEntryValue == '-') {
        continue;
            }
            EventStatusOptions.Add(new SelectOption(picklistEntryValue, picklistEntry.GetLabel()));
        }
    }
    
    global class MobileApiResult {
        
        public MobileApiResult(){
            WasSuccessful = false;            
            Errors = new List<string>();
            
        }
        
        public boolean WasSuccessful { get; set; }
        public List<string> Errors { get; set; }
        public Event evnt {get; set;} 
    }
}