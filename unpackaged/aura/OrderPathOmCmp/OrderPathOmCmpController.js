({
    init: function (component, event, helper) {
        helper.checkCancelOrderPermission(component);
        helper.getStageGuidance(component);
        component.find("recordLoader").reloadRecord(true);
    },

    handleOrderLoaded: function (component, event, helper) {
        var eventParams = event.getParams();

        if (eventParams.changeType === "LOADED") {
            var orderStatus = component.get("v.orderRecord.Status");
            var showKeyFields = component.get("v.showKeyFields");

            if (showKeyFields !== undefined && showKeyFields === false) {
                component.set("v.disableSubmit", orderStatus !== "Created" && orderStatus !== 'Rejected');
            }
            component.set("v.disableCancel", orderStatus === "Rejected");
        }
    },

    handleFormLoad: function (component, event, helper) {
        var record = event.getParams().records[component.get("v.recordId")];
        
        if (record) {
            var keyFields = component.get("v.keyFields").concat(component.get("v.keyFieldsReadOnly"));
            keyFields = keyFields.flatMap(function (field) {
                return field === "ShippingAddress"
                    ? ["ShippingCity", "ShippingStreet"]
                    : field;
            });
            var hasNullFields = keyFields.some(function (field) {
                return record.fields[field] ? record.fields[field].value === null : false;
            });
    
            if (record.fields.Status.value === "Created") {
                component.set("v.disableSubmit", hasNullFields);
            }
        }
    },
    
    handleCancel: function (component, event, helper) {
        helper.createModal(component, "cancel", "Order Cancellation");
    },

    handleSubmitForApproval: function (component, event, helper) {
        helper.createModal(component, "submit", "Submit for Approval");
    }
});