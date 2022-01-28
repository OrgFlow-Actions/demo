({
    updatingStage: function(component, event, stepName){  
        
        var stageGuidances = component.get("v.stageGuidances");
        component.set("v.fieldCheck", false,false,false,false);
        var array = [];
        var len = 0;
        var stageCount = stageGuidances.length;
        var matchFound = false;
        for(var i=0; i<stageCount; i++){
            var oppStage = stageGuidances[i].OppStage__c;
            if(oppStage == stepName){
                matchFound = true;
                component.set("v.stageGuidance", stageGuidances[i].StageGuidance__c);
                component.set("v.stageGuidanceDescr", stageGuidances[i].StageGuidanceDescr__c);
                if(stageGuidances[i].FieldsToDisplay__c){
                    var fieldsToDisplay = stageGuidances[i].FieldsToDisplay__c;
                    array = fieldsToDisplay.split(';');
                    len = array.length;   
                }
                else{
                    console.log('No fields to display found');
                }    
            }
        }
        //If no metadata is found for this stage, then display blank stage guidances
        if(matchFound == false){
            component.set("v.stageGuidance", "");
            component.set("v.stageGuidanceDescr", "");
        }
        if(len>0){
            var fields = [];
            for(var j=0; j<len; j++){
                fields.push(array[j]);
            }
            component.set("v.fields", fields);
        } else{
            component.set("v.fields", []);
        }

        component.set("v.showSpinner", false);
        
    },
    setStage: function(component, event, helper, stepName) {
        var recordId = component.get("v.recordId");
        var stageField = component.get("v.stageField");
        var currentStage = component.get("v.currentStage");
        var action = component.get("c.updateStage2");
        var stepName = stepName;

        action.setParams({
            "recordId": recordId,
            "stageName": stepName,
            "stageField": stageField
        });

        action.setCallback(this, function(response) {
            if (response.getState() === "SUCCESS") {
                component.set("v.currentStage", stepName);
                $A.get("e.force:refreshView").fire();
                helper.updatingStage(component, event, stepName);
            } else if (response.getState() === "ERROR") {
                var errors = response.getError();
                errors[0].message = errors[0].message.match(/(?:[A-Z]*, )(.*?)(?=:)/)[1];
                if (errors) {
                    component.set('v.error', errors[0]);
                    // component.find('pickListPath').set(v.value, 'Not Started');
                }
                component.set("v.showSpinner", false);
            }
        });
        
        if (stageField !== currentStage) $A.enqueueAction(action);
    },
    checkStageType: function(component, event, helper, stepName) {
        var action = component.get("c.checkStageType");
        var stepName = stepName;

        action.setParams({ "stageName": stepName });

        action.setCallback(this, function(response) {
            if (response.getState() === "SUCCESS") {
                var res = response.getReturnValue();
                if (res.IsClosed || res.IsWon) {
                    helper.createModal(component, event, helper, stepName);
                } else {
                    helper.setStage(component, event, helper, stepName);
                }
            } else if (response.getState() === "ERROR") {
                var errors = response.getError();
                errors[0].message = errors[0].message.match(/(?:[A-Z]*, )(.*?)(?=:)/)[1];
                if (errors) {
                    component.set('v.error', errors[0]);
                    // component.find('pickListPath').set(v.value, 'Not Started');
                }
                component.set("v.showSpinner", false);
            }
        });
        $A.enqueueAction(action);
    },
    createModal: function (component, event, helper, stepName) {
        var stepName = stepName
        var modalBody;
        $A.createComponent("c:OppStageGuidanceModalContent", { recordId: component.get("v.recordId"), objectType: component.get("v.objectType"), modalSuccess: component.getReference("v.modalSuccess"), stepName: stepName },
           function(content, status) {
               if (status === "SUCCESS") {
                   modalBody = content;
                   component.find('overlayLib').showCustomModal({
                       header: "Win/Loss Reason",
                       body: modalBody,
                       showCloseButton: true,
                       cssClass: "mymodal",
                       closeCallback: function() {
                            if (component.get("v.modalSuccess")) {
                                helper.setStage(component, event, helper, stepName);
                            } else {
                                helper.setStage(component, event, helper, component.get("v.currentStage"));
                            }

                       }
                   })
               }
           });
    }
})