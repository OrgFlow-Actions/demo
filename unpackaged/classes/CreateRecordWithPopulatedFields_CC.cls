/**
 * Created by kdoruibin on 22/11/2019.
 */

public with sharing class CreateRecordWithPopulatedFields_CC {

    @AuraEnabled
    public static String fetchRecordTypeValues(String objectToCreate) {
        List<Schema.RecordTypeInfo> recordTypeList = Schema.getGlobalDescribe().get(objectToCreate).getDescribe().getRecordTypeInfos();
        List<RecordTypeOptions> rtOptionList = new List<RecordTypeOptions>();
        Set<Id> recordTypeIdSet = new Set<Id>();

        for (RecordTypeInfo rtInfo : recordTypeList) {
            if (rtInfo.getName() != 'Master' && rtInfo.isAvailable() == true) {
                recordTypeIdSet.add(rtInfo.getRecordTypeId());
            }
        }

        for (RecordType rtRecord : [SELECT Id, Name, Description FROM RecordType WHERE Id IN :recordTypeIdSet ORDER BY Name]) {
            rtOptionList.add(new RecordTypeOptions(rtRecord.Id, rtRecord.Name, rtRecord.Description));
        }

        return JSON.serialize(rtOptionList);
    }

    // Wrapper class holding record type options for lightning:combobox
    public class RecordTypeOptions {
        public Id value;
        public String label;
        public String description;

        RecordTypeOptions(Id recordTypeId, String recordTypeLabel, String recordTypeDescription) {
            this.value = recordTypeId;
            this.label = recordTypeLabel;
            this.description = recordTypeDescription;
        }
    }
}