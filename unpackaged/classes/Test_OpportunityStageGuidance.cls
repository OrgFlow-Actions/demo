/*------------------------------------------------------------  
Author:         Richard Trum (Glimt) 2019-11-05     
Description:    Test class for testing the apex class OpportunityStageGuidanceClass
------------------------------------------------------------*/

@IsTest
private class Test_OpportunityStageGuidance {

    @IsTest
    private static void opportunityTest(){
        Account account1 = DC_UT_DataUtils.generateAccount('Account1');
        account1.Country__c = 'IE';
        insert account1;
        
        RecordType recType = [SELECT Id From RecordType WHERE DeveloperName ='Lightning_Pipeline_Opportunity' AND sObjectType = 'Opportunity'];
        
        Opportunity oppty1 = new Opportunity();
        oppty1.AccountId = account1.Id;
        oppty1.Name = 'x';
        oppty1.NA_Category__c = 'Implants';
        oppty1.CloseDate = date.today();
        oppty1.StageName = '0. Prospect';
        oppty1.RecordTypeId = recType.Id;
        insert oppty1;
        
        Test.startTest();
        OpportunityStageGuidanceClass.StageWrapper wrapper = new OpportunityStageGuidanceClass.StageWrapper();
        wrapper = OpportunityStageGuidanceClass.getOppStageGuidance(oppty1.Id, 'Opportunity', 'StageName', 'Account.Country__c', 'NA_Category__c', 'Lightning_Pipeline_Opportunity');
        System.assertEquals(wrapper.currentStage, oppty1.StageName);
        System.assertEquals(wrapper.objectType, 'Opportunity');
        
        try{
        wrapper = OpportunityStageGuidanceClass.getOppStageGuidance(oppty1.Id, 'Oppty', 'StageName', 'Account.Country__c', 'NA_Category__c', 'Lightning_Pipeline_Opportunity');
        } catch(Exception e){
            System.debug(e);
        }
        
        Test.stopTest();
        
    }
    
    @IsTest
    private static void prospectTest(){
        Account account1 = DC_UT_DataUtils.generateAccount('Account1');
        account1.Country__c = 'IE';
        insert account1;
        
        Field_Sales_Project__c initiative = new Field_Sales_Project__c();
        initiative.Title__c = 'Test';
        initiative.Name = 'Test';
        initiative.Start_Date__c = date.today();
        initiative.End_Date__c = date.today();
        initiative.Description__c = 'Testing';
        initiative.Initiative_Type__c = 'Sales Team Initiative';
        insert initiative;
        
        Field_Sales_Project_Members__c prospect1 = new Field_Sales_Project_Members__c();
        prospect1.Account__c = account1.Id;
        prospect1.Category__c = 'Implants';
        prospect1.Status__c = 'New';
        prospect1.Field_Sales_Project__c = initiative.Id;
        insert prospect1;

        Test.startTest();
        OpportunityStageGuidanceClass.StageWrapper wrapper = new OpportunityStageGuidanceClass.StageWrapper();
        wrapper = OpportunityStageGuidanceClass.getOppStageGuidance(prospect1.Id, 'Field_Sales_Project_Members__c', 'Status__c', 'Account__r.Country__c', 'Category__c', 'Outside_Sales_Lead');
        System.assertEquals(wrapper.currentStage, prospect1.Status__c);
        System.assertEquals(wrapper.objectType, 'Field_Sales_Project_Members__c');
        Test.StopTest();
    }

    @IsTest
    private static void testUpdateStage(){
        Account account1 = DC_UT_DataUtils.generateAccount('Account1');
        account1.Country__c = 'IE';
        insert account1;
        
        RecordType recType = [SELECT Id From RecordType WHERE DeveloperName ='Lightning_Pipeline_Opportunity' AND sObjectType = 'Opportunity'];
        
        Opportunity oppty1 = new Opportunity();
        oppty1.AccountId = account1.Id;
        oppty1.Name = 'x';
        oppty1.NA_Category__c = 'Implants';
        oppty1.CloseDate = date.today();
        oppty1.StageName = '0. Prospect';
        oppty1.RecordTypeId = recType.Id;
        insert oppty1;
        
        Test.startTest();
        OpportunityStageGuidanceClass.updateStage2(oppty1.Id, '2. Positioning products', 'StageName');
        Test.stopTest();
        
        System.assertEquals('2. Positioning products', [SELECT StageName FROM Opportunity WHERE Id = :oppty1.Id LIMIT 1]?.StageName);
    }
    
    @IsTest
    private static void testCheckStageType(){
        OpportunityStage testStage = [
            SELECT Id, MasterLabel, IsClosed, IsWon, IsActive 
            FROM OpportunityStage
            LIMIT 1
        ];

        System.assertEquals(testStage?.IsClosed, OpportunityStageGuidanceClass.checkStageType(testStage.MasterLabel)?.IsClosed);
    }
    
}