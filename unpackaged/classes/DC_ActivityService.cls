//Author: Sergey Legostaev
//Date: 05/02/2017
public with sharing class DC_ActivityService {
	
    public static List<DC_ActivityDTO> getActivitiesByAccountId(String accountId) {
        Account acc = DC_AccountDAO.getAccountById(accountId);

        List<DC_ActivityDTO> activities = new List<DC_ActivityDTO>();
        if (acc != null) {
            List<Event> events = DC_EventDAO.getEventsByAccountId(accountId);
            for (Event event : events) {
                activities.add(DC_ActivityDTOConverter.converToDTO(event));
            }
            for (ActivityHistory history : acc.ActivityHistories) {
                activities.add(DC_ActivityDTOConverter.converToDTO(history));
            }
        }
        activities.sort();
        return activities;
    }
        
}