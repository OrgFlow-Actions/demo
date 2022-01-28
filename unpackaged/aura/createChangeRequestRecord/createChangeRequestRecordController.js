//@Author: AmitKumarPrabhat
({
    doInitLoad: function(component, event, helper) {
        
        helper.getPicklistValues(component, event, helper);
        var accntId = component.get("v.recordId");
        var action = component.get("c.getAccountDetails");
        action.setParams({
            accountid: accntId
        });
        action.setCallback(this, function(response) {
            if (response.getState() === "SUCCESS") {
                component.set("v.ac", response.getReturnValue());
                console.log(response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
    },
    statusChange: function(component, event, helper) {
        //console.log(component.find('acStatus').get("v.value"));
        if(component.find('acStatus').get("v.value")=='Created'){
            component.set("v.disableSave", false);
             }
        else{
            component.set("v.disableSave", true);
        }
    },
    checkEmpty: function(component, event, helper) {
        //console.log(component.find('acComment').get("v.value"));
        if(component.find('acComment')){
            component.set("v.disableSave", false);
             }
        else{
            component.set("v.disableSave", true);
        }
    },
    handleSaveRecord: function(component, event, helper) {
       console.log('value--'+component.find('acComment').get("v.value")+'--');
        var evStatus = component.get("v.accountcreate.Status__c");
        if(evStatus != "Created"){
            alert("Please set the Status to Created");
            return;
        }
        if(component.find('acComment').get("v.value")){
            component.set("v.disableSave", false);
             }
        else{
            component.set("v.disableSave", true);
        }
        var accountcreate = component.get("v.accountcreate");
       var responseMsg = "";
        
        //component.set("v.accountcreate.Status__c", component.get("v.acStatus"));
        component.set("v.accountcreate.Existing_Account__c", component.get("v.recordId"));
        component.set("v.accountcreate.Account_Name__c", component.find('acName').get("v.value"));
        component.set("v.accountcreate.StreetAddress__c", component.find('acStreet').get("v.value"));
        component.set("v.accountcreate.City__c", component.find('acBilling').get("v.value"));
        component.set("v.accountcreate.State_Province__c", component.find('acState').get("v.value"));
        component.set("v.accountcreate.Postal_Zip_Code__c", component.find('acZip').get("v.value"));
        component.set("v.accountcreate.Account_Phone_Number__c", component.find('acPhone').get("v.value"));
        //debugger;
        var result = component.get("v.accountcreate");
        //console.log("result@123"+result);
        var action = component.get("c.createRecord");
            action.setParams({
            accountcreate: accountcreate
        });
        action.setCallback(this, function(a) {
            //get the response state
            var state = a.getState();
			console.log('state----'+state);
            //check if result is successfull
            if (state === "SUCCESS" || state === "DRAFT") {
                // record is saved successfully
              //  var dismissActionPanel = $A.get("e.force:closeQuickAction");
               // dismissActionPanel.fire();
               // $A.get("e.force:refreshView").fire();
               //console.log("return status" + state +' & id'+ a.getReturnValue());
                if(a.getReturnValue() != null) {
                var navEvt = $A.get("e.force:navigateToSObject");
   					 navEvt.setParams({
     				 "recordId": a.getReturnValue(),
     				 "slideDevName": "related"
   					 });
    				navEvt.fire();
                }
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    message: 'Account Create/Change Request was created',
                    duration: '3000',
                    type: 'success'
                });
            
        		toastEvent.fire();
            } else if (state === "INCOMPLETE") {
                // handle the incomplete state
                console.log("User is offline, device doesn't support drafts.");
            } else if (state === "ERROR") {
                // handle the error state
                console.log('Problem saving contact, error: ');
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : 'Error',
                    message:'Please Enter Comments with only 255 characters',
                    duration:' 5000',
                    type: 'error',
                    mode: 'pester'
                });
                toastEvent.fire();
            } else {
                console.log('Unknown problem, state: ' + state + ', error: ');
            }

        });
        $A.enqueueAction(action);
        
           
    }
        
})