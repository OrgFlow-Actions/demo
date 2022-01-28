//
//This class is used in a SF Email Service which accepts responses to
//ICalendar-events from participants.
//Used abbreviations:
// - ES = email service
//
//Author: Gennadiy Pervukhin (7-11-2014)
public class DC_ES_ICalendarResponseHandler implements Messaging.InboundEmailHandler
{
	//
	//Implementation of 'Messaging.InboundEmailHandler' interface
	//
	public Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email,
		Messaging.InboundEnvelope envelope)
	{
		//- process the response
		DC_ICalendarResponseManager responseManager = new DC_ICalendarResponseManager(email);
		responseManager.processResponse();
		
		//- generate a successful result
		Messaging.InboundEmailResult result = new Messaging.InboundEmailResult();
		result.success = true;
		return result;
	}
	//
}