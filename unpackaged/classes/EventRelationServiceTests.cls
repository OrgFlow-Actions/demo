@isTest
public class EventRelationServiceTests {
    static testMethod void SaveEventRelationSet_SavesEntireSet(){          
        EventRelationService sut = new EventRelationService();
        
        string eventId = createEvent().Id;
        
        sut.SaveEventRelationSet(eventId, new string[] { createContact('1').id, createContact('2').id }, false, true, true);
        
        system.assert(getEventRelations(eventId, false, true, true).size() == 2);
    }	
    
    static testMethod void SaveEventRelationSet_SavesEntireSet_NoDupes(){
        EventRelationService sut = new EventRelationService();
        
        string eventId = createEvent().Id;
        Contact contact2 = createContact('2');
        
        sut.SaveEventRelationSet(eventId, new string[] { createContact('1').id, contact2.id, contact2.id }, false, true, true);
        
        system.assert(getEventRelations(eventId, false, true, true).size() == 2);
    }
    
    static testMethod void AddEventRelationToSet_AddsAsExpected(){          
        EventRelationService sut = new EventRelationService();
        
        string eventId = createEvent().Id;
        
        sut.SaveEventRelationSet(eventId, new string[] { createContact('1').id, createContact('2').id }, false, true, true);
        sut.AddEventRelationToSet(eventId, createContact('3').Id, false, true, true);
        
        system.assert(getEventRelations(eventId, false, true, true).size() == 3);
    }
    
    static testMethod void AddEventRelationToSet_NoDupes(){          
        EventRelationService sut = new EventRelationService();
        
        string eventId = createEvent().Id;
        Contact contact2 = createContact('2');
        
        sut.SaveEventRelationSet(eventId, new string[] { createContact('1').id, contact2.id, contact2.id }, false, true, true);
        sut.AddEventRelationToSet(eventId, contact2.id, false, true, true);
        
        system.assert(getEventRelations(eventId, false, true, true).size() == 2);
    }	
    
    static testMethod void SaveEventRelation_AddsSingleRecord(){          
        EventRelationService sut = new EventRelationService();
        
        string eventId = createEvent().Id;
        
        sut.SaveEventRelation(eventId, createAccount('1').Id, true, false, true);
        
        system.assert(getEventRelations(eventId, true, false, true).size() == 1);
    }
    
    static testMethod void SaveEventRelation_OverridesCurrentSet(){          
        EventRelationService sut = new EventRelationService();
        User u1 = new User();
        u1.LastName= 'tstUsr135';
        u1.Alias= 'tstUsr13';
        u1.TimeZoneSidKey= 'Asia/Taipei';
        u1.LocaleSidKey= 'en_US';
        u1.EmailEncodingKey= 'UTF-8';
        u1.LanguageLocaleKey = 'en_US';
        u1.Username = 'Tst1113355@dentsplysirona.com';
        u1.Email = 'Tst1133555@dentsplysirona.com';
        u1.ProfileId = [select id from profile where Name like '%System Administrator%' Limit 1][0].Id;
        insert u1;
        string eventId = createEvent().Id;
        Contact contact2 = createContact('2');
        
        sut.SaveEventRelationSet(eventId, new string[] { createContact('1').id, createContact('2').id }, false, true, true);
        sut.SaveEventRelation(eventId, createContact('3').id, false, true, true);
        system.assert(getEventRelations(eventId, false, true, true).size() == 1);
        sut.SaveCustomEventRelationSet(eventId, new string[] { u1.Id }, false, true, true);
        EventRelationPickerState evrp = new EventRelationPickerState();
          evrp.ForInvitees = true;     
            evrp.IsParent = false;        
            evrp.PopulateEventRelationsFromDatabase();
        evrp.EventId = eventId;
        evrp.save();
        evrp.Save_custom();

    }	
    
    private static List<EventRelation> getEventRelations(string eventId, boolean isWhat, boolean isInvitee, boolean isParent){
        return [select id, relationId 
                from EventRelation 
                where eventid = :eventId 
                and isInvitee = :isInvitee  
                and isParent = :isParent  
                and isWhat = :isWhat];
    }
    
    private static Account createAccount(string name){
        Account account = new Account(Name = name);        
        insert account;
        
        return account;
    }
    
    private static Contact createContact(string lastName){              
        Contact contact = new Contact(FirstName = 'Test', LastName = lastName); 
        insert contact;
        
        return contact;
    }
    
    private static Event createEvent(){
        Event event = new Event(
			Subject = 'Test', 
			StartDateTime = datetime.now(), 
			EndDateTime = datetime.now().addMinutes(60), 
			WhoId = createContact('a').Id,
			SBU__c = 'Endodontics');

        insert event; 
        
        return event;
    }
}