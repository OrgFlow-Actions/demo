({
    invoke : function(cmp, event, helper) {
        
        /*var navService = cmp.find("navService");
        
        var pageReference = {
            type: 'standard__recordPage',
            attributes: {
                recordId: cmp.get("v.recordId"),
                objectApiName: cmp.get("v.objectType"),
                actionName: "view"
            }
        };
        console.log(cmp.get("v.objectType"));
        cmp.set("v.pageReference", pageReference);
        
        var defaultUrl = "#";
        navService.generateUrl(pageReference)
            .then($A.getCallback(function(url) {
                cmp.set("v.url", url ? url : defaultUrl);
            }), $A.getCallback(function(error) {
                cmp.set("v.url", defaultUrl);
            }));*/
        
        
           // Get the record ID attribute
   			var record = cmp.get("v.recordId");
   
   			// Get the Lightning event that opens a record in a new tab
   			var redirect = $A.get("e.force:navigateToSObject");
   
   			// Pass the record ID to the event
   			redirect.setParams({
      				"recordId": record
   			});
        
   			// Open the record
   			redirect.fire();
        
    }
})