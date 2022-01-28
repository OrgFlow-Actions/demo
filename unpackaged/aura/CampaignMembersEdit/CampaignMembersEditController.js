({
    //get Contact List from apex controller
    doInit : function(component, event, helper) {
        var action = component.get("c.getMemberList");
        action.setParams({
            recordId : component.get("v.recordId")
        });
        action.setCallback(this, function(result){
            var state = result.getState();
            if (component.isValid() && state === "SUCCESS"){
                component.set("v.memberList",result.getReturnValue());   
            }
        });
        $A.enqueueAction(action);
    },
     
    //Select all
    handleSelectAllContact: function(component, event, helper) {
        var getID = component.get("v.memberList");
        var checkvalue = component.find("selectAll").get("v.value");        
        var checkContact = component.find("checkContact"); 
        if(checkvalue == true){
            for(var i=0; i<checkContact.length; i++){
                checkContact[i].set("v.value",true);
            }
        }
        else{ 
            for(var i=0; i<checkContact.length; i++){
                checkContact[i].set("v.value",false);
            }
        }
    },
     
    //Process the selected records
    handleSelectedContacts: function(component, event, helper) {
        var selectedContacts = [];
        var selMembers = [];
        var checkvalue = document.getElementsByName('checkbox');
            for (var i = 0; i < checkvalue.length; i++) {
                if (checkvalue[i].checked == true) { 
                    selectedContacts.push(checkvalue[i].id);
                    var Item = {Id:checkvalue[i].id};
                    selMembers.push(Item);
                }
            }
        component.set("v.selectedMembers", selMembers);
}

});