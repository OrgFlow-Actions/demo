({
	init : function(component, event, helper) {
        component.find("fieldValue").set("v.value", component.get("v.fieldVal"));
        component.set("v.resId", component.find("fieldValue").get("v.value"));
        
	},
    
    
    update: function(component, event, helper) {
        component.set("v.resId", component.find("fieldValue").get("v.value"));       
    }
})