({
	init : function(component, event, helper) {
		component.set("v.columns",[
            				{ label: 'Event', fieldName: 'EventUrl', type: 'url', typeAttributes: {label: { fieldName: 'Name' }} },
                         	{ label: 'Status', fieldName: 'Status' },
                         	{ label: 'Contracted speaker', fieldName: 'Speaker' },
            				{ label: 'Start date', fieldName: 'StartDate', type: 'date-local'},
            				{ label: 'KOL Manager Email', fieldName: 'Email'},
                     ]);		
        helper.loadEvents(component, event);
        
	}
})