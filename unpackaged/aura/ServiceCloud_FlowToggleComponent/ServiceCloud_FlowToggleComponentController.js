({
    init: function(component, event, helper) {
    var def = component.get("v.defaultToggle");    
    component.find("inputCheck").set("v.value", def);    
    component.set("v.output", def);
        
    },
        
    createContact: function(component, event, helper) {
        var checkBox = component.get("v.defaultToggle");
        if (checkBox == true) {
        component.set("v.output", true);        
        }
        else {
        component.set("v.output", false);
        }
    },    
})