({
    //get user list from apex controller
    doInit : function(component, event, helper) {
        var action = component.get("c.getUsers");
        action.setParams({
            recordId : component.get("v.recordId"),
            dealerId: component.get("v.dealerId"),
            categoryInput: component.get("v.category"),
            brandInput: component.get("v.brand")
        });
        action.setCallback(this, function(result){
            var state = result.getState();
            if (component.isValid() && state === "SUCCESS"){
                var resultList = result.getReturnValue();                
                component.set("v.userList", resultList);   
            }
        });
        $A.enqueueAction(action);
    },

    handleSelectedContacts: function(component, event, helper) {
   
        var selectedMembers = [];
        var checkvalue = document.getElementsByName('checkbox');
        var arrLength = checkvalue.length;
		var anyChecked = false;
        
            for (var i = 0; i < arrLength; i++) {
                
                
                //Look for any checkboxes that are checked
                if (checkvalue[i].checked == true) {
                    anyChecked = true;
                    
                    //If checked, push the value to the list of selected members
                    var Item = {Id: checkvalue[i].id};
                    selectedMembers.push(Item);
                    
                    //If checked, disable all other checkboxes
                    for(var j=0; j<arrLength;j++) {                       
                        if(j!=i){
                      		document.getElementById(checkvalue[j].id).disabled = true;
                        }    
                    }                   
                }
            }
        
        //If no checkboxes are checked, make sure all checkboxes are available
        
        if(anyChecked == false){
            
            for(var k = 0; k<arrLength; k ++){
                document.getElementById(checkvalue[k].id).disabled = false;
            }
        }
        
        console.log(selectedMembers[0]);
        component.set("v.selectedUsers", selectedMembers[0]);
}

})