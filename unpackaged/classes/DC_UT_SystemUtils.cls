//
//This class contains Unit tests for system utilities.
//Used abbreviations:
//- UT - unit tests
//
//Author: Gennadiy Pervukhin (13-11-2014)
@IsTest
private class DC_UT_SystemUtils
{
	//
    //Unit tests for 'DC_ApexTypeUtils' class
    //
    @IsTest
    private static void testApexTypeUtils_getType()
    {
        System.assertEquals(null, DC_ApexTypeUtils.getType(null));
        System.assertEquals(null, DC_ApexTypeUtils.getType('Unknown_class_name'));
        System.assertNotEquals(null, DC_ApexTypeUtils.getType('User'));
    }
    
    @IsTest
    private static void testApexTypeUtils_createEmptyListByTypeName()
    {
        //WRONG PARAMTERS
        System.assertEquals(null, DC_ApexTypeUtils.createEmptyListByTypeName(null));
        System.assertEquals(null, DC_ApexTypeUtils.createEmptyListByTypeName('Unknown_class_name'));
        
        //GOOD PARAMETERS
        //try to create array of 'User' objects 
        User[] users = (User[])DC_ApexTypeUtils.createEmptyListByTypeName('User');
        System.assertEquals(0, users.size());
        
        //try to add new User
        users.add(new User());
        System.assertEquals(1, users.size());
        
        //try to create array of 'User' objects and add a new Account
        //(wrong type is used to show that array contains objects of a concrete type)
        List<Object> objectArray;
        try
        {
            objectArray = DC_ApexTypeUtils.createEmptyListByTypeName('User');
            objectArray.add(new Account());
            System.assert(false);
        }
        catch (System.TypeException e)
        {
            System.assert(true);
            System.assertEquals(0, objectArray.size());
        }
    }
    //
    
    
	
	//
	//Unit tests for 'DC_SObjectUtils' class
	//
	@IsTest
	private static void test_SObjectUtils_idBelongToSObject()
	{
		//disable all triggers to optimize creation of test data
		DC_SettingsUtils.setTriggersSettingForCurrentRequest(false);
		
		//incorrect parameters
		System.assertEquals(false, DC_SObjectUtils.idBelongToSObject(null, User.sObjectType));
		System.assertEquals(false, DC_SObjectUtils.idBelongToSObject('', User.sObjectType));
		
		//correct parameters
		//- test #1
		Event testEvent = DC_UT_DataUtils.generateEvent('Event-1_1', DateTime.now(),
			DateTime.now().addHours(1));
		insert testEvent;
		System.assert(DC_SObjectUtils.idBelongToSObject(testEvent.Id, Event.SObjectType));
		
		//- test #2
		System.assert(DC_SObjectUtils.idBelongToSObject(UserInfo.getUserId(), User.SObjectType));
	}
	
	@IsTest
	private static void test_SObjectUtils_extractStringValuesAndIds()
	{
		//disable triggers
		DC_SettingsUtils.setTriggersSettingForCurrentRequest(false);
		
		//incorrect parameters
		DC_SObjectUtils.extractIds(null, true);
		DC_SObjectUtils.extractStringFieldValues(null, null);
		
		//correct parameters
		DateTime startDateTime = DateTime.now();
		DateTime endDateTime = DateTime.now().addHours(1);
		Event event1 = DC_UT_DataUtils.generateEvent('Event-1_1', startDateTime, endDateTime);
		Event event2 = DC_UT_DataUtils.generateEvent('Event-1_2', startDateTime, endDateTime);
		Event event3 = DC_UT_DataUtils.generateEvent('Event-1_3', startDateTime, endDateTime);
		Event[] events = new Event[] {event1, event2, event3};
		insert events;
		
		//test #1: save order
		String[] ids = DC_SObjectUtils.extractIds(events, true);
		String[] subjects = DC_SObjectUtils.extractStringFieldValues(events, 'Subject');
		System.assertEquals(3, ids.size());
		System.assertEquals(3, subjects.size());
		for (Integer indexOfEvent = 0; indexOfEvent < events.size(); indexOfEvent++)
		{
			System.assertEquals(events[indexOfEvent].Id, ids[indexOfEvent]);
			System.assertEquals(events[indexOfEvent].Subject, subjects[indexOfEvent]);
		}
		
		//test #2: any order
		ids = DC_SObjectUtils.extractIds(events, false);
		System.assertEquals(3, ids.size());
	}
	//
	
	
	
	//
    //Unit tests for 'DC_EmailUtils' class
    //
    @IsTest
	private static void test_EmailUtils_sendEmails()
	{
		//incorrect parameters
		System.assertEquals(0, DC_EmailUtils.sendEmails(null, true).size());
		System.assertEquals(0, DC_EmailUtils.sendEmails(
			new Messaging.SingleEmailMessage[] {null}, true).size());
		
		//correct parameters
		//initialize builder
		DC_SingleEmailMessageBuilder emailBuilder =
			new DC_SingleEmailMessageBuilder(UserInfo.getUserID());
		emailBuilder.subject = 'Unit test';
		emailBuilder.plainTextBody = 'Plain text';
		Messaging.SingleEmailMessage email = emailBuilder.buildMessage();
		System.assertEquals(1, DC_EmailUtils.sendEmails(
			new Messaging.SingleEmailMessage[] {email}, true).size());
		System.assertEquals(1, DC_UT_TestManager.outboundEmails.size());
	}
    //
    
    
    
    //
    //Unit tests for 'DC_SingleEmailMessageBuilder' class
    //
    @IsTest
	private static void test_SingleEmailMessageBuilder_mainWorkFlow()
	{
		//TEST #1: null target
		DC_SingleEmailMessageBuilder emailBuilder = new DC_SingleEmailMessageBuilder();
		System.assertEquals(null, emailBuilder.buildMessage());
		emailBuilder.changeTarget(null);
		System.assertEquals(null, emailBuilder.buildMessage());
		
		//TEST #2: empty target
		emailBuilder = new DC_SingleEmailMessageBuilder(new DC_SingleEmailTarget(null, null));
		System.assertEquals(null, emailBuilder.buildMessage());
		
		//TEST #3: incorrect target object Id
		emailBuilder = new DC_SingleEmailMessageBuilder('IncorrectTargetObjectId');
		System.assertEquals(null, emailBuilder.buildMessage());
		
		//TEST #4.1: correct parameters (target is a email address)
		//- configure the builder
		emailBuilder = new DC_SingleEmailMessageBuilder(new String[] {UserInfo.getUserEmail()});
		emailBuilder.subject = 'Unit test';
		emailBuilder.plainTextBody = 'Plain Text';
		emailBuilder.htmlBody = '<html><head></head><body></body></html>';
		emailBuilder.replyToAddress = 'ut_reply_address@test.com';
		emailBuilder.orgWideEmailAddressId = null;
		emailBuilder.saveAsActivity = false;
		emailBuilder.addFileAttachment('test.txt', DC_FileMimeType.TEXT_PLAIN, 'content', true);
		//- build the email and check the results
		Messaging.SingleEmailMessage email = emailBuilder.buildMessage();
		System.assertNotEquals(null, email);
		System.assertEquals(null, email.getTargetObjectId());
		System.assertEquals(1, email.getToAddresses().size());
		System.assertEquals(UserInfo.getUserEmail(), email.getToAddresses()[0]);
		
		//TEST #4.2: change target (user Id + email address)
		String emailAddress = 'new_email_address@test.com';
		emailBuilder.changeTarget(new DC_SingleEmailTarget(UserInfo.getUserId(),
			new String[] {emailAddress}));
		//- build the email and check the results
		email = emailBuilder.buildMessage();
		System.assertNotEquals(null, email);
		System.assertEquals(UserInfo.getUserId(), email.getTargetObjectId());
		System.assertEquals(1, email.getToAddresses().size());
		System.assertEquals(emailAddress, email.getToAddresses()[0]);
	} 
    //
}