({
    refresh : function(component, event, helper) {
        $A.get('e.force:refreshView').fire();
    },

    refreshContacts : function(component, event, helper) {
        var childComponent = component.find("eventMultiWhoLwc");
        childComponent.refreshContacts();
    }
})