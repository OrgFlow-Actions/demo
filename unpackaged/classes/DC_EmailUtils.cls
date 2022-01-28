//
//This class provides utilities to work with emails.
//
//Author: Gennadiy Pervukhin (31-10-2014)
public class DC_EmailUtils
{
	//
	//Public static methods
	//
	public static Messaging.SendEmailResult[] sendEmails(Messaging.Email[] emails, Boolean allOrNothing)
	{
		try
        {
        	if (emails != null && emails.size() > 0)
        	{
	        	if (Test.isRunningTest())
	        	{
	        		System.debug('UNIT TEST: => Send Emails: number of emails = '
	        			+ emails.size() + '\nemails list:\n' + emails);
	        		DC_UT_TestManager.outboundEmails = emails;
	        	}
	        	return Messaging.sendEmail(emails, allOrNothing);
        	}
    	}
    	catch (System.Exception error)
    	{
    		System.debug(LoggingLevel.ERROR, '***** DC_EmailUtils.sendEmails() method tried to send '
    			+ emails.size() + ' messages, but the process failed');
    		System.debug(LoggingLevel.ERROR, error);
    	}
    	
    	return (new Messaging.SendEmailResult[0]);
	}
	//
}