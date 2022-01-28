public class EventRecurrenceService {
    public Event SetEventRecurrenceFromState(Event e, EventRecurrenceState state){
        // We can't change recurrence if this event is not new and does not already recur
        if(e.Id != null && !e.IsRecurrence) {
            return e;
        }
        
        system.debug('RecurrenceType: ' + state.RecurrenceType);
        
        if(e.Id == null && state.RecurrenceType != null){
        	e.IsRecurrence = state.RecurrenceType != state.RecurrenceTypes.None;
        }
        
        if(e.IsRecurrence){
            e.RecurrenceStartDateTime = e.StartDateTime;
        }
        
        e.RecurrenceDayOfMonth = null;
        e.RecurrenceDayOfWeekMask = null;
        e.RecurrenceInterval = null;
        e.RecurrenceMonthOfYear = null;
        
        //Recurs Daily (RecursDaily)
        //Recurs Every Weekday (RecursEveryWeekday)
        //Recurs Monthly (RecursMonthly)
        //Recurs Monthy Nth (RecursMonthlyNth)
        //Recurs Weekly (RecursWeekly)
        //Recurs Yearly (RecursYearly)
        //Recurs Yearly Nth (RecursYearlyNth)
        
        if(state.RecurrenceType == state.RecurrenceTypes.None){
            e.RecurrenceType = null;
            e.RecurrenceStartDateTime = null;
            
        	e.IsRecurrence = false;
        }
        else if(state.RecurrenceType == state.RecurrenceTypes.Daily){
            e.RecurrenceType = 'RecursDaily';
            
            e.RecurrenceInterval = state.DailyInterval;
        }
        else if(state.RecurrenceType == state.RecurrenceTypes.DailyEveryWeekday){
            e.RecurrenceType = 'RecursEveryWeekday';  
            
            e.RecurrenceDayOfWeekMask = 62;
        }
        else if(state.RecurrenceType == state.RecurrenceTypes.Weekly){
            e.RecurrenceType = 'RecursWeekly';
            
            integer dayOfWeekMask = 0;
            
            if(state.WeeklyOccursOnSunday){ dayOfWeekMask += 1; }
            if(state.WeeklyOccursOnMonday){ dayOfWeekMask += 2; }
            if(state.WeeklyOccursOnTuesday){ dayOfWeekMask += 4; }
            if(state.WeeklyOccursOnWednesday){ dayOfWeekMask += 8; }
            if(state.WeeklyOccursOnThursday){ dayOfWeekMask += 16; }
            if(state.WeeklyOccursOnFriday){ dayOfWeekMask += 32; }
            if(state.WeeklyOccursOnSaturday){ dayOfWeekMask += 64; }
            
            e.RecurrenceDayOfWeekMask = dayOfWeekMask;            
            e.RecurrenceInterval = state.WeeklyInterval;
        }
        else if(state.RecurrenceType == state.RecurrenceTypes.Monthly){
            e.RecurrenceType = 'RecursMonthlyNth';
            
            e.RecurrenceInstance = state.MonthlyInstance;
            e.RecurrenceDayOfWeekMask = state.MonthlyDay;
            e.RecurrenceInterval = state.MonthlyInterval;
        }
        else if(state.RecurrenceType == state.RecurrenceTypes.MonthlyFixedDate){
            e.RecurrenceType = 'RecursMonthly';
            
            e.RecurrenceDayOfMonth = state.MonthlyDayOfMonth;
            e.RecurrenceInterval = state.MonthlyFixedInterval;
        }
        else if(state.RecurrenceType == state.RecurrenceTypes.Yearly){
            e.RecurrenceType = 'RecursYearlyNth';
            
            
            e.RecurrenceInstance = state.YearlyInstance;
            e.RecurrenceDayOfWeekMask = state.YearlyDay;
            e.RecurrenceMonthOfYear = state.YearlyMonth;
        }
        else if(state.RecurrenceType == state.RecurrenceTypes.YearlyFixedDate){
            e.RecurrenceType = 'RecursYearly';
            
            e.RecurrenceMonthOfYear = state.YearlyFixedMonth;
            e.RecurrenceDayOfMonth = state.YearlyDayOfMonth;
        }
        
        return e;
    }
    
    public EventRecurrenceState GetEventRecurrenceState(Event e){
        EventRecurrenceState state = new EventRecurrenceState();

        if(e.IsRecurrence == false){           
            state.RecurrenceType = state.RecurrenceTypes.None;
        }
        else if(e.RecurrenceType == 'RecursDaily'){ 
            state.RecurrenceType = state.RecurrenceTypes.Daily;            
            state.DailyInterval = e.RecurrenceInterval;
        }
        else if(e.RecurrenceType == 'RecursEveryWeekday'){ 
            state.RecurrenceType = state.RecurrenceTypes.DailyEveryWeekday;  
        }
        else if(e.RecurrenceType == 'RecursWeekly'){ 
            state.RecurrenceType = state.RecurrenceTypes.Weekly;
            state.WeeklyInterval = e.RecurrenceInterval;
            
            integer dayOfWeekMask = e.RecurrenceDayOfWeekMask;
            
            state.WeeklyOccursOnSaturday = dayOfWeekMask >= 64;
            dayOfWeekMask = subtractBitwiseValue(dayOfWeekMask, 64);
            
            state.WeeklyOccursOnFriday = dayOfWeekMask >= 32;
            dayOfWeekMask = subtractBitwiseValue(dayOfWeekMask, 32);
            
            state.WeeklyOccursOnThursday = dayOfWeekMask >= 16;
            dayOfWeekMask = subtractBitwiseValue(dayOfWeekMask, 16);
            
            state.WeeklyOccursOnWednesday = dayOfWeekMask >= 8;
            dayOfWeekMask = subtractBitwiseValue(dayOfWeekMask, 8);
            
            state.WeeklyOccursOnTuesday = dayOfWeekMask >= 4;
            dayOfWeekMask = subtractBitwiseValue(dayOfWeekMask, 4);
            
            state.WeeklyOccursOnMonday = dayOfWeekMask >= 2;
            dayOfWeekMask = subtractBitwiseValue(dayOfWeekMask, 2);
            
            state.WeeklyOccursOnSunday = dayOfWeekMask >= 1;
            dayOfWeekMask = subtractBitwiseValue(dayOfWeekMask, 1);                    
        }
        else if(e.RecurrenceType == 'RecursMonthlyNth'){
            state.RecurrenceType = state.RecurrenceTypes.Monthly;
            
            state.MonthlyInstance = e.RecurrenceInstance;
            state.MonthlyDay = e.RecurrenceDayOfWeekMask;
            state.MonthlyInterval = e.RecurrenceInterval;
        }
        else if(e.RecurrenceType == 'RecursMonthly'){
            state.RecurrenceType = state.RecurrenceTypes.MonthlyFixedDate;
            
            state.MonthlyDayOfMonth = e.RecurrenceDayOfMonth;
            state.MonthlyFixedInterval = e.RecurrenceInterval;
        }
        else if(e.RecurrenceType == 'RecursYearlyNth'){
            state.RecurrenceType = state.RecurrenceTypes.Yearly;            
            
            state.YearlyInstance = e.RecurrenceInstance;
            state.YearlyDay = e.RecurrenceDayOfWeekMask;
            state.YearlyMonth = e.RecurrenceMonthOfYear;
        }
        else if(e.RecurrenceType == 'RecursYearly'){
            state.RecurrenceType = state.RecurrenceTypes.YearlyFixedDate;
            
            state.YearlyFixedMonth = e.RecurrenceMonthOfYear;
            state.YearlyDayOfMonth = e.RecurrenceDayOfMonth;
        }
        
        return state;
    }
    
    private integer subtractBitwiseValue(integer mask, integer value){
        if(mask >= value){
            mask = mask-value;
        }
        
        return mask;
    }
}