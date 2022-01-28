({
	init : function(component, event, helper) {
        
        var fieldValue = component.get("v.fieldVal");        
        var fieldValueNumber = 0;
        if(fieldValue == null || fieldValue == ''){
            fieldValueNumber = component.get("v.fieldValNumber");
            component.find("fieldValue").set("v.value", fieldValueNumber);
        }
        else{
            component.find("fieldValue").set("v.value", component.get("v.fieldVal"));            
        }

        component.set("v.resId", component.find("fieldValue").get("v.value"));
        
	},
        
    update: function(component, event, helper) {
        //component.find("recordViewForm").submit();
        component.set("v.resId", component.find("fieldValue").get("v.value"));       
    }
})