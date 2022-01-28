/*
This class tracks related objects of deleted events which are interesting for
a custom notification process.
Currently, the class works with attendees (EventRelation objects), because we
have no possibility to create a trigger for this object and can't get deleted
attendees in 'after delete' trigger. Therefore, we read all attendees for
selected events (events which participate in a custom notification process) before
deletion and remember them.
*/
//Author: Gennadiy Pervukhin (30-10-2014)
public class DC_EventsDeletionTrackerForNotices
{
	//
	//Private static variables
	//
	private static Event[] deletedEvents;
	//
	
	//
	//Public static methods
	//
	public static void trackBeforeDelete(Event[] events)
	{
		//STEP #1: select events which support custom notifications
		Event[] selectedEvents = DC_EventNoticesUtils.selectEventsForNotices(events);
		
		//STEP #2: get and remember events with attendees
		deletedEvents = DC_EventNoticesUtils.reReadEventsForNotices(
			selectedEvents, true);
	}
	
	public static Event[] getDeletedEvents()
	{
		return deletedEvents;
	}
	//
}