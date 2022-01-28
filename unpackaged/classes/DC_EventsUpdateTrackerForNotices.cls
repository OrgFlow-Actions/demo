/*
This class tracks updates in events (and related objects) which are interesting
for a custom notification process.
Currently, the class reads events with attendees (EventRelation objects), because
we have no possibility to create a trigger for this object and can't read deleted
objects from a recycle bin. Therefore, we read events with attendees before
update and after update, then use programmatic approach to compare these results
and find new, deleted and unchanged attendees.
*/
//Author: Gennadiy Pervukhin (27-10-2014)
public class DC_EventsUpdateTrackerForNotices
{
	//
	//Static variables
	//
	private static Map<String, Event> mapOfEventsBeforeUpdate = new Map<String, Event>();
	private static Map<String, Event> mapOfEventsAfterUpdate = new Map<String, Event>();
	//
	
	//
	//Private static methods
	//
	private static Map<String, Event> getMapOfEventsForNotices(Event[] events,
		Boolean selectAttachments)
	{
		//STEP #1: select events which support custom notifications
		Event[] selectedEvents = DC_EventNoticesUtils.selectEventsForNotices(events);
		
		//STEP #2: re-read events to include attendees and information which is
		//necessary for notices
		selectedEvents = DC_EventNoticesUtils.reReadEventsForNotices(
			selectedEvents, selectAttachments);
		if (selectedEvents != null)
		{
			return (new Map<String, Event>(selectedEvents));
		}
		//return an empty map
		return (new Map<String, Event>());
	}
	//
	
	//
	//Public static methods
	//
	public static void trackBeforeUpdate(Event[] events)
	{
		//remember events with attendees before an update. We can't simply
		//replace the variable by a new map, because the trigger can fire several
		//times during the transaction (for example, for recurring events). So,
		//we put a new map into the existing one.
		mapOfEventsBeforeUpdate.putAll(getMapOfEventsForNotices(events, false));
	}
	
	public static void trackAfterUpdate(Event[] events)
	{
		//remember events with attendees and attachments after an update.
		//We can't simply replace the variable by a new map, because the trigger
		//can fire several times during the transaction (for example, for
		//recurring events). So, we put a new map into the existing one.
		mapOfEventsAfterUpdate.putAll(getMapOfEventsForNotices(events, true));
	}
	
	public static Event getOldEvent(String eventId)
	{
		return mapOfEventsBeforeUpdate.get(eventId);
	}
	
	public static Event getNewEvent(String eventId)
	{
		return mapOfEventsAfterUpdate.get(eventId);
	}
	//
}