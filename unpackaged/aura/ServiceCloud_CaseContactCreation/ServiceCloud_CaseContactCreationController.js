({
    init : function(component, event, helper) {
    
	       
    },
        
    createContact: function(component, event, helper) {
        var checking = component.get("v.fieldN");
                
        if (checking != true) {
        component.set("v.fieldN", true);
        component.find("firstName").set("v.value", component.get("v.firstName"));
    	component.find("lastName").set("v.value", component.get("v.lastName"));
    	component.find("email").set("v.value", component.get("v.email"));
    	component.find("phone").set("v.value", component.get("v.phone"));            
        }
        else {
          component.set("v.fieldN", false);
          component.set("v.createContact", false);   
        }
    },    
    
    updateVal: function(component, event, helper) {        

        if (component.get("v.fieldN") == true) {
        component.set("v.firstName", component.find("firstName").get("v.value"));   
        component.set("v.lastName", component.find("lastName").get("v.value"));
        component.set("v.lastName", component.find("lastName").get("v.value"));
        component.set("v.phone", component.find("phone").get("v.value"));
        component.set("v.email", component.find("email").get("v.value"));
    
        component.set("v.createContact", true);    
        };
    },
})