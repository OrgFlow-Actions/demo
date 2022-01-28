/*-------------------------------------------------------------------------------------------------------
Author: 		Kevin Do (Salesforce) 20190926
Description:   	Util methods for TestDataFactory
Test Class:     AccountSetPayerLookupTest, DC_UT_AccountTrigger
History
20190926 	Kevin Do    Created class
--------------------------------------------------------------------------------------------------------*/

@isTest(seeAllData=false)
public class TestDataFactoryUtils {
    // Org-wide controller for triggers
    public static void runTriggers (Boolean enabledState) {
        GlobalBypassProcessesSettings__c  setting = GlobalBypassProcessesSettings__c.getOrgDefaults();
        setting.RunTriggers__c = enabledState;
        upsert setting;
    }

    // Org-wide controller for Process builders
    public static void runProcessBuilders (Boolean enabledState) {
        GlobalBypassProcessesSettings__c  setting = GlobalBypassProcessesSettings__c.getOrgDefaults();
        setting.RunProcessBuilder__c = enabledState;
        upsert setting;
    }

    // Org-wide controller for Validation rules
    public static void runValidationRules (Boolean enabledState) {
        GlobalBypassProcessesSettings__c  setting = GlobalBypassProcessesSettings__c.getOrgDefaults();
        setting.RunValidationRules__c = enabledState;
        upsert setting;
    }

    // Object-specific bypasses, enabledBypasses contains comma-seperate sObject list.
    public static void triggerObjectBypass (String enabledBypasses) {
        GlobalBypassProcessesSettings__c  setting = GlobalBypassProcessesSettings__c.getOrgDefaults();
        setting.TriggerObjectsBypass__c  = (String.isBlank(enabledBypasses) ? '' : enabledBypasses);
        upsert setting;
    }

    //returns a random Integer
    public static Integer getRandomNumber(Integer size) {
        Double d = math.random() * size;
        return d.intValue();
    }

    //Return a random string from a list of strings
    public static String getRandomString(List<String> strings) {
        List<Double> ranks = new List<Double>();
        Map<Double, String> rankMap = new Map<Double,String>();

        for (String s : strings) {
            Boolean isDup = true;
            Double rank;

            while (isDup) {
                Double x = getRandomNumber(100000);
                if(!rankMap.containsKey(x)) {
                    rank = x;
                    isDup = false;
                }
            }

            ranks.add(rank);
            rankMap.put(rank,s);
        }

        ranks.sort();
        return rankMap.get(ranks.get(0));
    }

    //Returns a random picklist value
    public static string getRandomPickListValue(SObject obj, String fieldName){
        List<String> Strings = new List<String>();
        Schema.sObjectType objType = obj.getSObjectType();
        Schema.DescribeSObjectResult objDescribe = objType.getDescribe();
        Map<String, Schema.SObjectField> fieldMap = objDescribe.fields.getMap();
        List<Schema.PicklistEntry> pleValues = fieldMap.get(fieldName).getDescribe().getPickListValues();
        for (Schema.PicklistEntry pleValue : pleValues) {
            Strings.add(pleValue.getValue());
        }
        return getRandomString(Strings);
    }

    // Returns Set of picklist values (API names) for a field
    public Static Set<String> getPicklistValues(SObject obj, String picklistName)
    {
        Schema.sObjectType objType = obj.getSObjectType();
        Schema.DescribeSObjectResult objDescribe = objType.getDescribe();
        Map<String, Schema.SObjectField> fieldMap = objDescribe.fields.getMap();
        List<Schema.PicklistEntry> pleValues = fieldMap.get(picklistName).getDescribe().getPickListValues();
        Set<String> Strings = new Set<String>();
        for (Schema.PicklistEntry pleValue : pleValues)
        {
            Strings.add(pleValue.getValue());
        }
        return Strings;
    }

    // Returns Map of picklist value LABELS for a field
    public Static Map<String, String> getPicklistValueLabels(SObject obj, String picklistName) {
        Schema.sObjectType objType = obj.getSObjectType();
        Schema.DescribeSObjectResult objDescribe = objType.getDescribe();
        Map<String, Schema.SObjectField> fieldMap = objDescribe.fields.getMap();
        List<Schema.PicklistEntry> pleValues = fieldMap.get(picklistName).getDescribe().getPickListValues();
        Map<String, String> Values = new Map<String, String>();
        for (Schema.PicklistEntry pleValue : pleValues) {
            if (pleValue.isActive()) Values.put(pleValue.getValue(), pleValue.getLabel());
        }
        return Values;
    }

    // Returns context userId
    public static Id getContextUserId()
    {
        return UserInfo.getUserId();
    }

    // Returns recordType.Id
    public static RecordType getRecordType(String objectName, String developerName){
        if(String.isEmpty(objectName) || String.isEmpty(developerName)) return null;
        RecordType rt = [SELECT Id FROM RecordType WHERE SObjectType =: objectName  AND DeveloperName =: developerName LIMIT 1];
        return rt;
    }

    @isTest
    public static void testRunTriggers () {
        TestDataFactoryUtils.runTriggers(true);
        System.assertEquals(true, [SELECT Id, RunTriggers__c FROM GlobalBypassProcessesSettings__c Where SetupOwnerId =: UserInfo.getOrganizationId()].RunTriggers__c,
                'GlobalBypassProcessesSettings__c.RunTriggers__c should be true');
    }

    @isTest
    public static void testTriggerObjectBypass () {
        TestDataFactoryUtils.triggerObjectBypass('Account');
        System.assertEquals('Account', [SELECT Id, TriggerObjectsBypass__c FROM GlobalBypassProcessesSettings__c Where SetupOwnerId =: UserInfo.getOrganizationId()].TriggerObjectsBypass__c,
                'GlobalBypassProcessesSettings__c.TriggerObjectsBypass__c should be Account');
    }
}