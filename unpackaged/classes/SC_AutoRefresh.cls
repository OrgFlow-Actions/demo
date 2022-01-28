/*------------------------------------------------------------
Author:         Nisreen AlSaleh (support@avity.com)  2021-08-1
Description:    Used to check the user has a permssion to auto enable the auto-refresh component.TFUS-000003196
History
<Date>      <Authors Name>     <Brief Description of Change>

------------------------------------------------------------*/

public with sharing class SC_AutoRefresh {
	@AuraEnabled
    public static boolean getUserPermission(){
    Id userId = userinfo.getuserid();
     user [] userPermissions = [SELECT id, Service_Cloud_Special_Permissions__c FROM user WHERE id=:userId];
        if(!userPermissions.isEmpty()){
           String permssions = userPermissions[0].Service_Cloud_Special_Permissions__c ;
            if(permssions.contains('Enable Auto Refresh Automatically')){
                return true;
            }    
                return false;
        }
        	    return false;
    }
}