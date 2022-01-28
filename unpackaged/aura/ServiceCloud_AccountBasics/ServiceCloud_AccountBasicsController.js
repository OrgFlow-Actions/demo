({
	init : function(component, event, helper) {
                
        var action = component.get("c.getAccountInfo");
        action.setParams({
            recordId: component.get("v.recordId")
        });
        action.setCallback(this, function(data){
		   var res = data.getReturnValue();
           component.set("v.acc", data.getReturnValue());    
                
        });
        $A.enqueueAction(action);
        		
	},
})