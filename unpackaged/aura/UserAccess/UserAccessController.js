({
    
    	getContactData : function(component, event) {
              
        var action = component.get("c.getUserAccess");
        
        action.setParams({
    		ComponentName: component.get("v.ComponentName")
		});    
                        
        action.setCallback(this, function(data) {
            component.set('v.isVisible', data.getReturnValue());
            var createEvent = component.getEvent("checkUserAcess");
            createEvent.setParams({"isVisible" : data.getReturnValue()});
            createEvent.fire();
		});
		$A.enqueueAction(action);
            
	},
    

        

    
    
})