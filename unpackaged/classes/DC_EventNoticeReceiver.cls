//
//This class encapsulates the details of email receiver
//
//Author: Gennadiy Pervukhin (28-10-2014)
public class DC_EventNoticeReceiver extends DC_SingleEmailTarget
{
	//
	//Constructors
	//
	public DC_EventNoticeReceiver(String targetObjectId, String[] emailAddresses,
		String iCalendarUID)
	{
		super(targetObjectId, emailAddresses);
		this.iCalendarUID = iCalendarUID;
	}
	//
	
	//
	//Properties
	//
	public String iCalendarUID {get; set;}
	//
}