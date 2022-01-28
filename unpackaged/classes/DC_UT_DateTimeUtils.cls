//
//This class provides Unit tests for 'DC_DateTimeUtils' class.
//Used abbreviations:
//- UT - unit tests
//
//Author: Gennadiy Pervukhin (13-11-2014)
@IsTest
private class DC_UT_DateTimeUtils
{
	//
	//Unit tests
	//
	@IsTest
    private static void test_formatDateTimeRange()
    {
        //incorrect parameters
        System.assertEquals(null, DC_DateTimeUtils.formatDateTimeRange(null, null, null));
        
        //correct parameters
        //1) 2 dates have the same date before converting and after converting
        DateTime startDateTime = DateTime.newInstanceGMT(2014, 9, 28, 10, 30, 0);
        DateTime endDateTime = DateTime.newInstanceGMT(2014, 9, 28, 15, 30, 0);
        String formattedDateRange = DC_DateTimeUtils.formatDateTimeRange(startDateTime, endDateTime, 'UTC');
        System.assertEquals('09/28/2014 10:30 AM - 3:30 PM '
        	+ TimeZone.getTimeZone('UTC').getDisplayName(), formattedDateRange);
        
        //2) 2 dates have different dates before converting and after converting
        startDateTime = DateTime.newInstanceGMT(2014, 9, 28, 10, 30, 0);
        endDateTime = DateTime.newInstanceGMT(2014, 9, 30, 15, 30, 0);
        formattedDateRange = DC_DateTimeUtils.formatDateTimeRange(startDateTime, endDateTime, 'UTC');
        System.assertEquals('09/28/2014 10:30 AM - 09/30/2014 3:30 PM '
        	+ TimeZone.getTimeZone('UTC').getDisplayName(), formattedDateRange);
        
        //3) 2 dates have the same date before converting and different dates after converting
        startDateTime = DateTime.newInstanceGMT(2014, 9, 28, 0, 30, 0);
        endDateTime = DateTime.newInstanceGMT(2014, 9, 28, 10, 30, 0);
        formattedDateRange = DC_DateTimeUtils.formatDateTimeRange(startDateTime, endDateTime, 'GMT-08:00');
        System.assertEquals('09/27/2014 4:30 PM - 09/28/2014 2:30 AM GMT-08:00', formattedDateRange);
    }
    
    @IsTest
    private static void test_formatDateRangeGmt()
    {
        //incorrect parameters
        System.assertEquals(null, DC_DateTimeUtils.formatDateRangeGmt(null, null));
        
        //correct parameters
        //1) 2 datetime values have the same date
        DateTime startDateTime = DateTime.newInstanceGMT(2014, 9, 28, 0, 0, 0);
        DateTime endDateTime = DateTime.newInstanceGMT(2014, 9, 28, 0, 0, 0);
        String formattedDateRange = DC_DateTimeUtils.formatDateRangeGmt(startDateTime, endDateTime);
        System.assertEquals('09/28/2014', formattedDateRange);
        
        //2) 2 datetime values have different dates
        startDateTime = DateTime.newInstanceGMT(2014, 9, 28, 0, 0, 0);
        endDateTime = DateTime.newInstanceGMT(2014, 9, 30, 0, 0, 0);
        formattedDateRange = DC_DateTimeUtils.formatDateRangeGmt(startDateTime, endDateTime);
        System.assertEquals('09/28/2014 - 09/30/2014', formattedDateRange);
    }
    
    @IsTest
    private static void test_calculateOffsetInMinutes()
    {
    	//incorrect parameters
        System.assertEquals(0, DC_DateTimeUtils.calculateOffsetInMinutes(null, null));
        
        //correct parameters
        DateTime currentDateTime = DateTime.now();
        System.assertEquals(0, DC_DateTimeUtils.calculateOffsetInMinutes(
        	currentDateTime, currentDateTime));
        System.assertEquals(0, DC_DateTimeUtils.calculateOffsetInMinutes(
        	currentDateTime, currentDateTime.addSeconds(59)));
        System.assertEquals(55, DC_DateTimeUtils.calculateOffsetInMinutes(
        	currentDateTime, currentDateTime.addMinutes(55)));
        System.assertEquals(300, DC_DateTimeUtils.calculateOffsetInMinutes(
        	currentDateTime, currentDateTime.addHours(5)));
        System.assertEquals(-300, DC_DateTimeUtils.calculateOffsetInMinutes(
        	currentDateTime.addHours(5), currentDateTime));
    }
    //
}