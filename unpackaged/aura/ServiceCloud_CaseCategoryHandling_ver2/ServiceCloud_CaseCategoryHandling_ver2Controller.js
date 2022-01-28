({
    
    init: function(component, event, helper) {
        console.log(component.get("v.caseId"));
        component.find("fieldCatValue").set("v.value", component.get("v.defaultVal"));
        component.find("depfieldCatValue").set("v.value", component.get("v.defaultDepVal"));
        component.find("depfieldCatValue2").set("v.value", component.get("v.defaultDepVal2"));
        
        component.set("v.resId", component.get("v.defaultVal"));
        component.set("v.depresId", component.get("v.defaultDepVal"));
        component.set("v.depres2Id", component.get("v.defaultDepVal2"));
        
        var action = component.get("c.findQuestions");

    	action.setCallback(this, function(data) {
           	var results = data.getReturnValue();
        
        	if (results.length >0) {           
            component.set("v.questions", data.getReturnValue());
            
            helper.findSpecificQuestions(component);
               
        		if(component.get("v.caseId")!=null){
					helper.updateCase(component); 
        		}
                
            }
            else {
            component.set("v.questions", null);    
            }
        }); 

        $A.enqueueAction(action);
        
    },
    
    updateVal: function(component, event, helper) {
        component.set("v.resId", component.find("fieldCatValue").get("v.value"));
        helper.findSpecificQuestions(component);
        
        if(component.get("v.caseId")!=null){
			helper.updateCase(component);
        }
    },
    
    updateDepVal: function(component, event, helper) {
        
       component.set("v.depresId", component.find("depfieldCatValue").get("v.value"));
       component.set("v.depres2Id", component.find("depfieldCatValue2").get("v.value")); 
       helper.findSpecificQuestions(component);
       
       if(component.get("v.caseId")!=null){
			helper.updateCase(component);
       }  
        
        
    },
    
    updateAnswers: function(component, event, helper) {
        // clear descriptionString so that it won't contain old data
        component.set("v.descriptionString", "");
        
        if(component.get("v.specificQuestions.Order_number__c") == true) {
        	component.set("v.orderNumber", component.find("orderNumber").get("v.value"));
            component.set("v.descriptionString", "Order number: " + component.find("orderNumber").get("v.value") + '\n');
        };
        
        if(component.get("v.specificQuestions.Item_number__c") == true) {
            component.set("v.itemNumber", component.find("itemNumber").get("v.value"));
            component.set("v.descriptionString", component.get("v.descriptionString") + " Item number: " + component.find("itemNumber").get("v.value") + '\n');
        };
        
        if(component.get("v.specificQuestions.Invoice_number__c") == true) {
            component.set("v.invoiceNumber", component.find("invoiceNumber").get("v.value"));
            component.set("v.descriptionString", component.get("v.descriptionString") + "Invoice number: " + component.get("v.invoiceNumber") + '\n');
        };
        
        if(component.get("v.specificQuestions.Amount__c") == true) {
            
            component.set("v.descriptionString", component.get("v.descriptionString") + "Amount: " + component.get("v.amount") + '\n');
        };
        
        if(component.get("v.specificQuestions.Expirationdate__c") == true) {
            component.set("v.descriptionString", component.get("v.descriptionString") + "Date: " + component.get("v.expirationDate") + '\n');
        };
        
        if(component.get("v.specificQuestions.Lot_Number__c") == true) {
            component.set("v.lotNumber", component.find("lotNumber").get("v.value"));
            component.set("v.descriptionString", component.get("v.descriptionString") + "LOT number: " + component.find("lotNumber").get("v.value") + '\n');
        }; 
        
        if(component.get("v.specificQuestions.Tracking_number__c") == true) {
        	component.set("v.trackingNumber", component.find("trackingNumber").get("v.value"));
            component.set("v.descriptionString", component.get("v.descriptionString") + "Tracking number: " + component.find("trackingNumber").get("v.value") + '\n');
        };
        
        if(component.get("v.specificQuestions.Carrier__c") == true) {
            component.set("v.descriptionString", component.get("v.descriptionString") + "Carrier: " + component.get("v.carrier") + '\n');
        }; 
        
        if(component.get("v.specificQuestions.Credit_Rebill__c") == true) {
            component.set("v.descriptionString", component.get("v.descriptionString") + "Credit_Rebill: " + component.get("v.Credit_Rebill") + '\n');
        };
        
        if(component.get("v.specificQuestions.New_or_Replacement_Order__c") == true) {
            component.set("v.descriptionString", component.get("v.descriptionString") + "New_or_Replacement_Order: " + component.get("v.New_or_Replacement_Order") + '\n');
        };
        
        if(component.get("v.specificQuestions.Softwarename__c") == true) {
            component.set("v.descriptionString", component.get("v.descriptionString") + "Software: " + component.get("v.softwareName") + '\n');
        }; 
        
        if(component.get("v.specificQuestions.Returnnumber__c") == true) {
            component.set("v.returnNumber", component.find("returnNumber").get("v.value"));
            component.set("v.descriptionString", component.get("v.descriptionString") + "Return number: " + component.get("v.returnNumber") + '\n');
        }; 
    }
})