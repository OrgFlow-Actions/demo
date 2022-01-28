({
	init : function(component, event, helper) {
        //component.find("fieldValue").set("v.value", component.get("v.fieldVal"));
        component.set("v.resId", component.get("v.fieldVal"));
        //component.set("v.resId", component.find("fieldValue").get("v.value"));
        
	},    
    
    update: function(component, event, helper) {
        
        component.set("v.invalidRes", false);        
        var output = component.get("v.fieldVal");
        //var output = component.find("fieldValue").get("v.value");		
        
        var mCurrency = component.get("v.modelCurrency");
        var cCurrency = component.get("v.contractCurrency");
        var max = component.get("v.maxVal");
        var min = component.get("v.minVal");

        /*if(mCurrency != cCurrency) {   
			var action = component.get("c.getCurrencyInfo");
            action.setCallback(this, function(data){
                var currencyInfo = data.getReturnValue();
                alert(currencyInfo[0].ISOCode);
            });
            $A.enqueueAction(action);
            
        }*/
        
        if((max==0 && min==0) || (output <= max && output>= min)){           
        	component.set("v.resId", output);
        }
        else {
            component.set("v.invalidRes", true);
            component.set("v.resId", output);
        }        
        
    }
})