({

    /*------------------------------------------------------------	
	Description:   	Init method to collect all non-ERP records active in the user's market,
    				and then check whether these products are profiled in the related account/contact
	------------------------------------------------------------*/    
    
init: function (cmp, event, helper) {
        //cmp.set('v.showSpinner', true);    	

		var focusActions = [
            {label: 'Focus products', type: 'text', name:'focus', iconName:"utility:filterList", checked: cmp.get('v.focusFilter')},
            {label: 'Show all', type: 'text', name:'all', checked: false}
            ];
    	var competitorActions = [
            {label: 'DentsplySirona products', type: 'text', iconName:"utility:filterList", name:'focus'},
            {label: 'Show all', type: 'text', name:'all'}
            ];    
        	
    	cmp.set('v.gridWrapperColumns', 
            [
            {label: 'Product name', fieldName: 'nodeName', type: 'text'},
            {label: 'Focus product?', fieldName: 'focusProduct', type: 'boolean', actions: focusActions},
            {label: 'Manufacturer', fieldName: 'manufacturer', type: 'text', actions: competitorActions},
            {label: 'Product Group', fieldName: 'SBU', type: 'text'},    
            {label: 'Added?', fieldName: 'isProfiled', type: 'boolean'},
        ]);

  	   	var record = cmp.get("v.recordId");
		
		helper.getProductsWithHierarchy(cmp, event, record);
        helper.getProfilingData(cmp, event, record);
    	helper.getDistinctValues(cmp, event, "ProductGroupText__c", "v.options");
    	helper.getDistinctValues(cmp, event, "Manufacturer__c", "v.manufacturers");
    	//helper.getDistinctValues(cmp, event, "Product_Category__c", "v.categories");
	    
        var formFactor = $A.get("$Browser.formFactor");            
            
        if(formFactor != 'DESKTOP'){
           $A.enqueueAction(cmp.get('c.getRowsMobile')); 
       	}
        else{
           $A.enqueueAction(cmp.get('c.getSelectedRows'));
        }             
    },
    
    /*------------------------------------------------------------	
	Description:   	Method to handle row selection
	------------------------------------------------------------*/    
        
    getSelectedRows: function(cmp, event, helper) {
        console.log('Launching getSelectedRows');

        var treeGridCmp = cmp.find('mytree');
        
        var selected = treeGridCmp.getSelectedRows();

        var products = cmp.get('v.currentSelectedRows');
                
        var currentView = cmp.get('v.gridWrapperFilteredData');
                
        var selectionMap = cmp.get("v.selectionMap");
                
        var selectedProductsNotInCurrentView = [];
                
        var currentViewArray = [];
        
        //Map of currently shown products
    	for(var currentProd in currentView){
        	var childRecords = currentView[currentProd]._children;
            for(var currentProdChild in childRecords){
                currentViewArray[childRecords[currentProdChild].node.Id] = childRecords[currentProdChild].node;
            }
            
    	}
            
    	//Map of selected rows in total
    	for(var prod in products){    		
    		var selProductId = products[prod].Id;
    		selectionMap[selProductId] = products[prod];
        }
    	
    	var notShownSelectedProducts = [];
    
    	//Find all selected products that are not shown currently
    	for(var prod in products){

            var shownSelectedProduct = currentViewArray[products[prod].Id];
            
            if(shownSelectedProduct == undefined){
                notShownSelectedProducts.push(products[prod]);
            }
            
    	}    	 
    	    
        var expanded = treeGridCmp.getCurrentExpandedRows();
    
    	var selectedProductsInView = [];

        for(var row in selected){
               
            if(selected[row].isProfiled == true || selected[row].isCat == true){                
                
                if(selected[row].isCat == true){
                	alert("Sorry! You cannot add a category as a product profiling."); 
                }  
                else{
                    alert("Oops! This product has already been profiled.");
                }
                
            }
            else{
                var idToCheck = selected[row].node.Id;
				
				//Only add value in case it hasn't been added before                
                if(selectionMap[idToCheck] == undefined){                    
                        products.push(selected[row].node);
                }
                
                selectedProductsInView.push(selected[row].node);
                
                //Add all selected products in the current view to the list of not shown but selected products
                notShownSelectedProducts.push(selected[row].node);
            }
        }
		
        cmp.find('mytree').set('v.expandedRows', expanded);
        cmp.set('v.currentSelectedRows', notShownSelectedProducts);
    	helper.preFillhelper(cmp, event);
    
    	var productsWrapper = [];
    
    	for(var prod in notShownSelectedProducts){
 			            
            var bundl = {};
            bundl.productId = notShownSelectedProducts[prod].Id;
            bundl.productName = notShownSelectedProducts[prod].Name;
            
            productsWrapper.push(bundl);
           
    	}
    console.log('Current product wrapper: ' + JSON.stringify(productsWrapper));
    	cmp.set('v.currentSelectedRowWrapper', productsWrapper);
    		
    },
    
   /*------------------------------------------------------------	
	Description:   	Method to get all selected rows in the mobile experience
	------------------------------------------------------------*/ 
    
        getRowsMobile : function(cmp, event, helper){
        
        var val = event.getSource().get("v.value");
        var selected = event.getSource().get("v.checked");
            
        var products = cmp.get('v.currentSelectedRows');
                        
        var currentView = cmp.get('v.gridWrapperFilteredData');
                
        var selectionMap = cmp.get("v.selectionMap");
                
        var selectedProductsNotInCurrentView = [];
                
        var currentViewArray = {};
        
        //Map of currently shown products
    	for(var currentProd in currentView){
        	var childRecords = currentView[currentProd]._children;
            for(var currentProdChild in childRecords){
                var childId = childRecords[currentProdChild].node.Id;
                currentViewArray[childId] = childRecords[currentProdChild].node;
            }
            
    	}
        var notShownSelectedProducts = [];               
            
        if(selected == true){
            val.node.isSelected = true;
        	products.push(val.node);
            notShownSelectedProducts.push(val.node);
            
        }
        else{
            for(var i in products){
                if(products[i].Id == val.node.Id){
                    products.splice(i, 1);
                }
            }   
        }
            
        console.log('Selected products: ' + JSON.stringify(products));

        //Find all selected products that are not shown currently
    	for(var prod in products){

            var shownSelectedProduct = currentViewArray[products[prod].Id];
            console.log('Shown selected product: ' + JSON.stringify(shownSelectedProduct));
            
            if(shownSelectedProduct == undefined){
                notShownSelectedProducts.push(products[prod]);
            }
            
    	}    	 
    	            
        cmp.set('v.currentSelectedRows', notShownSelectedProducts);
            
        var productsWrapper = [];
        
       for(var prod in notShownSelectedProducts){
 			            
            var bundl = {};
            bundl.productId = notShownSelectedProducts[prod].Id;
            bundl.productName = notShownSelectedProducts[prod].Name;
            
            productsWrapper.push(bundl);
           
    	}    
                        
    	cmp.set('v.currentSelectedRowWrapper', productsWrapper);    
        
    },
 
    
    /*------------------------------------------------------------	
	Description:   	Method to expand all rows in the table
	------------------------------------------------------------*/ 
    
        expandAllRows: function(cmp, event) {
        var tree = cmp.find('mytree');
        if(tree){
            tree.expandAll();
        }
        else{
        	var shownRecords = cmp.get("v.gridWrapperFilteredData");
            var expanded = [];
            
            for(var i in shownRecords){
                if(shownRecords[i].isCat == true){
                    expanded.push(shownRecords[i].nodeName);
                }
            }
            cmp.set('v.expandedRows', expanded);
            
        }    
    },
    
    /*------------------------------------------------------------	
	Description:   	Method to collapse all rows in the table
	------------------------------------------------------------*/ 
    
        collapseAllRows: function(cmp, event) {
        var tree = cmp.find('mytree');
        tree.collapseAll();
    },
        
    /*------------------------------------------------------------	
	Description:   	Method to find records in the data table based on a custom search string
	------------------------------------------------------------*/     
    
        newSearchTable : function(cmp,event,helper) {
        console.log('Launching newSearchTable');    
                        
        var searchFilter = event.getSource().get("v.value").toUpperCase();
        searchFilter = searchFilter.trim();    
        console.log('Search: ' + searchFilter);
            
        if(searchFilter.length>1){    
		
        var allRecords = JSON.parse(JSON.stringify(cmp.get("v.gridWrapperData")));
    
        var tempArray = [];
        var arrayLength =allRecords.length;
        var selectedRecords = cmp.get('v.currentSelectedRows');    
            
        for(var i=0; i < arrayLength; i++){
            var record = allRecords[i];
            var children = allRecords[i]._children;

            var childRecordsToAdd=[];
            var childLength = children.length;
            		for(var j=0; j < childLength; j++){

                        if((children[j].node.Name && children[j].node.Name.toUpperCase().indexOf(searchFilter) != -1))
                        {
                            childRecordsToAdd.push(children[j]);
                        }
                        
            		}
			
            if(childRecordsToAdd.length>0){
                
                   for(var n in childRecordsToAdd){

                    for(var k in selectedRecords){
                        if(selectedRecords[k].Id == childRecordsToAdd[n].node.Id){
                            childRecordsToAdd[n].isSelected = true;
                        }
                    }
                    
                }
                
                
            	record._children = childRecordsToAdd;
				tempArray.push(record);
            }    
        }

        cmp.set("v.gridWrapperFilteredData",tempArray);
        $A.enqueueAction(cmp.get('c.expandAllRows'));    
        }
        else{
           cmp.set("v.gridWrapperFilteredData",cmp.get("v.gridWrapperData"));
        }    
        helper.preFillhelper(cmp, event);
        
                      
    }, 
    
    /*------------------------------------------------------------	
	Description:   	Method to find records in the data table based on multiple filters
	------------------------------------------------------------*/      
        
        filterTable : function(cmp, event, helper){
        
        var allRecords = JSON.parse(JSON.stringify(cmp.get("v.gridWrapperData")));
        var currentRecords = cmp.get("v.gridWrapperFilteredData");
        var selectedRecords = cmp.get('v.currentSelectedRows');    
		
        var filter = {};
                
        filter.focus = cmp.find('focusFilter').get('v.checked');
        filter.competitor = cmp.find('competitorFilter').get('v.checked');
        filter.SBU = cmp.find('sbuFilter').get('v.value');
        filter.manufacturer = cmp.find('manufactFilter').get('v.value');    
        filter.categories = cmp.find('categoryFilter').get('v.value');
        var tempArray = [];
        var arrayLength =allRecords.length;            
		
       	for(var i=0; i < arrayLength; i++){

        var record = {
            isCat: allRecords[i].isCat,
            isProfiled: allRecords[i].isProfiled,
            nodeId: allRecords[i].nodeId,
            nodeName: allRecords[i].nodeName};
            
        var children = {};
        children = allRecords[i]._children;
            
        var filterTest = [];
            			
        filterTest = children.filter( 
                function(product){

                	return (
                    (filter.focus == true ? (product.focusProduct == filter.focus) : true) &&
					(filter.competitor == true ? (product.competitor != filter.competitor) : true)&&
                    ($A.util.isEmpty(filter.SBU)? true : product.SBU == filter.SBU) &&
                    ($A.util.isEmpty(filter.manufacturer)? true : product.manufacturer == filter.manufacturer)&&
                    ($A.util.isEmpty(filter.categories)? true: product.category == filter.categories)    
                    );
                    }
                   
        );
       
            if(filterTest.length > 0){
                
                for(var n in filterTest){

                    for(var k in selectedRecords){
                        if(selectedRecords[k].Id == filterTest[n].node.Id){
                            filterTest[n].isSelected = true;
                        }
                    }
                    
                }
                
       			record._children = filterTest;
	   			tempArray.push(record);
            }   
            
       }   
        cmp.set("v.gridWrapperFilteredData",tempArray);
        helper.preFillhelper(cmp, event);
        
        if((filter.SBU == null || filter.SBU == undefined || filter.SBU == '') && (filter.manufacturer == null || filter.manufacturer == undefined || filter.manufacturer == '')){
                //$A.enqueueAction(cmp.get('c.collapseAllRows'));
        }
        else{
           $A.enqueueAction(cmp.get('c.expandAllRows'));    
        }
    },
    
    
    goToProduct: function(cmp, event){
        var navService = cmp.find("navService");
        
        if(event.currentTarget.id != ''){
            
        var pageReference = {
            type: 'standard__recordPage',
            attributes: {
                recordId: event.currentTarget.id,
                objectApiName: 'Non_ERP_Products__c',
                actionName: 'view'
            }
        };    
        event.preventDefault();
        navService.navigate(pageReference);
        }
    },

	handleHeaderAction: function(cmp, event, helper){    
        // gives the selection header action name
        var actionName = event.getParam('action').name;      
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
            			if(columns[col].fieldName == 'competitor'){
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
                if(actionName == 'showAll'){
                    cmp.find('categoryFilter').set('v.value', '');
                    $A.enqueueAction(cmp.get('c.filterTable'));
                }
				
                var categories = cmp.get("v.categories");
                
                //Iterate through all categories
                for(var i in categories){
                	if(actionName == categories[i].value){
                    	cmp.find('categoryFilter').set('v.value', actionName);
                    	$A.enqueueAction(cmp.get('c.filterTable'));
                	}
                }    
                
            }
                
        
            cmp.set('v.gridWrapperColumns', columns);
        
        }
        
        
    },
       
})