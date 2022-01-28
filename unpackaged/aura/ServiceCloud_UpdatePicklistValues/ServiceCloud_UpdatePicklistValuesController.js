({
    
    init: function(component, event, helper) {
        component.find("fieldValue").set("v.value", component.get("v.defaultValue"));
        component.set("v.resultId", component.get("v.defaultValue"));
        
        component.find("depfieldValue").set("v.value", component.get("v.defaultDepValue"));
        component.set("v.depresultId", component.get("v.defaultDepValue"));
        
        component.find("depfieldValue2").set("v.value", component.get("v.defaultSecondDepValue"));
        component.set("v.depresultId2", component.get("v.defaultSecondDepValue"));
        
        component.find("depfieldValue3").set("v.value", component.get("v.defaultThirdDepValue"));
        component.set("v.depresultId3", component.get("v.defaultThirdDepValue"));
        
        component.set("v.disableFirstField", component.get("v.fieldDisabled"));
        console.log("Category: ",component.get("v.defaultDepValue"));
    },
    
    updateVal: function(component, event, helper) {     
        component.set("v.resultId", component.find("fieldValue").get("v.value"));

    },
    
    updateDepVal: function(component, event, helper) {
        component.set("v.depresultId", component.find("depfieldValue").get("v.value"));
        console.log(component.get("v.depresId"));        
        component.set("v.depresultId2", component.find("depfieldValue2").get("v.value"));
        component.set("v.depresultId3", component.find("depfieldValue3").get("v.value"));    
    }
})