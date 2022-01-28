({
    init: function (cmp, event, helper) {
		cmp.set("v.showSpinner", true);        
        var products = cmp.get("v.selectedProducts");        
    },
    
    hideSpinner: function(cmp, event, helper){
      cmp.set("v.showSpinner", false);
    },
    
    handleError: function(cmp, event, helper){
      cmp.set("v.showSpinner", false);
      console.log(event.getParameters());      
    },

    setValues: function(cmp, event, helper){
    var records = cmp.find("editForm");
	
    cmp.set("v.showSpinner", true);
     
    var allRecords = cmp.get("v.selectedProducts");        
    var recordLength = allRecords.length;  
 	
    if(recordLength > 1){
    	for(var i in records){
        
        	if(records[i].get("v.recordId")){
        		cmp.find("editForm")[i].submit();
        	}
    	}
    }
    else{
       	  records.submit();   
    }
        
    var cmpEvent = cmp.getEvent('cmpEvent');
    cmpEvent.fire();    
                
    },

	deleteProduct: function(cmp, event){
        
        var recordId = event.getSource().get("v.name");
        console.log('Record to delete: ' + recordId);
       	var cmpEvent = cmp.getEvent('cmpEvent');
        cmpEvent.setParams({"message" : recordId});  
        
        //Delete record from array in component
        var allRecords = cmp.get("v.selectedProducts");
        var recordToDelete = {};
        
        for(var i in allRecords){
        	console.log(allRecords[i]);
            if(allRecords[i].Id == recordId){
               allRecords.splice(i, 1); 
            }
        }
        
		//Delete record from server        
       	var action = cmp.get("c.deleteProductProfilingRecord");
        	
        action.setParams({
           recordId : recordId
        });
        	
       	action.setCallback(this, function(response) {
         	var state = response.getState();
            
            if (state === "SUCCESS") {
                var result=response.getReturnValue();
                console.log('Delete successful: ' + result);	
        		//cmpEvent.fire(); 
        		cmp.set("v.selectedProducts", allRecords);
        		             
            }    
        });
        $A.enqueueAction(action);
 
    },    
})