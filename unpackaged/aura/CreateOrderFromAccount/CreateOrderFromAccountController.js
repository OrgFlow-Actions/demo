({
	init : function(component, event, helper) {
	var url = "/apex/Order_Direct_Account?Id="+component.get("v.recordId");
    var urlEvent = $A.get("e.force:navigateToURL"); 
    urlEvent.setParams({ "url": url }); 
    urlEvent.fire();
    }
})