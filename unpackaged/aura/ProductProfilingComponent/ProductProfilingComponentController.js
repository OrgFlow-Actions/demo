({
init: function (cmp, event, helper) {
          
        var focusActions = [
            {label: 'Focus products', type: 'text', name:'focus', iconName:"utility:filterList", checked: cmp.get('v.focusFilter')},
            {label: 'Show all', type: 'text', name:'all', checked: false}
            ];
    	var competitorActions = [
            {label: 'DentsplySirona products', type: 'text', iconName:"utility:filterList", name:'focus'},
            {label: 'Show all', type: 'text', name:'all'}
            ];
    
    	var rowActions = helper.getRowActions.bind(this, cmp);    
	
    	cmp.set('v.gridWrapperColumns', 
            [
            {label: 'PRODUCT NAME', fieldName: 'productUrl', type: 'url', initialWidth: 300,
             typeAttributes: {
                    label: { fieldName: 'nodeName' },
                 	tooltip: {fieldName: 'nodeName'}
                }},
            {label: 'FOCUS PRODUCT', fieldName: 'focusProduct', actions:focusActions, type: 'boolean'},
            {label: 'MANUFACTURER', fieldName: 'manufacturer', actions:competitorActions, type: 'text'},
            {label:'QUANTITY', fieldName:'quantity', type:'text'},     
            {label: 'STATUS', fieldName: 'status', type: 'text'},
            //{label: 'CONTACT', fieldName: 'contact', type: 'text'},
            {label:'CONTACT', fieldName: 'contactUrl', type: 'url',
                 typeAttributes: {
                     label: {fieldName: 'contactName'}
                 }
			},    
            { type: "action", typeAttributes: { rowActions: rowActions }}                
        ]);

    
  	   var record = cmp.get("v.recordId");

       helper.getProfilingHierarchy(cmp, event, record);

    },
    
    /*------------------------------------------------------------	
	Description:   	Method to launch the flow for creating new product profiling records
	------------------------------------------------------------*/      
        
    launchFlow: function (component, event, helper) {
        	
        var formFactor = $A.get("$Browser.formFactor");
        
        if(formFactor == 'DESKTOP'){
            component.set('v.isOpenNew', true);
            var flow = component.find('flowData');
        	var inputVariables = [
      			{
        			name : 'recordId',
        			type : 'String',
        			value : component.get("v.recordId")
      			}	
    			];
       		flow.startFlow('Product_Profiling_Create_Product_Profiling_from_Contact', inputVariables);
        }
        else{
            
            /*var urlEvent = $A.get("e.force:navigateToURL");
    		urlEvent.setParams({
      				"url": '/flow/Product_Profiling_Create_Product_Profiling_from_Contact?recordId=' + component.get("v.recordId") + '&retURL=' + component.get("v.recordId")
    			});       	
    		urlEvent.fire();*/
                   
            var navService = component.find("navService");
        	var pageReference = {
            
            "type": "standard__component",
            "attributes": {
                "componentName": "c__ProductProfilingFlow"    
            },    
            "state": {
                "c__testVar": component.get("v.recordId")
           	}
        	};
			
        	component.set("v.pageReference", pageReference);
        	var defaultUrl = "#";
        	navService.generateUrl(pageReference)
        	.then($A.getCallback(function(url) {
            	component.set("v.url", url ? url : defaultUrl);
        	}), $A.getCallback(function(error) {
            	component.set("v.url", defaultUrl);
        	}));
        
        	navService.navigate(pageReference);
            
        }
        
    },
    
    closeFlowModal : function(component, event, helper) {
        component.set("v.isOpenNew", false);
        component.set("v.isOpenEdit", false);
    },

	closeModalOnFinish : function(component, event, helper) {
        //console.log(event.getParam('status'));
        if(event.getParam('status') === "FINISHED") {
            component.set("v.isOpenNew", false);
        }
    },
    
    closeModalOnSave : function(component, event, helper){
        component.set("v.isOpenNew", false);
        component.set("v.isOpenEdit", false);
        $A.enqueueAction(component.get('c.init'));
        
    },
    
    gotoRelatedList : function (component, event, helper) {
    	component.set('v.isOpenEdit', true);
	},
    
    openRelatedList: function(component, _event){
       	var relatedListEvent = $A.get("e.force:navigateToRelatedList");
   		relatedListEvent.setParams({
      			"relatedListId": "Products_Profiling__r",
      			"parentRecordId": component.get("v.recordId")
   		});
   		relatedListEvent.fire();
    },
    
    goToProduct: function(cmp, event){
        var navService = cmp.find("navService");
        
        console.log("Id: " + event.currentTarget.id);

        if(event.currentTarget.id != ''){
        //console.log("Navigating");
            
        var pageReference = {
            type: 'standard__recordPage',
            attributes: {
                recordId: event.currentTarget.id,
                objectApiName: 'Product_Profiling__c',
                actionName: 'view'
            }
        };    
        event.preventDefault();
        navService.navigate(pageReference);
        }
    },
 
    handleRowAction: function (cmp, event, helper) {
        //console.log(JSON.stringify(event));
        var row = event.getParam('row');
        var action = event.getParam('action');
        var recordId = row.productId;
        var parentRecord = cmp.get('v.recordId');
        
        if(action.name == 'view'){
        	helper.openProduct(cmp, event, recordId, 'view');
        }  
        if(action.name == 'edit'){
        	helper.openProduct(cmp, event, recordId, 'edit');
        }
        if(action.name == 'delete'){
            helper.deleteProduct(cmp, event, recordId, 'delete', parentRecord); 
        }
    },
    
    handleHeaderAction: function(cmp, event, helper){    
        // gives the selection header action name
        var actionName = event.getParam('action').name;
        //console.log("Data: ", cmp.get("v.gridWrapperFilteredData"));        
        // gives selected column definition
    	var colDef = event.getParam('columnDefinition');
       	// assigning columns to new variable
    	var column = colDef.fieldName;
		var columns = cmp.get('v.gridWrapperColumns');
        var len = columns.length;
        var idx = 0;        
        
       	if (actionName !== undefined) {
            if(column == 'focusProduct'){
                
                 //Get index of the Focused column
                	for(var col in columns){
            			if(columns[col].fieldName == 'focusProduct'){
                			idx = col;
            			}
        			}
                
                //Get action within the Focused column
            	var focusActions = columns[idx].actions;

                focusActions.forEach(function (action) {
                	action.checked = action.name === actionName;
            	});
                  
                //Check which action that was selected
                	if(actionName == 'all'){
                  		cmp.find('focusFilter').set('v.checked', false);
                    	cmp.set('v.activeFocusFilter', actionName);
     
                	}
                	else{
                    	cmp.find('focusFilter').set('v.checked', true);
                    	cmp.set('v.activeFocusFilter', actionName);
                	}
               	  	$A.enqueueAction(cmp.get('c.filterTable'));
            }
            
            if(column == 'manufacturer'){
                
                //Get index of the Competitor column
                for(var col in columns){
            			if(columns[col].fieldName == 'manufacturer'){
                			idx = col;
            			}
        		}
                
                //Get available action on the Competitor column
                var compActions = columns[idx].actions;                
                compActions.forEach(function (action) {
                	action.checked = action.name === actionName;
            	});
                
                	//Check which action that was selected
                	if(actionName == 'all'){
                   	 	cmp.find('competitorFilter').set('v.checked', false);
                    	cmp.set('v.activeCompetitorFilter', actionName);
                	}
                	else{
                		cmp.find('competitorFilter').set('v.checked', true);
                    	cmp.set('v.activeCompetitorFilter', actionName);
                	}
                	$A.enqueueAction(cmp.get('c.filterTable'));
            }
            
            if(column == 'nodeName'){
                if(actionName == 'expandAll'){
                    $A.enqueueAction(cmp.get('c.expandAllRows'));
                }    
                
            }
                
        
            cmp.set('v.gridWrapperColumns', columns);
        
        }
        
        
    },
    
    /*------------------------------------------------------------	
	Description:   	Method to find records in the data table based on multiple filters
	------------------------------------------------------------*/      
        
        filterTable : function(cmp, event, helper){
        var allRecords = cmp.get("v.gridWrapperData");
        var currentRecords = cmp.get("v.gridWrapperFilteredData");
        var filter = {};
                
        filter.focus = cmp.find('focusFilter').get('v.checked');
        filter.competitor = cmp.find('competitorFilter').get('v.checked');
//        filter.SBU = cmp.find('sbuFilter').get('v.value');
//        filter.manufacturer = cmp.find('manufactFilter').get('v.value');    
//        filter.categories = cmp.find('categoryFilter').get('v.value');
        var tempArray = [];
        var arrayLength =allRecords.length;
            //console.log("Filter: ", filter);            
		
       	for(var i=0; i < arrayLength; i++){
        
        var record = {
            nodeName: allRecords[i].nodeName,
            productName: allRecords[i].productName,
            productUrl: allRecords[i].productUrl};
            
        var children = {};
        children = allRecords[i]._children;
            //console.log("Children: ", children);    
            
        var filterTest = [];
            			
        filterTest = children.filter( 
                function(product){
                	return (
                    (filter.focus == true ? (product.focusProduct == filter.focus) : true) &&
					(filter.competitor == true ? (product.competitor != filter.competitor) : true)
                    );
                    }
                   
        );
       	
            if(filterTest.length > 0){
       			record._children = filterTest;
	   			tempArray.push(record);
            }
            
       }
            //console.log("Filtered records to assign: ", tempArray);    
        cmp.set("v.gridWrapperFilteredData",tempArray);

    },
    
})