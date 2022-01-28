/*Version History
 * Date: 06-Nov-2018
 * Class Name: ChangeOwner
 * Created By: Amit Kumar Prabhat(amitkumar.prabhat@mindtree.com)
 * Related to: TFUS-000000178 : “take_ownership button
 * Related Test Class: ChangeOwnerTest.cls
*/

public with Sharing class ChangeOwner {
@AuraEnabled
    public static Task changeOwnerMethod(Id taskId) {
        if(taskId != null) {
            Task c = [SELECT OwnerId FROM Task WHERE Id = :taskId];
            c.OwnerId = UserInfo.getUserId();
            c.status = 'In Progress';
            update c;
            return c;
            }
        
        return null;
    }

}