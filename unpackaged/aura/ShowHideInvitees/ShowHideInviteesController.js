({
    doInit: function(component, event, helper) {
        var recID = component.get("v.recordId");
        var action = component.get("c.getAttendeesList");
        action.setParams({
            eventid: recID
        });
        action.setCallback(this, function(response) {
            var data = response.getReturnValue();
            component.set("v.eventList", data);
        });
        $A.enqueueAction(action);
    }
})