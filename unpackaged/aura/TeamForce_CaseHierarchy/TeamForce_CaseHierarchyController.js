({
	doInit : function(component, event, helper) {
		var columns = [
            {
                type: 'url',
                fieldName: 'IdUrl',
                label:'Milestone',
				typeAttributes: {
                    label: {fieldName : 'Name'}
       			}                
            },
            {
                type: 'text',
                fieldName: 'Status__c',
                label: 'Status'                
            },
            {
                type: 'text',
                fieldName: 'Meeting_Date__c',
                label: 'Due'                
            },
            {
                type: 'url',
                fieldName: 'CaseUrl',
                label: 'Sprint Case',
				typeAttributes: {
                    label: {fieldName : 'CaseDesc'}
       			}  				                
            },
            {
                type: 'url',
                fieldName: 'ParentUrl',
                label: 'Requirement Case',
				typeAttributes: {
                    label: {fieldName : 'ParentCase'}
       			}                
            }
                        
        ];
        
        component.set("v.gridColumns", columns);
        
        var action = component.get("c.getCaseList");
        action.setParams({recordId: component.get("v.recordId")});
        action.setCallback(this, function(response) {
        var state = response.getState();
            if(state==="SUCCESS"){
                var resultData = response.getReturnValue();
 				
                for (var i=0; i<resultData.length; i++) {
                    resultData[i]._children = resultData[i]['Cases__r'];
                    resultData[i].IdUrl = '/' + resultData[i].Id;
                    var childCases = resultData[i]._children;
                    if(childCases != null){
                    for(var j=0; j<childCases.length;j++){   
                    resultData[i]._children[j].CaseUrl = '/' + resultData[i]._children[j].Id;
                    resultData[i]._children[j].CaseDesc = resultData[i]._children[j].CaseNumber + ' - ' + resultData[i]._children[j].Subject;
                    
                    if(resultData[i]._children[j].Parent != null) {
                    resultData[i]._children[j].ParentCase = resultData[i]._children[j].Parent['Subject'];
                    resultData[i]._children[j].ParentUrl= '/' + resultData[i]._children[j].Parent['Id'];
                    }
                    }
                    }    

                }
                component.set('v.gridData', resultData);                
            }            
        });
        $A.enqueueAction(action);
        
	}
})