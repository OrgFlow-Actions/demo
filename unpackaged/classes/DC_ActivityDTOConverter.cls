//Author: Sergey Legostaev
//Date: 05/02/2017
public class DC_ActivityDTOConverter {
    
    public static DC_ActivityDTO converToDTO(ActivityHistory history) {
        DC_ActivityDTO dto = new DC_ActivityDTO();
        dto.id = history.Id;
        dto.subject = history.Subject;
        dto.activityDate = history.ActivityDate;
        dto.whoId = history.WhoId;
        dto.whoName = history.Who.Name;
        dto.ownerId = history.OwnerId;
        dto.ownerName = history.Owner.Name;
        dto.eventStatus = history.Event_Status__c;
        dto.status = history.Status;
        dto.description = history.Description;
        dto.relatedToId = history.WhatId;
        dto.relatedToName = history.What.Name;
        dto.contactType = history.Contact_Type__c;
        return dto;
        //return converToDTO(history);
    }
    
    public static DC_ActivityDTO converToDTO(Event event) {
        DC_ActivityDTO dto = new DC_ActivityDTO();
        dto.id = event.Id;
        dto.subject = event.Subject;
        dto.activityDate = event.ActivityDate;
        dto.whoId = event.WhoId;
        dto.whoName = event.Who.Name;
        dto.ownerId = event.OwnerId;
        dto.ownerName = event.Owner.Name;
        dto.eventStatus = event.Event_Status__c;
        dto.description = event.Description;
        dto.relatedToId = event.WhatId;
        dto.relatedToName = event.What.Name;
        if (event.Call_Report__r != null) {
            dto.callNote = event.Call_Report__r.Call_Notes__c;
        }
        return dto;
    }
    /*
    private static DC_ActivityDTO converToDTO(sObject obj) {
        DC_ActivityDTO dto = new DC_ActivityDTO();
        dto.id = (String)obj.get('Id');
        dto.subject = (String)obj.get('Subject');
        dto.activityDate = (Date)obj.get('ActivityDate');
        dto.whoId = (String)obj.get('WhoId');
        dto.whoName = (String)obj.get('Who.Name');
        dto.ownerId = (String)obj.get('OwnerId');
        dto.ownerName = (String)obj.get('Owner.Name');
        dto.eventStatus = (String)obj.get('Event_Status__c');
        dto.description = (String)obj.get('Description');
        return dto;
	}*/
}