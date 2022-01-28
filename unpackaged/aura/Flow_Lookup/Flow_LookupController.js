({
    init: function(component, event, helper) {
        component.find("fieldValue").set("v.value", component.get("v.defaultVal"));
        component.set("v.resId", component.get("v.defaultVal"));
    },
    
    updateVal: function(component, event, helper) {     
        component.set("v.resId", component.find("fieldValue").get("v.value"));
    },

})