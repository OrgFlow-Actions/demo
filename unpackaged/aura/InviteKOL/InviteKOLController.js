({
	init: function (cmp, event, helper) {
			console.log("Init CVENT component");
        	var action = cmp.get("c.getKOLdata");
        	
            action.setParams({
                recordId : cmp.get("v.recordId")
            });
        	
        	action.setCallback(this, function(response) {

            var state = response.getState();
                
            if (state === "SUCCESS") {
                cmp.set("v.KOL", response.getReturnValue());
                console.log(response.getReturnValue());
            }
        });
		$A.enqueueAction(action);
    }

})