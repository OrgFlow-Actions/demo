//
//This class provides Unit tests for data helpers.
//
//Used abbreviations:
//- UT: unit tests
//Author: Gennadiy Pervukhin (14-11-2014)
@IsTest
private class DC_UT_DataHelpers
{
	//
	//Unit tests for 'DC_SObjectHelper' class
	//
	@IsTest
	private static void test_SObjectHelper_mainWorkFlow()
	{
		//incorrect parameters
		DC_SObjectHelper helper = DC_SObjectHelper.createHelperForList(null);
		System.assertEquals(0, helper.allObjects.size());
		System.assertEquals(null, helper.getSObjectById(null));
		
		//correct parameters
		//- create 3 test events
		List<Event> testEvents = DC_UT_DataUtils.createTestEvents(3);
		//- initialize a helper
		helper = DC_SObjectHelper.createHelperForList(new Event[] {testEvents[0], testEvents[1]});
		System.assertEquals(2, helper.allObjects.size());
		System.assertEquals(testEvents[0].Id, helper.getSObjectById(testEvents[0].Id).Id);
		System.assertEquals(testEvents[1].Id, helper.getSObjectById(testEvents[1].Id).Id);
		System.assertEquals(null, helper.getSObjectById(testEvents[2].Id));
	}
	//
}