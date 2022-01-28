({
	doInit : function(component, event, helper) {
		helper.getPickValAct(component);
        helper.getPickValTyp(component);
        helper.getPickValStat(component);
		helper.getCampaignList(component);
        var workspaceAPI = component.find("workspace");
         workspaceAPI.getFocusedTabInfo().then(function(response) {
            var focusedTabId = response.tabId;
            workspaceAPI.setTabLabel({
                tabId: focusedTabId,
                label: "Campaign Tracker"
            });
         })
	},
    // For count the selected checkboxes. 
    checkboxSelect: function(component, event, helper) {
        // get the selected checkbox value  
        var selectedRec = event.getSource().get("v.value");
        // get the selectedCount attrbute value(default is 0) for add/less numbers. 
        var getSelectedNumber = component.get("v.selectedCount");
        // check, if selected checkbox value is true then increment getSelectedNumber with 1 
        // else Decrement the getSelectedNumber with 1     
        if (selectedRec == true) {
            getSelectedNumber++;
        } else {
            getSelectedNumber--;
        }
        // set the actual value on selectedCount attribute to show on header part. 
        component.set("v.selectedCount", getSelectedNumber);
    },
    // For select all Checkboxes 
    selectAll: function(component, event, helper) {
        //get the header checkbox value  
        var selectedHeaderCheck = event.getSource().get("v.value");
        // get all checkbox on table with "boxPack" aura id (all iterate value have same Id)
        // return the List of all checkboxs element 
        var getAllId = component.find("boxPack");
        // If the local ID is unique[in single record case], find() returns the component. not array   
        if(! Array.isArray(getAllId)){
            if(selectedHeaderCheck == true){ 
                component.find("boxPack").set("v.value", true);
                component.set("v.selectedCount", 1);
            }else{
                component.find("boxPack").set("v.value", false);
                component.set("v.selectedCount", 0);
            }
        }else{
            // check if select all (header checkbox) is true then true all checkboxes on table in a for loop  
            // and set the all selected checkbox length in selectedCount attribute.
            // if value is false then make all checkboxes false in else part with play for loop 
            // and select count as 0 
            if (selectedHeaderCheck == true) {
                for (var i = 0; i < getAllId.length; i++) {
                    component.find("boxPack")[i].set("v.value", true);
                    component.set("v.selectedCount", getAllId.length);
                }
            } else {
                for (var i = 0; i < getAllId.length; i++) {
                    component.find("boxPack")[i].set("v.value", false);
                    component.set("v.selectedCount", 0);
                }
            } 
        }         
    },
    
    showNext : function (component, event, helper) {
        var err = false;
        component.get("v.selectedCampaigns").forEach(function(selectedCampaign){
            var conType = selectedCampaign.pick2;
            if(conType ==''){
                err = true;
            }
        });
        if(err == true){
            component.set("v.errorMessage1", "Please select Contact Type.");
        }
        else{
            component.set("v.errorMessage1", "");
            var currentStep = component.get("v.childAttr");
            component.set("v.childAttr","Next Step");
            var currentStepNew = component.get("v.childAttr");
            component.set("v.displayedSection","section3");
        }   
    },
    showPrev : function (component, event, helper) {  
        component.set("v.displayedSection","section1");
        component.set("v.errorMessage1", "");        
    },
    showPrev1 : function (component, event, helper) {  
        component.set("v.displayedSection","section2");  
    },
    onGroup: function(component, evt) {
		 var selected = evt.getSource().get("v.label");
        if (selected == "Create a follow-up task for myself.") {
            component.set("v.followRadioButton",true);
            var fl = component.get("v.followRadioButton");
        } else if (selected == "Complete - I'm finished.") {
            component.set("v.followRadioButton",false);
            var cm = component.get("v.followRadioButton");
        }   
	 },
    
    showNext1 : function (component, event, helper, followRadioButton, completeRadioButton) {
        var showNext1 = component.get("v.followRadioButton");
        var complete = component.get("v.completeRadioButton");
        if (showNext1) {
        var selIdNew = component.get("v.selCampIdList");
            helper.getshowNext1(component, event, selIdNew); 
        }     
        else if (!showNext1) {
            helper.getshowNext2(component, event, helper);
        }    
    },
    
    showNext2 : function (component, event, helper) {
    },
    
    //For Delete selected records 
    showSelectedCampaigns: function(component, event, helper) {
        // create var for store record id's for selected checkboxes  
        var getSelectedNumber = component.get("v.selectedCount");
        if(getSelectedNumber == 0){
            component.set("v.errorMessage", "Please select atleast one Campaign.");
        }
        else{
            component.set("v.errorMessage", "");
            var selId = [];
            // get all checkboxes 
            var getAllId = component.find("boxPack");
            // If the local ID is unique[in single record case], find() returns the component. not array
            if(! Array.isArray(getAllId)){
                if (getAllId.get("v.value") == true) {
                    selId.push(getAllId.get("v.text"));
                    console.log(getAllId.get("v.value"));
                }
            }else{
                // play a for loop and check every checkbox values 
                // if value is checked(true) then add those Id (store in Text attribute on checkbox) in delId var.
                for (var i = 0; i < getAllId.length; i++) {
                    if (getAllId[i].get("v.value") == true) {
                        selId.push(getAllId[i].get("v.text"));
                    }
                }
            } 
            var section1InputValue = component.get("v.displayedSection");
            component.set("v.displayedSection","section2");
            var section2InputValue = component.get("v.displayedSection");
            component.set("v.selCampIdList",selId);
            helper.showSelectedCampaignsHelper(component, event, selId);
            var currentStep = component.get("v.childAttr");
            component.set("v.childAttr","Notes/Status");
            var currentStepNew = component.get("v.childAttr");
        }    
    },
    populateRemDate : function(component, event, helper) { 
        var dueDate = component.get("v.task.ActivityDate");
        var action = component.get('c.setReminderDate');
        action.setParams({
            dueDate: component.get("v.task.ActivityDate")
        })
        action.setCallback(this, function(actionResult) {
            component.set("v.task.ReminderDateTime", actionResult.getReturnValue());
        });
        $A.enqueueAction(action);  
     }, 
})