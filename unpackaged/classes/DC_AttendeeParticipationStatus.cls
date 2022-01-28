//
//This class contains constants for all possible participation statuses, which
//are supported by SF, and provides the logic to work with them.
//
//Author: Gennadiy Pervukhin (7-11-2014)
public class DC_AttendeeParticipationStatus
{
	//
	//Constants
	//
	public static final String NEW_STATUS = 'New';
	public static final String ACCEPTED = 'Accepted';
	public static final String DECLINED = 'Declined';
	
	//map of possible pseudonyms for an every status
	private static final Map<String, Set<String>> MAP_OF_STATUS_SYNONYMS =
		new Map<String, Set<String>>
	{
		NEW_STATUS => new Set<String> {'NEW'},
		ACCEPTED => new Set<String> {'ACCEPTED', 'CONFIRMED', 'TENTATIVE', 'MAYBE'},
		DECLINED => new Set<String> {'DECLINED', 'REJECTED'}
	};
	//
	
	//
	//Public static methods
	//
	public static String convertToKnownStatus(String sourceStatus)
	{
		//check passed parameters
		if (String.isBlank(sourceStatus))
		{
			return null;
		}
		
		String sourceStatusUpperCase = sourceStatus.toUpperCase();
		//look through all known statuses
		for (String knownStatus : MAP_OF_STATUS_SYNONYMS.keySet())
		{
			//extract synonyms for the current known status
			Set<String> statusSynonyms = MAP_OF_STATUS_SYNONYMS.get(knownStatus);
			//check if the passed value is 1 of synonyms of the known status
			if (statusSynonyms.contains(sourceStatusUpperCase))
			{
				return knownStatus;
			}
		}
		
		//return null if the passed value was not recognized as a known status
		return null;
	}
	//
}