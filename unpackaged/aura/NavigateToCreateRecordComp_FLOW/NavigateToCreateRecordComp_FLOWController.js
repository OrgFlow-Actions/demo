({
    invoke: function(component, event, helper) {

    },
    
    navigateToNewRecord: function(component, event, helper) {
        var defaultFieldsString = event.getParam('defaultFields').replace(/(\r\n|\n|\r)/gm,"");
        var defaultFields = JSON.parse(defaultFieldsString);
        var recordTypeId = component.get('v.recordTypeId');
        var objectToCreate = component.get('v.objectToCreate');
        var createRecordEvent = $A.get('e.force:createRecord');
        var recordParams = {
            entityApiName: objectToCreate,
            defaultFieldValues: defaultFields,
            recordTypeId: null
        };

        if (recordTypeId) recordParams.recordTypeId = recordTypeId;

        createRecordEvent.setParams(recordParams);

        createRecordEvent.fire();

        setTimeout(() => component.set('v.hasNavigated', true), 1000);
    },
})