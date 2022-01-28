@IsTest
public class LightningCompSetupTest {

    @IsTest
    private static void loadRelatedRecordsTest() {
        String fullName = 'Team_setup';
        String fields = 'DeveloperName, Label, Status__c';
        
        List<SObject> testing = new List<SObject> ();
        List<SObject> testing2 = new List<SObject> ();
        Team_setup__mdt[] rows =
            [SELECT DeveloperName, Label, Status__c
            FROM Team_setup__mdt
            ORDER BY Label 
            LIMIT 10 ];
            
        testing = LightningCompSetup.loadRelatedRecord(fullName, fields);
        System.assertEquals(rows, testing);
        
        testing2 = MetadataRecordDataController.loadRecord(fullName, fields, 'Sweden');
        System.assertEquals(rows, testing2);
        
    }
        
    /*@IsTest
    private static void upsertCmpTest() {
        
        List<SObject> testing = new List<SObject> ();
        Lightning_component__mdt[] rows =
            [SELECT DeveloperName, Label, Status__c
            FROM Lightning_component__mdt
            LIMIT 10];
            
        String record = 'Testing';
        String Descr = 'Testing to create component';
        String Status = 'Active';
        
        String result = '';
        Test.startTest();
        result = LightningCompSetup.upsertCmp(record, Descr, Status);        
        System.assertNotEquals('', result);
        Test.stopTest();
        
    } 
    
    @IsTest
    private static void upsertTeamTest() {
        
        List<SObject> testing = new List<SObject> ();
        Team_setup__mdt[] rows =
            [SELECT DeveloperName, Label, Status__c
            FROM Team_setup__mdt
            LIMIT 10];
            
        String record = 'Testing';
        String Country = 'Sweden';
        String Descr = 'Testing to create component';
        String Status = 'Active';
        
        String result = '';
        result = Test.isRunningTest() ? 'Fake Job Id': LightningCompSetup.upsertTeam(record, Country, Descr, Status);        
        System.assertNotEquals('', result);
        
    }*/ 
    
    @IsTest
    private static void PickListValuesIntoListTest() {
        String Cmp = 'Lightning_Component__mdt';
        String Field = 'Status__c';
        List<String> result = new List<String>();
        result = LightningCompSetup.getPickListValuesIntoList(Cmp, Field);        
        System.assertNotEquals(0, result.size());
        
    } 
    @IsTest
    private static void SessionControllerTest() {
        String result = SessionController.getSessionId();       
        System.assertNotEquals(null, result);
        
    }
    
    @IsTest
    private static void getUserListTest() {
     String SearchStr = '';
     String Countr = '';
     String Tm = '';
        
     List<User> result = LightningCompSetup.getUserList(SearchStr, Countr, Tm);
        
     Countr = 'UK';        
     result = LightningCompSetup.getUserList(SearchStr, Countr, Tm);
        
     Countr = '';
     Tm = 'UK1';        
     result = LightningCompSetup.getUserList(SearchStr, Countr, Tm);    
          
     Countr = 'UK';
     result = LightningCompSetup.getUserList(SearchStr, Countr, Tm);   
        
    }
    
    @IsTest
    private static void updateUserTest() {
        
        User TestUsr = new User();
        TestUsr.FirstName = 'Test';
        TestUsr.LastName = 'Test';
        String Tm = 'UK1';
        
        String result = LightningCompSetup.updateUser(TestUsr, Tm);
        System.assertEquals('error', result);
        
    }
    
        
    @IsTest
    private static void upsertCmpTest() {

        // Given
        CustomMetadataTest.MockPlatform mockPlatform = new CustomMetadataTest.MockPlatform();
        mockPlatform.metadataEnqueueDeploymentResult = new Metadata.DeployResult();
        mockPlatform.metadataEnqueueDeploymentResult.details = new Metadata.DeployDetails();
        mockPlatform.metadataEnqueueDeploymentResult.details.componentFailures = new List<Metadata.DeployMessage>();
        mockPlatform.metadataEnqueueDeploymentResult.details.componentSuccesses = new List<Metadata.DeployMessage>();
        Metadata.DeployMessage deploySuccess = 
            (Metadata.DeployMessage) JSON.deserialize(
                '{"fullName":"Account","success":true}', Metadata.DeployMessage.class);
        mockPlatform.metadataEnqueueDeploymentResult.details.componentSuccesses.add(deploySuccess);
        mockPlatform.eventBusPublishResponse = 
            (List<Database.SaveResult>) JSON.deserialize(
                '[{"id":"e00xx000000001TAAQ","success":true,"errors":[],"warnings":[]}]', List<Database.SaveResult>.class);
        CustomMetadata.Platform = mockPlatform;
        List<Map<SObjectField, Object>> records = 
            new List<Map<SObjectField, Object>> {
                new Map<SObjectField, Object> {
                    Account.Description => 'My Record'
            } };
        
        // When
        String deployId = LightningCompSetup.upsertCmp('Test', 'Test', 'Active', 'Test Testsson');
        
        // Then
        System.assertEquals(
            'Status__c', ((Metadata.CustomMetadata) mockPlatform.metadataEnqueueDeploymentContainer.getMetadata()[0]).values[0].field);
        System.assertEquals(
            'Active', ((Metadata.CustomMetadata) mockPlatform.metadataEnqueueDeploymentContainer.getMetadata()[0]).values[0].value);        
    }    

        @IsTest
    private static void upsertTeamTest() {

        // Given
        CustomMetadataTest.MockPlatform mockPlatform = new CustomMetadataTest.MockPlatform();
        mockPlatform.metadataEnqueueDeploymentResult = new Metadata.DeployResult();
        mockPlatform.metadataEnqueueDeploymentResult.details = new Metadata.DeployDetails();
        mockPlatform.metadataEnqueueDeploymentResult.details.componentFailures = new List<Metadata.DeployMessage>();
        mockPlatform.metadataEnqueueDeploymentResult.details.componentSuccesses = new List<Metadata.DeployMessage>();
        Metadata.DeployMessage deploySuccess = 
            (Metadata.DeployMessage) JSON.deserialize(
                '{"fullName":"Account","success":true}', Metadata.DeployMessage.class);
        mockPlatform.metadataEnqueueDeploymentResult.details.componentSuccesses.add(deploySuccess);
        mockPlatform.eventBusPublishResponse = 
            (List<Database.SaveResult>) JSON.deserialize(
                '[{"id":"e00xx000000001TAAQ","success":true,"errors":[],"warnings":[]}]', List<Database.SaveResult>.class);
        CustomMetadata.Platform = mockPlatform;
        List<Map<SObjectField, Object>> records = 
            new List<Map<SObjectField, Object>> {
                new Map<SObjectField, Object> {
                    Account.Description => 'My Record'
            } };
        
        // When
        String deployId = LightningCompSetup.upsertTeam('Test', 'Sweden', 'Test', 'Active');
        
        // Then
        System.assertEquals(
            'Country__c', ((Metadata.CustomMetadata) mockPlatform.metadataEnqueueDeploymentContainer.getMetadata()[0]).values[0].field);
        System.assertEquals(
            'Sweden', ((Metadata.CustomMetadata) mockPlatform.metadataEnqueueDeploymentContainer.getMetadata()[0]).values[0].value);        
    }   
    
    
    //Test classes for MetadataRecordDataController
    
    @IsTest
    private static void createCountryRecordTest() {

        // Given
        CustomMetadataTest.MockPlatform mockPlatform = new CustomMetadataTest.MockPlatform();
        mockPlatform.metadataEnqueueDeploymentResult = new Metadata.DeployResult();
        mockPlatform.metadataEnqueueDeploymentResult.details = new Metadata.DeployDetails();
        mockPlatform.metadataEnqueueDeploymentResult.details.componentFailures = new List<Metadata.DeployMessage>();
        mockPlatform.metadataEnqueueDeploymentResult.details.componentSuccesses = new List<Metadata.DeployMessage>();
        Metadata.DeployMessage deploySuccess = 
            (Metadata.DeployMessage) JSON.deserialize(
                '{"fullName":"Account","success":true}', Metadata.DeployMessage.class);
        mockPlatform.metadataEnqueueDeploymentResult.details.componentSuccesses.add(deploySuccess);
        mockPlatform.eventBusPublishResponse = 
            (List<Database.SaveResult>) JSON.deserialize(
                '[{"id":"e00xx000000001TAAQ","success":true,"errors":[],"warnings":[]}]', List<Database.SaveResult>.class);
        CustomMetadata.Platform = mockPlatform;
        List<Map<SObjectField, Object>> records = 
            new List<Map<SObjectField, Object>> {
                new Map<SObjectField, Object> {
                    Account.Description => 'My Record'
            } };
        
        // When
        String deployId = MetadataRecordDataController.createCountryRecord('Test', 'SE1', 'Account_CFE_Summary', true);
        
        // Then
        System.assertEquals(
            'LightningComponent__c', ((Metadata.CustomMetadata) mockPlatform.metadataEnqueueDeploymentContainer.getMetadata()[0]).values[0].field);
        System.assertEquals(
            'Account_CFE_Summary', ((Metadata.CustomMetadata) mockPlatform.metadataEnqueueDeploymentContainer.getMetadata()[0]).values[0].value);        
    } 
    
    
        @IsTest
    private static void whenUpsertingBySObjectSendsEvent() {

        // Given
        CustomMetadataTest.MockPlatform mockPlatform = new CustomMetadataTest.MockPlatform();
        mockPlatform.metadataEnqueueDeploymentResult = new Metadata.DeployResult();
        mockPlatform.metadataEnqueueDeploymentResult.details = new Metadata.DeployDetails();
        mockPlatform.metadataEnqueueDeploymentResult.details.componentFailures = new List<Metadata.DeployMessage>();
        mockPlatform.metadataEnqueueDeploymentResult.details.componentSuccesses = new List<Metadata.DeployMessage>();
        Metadata.DeployMessage deploySuccess = 
            (Metadata.DeployMessage) JSON.deserialize(
                '{"fullName":"Account","success":true}', Metadata.DeployMessage.class);
        mockPlatform.metadataEnqueueDeploymentResult.details.componentSuccesses.add(deploySuccess);
        mockPlatform.eventBusPublishResponse = 
            (List<Database.SaveResult>) JSON.deserialize(
                '[{"id":"e00xx000000001TAAQ","success":true,"errors":[],"warnings":[]}]', List<Database.SaveResult>.class);
        CustomMetadata.Platform = mockPlatform;
        List<SObject> records = new List<SObject> { new Account(Description = 'My Record') }; 
        
        // When
        String deployId = MetadataRecordDataController.upsertRecord(records[0]);
        
        // Then
        System.assertEquals(
            'Description', ((Metadata.CustomMetadata) mockPlatform.metadataEnqueueDeploymentContainer.getMetadata()[0]).values[0].field);
        System.assertEquals(
            'My Record', ((Metadata.CustomMetadata) mockPlatform.metadataEnqueueDeploymentContainer.getMetadata()[0]).values[0].value);        
        /*System.assertEquals(
            '[{"success":true,"fullName":"Account"}]', 
            mockPlatform.eventBusPublishEvents[0].get('Description'));*/
    } 


}