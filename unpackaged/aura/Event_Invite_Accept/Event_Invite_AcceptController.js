({
	doInit : function(component, event, helper) {
        var eventId = component.get("v.recordId");
        var action = component.get("c.changeStatusAccepted");
        action.setParams({
            eventId : eventId
        });
        action.setCallback(this, function(response) {
            if(response.getState() === "SUCCESS") {
            var rec = response.getReturnValue();
          //console.log(rec);
                if(rec != 'SUCCESS') {
                 var dismissActionPanel = $A.get("e.force:closeQuickAction");
                 dismissActionPanel.fire();
                 alert(rec);
                } 
                else {
           var dismissActionPanel = $A.get("e.force:closeQuickAction");
         dismissActionPanel.fire();
        $A.get("e.force:refreshView").fire();
             }
            }
        if(response.getState() === 'ERROR'){
         alert(response.getError()[0].message);
        }
        });
        $A.enqueueAction(action);
        
        
         }
})