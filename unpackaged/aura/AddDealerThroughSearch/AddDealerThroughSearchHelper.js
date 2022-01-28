({
	checkDealerPermission :function (component,event,helper){
        var action = component.get('c.CheckPermission');
       // action.setStorable();
        action.setCallback(this, function(response){
            var result = response.getReturnValue();
            var state = response.getState();
            console.log('Permission check result---------'+result);
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
        //action.setStorable();
        console.log('RECORD ID ----------------'+component.get("v.recordId"));
        action.setParams({
            'orderId':component.get("v.recordId")
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();	
                console.log('Distributor Response----------'+storeResponse);
                component.set("v.distributorlist",storeResponse);
                console.log('distributors------'+component.get("v.distributorlist"));
            }
        });
        // enqueue the Action  
        $A.enqueueAction(action);
    },
    getOrderToUpdate: function(component,event,helper){
     console.log('inside getOrderto update method--------');
     var orId = component.get("v.recordId");
     var action=component.get("c.Initialize");
     action.setParams({
       ordrId:orId          
     });
     action.setCallback(this, function(data){
         var state = data.getState();
         console.log('state to set Order ------'+state);
         if (state === "SUCCESS") {
           console.log('initialize order call back---'+JSON.stringify(data.getReturnValue()));
           component.set("v.order", data.getReturnValue());
           console.log('Order record ---------------'+component.get("v.order"));
         }
         else {
                var errors = response.getError();
            }
      });
     $A.enqueueAction(action);
    },
    updateOrderInfo : function(component, event, helper){
        var orderRec = component.get("v.order");
        console.log('inside of select dealer helper ----');
        var action = component.get("c.updateDealerInfoToOrder");
        action.setParams({
             dealrId:component.get("v.dealerId"),
             orderRec:orderRec
        });
        action.setCallback(this, function(response){
            console.log('inside update order callback---------');
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log('inside success ---------');
             	console.log('updated Order-----------'+JSON.stringify(response.getReturnValue()));
            	 component.set("v.order", response.getReturnValue());
                 var navEvt = $A.get("e.force:navigateToSObject");
                  navEvt.setParams({
                    "recordId": response.getReturnValue(),
                    "slideDevName": "related"
                  });
    			  navEvt.fire();  
                
                $A.get('e.force:refreshView').fire(); 
            }  
            else if(state === "ERROR"){
                console.log('inside error callback-----');
            }
        });
        // enqueue the Action  
       $A.enqueueAction(action);
       
     }
})