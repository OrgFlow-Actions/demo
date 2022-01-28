//
//This class provides Unit tests for 'DC_StringUtils' class.
//Used abbreviations:
//- UT - unit tests
//
//Author: Gennadiy Pervukhin [Cervello] (13-11-2014)
@IsTest
private class DC_UT_StringUtils
{
	//
	//Unit tests
	//
	@IsTest
	private static void test_replaceLineBreaks()
	{
		//test #1: incorrect parameters
		System.assertEquals(null, DC_StringUtils.replaceLineBreaks(null, null));
		
		//test #2: correct parameters
		System.assertEquals('Line1_Line2_Line3',
			DC_StringUtils.replaceLineBreaks('Line1\r\nLine2\nLine3', '_'));
	}
	
	@IsTest
	private static void test_safeReplace()
	{
		//test #1: incorrect parameters
		System.assertEquals(null, DC_StringUtils.safeReplace(null, null, null));
		System.assertEquals('Source', DC_StringUtils.safeReplace('Source', null, null));
		
		//test #2: correct parameters
		System.assertEquals('15', DC_StringUtils.safeReplace('Text1Text5', 'Text', null));
		System.assertEquals('15', DC_StringUtils.safeReplace('Text1Text5', 'Text', ''));
		System.assertEquals('_1_5', DC_StringUtils.safeReplace('Text1Text5', 'Text', '_'));
	}
	
	@IsTest
	private static void test_safeJoin()
	{
		//incorrect parameters
		System.assertEquals(null, DC_StringUtils.safeJoin(null, null));
		System.assertEquals(null, DC_StringUtils.safeJoin(null, 'separator'));
		String[] stringValues = new String[] {'Text1', 'Text5'};
		System.assertEquals('Text1Text5', DC_StringUtils.safeJoin(stringValues, null));
		
		//correct parameters
		//test #1
		System.assertEquals('Text1_Text5', DC_StringUtils.safeJoin(stringValues, '_'));
		//test #2
		System.assertEquals('1,5', DC_StringUtils.safeJoin(new Integer[] {1, 5}, ','));
	}
	
	@IsTest
	private static void test_truncateString()
	{
		//incorrect parameters
		System.assertEquals(null, DC_StringUtils.truncateString(null, 10));
		System.assertEquals('', DC_StringUtils.truncateString('', 10));
		
		//correct parameters
		System.assertEquals('test1', DC_StringUtils.truncateString('test1', 10));
		System.assertEquals('test123456', DC_StringUtils.truncateString('test123456', 10));
		System.assertEquals('test123456', DC_StringUtils.truncateString('test1234567890', 10));
	}
	//
}