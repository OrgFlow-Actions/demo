({
    onUserUpdate : function(component, event, helper){
        var index = component.get("v.rowIndex");
        var Team = component.get("v.ChosenTeam");       
        component.getEvent("LightningComponentUserEv").setParams({"indexVar" : index, "SelTeam": Team}).fire();        
    },
})