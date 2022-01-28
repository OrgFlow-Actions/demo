public class AttendeesWrapperClass {
public class DisplayAttendeesRecords {
        
       // @AuraEnabled public boolean isSelected;
        @AuraEnabled public string AttendeesName;
        @AuraEnabled public string status;
        //@AuraEnabled public string EventId;
        
        public DisplayAttendeesRecords(){
            AttendeesName = '';
            status = 'Not Invited';
        }
    }
}