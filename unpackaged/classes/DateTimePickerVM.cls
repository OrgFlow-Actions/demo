public class DateTimePickerVM {
    private string DateTimeSeparator { get; private set; }
    
    public string DatePart { get; set; }
    public string TimePart { get; set; }
    
    public List<string> TimeOptions{ get; private set; }
    
    public string StringValue { 
        get {
        	return DatePart + DateTimeSeparator + TimePart;
    	}
    }
    
    public DateTime Value { 
        get {            
            return DateTime.parse(StringValue);
        }
        set {        
            DatePart = value.date().format();
            TimePart = getTimeString(value);
        } 
    }
    
    
    public boolean IsValid(){
        // Blurgh- using try/catch to control flow here, but there is no altenrative (ie tryParse etc...)
        try{
            DateTime.parse(StringValue);
            return true;
        }
        catch(Exception ex){
            return false;
        }
    }
    
    public DateTimePickerVM(DateTime seedValue){
        Value = seedValue;
        
        TimeOptions = new List<string>();
        DateTime optionCounter = DateTime.newInstance(2016, 01, 01);
        DateTime maxOptionCounter = DateTime.newInstance(2016, 01, 02);
        
        while(optionCounter < maxOptionCounter){
            TimeOptions.add(getTimeString(optionCounter));
            optionCounter = optionCounter.addMinutes(30);
        }
    }
    
    private String getTimeString(DateTime value) {    
        string timeString = value.format().removeStart(value.date().format());
        
        DateTimeSeparator = null; // Ensure this value is null before entering recursive operation
        return trimTimeString(timeString);
    }
    
    private string trimTimeString(string timeString){
        if(DateTimeSeparator == null){
            DateTimeSeparator = '';
        }
        
        string firstCharacter = timeString.substring(0, 1);
        
        if(firstCharacter.isNumeric()){
            return timeString;
        }
        
        DateTimeSeparator += firstCharacter;
        
        timeString = timeString.substring(1);
        
        return trimTimeString(timeString);
    }
}