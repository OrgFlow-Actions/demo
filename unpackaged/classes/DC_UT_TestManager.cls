//
//This class provides utilities for Unit tests.
//
//Used abbreviations:
//- UT: unit tests
//Author: Gennadiy Pervukhin (13-11-2014)
@IsTest
public class DC_UT_TestManager
{
	//
	//Static varoables
	//
	/*this variable stores the list of emails that are prepared for sending.
	We need it to check the results of sending. So, this variable simulates
	outbound email box*/
	public static Messaging.Email[] outboundEmails = new Messaging.Email[0];
	//
	
	
	//
	//Public static methods
	//
	public static void assertEqualStringLists(String[] expectedList, String[] actualList)
	{
		System.assertEquals(expectedList.size(), actualList.size());
		for (Integer indexOfValue = 0; indexOfValue < expectedList.size(); indexOfValue++)
		{
			System.assertEquals(expectedList[indexOfValue], actualList[indexOfValue]);
		}
	}
	//
	
	
	
}