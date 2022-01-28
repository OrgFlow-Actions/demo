({
	doInit : function(component, event, helper) {
        var taskId = component.get("v.recordId");
        var action = component.get("c.changeOwnerMethod");
        action.setParams({
            taskId : taskId
        });
        action.setCallback(this, function(response) {
            if(response.getState() === "SUCCESS") {
            var rec = response.getReturnValue();
          var dismissActionPanel = $A.get("e.force:closeQuickAction");
         dismissActionPanel.fire();
        $A.get("e.force:refreshView").fire();
             }
        });
        $A.enqueueAction(action);
        
        
         }
})