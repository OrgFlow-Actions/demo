({
	findQuestions : function(component) {
        
    var action = component.get("c.findQuestions");

    action.setCallback(this, function(data) {
           	var results = data.getReturnValue();
        
        	if (results.length >0) {           
            component.set("v.questions", data.getReturnValue());
            }
            else {
            component.set("v.questions", null);    
            }
        }); 

        $A.enqueueAction(action);    
        
	},  
    
    findSpecificQuestions : function(component) {
        
        var questions = component.get("v.questions");
        var matchFound = false;
        //Check for matching rows in the metadata
        for (var i=0, len = questions.length; i<len; i++) {              
			
             if(questions[i].Category__c == component.find("depfieldCatValue").get("v.value")){
                    
                 if(questions[i].Label == component.find("depfieldCatValue2").get("v.value")){
                     component.set("v.specificQuestions", questions[i]);
                     matchFound = true;
                 };       
             };
            
        }
        
       //If no matching metadata could be found 
        if(matchFound != true) {
            component.set("v.specificQuestions", []);
        }
        
    },
    
    updateCase : function(component) {
    
         var action = component.get("c.getCaseInfo");
        			
        action.setParams({
            			recordId : component.get("v.caseId"), 
        			});
        			
        action.setCallback(this, function(data) {
           				console.log(data.getReturnValue());
						var res = data.getReturnValue();
                        
                        if(component.get("v.specificQuestions.Order_number__c") == true){
            				component.find("orderNumber").set("v.value", res.Order_Number__c);
                        }
                        
                        if(component.get("v.specificQuestions.Returnnumber__c") == true){
            				component.find("returnNumber").set("v.value", res.Return_Tracking_Number__c);
                        }
            
                        if(component.get("v.specificQuestions.Item_number__c") == true){
            				component.find("itemNumber").set("v.value", res.Article_Number__c);
                        } 
            
                    	if(component.get("v.specificQuestions.Invoice_number__c") == true) {
                           component.find("invoiceNumber").set("v.value", res.Invoice_Number__c);
        				}
            
            
        			});
        			
        $A.enqueueAction(action);
    }     
})