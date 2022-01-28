({
    init : function(component, event, helper) {
        var stepName = '';
        var action = component.get("c.getOppStageGuidance");
        action.setParams({
            recordId: component.get("v.recordId"),
            objectType: component.get("v.objectType"),
            stageField: component.get("v.stageField"),
            countryField: component.get("v.countryField"),
            categoryField: component.get("v.categoryField"),
            recordTypeDeveloperName: component.get("v.recordTypeDeveloperName")
        });
        action.setCallback(this, function(data){
            var res = data.getReturnValue();
            component.set("v.stageGuidances", res.stageInfo);
            component.set("v.stageGuidance", res.currentStageGuidance);
            component.set("v.currentStage", res.currentStage);
            component.set("v.objectType", res.objectType);
            component.set("v.recordTypeDeveloperName", res.recordTypeDeveloperName);
            
            stepName = res.currentStage;
            helper.updatingStage(component, event, stepName);
            component.set('v.showSpinner', false);
        });
        if (component.get("v.stageGuidances").length === 0) {
            $A.enqueueAction(action);
        } else {
            component.set('v.showSpinner', false);
        }
        
    },
    
    updateStage: function(component, event, helper){
        if (event) {
            component.set("v.showSpinner", true);
            var stepName = event.getParam("detail").value;
            // helper.updatingStage(component, event, stepName);
            if (component.get("v.objectType") === 'Opportunity') {
                helper.checkStageType(component, event, helper, stepName);
            } else {
                helper.setStage(component, event, helper, stepName);
            }
        } 
    },
    
    handleSubmit: function(cmp, event, helper) {
        
        event.preventDefault();
        var eventFields = event.getParam('fields');
        console.log('Set event fields',eventFields);
        var stage = cmp.get('v.currentStage');
        var stageField = cmp.get('v.stageField');
        console.log('Stage field: ');
        eventFields[stageField] = stage;
        cmp.find('recordForm').submit(eventFields);
        cmp.set('v.disabled', true);
        cmp.set('v.showSpinner', true);
    },
    
    handleSuccess: function(cmp, event, helper) {
        cmp.set('v.showSpinner', false);
        cmp.set('v.disabled', false);
        // cmp.set('v.saved', true);
    }
})