/*-------------------------------------------------------------------------------------------------	
Author: 		Richard Trum 20200123 	
Description:   	Flow questionnaire lightning component controller
History	
20200123 		Created
--------------------------------------------------------------------------------------------------*/

({
	init : function(component, event, helper) {
        
        var existingResponses = component.get("v.responses");
        var componentsToCreate = [];
            
        //Get questions to add to the component
        var action = component.get("c.getQuestions");
		    action.setParams({
                recordId : component.get("v.recordId"),
                questionnaireId: component.get("v.questionnaireId"),
                category: component.get("v.category")
            });
        
       action.setCallback(this, function(response) {
            var state = response.getState();
			
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                var options = [];
                var anyRequiredQuestion = false;
				
                for(var j in result){
                    //Find all options to each question
                     options = [];
                		for(var i in result[j].options){
                   			 var option = {
                    				label: result[j].options[i],
                    				value: result[j].options[i]
                				};
                    		options.push(option);
                		}
                    result[j].options = options;
                    
                    //Check if any question is required
                    if(result[j].questionDetails.Required_Question__c == true){
                        anyRequiredQuestion = true;
                    }
                    
                    //Check if the question has already been answered in the questionnaire - if so, load the answer
                    var existingResponse = '';                   
                    for(var k in existingResponses){
                     	var sourceId = existingResponses[k].Source_Id__c;
                        var answer = existingResponses[k].Answer__c;
                    	
                        if(sourceId == result[j].questionDetails.Name && result[j].questionDetails.Question_Type__c != 'Multiselect Checkbox'){
                            existingResponse = answer;
                        }     
                    }    
                    
					//Assign type of component based on question type                    
                    var compType = "lightning:input";                    
                    if(result[j].questionDetails.Question_Type__c == 'Picklist') {
                    compType = "lightning:combobox";
                    }                    
                    else if(result[j].questionDetails.Question_Type__c == 'Multiselect Checkbox') {
                    compType = "lightning:dualListbox";
                    }                    
                    else if(result[j].questionDetails.Question_Type__c == 'Yes/No Radio Buttons') {
                    compType = "lightning:radioGroup";
                    }
                    
                    //Assign component details
                    var cmpToCreate = [
            		compType,
            		{
                			"aura:id": result[j].questionDetails.Name,
                        	"label": result[j].questionDetails.Question_Body__c,
                            "value" : existingResponse,
                			"onchange" : component.getReference("c.setResponse"),
                        	"required" :result[j].questionDetails.Required_Question__c,
                        	"name" : result[j].questionDetails.Name,
                        	"options": result[j].options,
                        	"qType" : result[j].questionDetails.Question_Type__c

            		}];
        			
                    componentsToCreate.push(cmpToCreate);
    
                }
                
                component.set('v.questions', result);
                
                //Create components
                $A.createComponents(
        		componentsToCreate,  
        		function(newCmp, status, errorMessage){
                			if (status === "SUCCESS") {
                                	var body = component.get("v.body");
                    				body = newCmp;
                   					component.set("v.body", body);
                			}
                        	else if (status === "INCOMPLETE") {
                				console.log("No response from server or client is offline.")
            				}
                        	else if(status === "ERROR"){
                                console.log("Error: " + errorMessage);
                        	}
         		}
 				);
                
                console.log("Required questions exist: " + anyRequiredQuestion);
               	if(anyRequiredQuestion == false){
                    component.set("v.requiredQuestionsAnswered", true);
                }
      
       }
       });
     $A.enqueueAction(action);   
          
      
	},

	/*------------------------------------------------------------	
	Description:   	Method to set the response for answered questions in the questionnaire
	Inputs:        	@param val 			Actual answer to the question
					@param respName 	Name for answered question
                    @param responses	All responses given in the questionnaire
                    @param questions	All questions in the questionnaire
	------------------------------------------------------------*/	      
    
    setResponse : function(component, event, helper) {
	
    var val = event.getSource().get("v.value");
    var answer = val;
    
    //Save answer as a JSON string if answer is multi-select
    var qType = typeof val;        
   	if(qType == 'object'){
        answer = JSON.stringify(val);
    } 
       
    var respName = event.getSource().get("v.name");
    var responses = component.get("v.responses");
    var questions = component.get("v.questions");
                          
    //Check if question has been answered before - if so, update answer    
    var updExistingAnswer = false;        
    for(var j in responses){
          if(responses[j].Source_Id__c == respName){
                   updExistingAnswer = true;
                   responses[j].Answer__c = answer;
          }                        
     }    
       
    var invalidCmp = false;        
        
   	for(var i in questions){  
            
        	//If question has not been answered - find the right question and add it as an answer     
        	if(questions[i].questionDetails.Name == respName && updExistingAnswer == false){

            		var response = {};
            		var question = questions[i];
            		var qId = question.questionDetails.Questionnaire_Setup__c;
            		response.Answer__c = answer;
    				response.Question__c = event.getSource().get("v.label");
    				response.Account_Name__c = component.get("v.recordId");
					response.Source_Id__c = event.getSource().get("v.name");
            		response.Questionnaire_Setup__c = qId;
            		responses.push(response);
                
            }
        	
        	//Check if question is valid
        	var sourceId = questions[i].questionDetails.Name;
   	    	var inputCmp = component.find(sourceId);
        
        	if(inputCmp.isRendered()) {            
            	if(inputCmp.checkValidity() == false){	
                 	invalidCmp = true;
            	}
    		}
    }
       
    //Set requiredQuestionsAnswered to true if all required questions are answered    
    if(invalidCmp == false){
            component.set("v.requiredQuestionsAnswered", true);
    }    
	
    //Assign responses
    component.set("v.responses", responses);

    }    
})