({
    checkCancelOrderPermission: function(component) {
        var action = component.get("c.checkCancelOrderPermission");

        action.setCallback(this, function (response) {
            var state = response.getState();

            if (state === "SUCCESS") {
                var hasCancelOrderPermission = response.getReturnValue();
                component.set("v.hasCancelOrderPermission", hasCancelOrderPermission);
            }
        });
        $A.enqueueAction(action);
    },

    getStageGuidance: function (component) {
        var action = component.get("c.getStageGuidance");

        action.setParams({ orderId: component.get("v.recordId") });
        action.setCallback(this, function (response) {
            var state = response.getState();

            if (state === "SUCCESS") {
                var setting = JSON.parse(response.getReturnValue());

                if (setting) {
                    var keyFields = setting.KeyFields__c ? JSON.parse(setting.KeyFields__c) : [];
                    var keyFieldsReadOnly = setting.KeyFieldsReadOnly__c ? JSON.parse(setting.KeyFieldsReadOnly__c) : [];
                    
                    component.set("v.showGuidance", true);
                    component.set("v.stageGuidanceSetting", setting);
                    component.set("v.keyFields", keyFields);
                    component.set("v.keyFieldsReadOnly", keyFieldsReadOnly);
                    component.set("v.showKeyFields", keyFields.length > 0 || keyFieldsReadOnly.length > 0);
                } else {
                    component.set("v.showGuidance", false);
                }
            } else {
                component.set("v.showGuidance", false);
            }
        });
        $A.enqueueAction(action);
    },

    toggleSpinner: function (component) {
        var spinner = component.find("mySpinner");

        $A.util.toggleClass(spinner, "slds-hide");
    },

    createModal: function (component, mode, header) {
        var modalBody;
        var modalFooter;

        $A.createComponents(
            [
                [
                    "c:ModalContentOm",
                    { recordId: component.get("v.recordId"), mode: mode }
                ],
                ["c:ModalFooterOm", {}]
            ],
            function (components, status) {
                if (status === "SUCCESS") {
                    modalBody = components[0];
                    modalFooter = components[1];
                    component.find("overlayLib").showCustomModal({
                        header: header,
                        body: modalBody,
                        footer: modalFooter,
                        showCloseButton: true,
                        cssClass: "mymodal",
                        closeCallback: function () {
                            // Do nothing
                        }
                    });
                }
            }
        );
    }
});