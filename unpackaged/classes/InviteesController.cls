public class InviteesController {
    private List<Invitee> InternalInvitees { get; set; }
    
    public string EventId { get; set; }    
    public string SeedIDs { get; set; }

    public List<Invitee> Invitees { 
        get {
        	system.debug('Seed IDs is ' + SeedIDs);
            //if(InternalInvitees == null || !string.IsBlank(SeedIDs)){
            if(InternalInvitees == null || SeedIDs != null){
                populateInvitees();
            }
            
            return InternalInvitees;
    	} 
    }
    
    private void populateInvitees(){
        InternalInvitees = new List<Invitee>();   
        
        if(EventId == null && SeedIDs == null) {   
            system.debug('EventId is null');
            return;
        }    
        
        List<EventRelation> EventRelations = new List<EventRelation>();
        
        List<User> users = new List<User>();
        List<Contact> contacts = new List<Contact>();
        List<Lead> leads = new List<Lead>();
        
        system.debug('Seed IDs is ' + SeedIDs);
        
        if(string.IsBlank(SeedIDs)){
        	EventRelations = [select relationId from EventRelation where isInvitee = true and eventId = :EventId];
        
            List<string> allInviteeIds = new List<string>();
            
            for(EventRelation er : EventRelations) {
                allInviteeIds.add(er.RelationId);
            }
            
            users = [select id, name from user where id in :allInviteeIds];
            contacts = [select id, name from contact where id in :allInviteeIds];
            leads = [select id, name from lead where id in :allInviteeIds];
        }
        else{
            List<string> allInviteeIds = SeedIDs.split('\\,');
            
            users = [select id, name from user where id in :allInviteeIds];
            contacts = [select id, name from contact where id in :allInviteeIds];
            leads = [select id, name from lead where id in :allInviteeIds];
        }
        
        for(User u : users){
            Invitee invitee = new Invitee(u.Id, u.Name, 'user');
            
            InternalInvitees.add(invitee);
        }
        
        for(Contact c : contacts){
            Invitee invitee = new Invitee(c.Id, c.Name, 'contact');
            
            InternalInvitees.add(invitee);
        }
        
        for(Lead l : leads){
            Invitee invitee = new Invitee(l.Id, l.Name, 'lead');
            
            InternalInvitees.add(invitee);
        }        
    }
    
    public class Invitee {
        public Invitee(string p_id, string p_name, string p_type){
            Id = p_id;
            Name = p_name;
            Type = p_type;
        }
        
        public string Id { get; set; }
        public string Type { get; set; }
        public string Name { get; set; }
    }
}