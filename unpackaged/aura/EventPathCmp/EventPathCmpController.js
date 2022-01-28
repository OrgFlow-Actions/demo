({
    handleSelect: function (component, event, helper) {
        component.set('v.error', null);
        component.set('v.loading', true);
        var stepName = event.getParam("detail").value;
        var toastEvent = $A.get("e.force:showToast");
        var action = component.get("c.setEventStatus");
        var eventId = component.get("v.recordId");

        action.setParams({
            "eventId": eventId,
            "eventStatus": stepName
        })

        action.setCallback(this, function (response) {
            if (response.getState() == 'SUCCESS') {
                // toastEvent.setParams({
                //     "title": "Success!",
                //     "message": "Toast from " + response.getReturnValue()
                // });
                $A.get('e.force:refreshView').fire();
                // toastEvent.fire();
            } else if (response.getState() == 'ERROR') {
                var errors = response.getError();
                errors[0].message = errors[0].message.match(/(?:[A-Z]*, )(.*?)(?=:)/)[1];
                if (errors) {
                    component.set('v.error', errors[0]);
                    // component.find('pickListPath').set(v.value, 'Not Started');
                }
            }
            component.set('v.loading', false);
        });

        $A.enqueueAction(action);
    },
})