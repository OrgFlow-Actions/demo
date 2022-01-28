public class EventRecurrenceState {    
    
    public EventRecurrenceState(){
        RecurrenceTypes = new RecurrenceTypes();
        
        DailyInterval = 1;
        WeeklyInterval = 1;
        MonthlyInterval = 1;
        MonthlyFixedInterval = 1;
        
        DaysOfTheMonth = new List<SelectOption>();
        DaysOfTheWeek = new List<SelectOption>();
        MonthsOfTheYear = new List<SelectOption>();
        Instances = new List<SelectOption>();
        
        integer x = 1;        
        while(x <= 31){
            DaysOfTheMonth.add(new SelectOption(string.valueOf(x), string.valueOf(x)));
            
            x++;
        }
        
        DaysOfTheWeek.add(new SelectOption('127', 'day'));
        DaysOfTheWeek.add(new SelectOption('1', 'Sunday'));
        DaysOfTheWeek.add(new SelectOption('2', 'Monday'));
        DaysOfTheWeek.add(new SelectOption('4', 'Tuesday'));
        DaysOfTheWeek.add(new SelectOption('8', 'Wednesday'));
        DaysOfTheWeek.add(new SelectOption('16', 'Thursday'));
        DaysOfTheWeek.add(new SelectOption('32', 'Friday'));
        DaysOfTheWeek.add(new SelectOption('64', 'Saturday'));
        
        for(Schema.PicklistEntry ple : Event.RecurrenceMonthOfYear.getDescribe().getPicklistValues()) {
            MonthsOfTheYear.add(new SelectOption(ple.getValue(), ple.getLabel()));
        }
        
        //MonthsOfTheYear.add(new SelectOption('January', 'January'));
        //MonthsOfTheYear.add(new SelectOption('February', 'February'));
        //MonthsOfTheYear.add(new SelectOption('March', 'March'));
        //MonthsOfTheYear.add(new SelectOption('April', 'April'));
        //MonthsOfTheYear.add(new SelectOption('May', 'May'));
        //MonthsOfTheYear.add(new SelectOption('June', 'June'));
        //MonthsOfTheYear.add(new SelectOption('July', 'July'));
        //MonthsOfTheYear.add(new SelectOption('August', 'August'));
        //MonthsOfTheYear.add(new SelectOption('September', 'September'));
        //MonthsOfTheYear.add(new SelectOption('October', 'October'));
        //MonthsOfTheYear.add(new SelectOption('November', 'November'));
        //MonthsOfTheYear.add(new SelectOption('December', 'December'));
        
        for(Schema.PicklistEntry ple : Event.RecurrenceInstance.getDescribe().getPicklistValues()) {
            Instances.add(new SelectOption(ple.getValue(), ple.getLabel()));
        }
        
        //Instances.add(new SelectOption('1st', '1st'));  
        //Instances.add(new SelectOption('2nd', '2nd'));  
        //Instances.add(new SelectOption('3rd', '3rd'));  
        //Instances.add(new SelectOption('4th', '4th'));  
        //Instances.add(new SelectOption('Last', 'Last'));        
    }
    
    public string RecurrenceType { get; set; }
    
    public integer DailyInterval { get; set; }
    
    public boolean WeeklyOccursOnSunday { get; set; }
    public boolean WeeklyOccursOnMonday { get; set; }
    public boolean WeeklyOccursOnTuesday { get; set; }
    public boolean WeeklyOccursOnWednesday { get; set; }
    public boolean WeeklyOccursOnThursday { get; set; }
    public boolean WeeklyOccursOnFriday { get; set; }
    public boolean WeeklyOccursOnSaturday { get; set; }
    public integer WeeklyInterval { get; set; }      
    
    public integer MonthlyDayOfMonth { get; set; } // eg day [3] of the month
    public string MonthlyInstance { get; set; } // eg [1st] Monday of the month. // this also needs to support last
    public integer MonthlyDay { get; set; } // eg 2nd [Tuesday] of the month
    public integer MonthlyFixedInterval { get; set; } 
    public integer MonthlyInterval { get; set; }
    
    public string YearlyFixedMonth { get; set; }
    public integer YearlyDayOfMonth { get; set; }
    public string YearlyInstance { get; set; }
    public string YearlyMonth { get; set; }
    public integer YearlyDay { get; set; }
    
    public List<SelectOption> DaysOfTheMonth { get; private set; }
    public List<SelectOption> DaysOfTheWeek { get; private set; }
    public List<SelectOption> MonthsOfTheYear { get; private set; }
    public List<SelectOption> Instances { get; private set; }
    
    public RecurrenceTypes RecurrenceTypes { get; private set;}
}