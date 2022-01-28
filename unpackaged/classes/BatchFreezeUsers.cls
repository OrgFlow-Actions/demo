/*-------------------------------------------------------------------------------------------------------
Author:         Miguel Coimbra(Salesforce) 2020709
Description:    Class to automatically freeze users if they don't login for more than X number of days and if they are not 
                    flagged as "Do not Freeze" 
Test Class:     Test_BatchFreezeUsers
History 
20200326    Miguel Coimbra           Created class. 
----------------------------------------------------------------------------------------*/

global class BatchFreezeUsers implements Database.Batchable<SObject>, Database.Stateful {

    /*
    FOR TESTING PURPOSE: 
    QUERY: 
    SELECT Id, LastLoginDate FROM User where isActive = true and Profile.UserLicense.Name = 'Salesforce' and isActive = true and DAY_ONLY(LastLoginDate) < 2020-09-02 and 
    Id in (SELECT UserId FROM UserLogin where isFrozen = false)
    */
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        Integer nrOfDays = [SELECT ofDaysSinceLastLogin__c FROM AdminSetting__mdt 
                                                        WHERE DeveloperName = 'BatchFreezeUsers' LIMIT 1].ofDaysSinceLastLogin__c.intValue() ; 
        if (nrOfDays == null) return null ; 
        String limitToFreezeDateAsString = String.valueOf(System.today() - nrOfDays);

        String  query = 'SELECT Id, LastLoginDate FROM User WHERE isActive = true AND Profile.UserLicense.Name = \'Salesforce\' AND doNotFreeze__c = false AND lastlogindate <> null';
                query += ' AND DAY_ONLY(LastLoginDate) < '+ limitToFreezeDateAsString;  
                query += ' AND Id in (SELECT UserId FROM UserLogin where isFrozen = false)'; 
        		if(Test.isRunningTest()) query+= ' limit 50'; // Class System.UnexpectedException: No more than one executeBatch can be called from within a test method.
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext bc, List<User> scope) {
        Set<Id> userIds = (new Map<Id,SObject>(scope)).keySet(); 
        try {
            List<UserLogin> usersToFreezeList = new List<userLogin>(); 
            List<UserLogin> userLogins =  [SELECT UserId FROM UserLogin WHERE isFrozen = false AND UserId in: userIds]; 
            for (UserLogin u : userLogins){
                u.isFrozen = true ; 
                usersToFreezeList.add(u); 
            }
            if (!usersToFreezeList.isEmpty()){
                update usersToFreezeList;
            }
        } catch (DmlException e) {
            DebugLog.addException(e, 'Error occurred on: BatchFreezeUsers '); 
        }
    }

    global void finish(Database.BatchableContext bc) {
        DebugLog.addinfo('Batch finished successfuly: BatchFreezeUsers JobId:', bc.getJobId());
    }
}