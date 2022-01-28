({
	init : function(cmp, event, helper) {

        	var pageReference = cmp.get("v.pageReference");
        
            var flow = cmp.find('flowData');
        	var inputVariables = [
      			{
        			name : 'recordId',
        			type : 'String',
        			value : pageReference.state.c__testVar
      			}	
    			];
       		flow.startFlow('Product_Profiling_Create_Product_Profiling_from_Contact', inputVariables);

	}
})