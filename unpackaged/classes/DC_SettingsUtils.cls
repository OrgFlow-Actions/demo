// 
//This class provides access to custom settings
//
//Author: Gennadiy Pervukhin (30-10-2014)
public class DC_SettingsUtils
{
    //
    //Constants
    //
    public static final String TRIGGERS_ENABLED = 'TRIGGERS_ENABLED';
    
    public static final String EVENT_RTs_FOR_CUSTOM_NOTICES = 'EVENT_RTs_FOR_CUSTOM_NOTICES';
    private static final String SEPARATOR_OF_RT_IDs = ',';
    public static final String SEND_EVENT_NOTICES_FROM_ADDRESS = 'SEND_EVENT_NOTICES_FROM_ADDRESS';
    public static final String ADDRESS_OF_REPLY_TO_EVENT_NOTICE = 'ADDRESS_OF_REPLY_TO_EVENT_NOTICE';
    public static final String CASE_RECORD_TYPE_NAME = 'CASE_RECORD_TYPE_NAME';
    public static final String ARTICLE_RECORD_TYPE_NAME = 'ARTICLE_RECORD_TYPE_NAME';
    public static final String AUTO_APPROVE_CASE_RECORD_TYPE = 'AUTO_APPROVE_CASE_RECORD_TYPE';
    public static final String AUTO_APPROVE_ARTICLE_RECORD_TYPE = 'AUTO_APPROVE_ARTICLE_RECORD_TYPE';
    
    //
    
    //
    //Variables
    //
    private static Boolean triggersEnabled;
    //
    
    //
    //Public static methods
    //
    //this method gets string value from a custom setting and returns it
    public static String getStringValueByName(String settingName)
    {
        try
        {
            DC_Setting__c setting = DC_Setting__c.getValues(settingName);
            if (setting != null)
            {
                return setting.Value__c;
            }
        }
        catch (Exception ex)
        {
            System.debug(LoggingLevel.WARN, ex);
        }
        return null;
    }
    
    public static Set<String> getStringValuesByName(String settingName) {
        final String value = getStringValueByName(settingName);
        return String.isBlank(value) ? new Set<String>() 
            : new Set<String>(value.split(SEPARATOR_OF_RT_IDs));
    }
    
    /*this method gets string value from a custom setting, tries to convert it
    to a Boolean-value and returns the result*/
    public static Boolean getBooleanValueByName(String settingName)
    {
        try
        {
            String settingValue = getStringValueByName(settingName);
            return Boolean.valueOf(settingValue);
        }
        catch (Exception ex)
        {
            System.debug(LoggingLevel.WARN, ex);
        }
        return null;
    }
    
    /*this method returns the value which determines whether the triggers are
    enabled or no. The method reads custom setting only one time per a transaction
    and stores the value in a local static variable.*/ 
    public static Boolean triggersEnabled()
    {
        if (triggersEnabled == null)
        {
            String settingForTriggersValue = getStringValueByName(TRIGGERS_ENABLED);
            if (settingForTriggersValue != null)
            {
                triggersEnabled = Boolean.valueOf(settingForTriggersValue);
            }
            else
            {
                triggersEnabled = true;
            }
        }
        return triggersEnabled;
    }
    
    public static void setTriggersSettingForCurrentRequest(Boolean areTriggersEnabled)
    {
        DC_SettingsUtils.triggersEnabled = areTriggersEnabled;
    }
    
    public static Set<Id> getIdsOfEventRTsForNotices()
    {
    	//extract a string value from the custom setting
    	String stringOfIds = getStringValueByName(EVENT_RTs_FOR_CUSTOM_NOTICES);
    	if (String.isBlank(stringOfIds))
    	{
    		return new Set<Id>();
    	}
    	
    	//split the value into an array and trim each Id
    	Set<Id> setOfIds = new Set<Id>(); 
    	String[] idValues = stringOfIds.split(SEPARATOR_OF_RT_IDs);
    	for (String idValue : idValues)
    	{
    		setOfIds.add(idValue.trim());
    	}
    	
    	return setOfIds;
    }
    //
}