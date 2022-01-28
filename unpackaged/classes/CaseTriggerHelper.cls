/*-------------------------------------------------------------------------------------------------------
Author:         NISREEN ALSALEH (support@avity.com) 25-March-2021
Description:    Case Trigger Helper Class   
History
20210518	Nisreen AlSaleh		Updates on defaultEntitlement to check if the case entitlement not equals to the assigned account entitlement (#TFUS-000003133)
20210711	Nisreen AlSaleh		Updates on defaultEntitlement to assign a blank value for the case entitlement if the account doesn't have an entitlement (#TFUS-000003317)
--------------------------------------------------------------------------------------------------------*/
public class CaseTriggerHelper {
    
    /*------------------------------------------------------------  
Description:    Marks First Response Email milestone as completed when the case status is changed to Active (#TFUS-000001231)
Inputs:         @param newCases
Reference:      https://help.salesforce.com/articleView?id=entitlements_milestones_trigger.htm&type=5
------------------------------------------------------------*/
    public static void completeFirstResponseTime(List<Case> newCases) {
        
        if (UserInfo.getUserType() == 'Standard'){  
            DateTime completionDate = System.now(); 
            List<Id> updateCases = new List<Id>();
            
            for (Case c : newCases){
                if (((c.Status == 'Activ e') && c.RecordTypeId == '01220000000AvOOAA0')&&((c.SlaStartDate 
                                                                                          <= completionDate)&&(c.SlaExitDate == null) ))
                    updateCases.add(c.Id);
            }
            
            if (updateCases.isEmpty() == false){
                try{
                    milestoneUtils.completeMilestone(updateCases, 'First Response Time', completionDate);
                } catch(exception e){
                    DebugLog.addException(e, 'Error in CompleteFirstResponseTime');
                }
            }
            
        }
    }
    
    /*------------------------------------------------------------  
Description:    If the Entitlement Name is not set then, check to see if the Contact on the Case has an active Entitlement
and select the first one.  If not then check to see if the Account on the Case has an active Entitlement. (#TFUS-000001231)
Inputs:         @param newCases
------------------------------------------------------------*/
    public static void defaultEntitlement(Case[] newcases) {
        
        Set<Id> contactIds = new Set<Id>(); 
        Set<Id> acctIds = new Set<Id>();
        
        for (Case c : newcases) {
            contactIds.add(c.ContactId);
            acctIds.add(c.AccountId);
        }
        
        List <EntitlementContact> entlContacts = [Select e.EntitlementId,e.ContactId,e.Entitlement.AssetId
                                                  From EntitlementContact e
                                                  Where e.ContactId in :contactIds
                                                  And e.Entitlement.EndDate >= Today
                                                  And e.Entitlement.StartDate <= Today];
        if(entlContacts.isEmpty()==false){
            for(Case c : newcases){
                if(c.EntitlementId == null && c.ContactId != null){
                    for(EntitlementContact ec:entlContacts){
                        if(ec.ContactId==c.ContactId){
                            c.EntitlementId = ec.EntitlementId;
                            break;
                        }
                    }
                }
            }
        } else{
            List <Entitlement> entls = [Select e.StartDate, e.Id, e.EndDate, e.AccountId, e.AssetId
                                        From Entitlement e
                                        Where e.AccountId in :acctIds And e.EndDate >= Today
                                        And e.StartDate <= Today];
            if(entls.isEmpty()==false){
                for(Case c : newcases){
                    if((c.AccountId != null)){
                        for(Entitlement e:entls){
                            if((e.AccountId==c.AccountId) || (c.EntitlementId != e.Id)){
                                c.EntitlementId = e.Id;
                                break;
                            }
                        }
                    }
                }
            }
            else{
                for(Case c : newcases){
                     c.EntitlementId = null;
                    break;
                }
            }
        }
        
    }
    
    /*------------------------------------------------------------  
Description:     Marks Resolution Time milestone as completed when the case status is changed to Closed (#TFUS-000001231)
Inputs:         @param newCases
Reference:      https://help.salesforce.com/articleView?id=entitlements_milestones_trigger.htm&type=5
------------------------------------------------------------*/  
    
    public static void completeResolutionTimeMilestone (List<Case> newCases) { 
        if (UserInfo.getUserType() == 'Standard'){
            DateTime completionDate = System.now(); 
            List<Id> updateCases = new List<Id>();
            for (Case c : newcases){
                if (c.RecordTypeId == '01220000000AvOOAA0'&&((c.isClosed == true)||(c.Status == 'Closed'))&&((c.SlaStartDate 
                                                                                                              <= completionDate)&&(c.SlaExitDate == null)))
                    updateCases.add(c.Id);
            }
            if (updateCases.isEmpty() == false){
                try{
                    milestoneUtils.completeMilestone(updateCases, 'Resolution Time', completionDate);
                }
                catch(exception e){
                    DebugLog.addException(e, 'Error in CompleteResolutionTimeMilestone');
                }
            }
        }
    } 
}