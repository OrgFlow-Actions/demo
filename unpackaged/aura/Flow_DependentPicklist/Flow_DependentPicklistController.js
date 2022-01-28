({
    
    init: function(component, event, helper) {
        component.find("fieldValue").set("v.value", component.get("v.defaultVal"));
        component.set("v.resId", component.get("v.defaultVal"));
        component.find("depfieldValue").set("v.value", component.get("v.defaultDepVal"));
        component.set("v.depresId", component.get("v.defaultDepVal"));
        component.find("depfieldValue2").set("v.value", component.get("v.defaultSecondDepVal"));
        component.set("v.depresId2", component.get("v.defaultSecondDepVal"));
        component.find("depfieldValue3").set("v.value", component.get("v.defaultThirdDepVal"));
        component.set("v.depresId3", component.get("v.defaultThirdDepVal"));
        component.set("v.disableFirstField", component.get("v.fieldDisabled"));
        console.log("Category: ",component.get("v.defaultDepVal"));
    },
    
    updateVal: function(component, event, helper) {     
        component.set("v.resId", component.find("fieldValue").get("v.value"));

    },
    
    updateDepVal: function(component, event, helper) {
        component.set("v.depresId", component.find("depfieldValue").get("v.value"));
        console.log(component.get("v.depresId"));        
        component.set("v.depresId2", component.find("depfieldValue2").get("v.value"));
        component.set("v.depresId3", component.find("depfieldValue3").get("v.value"));    
    }
})