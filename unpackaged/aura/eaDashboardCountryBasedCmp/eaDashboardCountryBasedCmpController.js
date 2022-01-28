({
    doInit : function(component, event, helper) {
        if(component.get('v.recordId')) {
            helper.getSObjectDashboard(component, event, helper);
        } else {
            helper.getHomeDashboard(component, event, helper);
        }
    }
})