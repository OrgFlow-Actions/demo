({
    
    init: function(component, event, helper) {
		
        
        component.find("fieldValue").set("v.value", component.get("v.defaultVal"));
        component.set("v.resId", component.get("v.defaultVal"));
        
		component.find("depfieldValue").set("v.value", component.get("v.defaultDepValue"));
        component.set("v.depresId", component.get("v.defaultDepValue"));
        
        component.find("depfieldValue2").set("v.value", component.get("v.defaultSecondDepValue"));
        component.set("v.depresId2", component.get("v.defaultSecondDepValue"));
        
        component.find("depfieldValue3").set("v.value", component.get("v.defaultThirdDepValue"));
        component.set("v.depresId3", component.get("v.defaultThirdDepValue"));
        
        component.set("v.disableFirstField",component.get("v.fieldDisabled"));

       // component.find("recordViewForm").submit(); 
     
		component.set('v.validate', function() {
   	    const invalidMessage = { isValid: false, errorMessage: 'One or more required picklist values are missing' };
    	const validMessage =   { isValid: true };
            
        // Check invalid scenarios
        if (component.get('v.field1req') && !component.get('v.defaultVal')  ) return invalidMessage;
        if (component.get('v.field2req') && !component.get('v.defaultDepValue')  )  return invalidMessage;
        if (component.get('v.field3req') && !component.get('v.defaultSecondDepValue')) return invalidMessage;
        if (component.get('v.field4req') && !component.get('v.defaultThirdDepValue')) return invalidMessage;

            return validMessage;
          });      
     
    },
    

    updateVal: function(component, event, helper) {      
        component.set("v.resId", component.find("fieldValue").get("v.value"));
    },
    
        updateDepVal: function(component, event, helper) {
     // component.find("recordViewForm").submit();               
        component.set("v.depresId", component.find("depfieldValue").get("v.value"));   
        component.set("v.depresId2", component.find("depfieldValue2").get("v.value"));
        component.set("v.depresId3", component.find("depfieldValue3").get("v.value"));    
    }
})