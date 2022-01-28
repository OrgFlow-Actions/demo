({
    closeQA: function (component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    },

    refresh: function (component, event, helper) {
        $A.get('e.force:refreshView').fire();
    },

    handleNewEvent: function(component, event, helper) {
        // var flow = component.find('newEventFlow');
        // var recordId = component.get('v.recordId');
        // var inputVariables = [
        //     {
        //         name: 'recordId',
        //         type: 'String',
        //         value: recordId,
        //     },
        // ];
        // flow.startFlow('Contact_NewEvent_CFE2_0', inputVariables);
        component.set('v.renderForm', false);
        component.set('v.renderForm', true);
    }
})