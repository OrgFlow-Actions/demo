({
    handleCancel: function (component) {
        component.find('overlayLib').notifyClose();
    },

    handleSubmit: function (component, event, helper) {
        component.set("v.isLoading", true);
        var mode = component.get("v.mode");
        var recordId = component.get("v.recordId");
        var textarea = component.find("textareacomment").get("v.value");
        var action =
            mode === "cancel"
                ? component.get("c.orderCancel")
                : component.get("c.submitForApproval");

        action.setParams({ orderId: recordId, comment: textarea });
        action.setCallback(this, function (response) {
            component.set("v.isLoading", false);
            var state = response.getState();

            if (state === "SUCCESS") {
                $A.get("e.force:refreshView").fire();
                component.find("overlayLib").notifyClose();
            } else if (state === "ERROR") {
                var errors = response.getError();
                var errorMessage = errors.length > 0 ? errors[0].message : "Unknown error";
                var toastParams = {
                    title: "Error",
                    message: errorMessage,
                    type: "error"
                };

                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams(toastParams);
                toastEvent.fire();
            } else {
                alert(response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
    }
})