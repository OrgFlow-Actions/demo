({
    doInit : function(component, event, helper) {
			
        var listInput =component.get("v.listInput");
        console.log(listInput);
    },
    
    handleSelection : function(component, event, helper){
        
        const selectedRecord = event.target.value;
        component.set("v.selectedRecord", selectedRecord);
        console.log(selectedRecord);
    }
    
})