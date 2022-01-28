({
	init : function(cmp, event, helper) {

        	var pageReference = cmp.get("v.pageReference");
        	console.log(cmp.get("v.recordId"));
        
            var flow = cmp.find('flowData');
        	/*var inputVariables = [
      			{
        			name : 'recordId',
        			type : 'String',
        			value : cmp.get("v.recordId")
      			}	
    			];*/
       		flow.startFlow('Lead_Create_lead_from_account'); //inputVariables

	}
})