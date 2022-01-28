/*Version History
 * Date: 06-Nov-2018
 * Class Name: ChangeOwnerTest
 * Created By: Amit Kumar Prabhat(amitkumar.prabhat@mindtree.com)
 * Related to: TFUS-000000178 : “take_ownership button
 * Related Class: ChangeOwner.cls
*/
@isTest
private class ChangeOwnerTest
{
    @isTest
    static void changeTaskOwner()
    {
       Account a=new Account(name='Testdata',phone='8885856208',billingstate='California',billingcity='anah',billingcountry='United States',billingpostalcode='92801',billingstreet='ls');
          insert a;
        Task t=new Task(subject='test_test',description='Account info on Task',Whatid=a.Id,status='open',priority='normal');
         insert t;
        Task t1 = ChangeOwner.changeOwnerMethod(t.id);
        System.assertNotEquals(t,t1);
        ChangeOwner.changeOwnerMethod(null);
        
    }
}