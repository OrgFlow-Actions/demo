({
	getPicklistValues : function(component, event, helper) {
		
         var action = component.get("c.getselectOptions");
        
        
        action.setCallback(this, function(response) {
            if (response.getState() === "SUCCESS") {
           
       			 component.set("v.status",response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
	}
})