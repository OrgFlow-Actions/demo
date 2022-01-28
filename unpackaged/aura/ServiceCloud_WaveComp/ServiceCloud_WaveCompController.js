({
    
    getUserInfo: function(component, event, helper) {
        var userId = $A.get("$SObjectType.CurrentUser.Id");
        component.set("v.UserId", userId);
        var filterT = "{'datasets':{'" + component.get("v.datasetName") + "':[{'fields':['OwnerId'], 'filter':{'operator': 'matches', 'values':['" + userId + "']}}]}}";
        component.set("v.filterTest", filterT);
    },
})