/*-------------------------------------------------------------------------------------------------------
Author:         Ahmed LOUDRASSI (Salesforce) 20191127
Description:    Expert  Trigger Handler Class
History
20191023   Ahmed LOUDRASSI   Migrated   setProgramParticipationName trigger. (#)
----------------------------------------------------------------------------------------*/
public class ProgramParticipationTriggerHelper {
    
	public static void setProgramParticipationName(List<Program_Participation__c> newProgramParticipationList) {
        List<Program_Participation__c> programParticipationsToUpdateList = new List<Program_Participation__c>();
        List<ID> programParticipationsToUpdateIds = new List<ID>();
        for(Program_Participation__c programParticipation : newProgramParticipationList) {
            if(programParticipation.Program__c != null){
                programParticipationsToUpdateList.add(programParticipation);
                programParticipationsToUpdateIds.add(programParticipation.Program__c);
            }
        }
        Map<ID,Program__c> programs = new Map<ID,Program__c> 
                                    ([select id, Name from Program__c where id=:programParticipationsToUpdateIds]);
        
        for(Program_Participation__c programParticipation : programParticipationsToUpdateList) {
            programParticipation.Name = programs.get(programParticipation.Program__c).Name + '-' + 
                                        programParticipation.SBU__c + '-' +
                                        programParticipation.Participation_Type__c;
        } 
    }
}