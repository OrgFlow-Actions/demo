@IsTest
private class InCountryContactTriggerTest {

    private static final String SOBJECT_API_NAME = 'Contact';
    private static final Map<String, Object> TEST_VALUE_BY_FIELD_TYPE = new Map<String, Object>{
        'STRING' => 'TestValue',
        'TEXTAREA' => 'TestTextAreaValue',
        'PHONE' => '12345678',
        'URL'  => 'https://www.test.com',
        'EMAIL' => 'test@test.com',
        'DATETIME' => Datetime.now(),
        'DATE' => Date.today(),
        'TIME' => Datetime.now().time(),
        'DOUBLE' => 10,
        'CURRENCY' => 10,
        'INTEGER' => 10,
        'BOOLEAN' => true
    };

    @TestSetup
    static void testSetup() {
        insert new testInCountry1__Object_relationship__c(testInCountry1__Object_name__c = SOBJECT_API_NAME, testInCountry1__Type__c = 'object', testInCountry1__Country__c = 'ru');

        List<testInCountry1__Object_relationship_fields__c> objectRelationshipFields = new List<testInCountry1__Object_relationship_fields__c>();
        testInCountry1__Object_relationship_fields__c objectRelationshipField; 
        for (String requiredField : getRequiredFields()) {
            objectRelationshipField = new testInCountry1__Object_relationship_fields__c();
            objectRelationshipField.testInCountry1__Object_name__c = SOBJECT_API_NAME;
            objectRelationshipField.testInCountry1__Field_name__c = requiredField;
            objectRelationshipFields.add(objectRelationshipField);
        }
        insert objectRelationshipFields;
    }

    @IsTest
    static void test_handleBeforeInsert_positive() {
        setMetadata();
        Contact newRecord = new Contact();
        populateRequiredFields(newRecord, SOBJECT_API_NAME);
        testInCountry1.InCountryReplicationTriggerHandler.disableTrigger = false;    
        testInCountry1.InCountryCustomMock.setMock(new InCountryRestAPIMock());

        Test.startTest();
        insert newRecord;
        Test.stopTest();

        List<Contact> records = [SELECT Id FROM Contact WHERE Id = :newRecord.Id];
        System.assert(!records.isEmpty(), 'Record wasn\'t inserted.');
    }

    @IsTest
    static void test_handleAfterDelete_positive() {
        setMetadata();
        Contact newRecord = new Contact();
        populateRequiredFields(newRecord, SOBJECT_API_NAME);
        testInCountry1.InCountryReplicationTriggerHandler.disableTrigger = true;     
        insert newRecord; 
        testInCountry1.InCountryReplicationTriggerHandler.disableTrigger = false;
        testInCountry1.InCountryCustomMock.setMock(new InCountryRestAPIMock());

        Test.startTest();
        delete newRecord;
        Test.stopTest();

        System.assert([SELECT Id FROM Contact].isEmpty(), 'List of records must be empty.');
    }

    private static void populateRequiredFields(SObject newRecord, String sobjectApiName) {
        Map<String,Schema.SObjectField> fields = Schema.getGlobalDescribe().get(sobjectApiName).getDescribe().fields.getMap();
        Schema.DescribeFieldResult fieldDescribe;
        for(String fieldName : fields.keyset()) {
            fieldDescribe = fields.get(fieldName).getDescribe();
            if (fieldDescribe.isCreateable() && !fieldDescribe.isNillable() && !fieldDescribe.isDefaultedOnCreate()) {
                populateField(newRecord, fieldName, fieldDescribe);
            }
        }
    }

    private static void populateField(SObject newRecord, String fieldName, Schema.DescribeFieldResult fieldDescribe) {
        String fieldType = fieldDescribe.getType().name();
        switch on fieldType {
            when 'STRING', 'TEXTAREA', 'PHONE', 'URL', 'EMAIL' {
                newRecord.put(fieldName, (String)TEST_VALUE_BY_FIELD_TYPE.get(fieldType));
            }
            when 'DATETIME' {
                newRecord.put(fieldName, (Datetime)TEST_VALUE_BY_FIELD_TYPE.get(fieldType));
            }
            when 'DATE' {
                newRecord.put(fieldName, (Date)TEST_VALUE_BY_FIELD_TYPE.get(fieldType));
            }
            when 'TIME' {
                newRecord.put(fieldName, (Time)TEST_VALUE_BY_FIELD_TYPE.get(fieldType));
            }
            when 'DOUBLE' {
                newRecord.put(fieldName, (Double)TEST_VALUE_BY_FIELD_TYPE.get(fieldType));
            }
            when 'CURRENCY' {
                newRecord.put(fieldName, (Decimal)TEST_VALUE_BY_FIELD_TYPE.get(fieldType));
            }
            when 'INTEGER' {
                newRecord.put(fieldName, (Integer)TEST_VALUE_BY_FIELD_TYPE.get(fieldType));
            }
            when 'BOOLEAN' {
                newRecord.put(fieldName, (Boolean)TEST_VALUE_BY_FIELD_TYPE.get(fieldType));
            }
            when 'PICKLIST' {
                List<Schema.PicklistEntry> picklistValues = Schema.getGlobalDescribe()
                    .get(newRecord.getSObjectType().getDescribe().getName()).getDescribe()
                    .fields.getMap().get(fieldName).getDescribe().getPicklistValues();
                if (!picklistValues.isEmpty()) {
                    newRecord.put(fieldName, picklistValues[0].getLabel());
                } else {
                    newRecord.put(fieldName, 'test_option');
                }
            }
            when 'REFERENCE' {
                List<Schema.sObjectType> parentSObjectList = fieldDescribe.getReferenceTo();
                if (!parentSObjectList.isEmpty()) {
                    String parentSObjectApiName = parentSObjectList[0].getDescribe().getName();
                    SObject parentSObject = parentSObjectList[0].newSObject();
                    if (parentSObject.getSObjectType().getDescribe().isCreateable()) {
                        populateRequiredFields(parentSObject, parentSObjectApiName);
                        insert parentSObject;
                        newRecord.put(fieldName, parentSObject.Id);
                    }
                }
            }
            when else {
                System.assert(false, 'Test doesn\'t have a required type.');
            }
        }
    }

    private static List<String> getRequiredFields() {
        Map<String,Schema.SObjectField> fields = Schema.getGlobalDescribe().get(SOBJECT_API_NAME).getDescribe().fields.getMap();
        List<String> requiredFields = new List<String>();
        Schema.DescribeFieldResult describeResult;
        for(String fieldName : fields.keyset()) {
            describeResult = fields.get(fieldName).getDescribe();
            if (describeResult.isCreateable() && !describeResult.isNillable() && !describeResult.isDefaultedOnCreate()) {
                requiredFields.add(fieldName);
            }
        }
        return requiredFields;
    }

    private class InCountryRestAPIMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse response = new HttpResponse();
            response.setStatusCode(200);
            return response;
        }
    }

    private static void setMetadata() {
        String jsonRestApiEndpoint = '[{' + 
            '"testInCountry1__Country__c":"ru", ' + 
            '"testInCountry1__Endpoint__c":"https://ru-restapi.incountry.io",' + 
            '"testInCountry1__CertificateNameApi__c":"someapi",' + 
            '"testInCountry1__CertificateNameRest__c":"someapi",' + 
            '"testInCountry1__CertificateNameServerless__c":"someapi",' + 
            '"testInCountry1__CertificateNameBatch__c":"someapi",' +
            '"testInCountry1__Token__c":"Bearer {JWS}",' + 
            '"testInCountry1__Default__c":"false",' + 
            '"testInCountry1__x_env_id":""' + 
        '}]';

        testInCountry1.InCountryCustomMetadataDAOtest.setMetadata(
            'SELECT testInCountry1__Country__c, testInCountry1__Endpoint__c, testInCountry1__CertificateNameApi__c, ' + 
                'testInCountry1__CertificateNameRest__c, testInCountry1__CertificateNameServerless__c, ' + 
                'testInCountry1__CertificateNameBatch__c, testInCountry1__Token__c, testInCountry1__Default__c, testInCountry1__x_env_id__c ' + 
            'FROM testInCountry1__InCountryRestApiEndpoint__mdt ' + 
            'LIMIT 50',
            (List<testInCountry1__InCountryRestApiEndpoint__mdt>) JSON.deserialize(jsonRestApiEndpoint, List<testInCountry1__InCountryRestApiEndpoint__mdt>.class)
        );
    }
}