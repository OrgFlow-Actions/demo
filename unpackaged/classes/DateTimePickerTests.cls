@isTest
public class DateTimePickerTests {
    public static testmethod void DateTimeIsSplitCorrectly_enUS(){
        runTestForLocale('en_US');
    }
    
    public static testmethod void DateTimeIsSplitCorrectly_enGB(){
        runTestForLocale('en_GB');
    }
    
    public static testmethod void DateTimeIsSplitCorrectly_enMY(){
        runTestForLocale('en_MY');
    }
    
    public static testmethod void DateTimeIsSplitCorrectly_ms(){ //Malay
        runTestForLocale('ms');
    }
    
    public static testmethod void DateTimeIsSplitCorrectly_enHK(){
        runTestForLocale('en_HK');
    }
    
    public static testmethod void DateTimeIsSplitCorrectly_enSG(){
        runTestForLocale('en_SG');
    }
    
    private static void runTestForLocale(string locale){    	
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        User u = new User(Alias = 'standt', Email='standarduser@dentsplysirona.com',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                          LocaleSidKey=locale, ProfileId = p.Id,
                          TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@dentsplysirona.com');
        
        System.runAs(u){
            DateTime expectedDateTime = DateTime.newInstance(2016, 01, 02, 15, 16, 00);
            
            DateTimePickerVM sut = new DateTimePickerVM(expectedDateTime);
            
            string dateString = sut.DatePart;
            string timeString = sut.TimePart;
            
            system.assert(expectedDateTime == sut.Value, 'Expected value was ' + expectedDateTime + ', but actual value was ' + sut.Value);
            system.assert(sut.TimeOptions.size() == 48, 'There should be 48 Time Options, but the actual size was ' + sut.TimeOptions.size());
            
            for(string timeOption : sut.TimeOptions){
                sut.TimePart = timeOption;
                
                system.assert(sut.IsValid(), 'The Time Option `' + timeOption + '` resulted in an invalid DateTime string. The full string was `' + sut.StringValue + '`');
            }
        }
    }
}