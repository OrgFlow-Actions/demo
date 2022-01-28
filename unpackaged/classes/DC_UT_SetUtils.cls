//
//This class provides Unit tests for 'DC_SetUtils' class.
//Used abbreviations:
//- UT - unit tests
//
//Author: Gennadiy Pervukhin (14-11-2014)
@IsTest
private class DC_UT_SetUtils
{
	//
	//Unit tests
	//
	@IsTest
	private static void test_findRelativeComplement()
	{
		//incorrect parameters
		System.assertEquals(null, DC_SetUtils.findRelativeComplement(null, null));
		System.assertEquals(0, DC_SetUtils.findRelativeComplement(new Event[0], null).size());
		
		//correct parameters
		//- create 3 test events
		List<Event> testEvents = DC_UT_DataUtils.createTestEvents(3);
		
		//TEST #1: testEvents - {event2, event3}
		Event[] relativeComplement = DC_SetUtils.findRelativeComplement(
			testEvents, new Event[] {testEvents[1], testEvents[2]});
		System.assertEquals(1, relativeComplement.size()); 
		System.assertEquals(testEvents[0].Id, relativeComplement[0].Id);
		
		//TEST #2: testEvents - {event3}
		relativeComplement = DC_SetUtils.findRelativeComplement(
			testEvents, new Event[] {testEvents[2]});
		System.assertEquals(2, relativeComplement.size()); 
		System.assert(!(new Map<Id, Event>(relativeComplement).keySet().contains(testEvents[2].Id)));
		
		//TEST #3: {event1} - testEvents
		relativeComplement = DC_SetUtils.findRelativeComplement(
			new Event[] {testEvents[0]}, testEvents);
		System.assertEquals(0, relativeComplement.size());
	}
	
	@IsTest
	private static void test_findIntersection()
	{
		//incorrect parameters
		System.assertEquals(null, DC_SetUtils.findIntersection(null, null));
		System.assertEquals(null, DC_SetUtils.findIntersection(new Event[0], null));
		
		//correct parameters
		//- create 3 test events
		List<Event> testEvents = DC_UT_DataUtils.createTestEvents(3);
		
		//TEST #1: testEvents and {event1, event2}
		Event[] intersection = DC_SetUtils.findIntersection(testEvents,
			new Event[] {testEvents[0], testEvents[1]});
		System.assertEquals(2, intersection.size()); 
		System.assert(!(new Map<Id, Event>(intersection).keySet().contains(testEvents[2].Id)));
		
		//TEST #2: testEvents and {event1}
		intersection = DC_SetUtils.findIntersection(testEvents, new Event[] {testEvents[0]});
		System.assertEquals(1, intersection.size());
		System.assertEquals(testEvents[0].Id, intersection[0].Id);
		
		//TEST #3: {event1} and testEvents
		intersection = DC_SetUtils.findIntersection(new Event[] {testEvents[0]}, testEvents);
		System.assertEquals(1, intersection.size());
		System.assertEquals(testEvents[0].Id, intersection[0].Id);
	}
	//
}