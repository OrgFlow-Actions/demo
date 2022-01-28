({
    doInit : function(component,event,helper){
        console.log('inside Controller init----------');
        helper.checkDealerPermission(component,event,helper);
        helper.getPreferredDealerInfo(component,event,helper);
        helper.getOrderToUpdate(component,event,helper);
    },
    selectedDealerRecord : function(component,event,helper){
        var target = event.getSource(); 
        var txtVal = target.get("v.value") ;
        component.set("v.dealerId",txtVal);
        console.log('DEALER ID -----------'+component.get("v.dealerId"));
    },
    SaveDealerInfo : function(component,event,helper){
        helper.updateOrderInfo(component,event,helper);
    },
    handleClick : function(component,event,helper){
        $A.get('e.force:refreshView').fire(); 
    }
    /*,
    updateOrd : function(component,event,helper){
        console.log('inside refresh view--------');
         var ordrecord = component.get("v.order");
   	     var action1 = component.get("c.updateOrder");
         action1.setParams({
                orderRec: ordrecord
         });
         action1.setCallback(this, function(response){
          var state = response.getState();
            console.log('After refreshing view update -------------');
            if (state === "SUCCESS") {
                var or = response.getReturnValue();
            }
         });
         $A.enqueueAction(action1);
         console.log('Update Done -------------');
    	 var recordId = component.get("v.recordId");
   	     var action = component.get("c.getUpdateFromOrder");
         action.setParams({
                recordId: recordId
         });
         action.setCallback(this, function(response){
          var state = response.getState();
            console.log('Refresh final Order with updated info -------------');
            if (state === "SUCCESS") {
                var or = response.getReturnValue();
            }
         });
         $A.enqueueAction(action);
   }*/

})