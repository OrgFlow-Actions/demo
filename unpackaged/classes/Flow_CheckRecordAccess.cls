/*------------------------------------------------------------	
	Author: 		Richard Trum (Glimt) 2020-09-15	
	Description:   	Class used in flows for checking if a user has access to a specific record
	------------------------------------------------------------*/ 

public class Flow_CheckRecordAccess {
    
    @InvocableMethod
    public static List<String> checkRecordAccess(List<Id> recordId){
        
        List<String> maxaccess = new List<String>();
        
        for (UserRecordAccess ura : [SELECT RecordID, MaxAccessLevel 
                                     FROM UserRecordAccess 
                                     WHERE UserId= :userinfo.getuserid()
                                     AND RecordID=:recordID]){

        maxaccess.add(ura.MaxAccessLevel);
        system.debug('The MaxAccessLevel is '+ ura.MaxAccessLevel); 
        }
        return maxaccess;        
    }    

}