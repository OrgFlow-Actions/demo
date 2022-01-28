/**20-May-2019: amitkumar.prabhat@mindtree.com
 * added method Save_Custom() as part of LightningSync Project
 **/
public class EventRelationPickerState {  
    private List<EventRelationVM> internalEventRelations { get; set; }
    
    public string EventId { get; set; }
    public boolean ForInvitees { get; set; }
    public boolean IsParent { get; set; }
    public string StringRepresentation { get; set; }
    public string PrimaryValue { get; set; }
    
    public List<string> RelationIds { 
        get {
            return StringRepresentation.split('\\,');
        }
    }
    
    public List<EventRelationVM> EventRelationVMs { 
        get {
            //if(internalEventRelations == null){
        		SetEventRelationsFromString();
            //}
            
            return internalEventRelations;
    	} 
        //set{
        //    internalEventRelations = value;
        //}
    }
    
    public void PopulateEventRelationsFromDatabase(){
        system.debug('Seeding from database');
        
        if(EventId == null){            
        	SetEventRelationsFromString();
        }
        
        List<EventRelation> EventRelations = [select relationId 
                                              from EventRelation 
                                              where isInvitee = :ForInvitees 
                                              	  and isParent = :IsParent
                                                  and eventId = :EventId
                                             	  and isWhat = false];
        
        system.debug(EventRelations);
        
        List<string> allInviteeIds = new List<string>();
        
        for(EventRelation er : EventRelations) {
            allInviteeIds.add(er.RelationId);
        }
//20-May-2019: amitkumar.prabhat@mindtree.com :: added part of LightningSync project    
        if(EventRelationDetails.lightningSyncEnabledProfile()) {
        List<EventAttendees__c> att = [SELECT RelationId__c FROM EventAttendees__c WHERE 
                                       EventId__c = :EventId and isParent__c = :IsParent];
            if(att.size() > 0){
                for(EventAttendees__c e:att){
                        allInviteeIds.add(e.RelationId__c);
                    }
            }
        }
        
        StringRepresentation = string.join(allInviteeIds, ',');        
        
        SetEventRelationsFromString();
    }
    
    public void Save(){
        system.debug('Save Event Relation VM');
        system.debug(StringRepresentation);
                    
        List<String> relations = RelationIds;        
        
        EventRelationService eventRelationService = new EventRelationService();
        
        system.debug('Saving Event relations (ForInvitees == ' + ForInvitees + ')');
        system.debug(relations);
        eventRelationService.SaveEventRelationSet(EventId, relations, false, ForInvitees, IsParent);
    }
  //20-May-2019: amitkumar.prabhat@mindtree.com
   public void Save_custom(){
       List<String> relations = RelationIds;
        if(relations.isEmpty()){
            System.debug('Event Relation not created because it\'s empty');    
           return;			
        }
		
        EventRelationService eventRelationService = new EventRelationService();
        
        system.debug('Saving to custom Event relations (ForInvitees == ' + ForInvitees + ')');
        system.debug(relations);
        eventRelationService.SaveCustomEventRelationSet(EventId, relations, false, ForInvitees, IsParent);
    }
    public void SetEventRelationsFromString(){
        system.debug('Seeding relations list from string: ' + StringRepresentation);
        
        internalEventRelations = new List<EventRelationVM>();  
        
        if(StringRepresentation == null) {   
            system.debug('There are no seed values');
            
            return;
        }    
        
        List<EventRelation> EventRelations = new List<EventRelation>();
        
        List<User> users = new List<User>();
        List<Contact> contacts = new List<Contact>();
        List<Lead> leads = new List<Lead>();
        
        if(!string.IsBlank(StringRepresentation)){
            List<string> allInviteeIds = StringRepresentation.split('\\,');
            
            users = [select id, name from user where id in :allInviteeIds];
            contacts = [select id, name, account.Name from contact where id in :allInviteeIds];
            leads = [select id, name, company from lead where id in :allInviteeIds];
        }
        
        for(User u : users){
            EventRelationVM invitee = new EventRelationVM(u.Id, u.Name, 'User', '');
            
            System.debug('Adding user:');
            System.debug(invitee);
            
            if(PrimaryValue != null && PrimaryValue == u.Id){
            	internalEventRelations.add(0, invitee);
            }
            else{
            	internalEventRelations.add(invitee);
            }
        }
        
        for(Contact c : contacts){
            EventRelationVM invitee = new EventRelationVM(c.Id, c.Name, 'Contact', c.Account.Name);
            
            System.debug('Adding contact:');
            System.debug(invitee);          
            
            System.debug('Primary Value is: ' + PrimaryValue);
            
            if(PrimaryValue != null && PrimaryValue == c.Id && internalEventRelations.size() > 0){
            	internalEventRelations.add(0, invitee);
            }
            else{
            	internalEventRelations.add(invitee);
            }
        }
        
        for(Lead l : leads){
            EventRelationVM invitee = new EventRelationVM(l.Id, l.Name, 'Lead', l.company);
            
            System.debug('Adding lead:');
            System.debug(invitee);
            
            if(PrimaryValue != null && PrimaryValue == l.Id && internalEventRelations.size() > 0){
            	internalEventRelations.add(0, invitee);
            }
            else{
            	internalEventRelations.add(invitee);
            }
        }      
    }
    
    public class EventRelationVM {
        public EventRelationVM(string p_id, string p_name, string p_type, string p_secondaryInfo){
            Id = p_id;
            Name = p_name;
            Type = p_type;
            SecondaryInfo = p_secondaryInfo;
        }
        
        public string Id { get; set; }
        public string Type { get; set; }
        public string Name { get; set; }
        public string SecondaryInfo { get; set; }
    }
}