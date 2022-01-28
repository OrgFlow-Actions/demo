/*------------------------------------------------------------
Author: 		Kevin Do (Salesforce) 20191122
Description:   	Test Class for CreateRecordWithPopulatedFields_CC.
History
20191122 	Kevin Do		Created test class.
------------------------------------------------------------*/

@isTest (seeAllData=false)
public class Test_CreateRecordWithPopulatedFields_CC {
    private static final String TEST_OBJECT = 'Account';

    @isTest
    private static void testFetchRecordTypeValues() {
        List<RecordTypeInfo> recordTypeInfoList = Schema.getGlobalDescribe().get(TEST_OBJECT).getDescribe().getRecordTypeInfos();
        List<String> recordTypeInfoNameList = new List<String>();

        for (RecordTypeInfo rtInfo : recordTypeInfoList) {
            if (rtInfo.getName() != 'Master' && rtInfo.isAvailable()) {
                recordTypeInfoNameList.add(rtInfo.getName());
            }
        }

        List<Object> recordTypeTestList = new List<Object>();
        recordTypeTestList = (List<Object>) JSON.deserializeUntyped(CreateRecordWithPopulatedFields_CC.fetchRecordTypeValues(TEST_OBJECT));

        System.assertEquals(recordTypeInfoNameList.size(), recordTypeTestList.size());
    }
}