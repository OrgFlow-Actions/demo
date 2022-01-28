({    
    invoke : function(component, event, helper) {
        // Get the record ID attribute
        var url = component.get("v.url");
        var record = component.get("v.recordId");
        var link = url + record;
        var navService = component.find("navigationService");
        var pageReference = { 
    	"type": "standard__webPage", 
    	"attributes": { 
        	"url": link 
        }
        };
        navService.navigate(pageReference);
        }
})