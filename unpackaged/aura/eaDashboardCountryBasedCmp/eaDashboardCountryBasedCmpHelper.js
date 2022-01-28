({
	getHomeDashboard : function(component, event, helper) {
		var action = component.get('c.getHomeDashboardName');
        var fieldName = component.get('v.fieldName');
        var filterFieldName = component.get('v.filterFieldName');
        action.setParams({'fieldName' : fieldName,
                          'filterFieldName' : filterFieldName});
        action.setCallback(this, function(response) {
            if(response.getState() === 'SUCCESS'){
                var result =  response.getReturnValue(); 
                component.set('v.dashboardName', result[fieldName]);
                component.set('v.dashBoardFilter', result[filterFieldName]);
                component.set("v.displayDashboard", true);
               // console.log(JSON.stringify(result[filterFieldName]));
            }
        });
        $A.enqueueAction(action);
	},
    getSObjectDashboard : function(component, event, helper) {
		var action = component.get('c.getSObjectDashboardName');
        var fieldName = component.get('v.fieldName');
        var filterFieldName = component.get('v.filterFieldName');
        action.setParams({'fieldName' : fieldName,
                          'filterFieldName' : filterFieldName,
                          'recordId' : component.get('v.recordId'),
                          'sObjectFieldName' : component.get('v.sObjectFieldName')});
        action.setCallback(this, function(response) {
            if(response.getState() === 'SUCCESS'){
                var result =  response.getReturnValue();
                component.set('v.dashBoardFilter', result[filterFieldName]);
                component.set('v.dashboardName', result[fieldName]);
                var newFilter = component.get("v.dashBoardFilter").replace("#recordId#", component.get("v.recordId"));
            	component.set("v.dashBoardFilter", newFilter);
            	component.set("v.displayDashboard", true);
            }
        });
        $A.enqueueAction(action);
	}
})