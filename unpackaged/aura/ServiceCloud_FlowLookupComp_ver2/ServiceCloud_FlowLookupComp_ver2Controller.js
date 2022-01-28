({
	initRun : function(component, event, helper) {
        
		var action = component.get("c.getCaseInfo");
        
        var useId = new String();
        
        if (component.get("v.recordId")!=null){
            useId = component.get("v.recordId");            
        }
        else{
            useId = '5003E00000EDKadQAH';
        }
        
        action.setParams({
            
            recordId: useId
        });
        action.setCallback(this, function(data) {
			var value = data.getReturnValue();
            
			component.set("v.case", value);
            component.set("v.caseId", value.Id);
            console.log(value);
			
        });
        $A.enqueueAction(action);
        
        
        console.log("Init");
	},

	itemSelected : function(component, event, helper) {
		helper.itemSelected(component, event, helper);
	}, 
    serverCall :  function(component, event, helper) {
		helper.serverCall(component, event, helper);
	},
    clearSelection : function(component, event, helper){
        helper.clearSelection(component, event, helper);
    },
    
    handleKeyUp: function (cmp, evt) {
        var isEnterKey = evt.keyCode === 13;
        if (isEnterKey) {
            var queryTerm = cmp.find('enter-search').get('v.value');
            alert('Searched for "' + queryTerm + '"!');
        }
    }
    
})