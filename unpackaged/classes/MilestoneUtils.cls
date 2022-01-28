/*---------------------------------------------------------
    Author: Nisreen Al Saleh (support@avity.com)
    Original Author: Salesforce
    Description: Marks milestones as completed based on different criterias  (#TFUS-000001231) 
    Test Class: Test_CaseTrigger
    Reference: https://help.salesforce.com/articleView?id=entitlements_milestones_trigger.htm&type=5
------------------------------------------------------------*/

public class MilestoneUtils {
    public static void completeMilestone(List<Id> caseIds, String milestoneName, DateTime complDate){ 
        
                 List<CaseMilestone> cmsToUpdate = [select Id, completionDate
                                                    from CaseMilestone cm
                                                    where caseId in :caseIds and cm.MilestoneType.Name=:milestoneName 
                                                    and completionDate = null limit 1];
               
                   for (CaseMilestone cm : cmsToUpdate){
                      cm.completionDate = complDate;
                           }
                                             
                       update cmsToUpdate;
                                         }
}