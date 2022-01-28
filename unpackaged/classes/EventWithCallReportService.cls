public class EventWithCallReportService {
    public void Save(Event eventToSave, 
                     Call_Report__c callReportToSave, 
                     EventRelationPickerState whoIdPickerState, 
                     EventRelationPickerState inviteesPickerState, 
                     boolean sendCalendarInvites){        
                         
        SavePoint savePoint = Database.setSavepoint();  

        // This is required in order to restore the original subject in the event of a DML error
        string originalEventSubject = eventToSave.Subject;
        Boolean syncProfile = EventRelationDetails.lightningSyncEnabledProfile();
        try{
            system.debug('Calling into EventWithCallReportService Save():');
            system.debug(eventToSave);
            system.debug('WhoIdPickerState:');
            system.debug(whoIdPickerState);
            system.debug('InviteesPickerState:');
            system.debug(inviteesPickerState);
            
            boolean eventIsNew = eventToSave.Id == null;    
            
            eventToSave.Bypass_Auto_Invites_When_Creating__c = true;
            eventToSave.Send_Calendar_Invites__c = SendCalendarInvites;
            eventToSave.DurationInMinutes = null;
            If(eventIsNew)
            eventToSave.EventOrigin__c = 'Classic';
            
            if(eventToSave.Co_travel__c != 'Manager') {                
                eventToSave.Co_Travel_Manager__c = null;
            }
           
            if(callReportToSave != null){
                if(eventIsNew) {
                    callReportToSave.Id = null;
                }

                User eventOwner = getUserById(eventToSave.OwnerId);
                if(eventOwner != null){
                    System.debug('Setting Call Report Assigned To User Country to "' + eventOwner.User_Country__c + '"');

                    callReportToSave.Assigned_To_User_Country__c = eventOwner.User_Country__c;
                }
                
                System.debug('Upsert Call Report object...');
                System.debug(callReportToSave);
                
                upsert callReportToSave;
                eventToSave.Call_Report__c = callReportToSave.Id;
            }
            
            
            System.debug('Event Start Date Time is: ' + eventToSave.StartDateTime);
            eventToSave.ActivityDate = eventToSave.StartDateTime.Date(); // Explicitly set ActivityDate so that validation rules that use this field wil work as expected
            
            // Clear out duration and activity date so that they are automatically calculated
            if(eventToSave.IsAllDayEvent){      
                TimeZone tz = UserInfo.getTimeZone();
                eventToSave.StartDateTime = eventToSave.StartDateTime.AddSeconds(tz.getOffset(eventToSave.StartDateTime)/1000);  
                eventToSave.EndDateTime = eventToSave.EndDateTime.AddSeconds(tz.getOffset(eventToSave.EndDateTime)/1000); 
                
                eventToSave.ActivityDate = null;
            }      
            
            if(whoIdPickerState != null && !whoIdPickerState.RelationIds.IsEmpty() && string.isNotEmpty(whoIdPickerState.RelationIds[0])){
                system.debug('Setting Event WhoId to "' + whoIdPickerState.RelationIds[0] + '"');
                eventToSave.WhoId = whoIdPickerState.RelationIds[0];
            }
            
            // remove all event relations /todo: we don't always want to do this. should filter for who ids only
            if(!eventIsNew){
                List<EventRelation> ersToDelete = [select id 
                                                   from EventRelation 
                                                   where eventId = :eventToSave.Id 
                                                   and IsInvitee = false];
                
                delete ersToDelete;
            }
            
            if(String.isEmpty(originalEventSubject)) {
                User currentUser = getUserById(UserInfo.getUserId());

                eventToSave.Subject = currentUser.Default_Event_Subject__c;
            }
            
            if(String.isEmpty(eventToSave.Location)) {
                eventToSave.Location = GetEventLocation(eventToSave);
            }           

            ResolveSubjectTokens(eventToSave);
            
            system.debug('Saving Event object...');
            system.debug(eventToSave);
            upsert eventToSave;
            
            system.debug('Event object saved');
            
            if(inviteesPickerState != null){
                inviteesPickerState.EventId = eventToSave.Id; 
            }
            
            if(whoIdPickerState != null){
                whoIdPickerState.EventId = eventToSave.Id; 
            }
//changed on 20-May-2019 : amitkumar.prabhat@mindtree.com            
            if(!Test.isRunningTest()){
                if(inviteesPickerState != null){
                    if(syncProfile) {
                    if(sendCalendarInvites) {
                    inviteesPickerState.Save(); 
                    }
                    else{
                     inviteesPickerState.Save_Custom();   
                    }
                    }
                    else inviteesPickerState.Save();
                }
                
                if(whoIdPickerState != null){
                    whoIdPickerState.Save(); 
                }
            }
            
            EventRelationService eventRelationService = new EventRelationService();
            
            eventRelationService.SaveEventRelation(eventToSave.Id, eventToSave.WhatId, true, false, true);
            
            if(eventToSave.Co_Travel_Manager__c != null){
                eventRelationService.AddEventRelationToSet(eventToSave.Id, eventToSave.Co_Travel_Manager__c, /*isWhat*/ false, /*isInvitee*/ true, /*isParent*/ false);
            }
            
            System.debug('Event Start Date Time is: ' + Event.StartDateTime);
             //if syncProfile don't execute this
            if(eventIsNew && !syncProfile){
                System.Debug('Event is new; calling into Notices Manager');
                DC_EventNoticesManager.manageNotices_onEventsInserted(new List<Event> { eventToSave }, false);
            }
            
            User owner = getUserById(eventToSave.OwnerId);
            
            if(owner != null && string.isBlank(owner.User_Country__c)){
                owner.User_Country__c = eventToSave.Call_Report__r.Assigned_To_User_Country__c;
                update owner;
            }            
        }
        catch(DmlException ex){            
            Database.rollback(savePoint);

            eventToSave.Subject = originalEventSubject;
            
            throw ex;
        }
        // 210408 kdoruibin TFUS-000002673: Moved SyncClonedEvent() into class
        //Amit Prabhat added code for updating cloned Event in case of update_calender set as false ...
        //..and Parent Event gets an update
        syncClonedEvent(eventToSave.Id);
    }

    // 210408 kdoruibin TFUS-000002673: Moved SyncClonedEvent() into class
    public static void syncClonedEvent(Id parEventId) {
        List<Event> childEventUpdate = new List<Event> ();
        List<Id> attendee = new List<Id> ();
        Event parEvent = [select Astra_Tech_Type__c, Call_Report__c, Contact_Id__c, Customer_Facing_Event__c,
            Related_to_Account_Opportunity__c, SBU__c, Objective__c, Co_travel__c, Co_Travel_Manager__c,
            WhatCount, WhatId, WhoCount, WhoId, AccountId, EventOrigin__c, Activity_Subtype__c,
            DurationInMinutes, EventSubtype, Event_Status__c, EndDateTime, Location, Dealer_Customer__c,
            IsAllDayEvent, IsArchived, IsDeleted, ActivityDateTime, IsGroupEvent, new_customer_acquisition_DE__c,
            Number_of_implants_TR__c, ActivityDate, Number_of_patients_TR__c, ShowAs, IsPrivate, RecordTypeId,
            StartDateTime, Subject from Event where id =: parEventId limit 1
        ][0];
        List <EventAttendees__c> att = [SELECT Id, EventId__c, RelationId__c
            FROM EventAttendees__c
            WHERE EventId__c =: parEventId
        ];
        if (att.size() > 0) {
            for (EventAttendees__c chld: att) {
                attendee.add(chld.RelationId__c);
            }
            List<Event> childEvents = [select id, OwnerId from Event
                where OwnerId IN: attendee
                and Call_Report__c =: parEvent.Call_Report__c
            ];
            for (Event clEvent: childEvents) {
                clEvent.Astra_Tech_Type__c = parEvent.Astra_Tech_Type__c;
                clEvent.new_customer_acquisition_DE__c = parEvent.new_customer_acquisition_DE__c;
                clEvent.Customer_Facing_Event__c = parEvent.Customer_Facing_Event__c;
                clEvent.Number_of_implants_TR__c = parEvent.Number_of_implants_TR__c;
                clEvent.SBU__c = parEvent.SBU__c;
                clEvent.Co_Travel_Manager__c = parEvent.Co_Travel_Manager__c;
                clEvent.WhatId = parEvent.WhatId;
                clEvent.Co_travel__c = parEvent.Co_travel__c;
                clEvent.WhoId = parEvent.WhoId;
                clEvent.Objective__c = parEvent.Objective__c;
                clEvent.DurationInMinutes = parEvent.DurationInMinutes;
                clEvent.Activity_Subtype__c = parEvent.Activity_Subtype__c;
                clEvent.Event_Status__c = parEvent.Event_Status__c;
                clEvent.IsAllDayEvent = parEvent.IsAllDayEvent;
                clEvent.EventOrigin__c = parEvent.EventOrigin__c;
                //clEvent.EventSubtype = parEvent.EventSubtype;
                clEvent.Location = parEvent.Location;
                clEvent.IsPrivate = parEvent.IsPrivate;
                clEvent.RecordTypeId = parEvent.RecordTypeId;
                clEvent.ShowAs = parEvent.ShowAs;
                clEvent.StartDateTime = parEvent.StartDateTime;
                clEvent.Subject = parEvent.Subject;
                clEvent.EndDateTime = parEvent.EndDateTime;
                clEvent.ActivityDate = parEvent.ActivityDate;
                clEvent.ActivityDateTime = parEvent.ActivityDateTime;
                clEvent.Dealer_Customer__c = parEvent.Dealer_Customer__c;
                clEvent.Number_of_patients_TR__c = parEvent.Number_of_patients_TR__c;
                childEventUpdate.add(clEvent);
            }
            database.update(childEvents);
        }
    }

    public void ResolveSubjectTokens(Event e){
        string subject = e.Subject;

        // This is a fail safe to ensure that null is not passed to the pattern matcher.
        if(subject == null){
            subject = '';
        }


        // This regex looks more complex than it actually is. It should match the following:
        // \{ Matches the character '{' literally
        // .*? Matches any number of characters (including none)
        // \|\| Matches '||' literally
        // .+? Matches a string containing 1 or more characters
        // \|\| Matches '||' literally
        // .*? Matches any number of characters (including none)
        // \} Matches the character '}' literally
        //
        // Note: all backslash characters have to be escaped in the string, which is the reason the double backslashes are required.
        //
        // eg: {[0 or more characters]||[1 or more characters]||[0 or more characters]}
        string regex = '\\{.*?\\|\\|.+?\\|\\|.*?\\}';
        Matcher tokenMatcher = Pattern.Compile(regex).Matcher(subject);
        
        while(tokenMatcher.find()){
            string matchedToken = tokenMatcher.group();

            // Strip the bounding {} characters from the token and split by ||
            // 0 = Prefix
            // 1 = Token
            // 2 = Suffix
            string[] tokenParts = matchedToken.removeStart('{').removeEnd('}').split('\\|\\|', 3);

            string prefix = tokenParts[0];
            string token = tokenParts[1];
            string suffix = tokenParts[2];

            string resolvedToken;
            boolean replaceToken = true;

            if(token.equalsIgnoreCase('EventType')) {
                resolvedToken = getLocalisedEventType(e);
            }
            else if(token.equalsIgnoreCase('WhoName')) {
                resolvedToken = getNameFromId(e.WhoId);
            }
            else if(token.equalsIgnoreCase('RelatedToName')) {
                resolvedToken = getNameFromId(e.WhatId);
            }
            else if(token.equalsIgnoreCase('AccountERP')) {
                resolvedToken = getErpNumberFromAccount(e.WhatId);
            }
            else {
                replaceToken = false;
            }

            if(!String.isEmpty(resolvedToken)) {
                // If there is a value supplied for the token, then also apply the prefix and suffix
                resolvedToken = prefix + resolvedToken + suffix;
            }

            if(resolvedToken == null){
                // This is a fail safe, to ensure that null is never passed into the replace method below.
                resolvedToken = '';
            }

            if(replaceToken) {
                System.debug('Replacing the event subject token "' + matchedToken + '" with the value "' + resolvedToken + '"');
                subject = subject.replace(matchedToken, resolvedToken);
            }
        }

        e.Subject = subject;
    }

    public string GetEventLocation(Event e){        
        string addressString;
        
        List<Contact> contacts = [SELECT mailingstreet, mailingcity, mailingstate, mailingPostalCode, mailingCountry
                                  FROM contact 
                                  WHERE id = :e.WhoId 
                                  LIMIT 1];
        
        if(!contacts.IsEmpty()){
            Contact contact = contacts[0];
            
            addressString = buildAddressString(new List<string> {contact.mailingstreet, contact.mailingcity, contact.mailingstate, contact.mailingPostalCode, contact.mailingCountry});
            
            
            if(addressString.Length() > 0){
                return addressString;
            }
        }
        
        List<Account> accounts = [SELECT billingstreet, billingcity, billingstate, billingPostalCode, billingCountry,
                                            shippingstreet, shippingcity, shippingstate, shippingPostalCode, shippingCountry
                                   FROM account 
                                   WHERE id = :e.WhatId];
                           
        if(accounts.IsEmpty()){
            system.debug('Could not calculate location because there is no account with Id ' + e.WhatId);       
            
            return null;
        }
        
        Account account = accounts[0];
                           
        addressString = buildAddressString(new List<string> {account.billingstreet, account.billingcity, account.billingstate, account.billingPostalCode, account.BillingCountry});
    
        if(addressString.Length() == 0){
            addressString = buildAddressString(new List<string> {account.shippingstreet, account.shippingcity, account.shippingstate, account.shippingPostalCode, account.shippingCountry});
        }
    
        return addressString;
    }

    public void SetDefaultSBUs(Event e){
        User owner = [SELECT id, 
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
                       SBU_Ratio_IMAG__c,
                       Sales_Business_Unit_SBU__c                       
                      FROM user 
                      WHERE id = :e.OwnerId][0];
        
        if(owner.Default_CFE_SBUs__c != null && owner.Default_CFE_SBUs__c.length() > 0){
            e.SBU__c = owner.Default_CFE_SBUs__c;

            return;
        }
        
        string SBU = null;
        double currentSBUPercentage = 0;
        
        if(owner.SBU_Ratio_ENDO__c != null && owner.SBU_Ratio_ENDO__c > currentSBUPercentage){
            SBU = 'Endodontics';
            currentSBUPercentage = owner.SBU_Ratio_ENDO__c;
        }
        
        if(owner.SBU_Ratio_IMPL__c != null && owner.SBU_Ratio_IMPL__c > currentSBUPercentage){
            SBU = 'Implants';
            currentSBUPercentage = owner.SBU_Ratio_IMPL__c;
        }
        
        if(owner.SBU_Ratio_ORTH__c != null && owner.SBU_Ratio_ORTH__c > currentSBUPercentage){
            SBU = 'Orthodontics';
            currentSBUPercentage = owner.SBU_Ratio_ORTH__c;
        }
        
        if(owner.SBU_Ratio_PREV__c != null && owner.SBU_Ratio_PREV__c > currentSBUPercentage){
            SBU = 'Preventive';
            currentSBUPercentage = owner.SBU_Ratio_PREV__c;
        }
        
        if(owner.SBU_Ratio_PROS__c  != null && owner.SBU_Ratio_PROS__c > currentSBUPercentage){
            SBU = 'Prosthetics';
            currentSBUPercentage = owner.SBU_Ratio_PROS__c;
        }
        
        if(owner.SBU_Ratio_REST__c != null && owner.SBU_Ratio_REST__c > currentSBUPercentage){
            SBU = 'Restorative';
            currentSBUPercentage = owner.SBU_Ratio_REST__c;
        }
        
        if(owner.SBU_Ratio_CERE__c != null && owner.SBU_Ratio_CERE__c > currentSBUPercentage){
            SBU = 'CAD/CAM';
            currentSBUPercentage = owner.SBU_Ratio_CERE__c;
        }
        
        if(owner.SBU_Ratio_INST__c != null && owner.SBU_Ratio_INST__c > currentSBUPercentage){
            SBU = 'Instruments';
            currentSBUPercentage = owner.SBU_Ratio_INST__c;
        }
        
        if(owner.SBU_Ratio_TRCE__c != null && owner.SBU_Ratio_TRCE__c > currentSBUPercentage){
            SBU = 'Treatment Centers';
            currentSBUPercentage = owner.SBU_Ratio_TRCE__c;
        }
        
        if(owner.SBU_Ratio_IMAG__c != null && owner.SBU_Ratio_IMAG__c > currentSBUPercentage){
            SBU = 'Imaging Systems';
            currentSBUPercentage = owner.SBU_Ratio_IMAG__c;
        }
                
        e.SBU__c = SBU;
    }
      
    private string getNameFromId(Id objectId){
        if(objectId == null) {
            return null;
        }

        string objectType = objectId.getSObjectType().getDescribe().getName();

        // objectType and objectId are safe and do not need to be escaped
        sObject so = Database.query('select name from ' + objectType + ' where id = \'' + objectId + '\' limit 1');

        if(so == null) {
            return null;
        }

        return (string) so.get('Name');
    }
    
    private User getUserById(string userId){
        List<User> owners = [SELECT managerId,
                                 Sales_Business_Unit_SBU__c,
                                 User_Country__c,
                                 Default_Activity_Length_In_Minutes__c,
                                 Default_Event_Update_Calendar__c,
                                 Default_Event_Subject__c,
                                 Name,
                                 Id
                             FROM user
                             WHERE id = :userId];
                             
        if(owners.IsEmpty()){        
            return null;
        }
        
        return owners[0];
    }
    
    @TestVisible
    private string getErpNumberFromAccount(Id objectId){
        if(objectId == null) {
            return null;
        }

        string objectType = objectId.getSObjectType().getDescribe().getName();
        if(objectType != 'Account') {
            return null;
        } 

        Account acc = Database.query('select Movex__c from Account where id = \'' + objectId + '\' limit 1');

        if(acc == null) {
            return null;
        }

        return acc.Movex__c;
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
}