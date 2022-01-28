({
    navigateNext : function(component, event, helper) {
        var selectedRecordType = event.getParams();
        if (Object.keys(selectedRecordType).length !== 0) {
            var recordTypeLabel = selectedRecordType.label;
            var recordTypeId = selectedRecordType.value;
            component.set('v.recordTypeLabel', recordTypeLabel);
            component.set('v.recordTypeId', recordTypeId);
            console.log('comp::'+recordTypeLabel);
        }

        var navigate = component.get('v.navigateFlow');
        navigate('NEXT');
    }
})