({
    doInit : function(component,event,helper){
        helper.checkDealerPermission(component,event,helper);
        helper.getPreferredDealerInfo(component,event,helper);
    }
})