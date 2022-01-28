public class BulkCFEsController{
    //public integer MoveFromIndex { get; set; }
    //public integer MoveToIndex { get; set; }
    
    public final BulkCFEsVM Model { get; Set; } 
    
    public final List<SelectOption> VisitDurations { get; set; }
    public final List<SelectOption> TravelTimes { get; set; }
    
    public BulkCFEsController(){ 
        Model = new BulkCFEsVM();
        
        string idsParameter = ApexPages.currentPage().getParameters().get('idArray');
        
        if(idsParameter == null){
            //return;
            //throw new Exception('No linked object IDs were provided. Ensure that a comma seperated list of object IDs is provided in either a POST or GET prarameter called idArray.');
        }
        else{
            
            List<Account> accounts = [SELECT 
                                      Id, Name, BillingAddress, ShippingAddress
                                      FROM Account
                                      WHERE Id in :idsParameter.split(',')];
            
            List<Contact> contacts = [SELECT 
                                      Id, Name, MailingAddress
                                      FROM Contact
                                      WHERE Id in :idsParameter.split(',')];
            
            List<Opportunity> opportunities = [SELECT 
                                               Id, Name, Account.ShippingAddress
                                               FROM Opportunity
                                               WHERE Id in :idsParameter.split(',')];
            
            Integer stopDuration = 60;
            
            //List<geopointe__GP_User_Settings__c> userSettings = [select 
            //geopointe__Default_Route_Stop_Duration__c,
            //geopointe__Default_Route_Window_Start__c,
            //ownerid
            //from geopointe__GP_User_Settings__c
            //where ownerid = :UserInfo.getUserId()];
            
            //if(userSettings.size() > 0){
            //stopDuration = userSettings[0].geopointe__Default_Route_Stop_Duration__c.intValue();
            //}
            
            DateTime defaultStartTime = Datetime.newInstance(Date.today().addDays(1), Time.newInstance(9, 0, 0, 0));
            
            for(Account acc : accounts){
                BulkCFERouteEntry entry = new BulkCFERouteEntry();
                
                entry.Id = acc.Id;
                entry.Name = acc.Name;
                entry.Address = GetAddress(acc.BillingAddress != null ? acc.BillingAddress : acc.ShippingAddress);
                entry.StartTimePicker = new DateTimePickerVM(defaultStartTime);
                entry.VisitDuration = stopDuration;
                
                Model.RouteEntries.add(entry);
            }
            
            for(Contact con : contacts){
                BulkCFERouteEntry entry = new BulkCFERouteEntry();
                
                entry.Id = con.Id;
                entry.Name = con.Name;
                entry.Address = GetAddress(con.MailingAddress);
                entry.StartTimePicker = new DateTimePickerVM(defaultStartTime);
                entry.VisitDuration = stopDuration;
                
                entry.IsWhoId = true;
                
                Model.RouteEntries.add(entry);
            }
            
            for(Opportunity opp : opportunities){
                BulkCFERouteEntry entry = new BulkCFERouteEntry();
                
                entry.Id = opp.Id;
                entry.Name = opp.Name;
                entry.Address = GetAddress(opp.Account.ShippingAddress);
                entry.StartTimePicker = new DateTimePickerVM(defaultStartTime);
                entry.VisitDuration = stopDuration;
                
                Model.RouteEntries.add(entry);
            }
            
            VisitDurations = new List<SelectOption>();
            TravelTimes = new List<SelectOption>();
            
            for(integer i = 5; i <= 240; i+=5){
                VisitDurations.add(new SelectOption(String.valueOf(i), i + ' minutes'));
                TravelTimes.add(new SelectOption(String.valueOf(i), i + ' minutes'));
            }
        }
    }
    
    
    
    public PageReference saveRecords(){ 
        List<event> alleventToSave = new List<event>();
        EventWithCallReportService eventWithCallReportService = new EventWithCallReportService();
        User currentUser = getUserById(UserInfo.getUserId());
        String SBU = getSBU(currentUser);
        for(BulkCFERouteEntry entry : Model.RouteEntries){      
            DateTime startTime = entry.StartTimePicker.Value;
            Event eventToSave = new Event(
                OwnerId = UserInfo.getUserId(),
                StartDateTime = startTime,
                // eventWithCallReportService sets DurationInMinutes to null, so we cannot use that property
                EndDateTime = startTime.addMinutes(entry.VisitDuration)
            );
            system.debug(entry.Address);
            if(entry.IsWhoId){
                eventToSave.WhoId = entry.Id;
            }
            else{
                eventToSave.WhatId = entry.Id;
            }
            //need to bulkify -> location field populated with with contact addresswhotID or account addresswhatid if contact is blank
            //always will be account address for this scenario
            //eventToSave.Location = eventWithCallReportService.GetEventLocation(eventToSave);
            eventToSave.Location =entry.Address;
            //need to bulkify -> get event SBU__c field from user default SBU details
            //eventWithCallReportService.SetDefaultSBUs(eventToSave);
            eventToSave.SBU__c = SBU;
            eventToSave.Bypass_Auto_Invites_When_Creating__c = true;
            eventToSave.Send_Calendar_Invites__c = eventToSave.Send_Calendar_Invites__c;
            
            //need to bulkify -> Contact info is not necesary since only we have whatID 
            //eventWithCallReportService.Save(eventToSave, null, null, null, eventToSave.Send_Calendar_Invites__c);  
            //if(eventToSave.Subject!=null )
            eventToSave.Subject = '- ' + entry.Name;
            alleventToSave.add(eventToSave);
            
        }
        upsert(alleventToSave);
        String calendarUrl = 'Theme3'.equals(UserInfo.getUIThemeDisplayed()) ? '/00U/c' : '/lightning/o/Event/home';
        PageReference calendarPage = new PageReference(calendarUrl);
        calendarPage.setRedirect(true);
        return calendarPage;
    }
    
    private string GetAddress(Address address){         
        if(address == null){
            return null;
        }
        
        return buildAddressString(new List<string> {address.Street, address.City, address.State, address.PostalCode, address.Country});
    }
    
    private User getUserById(string userId){
        
        List<User> owners = [SELECT managerId,
                             Sales_Business_Unit_SBU__c,
                             User_Country__c,
                             Default_Activity_Length_In_Minutes__c,
                             Default_Event_Update_Calendar__c,
                             Default_Event_Subject__c,
                             Name,
                             Id,
                             Default_CFE_SBUs__c,
                             SBU_Ratio_ENDO__c,
                             SBU_Ratio_IMPL__c,
                             SBU_Ratio_ORTH__c,
                             SBU_Ratio_PREV__c,
                             SBU_Ratio_PROS__c,
                             SBU_Ratio_REST__c,
                             SBU_Ratio_CERE__c,
                             SBU_Ratio_INST__c,
                             SBU_Ratio_TRCE__c,
                             SBU_Ratio_IMAG__c
                             FROM user
                             WHERE id = :userId];
        
        if(owners.IsEmpty()){        
            return null;
        }
        
        return owners[0];
    }
    
    private String getSBU(user u){
        string SBU = null;
        double currentSBUPercentage = 0;
        if(u.Default_CFE_SBUs__c != null && u.Default_CFE_SBUs__c.length() > 0)
            SBU=u.Default_CFE_SBUs__c;
        if(u.SBU_Ratio_ENDO__c != null && u.SBU_Ratio_ENDO__c > currentSBUPercentage){
            SBU = 'Endodontics';
            currentSBUPercentage = u.SBU_Ratio_ENDO__c;
        }
        
        if(u.SBU_Ratio_IMPL__c != null && u.SBU_Ratio_IMPL__c > currentSBUPercentage){
            SBU = 'Implants';
            currentSBUPercentage = u.SBU_Ratio_IMPL__c;
        }
        
        if(u.SBU_Ratio_ORTH__c != null && u.SBU_Ratio_ORTH__c > currentSBUPercentage){
            SBU = 'Orthodontics';
            currentSBUPercentage = u.SBU_Ratio_ORTH__c;
        }
        
        if(u.SBU_Ratio_PREV__c != null && u.SBU_Ratio_PREV__c > currentSBUPercentage){
            SBU = 'Preventive';
            currentSBUPercentage = u.SBU_Ratio_PREV__c;
        }
        
        if(u.SBU_Ratio_PROS__c  != null && u.SBU_Ratio_PROS__c > currentSBUPercentage){
            SBU = 'Prosthetics';
            currentSBUPercentage = u.SBU_Ratio_PROS__c;
        }
        
        if(u.SBU_Ratio_REST__c != null && u.SBU_Ratio_REST__c > currentSBUPercentage){
            SBU = 'Restorative';
            currentSBUPercentage = u.SBU_Ratio_REST__c;
        }
        
        if(u.SBU_Ratio_CERE__c != null && u.SBU_Ratio_CERE__c > currentSBUPercentage){
            SBU = 'CAD/CAM';
            currentSBUPercentage = u.SBU_Ratio_CERE__c;
        }
        
        if(u.SBU_Ratio_INST__c != null && u.SBU_Ratio_INST__c > currentSBUPercentage){
            SBU = 'Instruments';
            currentSBUPercentage = u.SBU_Ratio_INST__c;
        }
        
        if(u.SBU_Ratio_TRCE__c != null && u.SBU_Ratio_TRCE__c > currentSBUPercentage){
            SBU = 'Treatment Centers';
            currentSBUPercentage = u.SBU_Ratio_TRCE__c;
        }
        
        if(u.SBU_Ratio_IMAG__c != null && u.SBU_Ratio_IMAG__c > currentSBUPercentage){
            SBU = 'Imaging Systems';
            currentSBUPercentage = u.SBU_Ratio_IMAG__c;
        }
        return(SBU);
    }
    
    private string buildAddressString(List<String> components){        
        string result = '';
        boolean firstLine = true;
        
        for(string component : components){
            if(component != null){
                if(firstLine){
                    result = component;
                    
                    firstLine = false;
                }
                else{
                    result = result + ', ' + component;
                }
            }
        }
        
        return result;
    }
    
    public class BulkCFEsVM{
        public BulkCFEsVM(){
            //DateTime defaultStartTime = Datetime.newInstance(Date.today().addDays(1), Time.newInstance(9, 0, 0, 0));
            
            RouteEntries = new List<BulkCFERouteEntry>();
            //StartTimePicker = new DateTimePickerVM(defaultStartTime);
            Event = new Event();
        }
        
        // Dummy object to allow us to display an s object date picker
        public Event Event { get; set; }
        public List<BulkCFERouteEntry> RouteEntries { get; set; }
    }
    
    public class BulkCFERouteEntry{
        
        public BulkCFERouteEntry (){
            IsWhoId = false;
        }
        
        public ID Id { get; set; }
        public string Name { get; set; }
        public string Address { get; set; }
        public boolean IsWhoId { get; set; }
        public DateTimePickerVM StartTimePicker { get; set; }
        public integer VisitDuration { get; set; }
    }
}