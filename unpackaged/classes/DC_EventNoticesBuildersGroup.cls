//
//This class represents a group of builder of notices which are used to build
//notices for 1 event.
//
//Author: Gennadiy Pervukhin (28-10-2014)
public class DC_EventNoticesBuildersGroup
{
	//
	//Constructors
	//
	public DC_EventNoticesBuildersGroup(Event event)
	{
		this.event = event;
		this.builders = new List<DC_EventNoticesBuilder>();
	}
	//
	
	//
	//Properties
	//
	public Event event {get; private set;}
	public List<DC_EventNoticesBuilder> builders {get; private set;}
	//
	
	//
	//Public methods
	//
	public Boolean isNotEmpty()
	{
		return (this.builders.size() > 0);
	}
	//
}