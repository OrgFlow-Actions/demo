({
    handleCancel: function (component) {
        component.find("overlayLib").notifyClose();
    },

    handleSubmit: function (component) {
        var modalEvent = $A.get("e.c:ModalEventOm");
        
        component.set('v.isLoading', true);
        modalEvent.fire();
    }
});