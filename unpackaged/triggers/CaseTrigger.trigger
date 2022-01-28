/*------------------------------------------------------------  
Author:         Nisreen Al Saleh (support@avity.com) 2021-March-25   
Description:    Generic Trigger for Case (Following Trigger Framework)
------------------------------------------------------------*/

trigger CaseTrigger on Case  (
                             before insert
                           , before update
                           , before delete
                           , after insert
                           , after update
                           , after delete
                           , after undelete) {
                                 
                    new CaseTriggerHandler().run();
}