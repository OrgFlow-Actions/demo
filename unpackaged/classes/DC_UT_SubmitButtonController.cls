@isTest
public class DC_UT_SubmitButtonController {
    
    private static Case caze;

    private static void beforeTest() {
        RecordType rt = [select Name from RecordType where Name = 'Return Authorizations'];
        
        //create test Case
        caze = new Case();
        caze.RecordTypeId = rt.Id;
        insert caze;
        system.debug('case RecordTypeId' + caze.RecordTypeId);
        
        rt = [select Name from RecordType where Name = 'Return Authorization'];
        //create Article__c object
        Article__c atricle = new Article__c();
        atricle.Related_Case__c = caze.Id;
        atricle.RecordTypeId = rt.Id;
        insert atricle;
        
        //create custom settings for test
        DC_Setting__c settings = new DC_Setting__c();
        settings.Name = DC_SettingsUtils.CASE_RECORD_TYPE_NAME;
        settings.Value__c = 'Return Authorizations,Service Complaint';
        insert settings;
        
        DC_Setting__c settings2 = new DC_Setting__c();
        settings2.Name = DC_SettingsUtils.ARTICLE_RECORD_TYPE_NAME;
        settings2.Value__c = 'Return Authorization,Service Complaints';
        insert settings2;
    }
    
    private static testMethod void submitArticlesForApprovalTest() {
        beforeTest();
        
        ApexPages.StandardController sc = new ApexPages.StandardController(caze);
        DC_SubmitButtonController controller = new DC_SubmitButtonController(sc);
        controller.submitArticlesForApproval();
    }
}