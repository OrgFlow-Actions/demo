({
	init : function(component, event, helper) {
        
        if(component.get("v.accId") != null){
            component.set("v.recordId", component.get("v.accId"));
        }
        
        var actions = [
            { label: 'Edit', name: 'edit' },
            { label: 'Delete', name: 'delete' }
        ]; 
        
        component.set('v.columns', [
            {label: 'Case', fieldName: 'CaseURL', sortable: true, type: 'url', typeAttributes: {label: {fieldName : 'CaseNumber'}}},
            {label: 'Record type', fieldName: 'RecordTypeName', sortable:true, type: 'text'},
            {label: 'Subject', fieldName: 'Subject', type: 'text'},
            {label: 'Status', fieldName: 'Status', type: 'text'},
            { type: 'action', typeAttributes: { rowActions: actions } }
        ]);
        
        
        var getOpenCases = component.get("c.getOpenCases");
        getOpenCases.setParams({
            recordId: component.get("v.recordId")
        });
        getOpenCases.setCallback(this, function(data){
        	
            if(data.getState() =="SUCCESS"){
            var res = data.getReturnValue();
            var openCases = component.get("v.openCases");
            var closedCases = component.get("v.closedCases");
         	                
                for(var i=0; i<res.length; i++){                    
                    var rowRes = res[i];
                    rowRes.CaseURL = '/' + rowRes.Id;
                    rowRes.RecordTypeName = rowRes.RecordType.Name;
                    if(rowRes.IsClosed == true) {
                        rowRes.ClosedCase = 'Yes';
                        closedCases.push(rowRes);
                    }
                    if(rowRes.IsClosed == false){
                       rowRes.ClosedCase = 'No';
                       openCases.push(rowRes);
                    }     
                }             
            component.set("v.openCases", openCases);
            component.set("v.listSize", openCases.length);
            component.set("v.closedCases", closedCases);    
            }    
        });
        $A.enqueueAction(getOpenCases);
        
        //Get labels for the case object
        
        var getLabels = component.get("c.getCaseFieldLabels");
        
        getLabels.setCallback(this, function(data){
            component.set("v.caseLabels", data.getReturnValue());
        });
        $A.enqueueAction(getLabels);
        		
	},
    
    handleNew: function(component, event, helper) {
	   
            var createRecordEvent = $A.get("e.force:createRecord");
        	createRecordEvent.setParams({
        	"entityApiName": "Case",
            "recordTypeId":"01220000000AvOOAA0",
            "accountId":component.get("v.recordId")
    		});
    		createRecordEvent.fire();
        
    },
    
    handleRowAction: function (cmp, event, helper) {
        var action = event.getParam('action');
        var row = event.getParam('row');

        switch (action.name) {
            case 'edit':
                var editRecordEvent = $A.get("e.force:editRecord");
                editRecordEvent.setParams({
        			"recordId": row.Id
   				});
    			editRecordEvent.fire();
                break;
            	
            	case 'delete':
                alert('Showing Details: ' + JSON.stringify(row));
                break;
        }
    },
    
    recordUpdated: function(component, event, helper) {

    var changeType = event.getParams().changeType;

    if (changeType === "ERROR") { /* handle error; do this first! */ }
    else if (changeType === "LOADED") { 
        $A.get("e.force:refreshView").fire(); 
    }
    else if (changeType === "REMOVED") { /* handle record removal */ }
    else if (changeType === "CHANGED") { 
        $A.get("e.force:refreshView").fire(); 
    }
	},
    
    refreshRec : function(component, event, helper) {
        
        var action = component.get("c.getOpenCases");
        action.setParams({
            recordId: component.get("v.recordId")
        });
        action.setCallback(this, function(data){
        	
            if(data.getState() =="SUCCESS"){
            var res = data.getReturnValue();
            component.set("v.openCases", []);
            var openCases = component.get("v.openCases");
            var closedCases = component.get("v.closedCases");
                          
                for(var i=0; i<res.length; i++){                    
                    var rowRes = res[i];
                    rowRes.CaseURL = '/' + rowRes.Id;
                    rowRes.RecordTypeName = rowRes.RecordType.Name;
                    if(rowRes.IsClosed == true) {
                        rowRes.ClosedCase = 'Yes';
                        closedCases.push(rowRes);
                    }
                    if(rowRes.IsClosed == false){
                       rowRes.ClosedCase = 'No';
                       openCases.push(rowRes);
                    }     
                }             
            component.set("v.openCases", openCases);
            component.set("v.closedCases", closedCases);    
            }    
        });
        $A.enqueueAction(action);
        
    },
    
    getFieldLabel: function(component, event, helper) {
        var action = component.get("c.getCaseFieldLabels");
        
        action.setCallback(this, function(data){
            component.set("v.caseLabels", data.getReturnValue());
        });
        $A.enqueueAction(action);
        
    }
})