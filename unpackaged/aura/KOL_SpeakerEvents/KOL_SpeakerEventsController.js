({
	init : function(component, event, helper) {
		component.set("v.columns",[
            				{ label: 'Event', fieldName: 'EventUrl', type: 'url', typeAttributes: {label: { fieldName: 'Name' }} },
                         	{ label: 'Contract', fieldName: 'Contract' },
                         	{ label: 'Contracted speaker', fieldName: 'Speaker' },
            				{ label: 'Start date', fieldName: 'StartDate', type: 'date-local'}
                     ]);
		//helper.loadDeliverables(component, event);		
        helper.loadSpeakerEvents(component, event);
        
	}
})