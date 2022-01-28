({
	loadEvents : function(component, event) {
		var action =component.get("c.getMyCventEvents");
        action.setParams({
           
        });
        action.setCallback(this, function(response){
            	var state = response.getState();
				if (state === "SUCCESS") {
					var result = response.getReturnValue();
                    console.log(JSON.stringify(result));
                    
                    var eventsToAdd = component.get("v.eventList");                    
                    for(var i in result){
                        var event = {};
                        event.Id = result[i].Id;
                        event.Name = result[i].CventEvents__pkg_Title__c;
                        event.Speaker = result[i].ContractedSpeaker__c;
                        event.EventUrl = '/lightning/r/CventEvents__Event__c/' + result[i].Id + '/view/';
                        event.StartDate = result[i].CventEvents__pkg_StartDate__c;
                        event.Status = result[i].CventEvents__pkg_PlanningStatus__c;
                        event.Email = result[i].KOLManageremail__c;
                        eventsToAdd.push(event);
                    }
                    
                    component.set("v.eventList", eventsToAdd);
                    
                }
        		else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                 errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
       
        });
		$A.enqueueAction(action);
	}
    
})