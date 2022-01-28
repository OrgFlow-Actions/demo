({    

    /*------------------------------------------------------------	
	Description:   	Helper method to check if non-ERP Products are profiled in the related account/contact
    Inputs:			@param recordId
	------------------------------------------------------------*/     
    
    getProfilingData : function(cmp, event, recordId) { 
        	console.log('Launching getProfilingData');
			var action = cmp.get("c.getProductProfilingMap");
        	
            action.setParams({
                recordId : cmp.get("v.recordId")
            });
        	
        	action.setCallback(this, function(response) {

            var state = response.getState();
            if (state === "SUCCESS") {
                var result=response.getReturnValue();
                var data = JSON.parse(JSON.stringify(cmp.get('v.gridWrapperData')));
                
                var selectedRows = cmp.get('v.currentSelectedRows');
                
                for (var prodKey in result){
				
                    for(var key in data){
                        
                        var children = data[key]._children;

                    	for (var childKey in children){
                        	var childId = children[childKey].node.Id
         
                            if(prodKey == childId){
                                
                            	children[childKey].isProfiled = true;
                                children[childKey].isSelected = true;
                            	data[key].isProfiled = true;          
                        	}
                            
                            for(var selectedKey in selectedRows){
                                if(selectedRows[selectedKey].Id == childId){
                                    children[childKey].isSelected = true;
                                }
                            }
                        
                    	}
                        
                    }
					                    
                }
                cmp.set('v.gridWrapperData', data);
                cmp.set('v.gridWrapperFilteredData', data);
                cmp.set('v.productProfilingData', result);   
            }
                
            else if(state === "ERROR")
            {
                console.log('Problem with connection. Please try again.');
            }
                
           
            
        });
        $A.enqueueAction(action);
        
    },
    
    /*------------------------------------------------------------	
	Description:   	Helper method to find non-ERP products and create a parent level based on the found records' category
    Inputs:			@param recordId
	------------------------------------------------------------*/     
    
    getProductsWithHierarchy : function(cmp, event, recordId) { 
        console.log('Launching getProductsWithHierarchy');    
		var action = cmp.get("c.getAllProducts");
            action.setParams({
                recordId : cmp.get("v.recordId")
            });
        action.setCallback(this, function(response) {
            var state = response.getState();
            var data = cmp.get("v.gridWrapperData");
            var dataToAdd = [];
            var recordsWOCat = [];
            var int = 0;
            var formFactor = $A.get("$Browser.formFactor");            
            var selectedProducts = cmp.get('v.currentSelectedRows');
            /*if(formFactor != 'DESKTOP'){
             	cmp.set('v.currentSelectedRows', []);   
            }*/
            
            var expanded = [];
            
            if (state === "SUCCESS") {
                var result=response.getReturnValue();
                var categories = {};
                var categoriesToExpand = {};
				    
                //Find all categories
                 for(var prodKey in result){					   
					var cat = result[prodKey].node.Product_Category__c;
                    categories[cat] = cat;                                          
                 }
                
                   for(var p in selectedProducts){
                       	var catToExp = selectedProducts[p].Product_Category__c;
                       	categoriesToExpand[catToExp] = catToExp;    	                       
                   }
                	
                for(var x in categoriesToExpand){
                    expanded.push(categoriesToExpand[x]);
                }
                                
                for(var catKey in categories){
                    var recordToAdd = {};
					recordToAdd.nodeName = categories[catKey];
                    recordToAdd.isCat = true;
                    recordToAdd.nodeId = categories[catKey];
					
                    var childrenToAdd = [];
                    
					for(var key in result){					   
                       var record = result[key];
                       record.competitor = record.node.Competitor_Product__c;
					   record.focusProduct = record.node.KeyProduct__c;
                       record.SBU = record.node.ProductGroupText__c; 
                       record.isCat = false; 
                       record.nodeId = record.node.Id;
                       record.manufacturer = record.node.Manufacturer__c;
                       record.category =  record.node.Product_Category__c; 
 
                       if(record.node.Product_Category__c == categories[catKey]){
                           
                            if(record.node.Product_Category__c == null){
                            	recordsWOCat.push(record);
                        	}
                           	else{
                         		childrenToAdd.push(record);
                            }    
                       }
                                                                    
                   }
                  
				  recordToAdd._children = childrenToAdd;
                    
                   //Sort child records ascending 
                   this.sortTable(cmp, event, true, childrenToAdd, "nodeName");                        
                    
                  //Add category and children as records
                    if(categories[catKey] != null){
                   		dataToAdd.push(recordToAdd);
                   }
                                       
                }
                
                //Handle records that do not have a category assigned
                if(recordsWOCat.length > 0){
                    
                    var othersCat = {};
                    othersCat.nodeName = "Without Category";
                    othersCat._children = recordsWOCat;
                    dataToAdd.push(othersCat);
                };
                                   
                data = dataToAdd;
                
                //Sort node records ascending 
                this.sortTable(cmp, event, true, data, "nodeName");

                cmp.set('v.gridWrapperData', data);
                cmp.set('v.gridWrapperFilteredData', data);
                cmp.set('v.expandedRows', expanded);
                cmp.set('v.categories', categories);
                
               	
                //Handle header actions in the first column of the table
                var columns = cmp.get('v.gridWrapperColumns');
				var idx = 0;
                
                for(var col in columns){
	
                    if(columns[col].fieldName == 'nodeName'){
                			idx = col;
            			}
        		}
                
                var actions = [ ];
                
                this.getDistinctValues(cmp, event, "Product_Category__c", "v.categories"); 
                
                var categories = cmp.get("v.categories");
                    
                var cat = categories[0];
                	
                for(var i in cat){
                    var actionToAdd = 
                        {label: cat[i], type: 'text', name:cat[i], checked: false, iconName: 'utility:filterList'}
            			;
                    actions.push(actionToAdd);
                }
                this.sortTable(cmp, event, true, actions, "label");
                actions.push({label: 'Show all', type: 'text', name: 'showAll', checked: false});
                actions.unshift({label: 'Expand all', type: 'text', name:'expandAll', checked: false, iconName: 'utility:expand_all'});
                columns[idx].actions = actions;
                
                cmp.set('v.gridWrapperColumns', columns);
                  
            }else if(state === "ERROR"){
                alert('Problem with connection. Please try again.');
            }
         cmp.set('v.showSpinner', false);
         this.preFillhelper(cmp, event);
            
         
        });
		$A.enqueueAction(action);
              
    },
    
    preFillhelper: function(cmp, event) {
      	console.log('Launching PreFill Helper');
        var expanded = cmp.get('v.expandedRows');
          
        if(expanded.length>0){
             if(cmp.find('mytree')){
                cmp.find('mytree').set('v.expandedRows', expanded);
             }    
        }          
            
        var selectedRows = cmp.get('v.currentSelectedRows');
        var shownRows = cmp.get('v.gridWrapperFilteredData');
        var records = [];
        var expandedNodes = [];

        if(selectedRows.length > 0){

            for(var i in selectedRows){
				
                //Check if selected row is currently displayed in the table
                var getElementIndex = shownRows.indexOf(selectedRows);
                if(getElementIndex == -1){
                	records.push(selectedRows[i].Id);
                    expandedNodes.push(selectedRows[i].Product_Category__c);
                }    
            }	
        
        }
            
       	if(cmp.find('mytree')){
        	cmp.find('mytree').set('v.selectedRows', records);
            cmp.find('mytree').set('v.expandedRows', expandedNodes);
    	}
        
    },

    getDistinctValues: function(cmp, event, fieldName, varToAssign){
        
       var action = cmp.get("c.getDistinctValues");
       var recordId = cmp.get("v.recordId"); 
       action.setParams({
           		field_name: fieldName,
           		recordId: recordId
            });
        action.setCallback(this, function(response) {
        	var result=response.getReturnValue();
            var plList = [];
            var plDef = {};
            plDef.label="";
            plDef.value="";
            plList.push(plDef);
            for(var res in result){
                var plVal = {};
                plVal.label = result[res];
                plVal.value = result[res];
                plList.push(plVal);
            }
			
            //Sort values ascending
            this.sortTable(cmp, event, true, plList, "label"); 
            //console.log("Picklist values: ", fieldName, plList);
            cmp.set(varToAssign, plList);
            
        });
        $A.enqueueAction(action);
        
    },
    
    sortTable : function(cmp, event, sortAsc, dataSet, sortField){
                	try{
                    	dataSet.sort(function(a,b){
						var t1 = a[sortField] == b[sortField],
                			t2 = a[sortField] > b[sortField];
            				return t1? 0: (sortAsc?-1:1)*(t2?-1:1);                        
                    	})
                		}
                	catch(e){
                    	console.error(e);
                	}   
    },
    
})