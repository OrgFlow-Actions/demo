({
	init : function(component, event, helper) {
		
        var action =component.get("c.getReportLink");
        action.setCallback(this, function(response){
        var state = response.getState();
        	if (state === "SUCCESS") {
        		component.set("v.reportLink", response.getReturnValue());
        	}            
        });
        
     	$A.enqueueAction(action);                      
        
	}
})