/*------------------------------------------------------------	
Author: 		Richard Trum (Glimt) 2019-11-28 	
Description:   	Test class for testing the apex class flowQuestionnaireController
------------------------------------------------------------*/

@isTest
private class Test_flowQuestionnaireController {

    @IsTest
    private static void questionnaireTest(){
		Questionnaire_Setup__c q = new Questionnaire_Setup__c();
		q.Country__c = 'UK;IE';
        q.Questionnaire_Type__c = 'xSBU';
        q.Status__c = 'Active';
        q.Name = 'Test questionnaire';
        q.Create_Opportunity__c = 'Do Not';
        insert q;
        
        Account acc = new Account();
        acc.Name = 'Test account';
        acc.Country__c = 'IE';
        insert acc;
        
        Questions__c quest = new Questions__c();
        quest.Product_Line__c = 'Not SBU-Specific';
        quest.Question_Order__c = 1;
        quest.Question_Type__c = 'Free Text';
        quest.Responses__c = 'Yes;No';
        quest.Questionnaire_Setup__c = q.Id;
        quest.Status__c = 'Active';
		insert quest;        

        Test.startTest();
        List<String> input = new List<String>();
        input.add('UK');
		List<Questionnaire_Setup__c> qList = flowQuestionnaireController.getQuestionnaire(input);
        System.assertNotEquals(qList, null);
        
        List<flowQuestionnaireController.QuestionWrapper> result = flowQuestionnaireController.getQuestions(acc.Id, q.Id, '');
        System.assertEquals(result[0].questionDetails.Question_Order__c, 1);
        
        
        Test.stopTest();
        
    }

}