/*
 * Author: SLegostaev
 * Created: 9/21/2017
 */
public class DC_RecordTypeDao {
    
    public static RecordType getRecordTypeByIdForObject(String recordId, String objectName) {
        RecordType recordType = null;
        try {
            recordType = [select Name from RecordType where id = :recordId and SobjectType = :objectName];
        } catch (Exception e) {}
        return recordType;
    }
    
    /*
    public static RecordType getRecordTypeByNameForObject(String recordTypeName, String objectName) {
        RecordType recordType = null;
        try {
            recordType = [select Id from RecordType where Name = :recordTypeName and SobjectType = :objectName];
        } catch (Exception e) {}
        return recordType;
    }*/
    
    public static List<RecordType> getRecordTypeByNamesForObject(Set<String> recordTypeNames, String objectName) {
        return [select Id from RecordType where Name IN :recordTypeNames and SobjectType = :objectName];
    }
}