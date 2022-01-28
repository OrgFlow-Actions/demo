({
    handleLoad: function (component) {
        var stageFieldValue = component.find("stageField").set("v.value", component.get("v.stepName"));
    },
    
    handleCancel: function (component) {
        component.set("v.modalSuccess", false);
        component.find('overlayLib').notifyClose();
    },
    
    handleSubmit: function (component, event, helper) {
        component.set("v.isLoading", true);
        event.preventDefault();
        var eventFields = event.getParam('fields');
        component.find('recordForm').submit(eventFields);
    },
    
    handleSuccess: function (component, event, helper) {
        // component.set("v.isLoading", false);
        component.set("v.modalSuccess", true);
        component.find('overlayLib').notifyClose();
    },

    handleCancel: function (component, event, helper) {
        component.find('overlayLib').notifyClose();
    }
})