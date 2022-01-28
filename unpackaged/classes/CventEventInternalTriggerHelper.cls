/*-------------------------------------------------------------------------------------------------------
Author: 		Richard Trum (Glimt) 2020-03-03
Description:   	Cvent Event Trigger Helper Class
Test Class:      
History	
20200303 		Richard Trum			Created triggers in the trigger framework for the Cvent Event object
--------------------------------------------------------------------------------------------------------*/

public with sharing class CventEventInternalTriggerHelper {
    
    /*------------------------------------------------------------	
	Description:   	Method to replicate Cvent Events as Campaigns
    Inputs:        	@param
	------------------------------------------------------------*/
    
    public static void createCampaign(List<CVENT__Cvent_Event__c> newEventList){
        
    BatchSettings__c settings = BatchSettings__c.getInstance('Default');    
    if (Test.isRunningTest() || settings.CventEventInternalTriggerIsEnabled__c){
    
        
    for(CVENT__Cvent_Event__c ev : newEventList){
        
			CVENT__Cvent_Event__c eventToCopy = 
                							 [SELECT Id, 
                                             CVENT__Agenda__c,
                                             CVENT__Allow_Invitation__c, 
                                             CVENT__Allow_Registration__c,
                                             CVENT__AllowAddInvitationList__c,
                                             CVENT__Campaign__c,
                                             CVENT__Country_Name__c,
                                             CVENT__CurrencyCode__c,
                                             CVENT__StartDate__c,
                                             CVENT__EndDate__c,
                                             CVENT__EndDateTimeStr__c,
                                             CVENT__Event_Category__c,
                                             CVENT__Event_Address_City__c,
                                             CVENT__StartDateTimeStr__c,
                                             CVENT__Status__c,
                                         	 CVENT__Event_Status__c, //Primary_Specialty_Focus__c,
                                             Name,
                                             OwnerId
                                             FROM CVENT__Cvent_Event__c WHERE Id =: ev.Id];
        
        //Create new Campaign

        Campaign newCampaign = new Campaign();
        RecordType recType = [SELECT Id FROM RecordType WHERE DeveloperName='CventCampaign' AND SObjectType = 'Campaign'];
        newCampaign.RecordTypeId = recType.Id;
        newCampaign.Type = 'Event';
        newCampaign.Name = eventToCopy.Name;
        newCampaign.Campaign_Coordinator__c = eventToCopy.OwnerId;
        newCampaign.Campaign_Approver__c = eventToCopy.OwnerId;
        newCampaign.Campaign_City__c = eventToCopy.CVENT__Event_Address_City__c;
        newCampaign.StartDate = eventToCopy.CVENT__StartDate__c;
        newCampaign.EndDate = eventToCopy.CVENT__EndDate__c;
		newCampaign.Campaign_Country__c = eventToCopy.CVENT__Country_Name__c;
        newCampaign.IsActive = true;
        //newCampaign.SBU_Focus__c = ev.Primary_Specialty_Focus__c;
        List<CVENT_CampaignEventMapping__c> cmpStatus = new List<CVENT_CampaignEventMapping__c>();
        try{
        	cmpStatus = [SELECT CampaignStatus__c, CventEventStatus__c FROM CVENT_CampaignEventMapping__c WHERE CventEventStatus__c =: eventToCopy.CVENT__Event_Status__c];
        }
        catch(exception e){
            System.debug(e);
        }
        if(!cmpStatus.IsEmpty()){
        newCampaign.Status = cmpStatus[0].CampaignStatus__c;
        }
        
        try{
        	insert newCampaign;            
        }
        catch(DmlException e){
              DebugLog.addException(e, 'Method: CventEventInternalTrigger.createCampaign'); 
        }
        
        //update Cvent Event with Campaign Id        
        CVENT__Cvent_Event__c eventToUpdate = [SELECT Id FROM CVENT__Cvent_Event__c WHERE Id =: eventToCopy.Id];              
        eventToUpdate.CVENT__Campaign__c = newCampaign.Id;        
        update eventToUpdate;
        
        //Map campaign statuses        
        List<CVENT_CampaignAttendeeMapping__c> statusTemplate = [SELECT Id, CampaignStatus__c, CVENTAtteendeStatus__c FROM CVENT_CampaignAttendeeMapping__c];       
        List<CVENT__Attendee_Status_Mapping__c> statusMap = new List<CVENT__Attendee_Status_Mapping__c>();
        
        for(CVENT_CampaignAttendeeMapping__c currentStatus : statusTemplate){
            
            CVENT__Attendee_Status_Mapping__c newStatusMap = new CVENT__Attendee_Status_Mapping__c();
            newStatusMap.CVENT__Campaign_Member_Status__c = currentStatus.CampaignStatus__c;
            newStatusMap.CVENT__Attendee_Status__c = currentStatus.CVENTAtteendeStatus__c;
            newStatusMap.CVENT__Campaign__c = newCampaign.Id;
            statusMap.add(newStatusMap);
        }
        
        try{
         	insert statusMap;   
        }    
            catch(DmlException e){
                DebugLog.addException(e, 'Method: CventEventInternalTrigger.createCampaign, Action: Add status mappings');
            }
    }   
    }
        
   }
    
    /*------------------------------------------------------------	
	Description:   	Method to update Campaign based on Cvent Event
    Inputs:        	@param
	------------------------------------------------------------*/
    
    public static void updateCampaign(List<CVENT__Cvent_Event__c> newEventList){
        
    BatchSettings__c settings = BatchSettings__c.getInstance('Default');    
    if (Test.isRunningTest() || settings.CventEventInternalTriggerIsEnabled__c){
           
    for(CVENT__Cvent_Event__c eventToUpdate : newEventList){    
        	
        CVENT__Cvent_Event__c ev = [SELECT Id, 
                                             CVENT__Agenda__c,
                                             CVENT__Allow_Invitation__c, 
                                             CVENT__Allow_Registration__c,
                                             CVENT__AllowAddInvitationList__c,
                                             CVENT__Campaign__c,
                                             CVENT__Country_Name__c,
                                             CVENT__CurrencyCode__c,
                                             CVENT__StartDate__c,
                                             CVENT__EndDate__c,
                                             CVENT__EndDateTimeStr__c,
                                             CVENT__Event_Category__c,
                                             CVENT__Event_Address_City__c,
                                             CVENT__StartDateTimeStr__c,
                                             CVENT__Status__c,
                                    		 CVENT__Event_Status__c, //Primary_Specialty_Focus__c,
                                             Name,
                                             OwnerId
                                             FROM CVENT__Cvent_Event__c WHERE Id =: eventToUpdate.Id];
        
        if(!String.isBlank(ev.CVENT__Campaign__c)){
        Campaign campaignToUpdate = [SELECT Id, Name FROM Campaign WHERE Id =: ev.CVENT__Campaign__c];
        campaignToUpdate.Name = ev.Name;
        campaignToUpdate.Campaign_City__c = ev.CVENT__Event_Address_City__c;
        campaignToUpdate.StartDate = ev.CVENT__StartDate__c;
        campaignToUpdate.EndDate = ev.CVENT__EndDate__c;
		campaignToUpdate.Campaign_Country__c = ev.CVENT__Country_Name__c;
        //campaignToUpdate.SBU_Focus__c = ev.Primary_Specialty_Focus__c;
        
        List<CVENT_CampaignEventMapping__c> cmpStatus = new List<CVENT_CampaignEventMapping__c>();
        try{
        	cmpStatus = [SELECT CampaignStatus__c, CventEventStatus__c FROM CVENT_CampaignEventMapping__c WHERE CventEventStatus__c =: ev.CVENT__Event_Status__c];
        }
        catch(exception e){
            System.debug(e);
        }
        if(!cmpStatus.IsEmpty()){
        campaignToUpdate.Status = cmpStatus[0].CampaignStatus__c;
        }    
            
        update campaignToUpdate;
        }    
    }    
        
    }
        
    }
    
    /*------------------------------------------------------------	
	Description:   	Method to assign an owner to a Cvent Event
    Inputs:        	@param
	------------------------------------------------------------*/ 
    
    public static void setEventOwner(List<CVENT__Cvent_Event__c> newEventList){    
       
    BatchSettings__c settings = BatchSettings__c.getInstance('Default');    
    if (Test.isRunningTest() || settings.CventEventInternalTriggerIsEnabled__c){
     	
            for(CVENT__Cvent_Event__c eventToUpdate : newEventList){
                
                        CVENT__Cvent_Event__c ev = [SELECT Id,
                                             CVENT__Status__c,
                                    		 CVENT__Event_Status__c,
                                             Email_of_Meeting_Planner_KOL_Manager__c,       
                                             Name,
                                             OwnerId
                                             FROM CVENT__Cvent_Event__c WHERE Id =: eventToUpdate.Id];
                
                	List<User> usersToAssign = new List<User>();
                	try{
                		usersToAssign = [SELECT Id, Email, Name FROM User WHERE Email =: ev.Email_of_Meeting_Planner_KOL_Manager__c];
                    }
                	catch(exception e){
                    	System.debug('Assign owner to Cvent Event - no matching user could be found: ' + e);
                	}
                
                	if(!usersToAssign.IsEmpty()){
                        if(usersToAssign[0].Id != ev.OwnerId){
                    		ev.OwnerId = usersToAssign[0].Id;
                            System.debug('Updating owner');
                            try{
                            	update ev;
                            }
                            catch(exception e){
                                System.debug(e);
                            }
                		}
                	}
            }    
        
    }    
    }

}