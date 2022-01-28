({
	checkDealerPermission :function (component,event,helper){
        var action = component.get('c.CheckPermission');
        action.setStorable();
        action.setCallback(this, function(response){
            var result = response.getReturnValue();
            var state = response.getState();
            if (state === 'SUCCESS') {                
                component.set("v.showPage",result);
                console.log('showpage------'+component.get("v.showPage"));
            }
            else {
                var errors = response.getError();
            }
        });
        $A.enqueueAction(action);
    },
    getPreferredDealerInfo :function (component,event,helper){
        var action = component.get("c.getAllPdeList");
        action.setStorable();
        action.setParams({
            'orderId':component.get("v.recordId")
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();	
                component.set("v.distributorlist",storeResponse);
                console.log('distributors------'+component.get("v.distributorlist"));
            }
        });
        // enqueue the Action  
        $A.enqueueAction(action);
    }
})