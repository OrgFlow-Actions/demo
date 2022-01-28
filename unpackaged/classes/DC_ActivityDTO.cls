//Author: Sergey Legostaev
//Date: 05/02/2017
public class DC_ActivityDTO implements Comparable {
    public String id {get; set;}
    public String subject {get; set;}
    public Date activityDate {get; set;}
    public String whoId {get; set;}
    public String whoName {get; set;}
    public String ownerId {get; set;}
    public String ownerName {get; set;}
    public String eventStatus {get; set;}
    public String status {get; set;}
    public String description {get; set;}
    public String callNote {get; set;}
    public String relatedToId {get; set;}
    public String relatedToName {get; set;}
    public String contactType {get; set;}
    
    public Integer compareTo(Object obj) {
        DC_ActivityDTO dto = (DC_ActivityDTO) obj;
        if (dto != null && this.activityDate != null && dto.activityDate != null) {
            return this.activityDate >= dto.activityDate ? -1 : 1; 
        }
        return 0;
    }
    
}