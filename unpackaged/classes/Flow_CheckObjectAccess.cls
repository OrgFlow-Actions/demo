public with sharing class Flow_CheckObjectAccess {
    
    @InvocableMethod
    public static List<ObjectAccessResult> checkObjectAccess(List<String> objectType) {
        return new List<ObjectAccessResult>{new ObjectAccessResult(objectType[0])};
    }

    public class ObjectAccessResult {
        @InvocableVariable
        public Boolean creatable;
        
        @InvocableVariable
        public Boolean accessible;
        
        @InvocableVariable
        public Boolean deletable;

        public ObjectAccessResult(String objectType) {
            Schema.DescribeSObjectResult describeResult = Schema.describeSObjects(new List<String>{objectType})[0];
            this.accessible = describeResult.isAccessible();
            this.creatable = describeResult.isCreateable();
            this.deletable = describeResult.isDeletable();
        }
    }
}