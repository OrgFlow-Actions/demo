({
    handleShowModal: function(component, event, helper) {
        
        var modalBody;
        
        $A.createComponent(
           "c:ServiceCloud_CaseModal", 
           {"CaseInst": component.get("v.CaseInstance")},
           function(content, status) {
               
               if (status === "SUCCESS") {
                   if(component.get("v.modalClosed")!=true){
                   		modalBody = content;
                   			var modalPromise = component.find('overlayLib').showCustomPopover({
                       			body: modalBody,
                       			referenceSelector: '.accountpopover' + component.get("v.rowIndex")                       
                   			});
				
                   if(modalPromise != null){
               			component.set("v.modalPromise", modalPromise);                          
                   };
   
                   };
                   component.set("v.modalClosed", false);
               };                               
           });
        
           },                               

    handleCloseModal: function(component, event, helper) {
      
    if(component.get("v.modalPromise") != null) {
        component.get("v.modalPromise").then(    	
        function (overlay) {
        overlay.close();   
    });        
    }    
        else {
         component.set("v.modalClosed", true);  
        };    
    
    },
    
    navRecord : function (component, event, helper) {
    var navEvt = $A.get("e.force:navigateToSObject");
    navEvt.setParams({
      "recordId": component.get("v.CaseInstance.Id"),
      "slideDevName": "detail"
    });
    navEvt.fire();
	},

    
})