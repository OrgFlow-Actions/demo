/*------------------------------------------------------------	
	Author: 		Richard Trum (Glimt) 2019-11-28 	
	Description:   	Class for getting Questionnaire_Setup__c records and Questions__c records
					that are used within the flow to create new prospects/leads from an account
	------------------------------------------------------------*/ 
public with sharing class flowQuestionnaireController {

	/*------------------------------------------------------------	
	Description:   	AuraEnabled method to get questions from a certain questionnaire and related to a certain product line
	Inputs:        	@param recordId - the account's Id
					@param questionnaireId - the questionnaire (Questionnaire_Setup__c) Id
					@param category - The category/product line to filter the questions on
	------------------------------------------------------------*/	
    @AuraEnabled
    public static List<QuestionWrapper> getQuestions(String recordId, String questionnaireId, String category) {
        
    Account acc = [SELECT Id, Name, Country__c FROM ACCOUNT WHERE Id =: recordId];    
	
    List<Questions__c> questions = [SELECT Id, Name, Product_Line__c, Question_Body__c, Question_Order__c, Question_Type__c, Questionnaire_Setup__c, Questionnaire_Setup__r.Product_Line__c, Required_Question__c, Status__c, Responses__c
                                    FROM Questions__c WHERE (Questionnaire_Setup__c =: questionnaireId AND (Product_Line__c =: category OR Product_Line__c=:'Not SBU-Specific')) AND Status__c = 'Active' ORDER BY Question_Order__c ASC NULLS LAST];
        
    List<QuestionWrapper> result = new List<QuestionWrapper>();
        
    for(Questions__c q: questions){
            result.add(new QuestionWrapper(q));
    }
        
    return result;

    }

	/*------------------------------------------------------------	
	Description:   	Invokable method (used in flows) to get cross-SBU questionnaires related to a certain country
					This method is handled in apex to be able to filter on the Country__c field which is a multi-select field
	Inputs:        	@param inputs - List of strings to input which country to filter on
	------------------------------------------------------------*/	    
    
    @InvocableMethod
    public static List<Questionnaire_Setup__c> getQuestionnaire(List<String> inputs){
    
    String country = inputs[0];
    List<Questionnaire_Setup__c> qList = new List<Questionnaire_Setup__c>();
    
        try{  
    		 qList = [SELECT Id, Country__c FROM Questionnaire_Setup__c WHERE (Country__c includes (:country) AND Questionnaire_Type__c =: 'xSBU' AND Status__c = 'Active')];
        }
        catch(DmlException e){
            System.debug('The following exception has occurred: ' + e.getMessage());
        }
 
    return qList;
        
    }

	/*------------------------------------------------------------	
	Description:   	Wrapper class to be able to return both the question details as well as the question options as an array
	------------------------------------------------------------*/	     
    
    public class QuestionWrapper {
    @AuraEnabled public Questions__c questionDetails;
    @AuraEnabled public List<String> options;
        
    QuestionWrapper(Questions__c q) {
        questionDetails = q;
        if(String.isBlank(q.Responses__c)){
        }
        else{
        options = q.Responses__c.split(';');
        }    
    }
	}
}