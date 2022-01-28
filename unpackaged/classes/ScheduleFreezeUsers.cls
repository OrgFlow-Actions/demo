/*-------------------------------------------------------------------------------------------------------
Author:         Miguel Coimbra(Salesforce) 20201012
Description:    Class to Schedule BatchFreezeUsers Batchable Class
                Frequence : each sunday
Test Class:     Test_ScheduleFreezeUsers
History 
----------------------------------------------------------------------------------------*/
global class ScheduleFreezeUsers implements Schedulable {
    global void execute (SchedulableContext ctx){
        Database.executeBatch(new BatchFreezeUsers());
    }
}