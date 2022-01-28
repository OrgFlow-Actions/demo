({    

    /*------------------------------------------------------------	
	Description:   	Helper method to find all Product Profiling records related to an account/contact, and display them in a hierarchy 
    Inputs:			@param recordId
	------------------------------------------------------------*/   
    
    getProfilingHierarchy : function(cmp, event, recordId) { 
			var action = cmp.get("c.getProductProfiling");
        	
            action.setParams({
                recordId : cmp.get("v.recordId")
            });
        	
        	action.setCallback(this, function(response) {

            var state = response.getState();
                
            var data = cmp.get("v.gridWrapperData");
            var productProfilingData = [];
            var dataToAdd = [];
            var recordsWOCat = [];
            var int = 0;

            if (state === "SUCCESS") {
                var result=response.getReturnValue();
                //console.log(result);
                var categories = {};
				var productCount = {};    
                //Find all categories
                  for(var prodKey in result){					   
					var cat = result[prodKey].Product_Category__c;
                    categories[cat] = cat; 
                     
                    var prodId = result[prodKey].Product_Name__r.Id;
                    if(productCount[prodId]>0){
                    	productCount[prodId] = productCount[prodId] + 1;    
                    }
                    else{
                        productCount[prodId] = 1;
                    }  
                   }
                                
                //Loop all categories
                for(var catKey in categories){
                    
                    //Create parent records for each category
                    var recordToAdd = {};
					recordToAdd.nodeName = categories[catKey];
                    recordToAdd.productUrl = categories[catKey];
                    recordToAdd.productName = categories[catKey];
					
                    var childrenToAdd = [];
                    var productAdded = {};
                    
                    //Loop all non-ERP products for each category
					for(var key in result){
                       
                       var record = result[key];
                        //console.log(record);
                                             
                       if(record.Product_Category__c == categories[catKey]){
                           		
                           		//Create child record
                       			var childToAdd = {};
                           		var q = '';
                           		if(record.Quantity__c){
                               		var q1 = record.Quantity__c;
                                    q=q1.toString();
                                    //console.log(q);
                                    if(record.Product_Name__r.QuantityUnitOfMeasure__c){
                               			q = q + ' ' + record.Product_Name__r.QuantityUnitOfMeasure__c;
                           			}
                                }
                           		
                           		childToAdd.nodeName =  record.Product_Name__r.Name;
                           		childToAdd.productName =  record.ProductName;
                           		childToAdd.productId = record.Id;
                           		childToAdd.nonErpId = record.Product_Name__r.Id;
                       			var prodUrl = '/' + record.Id;
                       			childToAdd.productUrl = prodUrl; 
                       			childToAdd.competitor = record.Product_Name__r.Competitor_Product__c;
					   			childToAdd.focusProduct = record.Product_Name__r.KeyProduct__c;
                           		childToAdd.manufacturer = record.Product_Name__r.Manufacturer__c;
                           		
                           		if(productCount[record.Product_Name__r.Id]==1){
                           			childToAdd.status = record.Status__c;
                           			childToAdd.quantity = q;
                                    //console.log("Assign quantity: ", q);
                                }
                           		
                           		/*if(record.Contact__c != null){
                           			childToAdd.contactName = record.Contact__r.FirstName + ' ' + record.Contact__r.LastName;
                           			childToAdd.contactUrl = '/' + record.Contact__c;
                                }*/
                           		productProfilingData.push(record);
                     
                            if(record.Product_Name__r.Product_Category__c){
                                if(productCount[record.Product_Name__r.Id]==1){
                                    
                                    if(record.Contact__c != null){
                           				childToAdd.contactName = record.Contact__r.FirstName + ' ' + record.Contact__r.LastName;
                           				childToAdd.contactUrl = '/' + record.Contact__c;
                                	}
                                    
                                	childrenToAdd.push(childToAdd);
                                }
                                else{
									
                                    var subChildren = [];
                                    
                                    var productId = record.Product_Name__r.Id;
                                    var subChild ={};
                                    
                                    if(productAdded[productId]>0){
                    					
                                        var childNode={};
                                        
                                        for(var child in childrenToAdd){
                                            
                                            if(childrenToAdd[child].nonErpId == productId){
                                            childNode = childrenToAdd[child];

                                            var subChildrenToAdd = [];
                                            subChildrenToAdd = childNode._children;
                                            
                                            if(record.Contact__c != null){    
                                            	subChild.nodeName =  record.Product_Name__r.Name + ' (Contact)';
                                            }
                                            else{
                                                subChild.nodeName =  record.Product_Name__r.Name + ' (Account)';
                                            }    
                           					subChild.productName =  record.ProductName;
                           					subChild.productId = record.Id;
                                            subChild.nonErpId = record.Product_Name__r.Id;  
                       						subChild.productUrl = prodUrl; 
                       						subChild.competitor = record.Product_Name__r.Competitor_Product__c;
					   						subChild.focusProduct = record.Product_Name__r.KeyProduct__c;                           		
                           					subChild.status = record.Status__c;
                           					subChild.quantity = q;
                                            //subChild.contact = record.Contact__c;
                                            
                                           	if(record.Contact__c != null){
                           						subChild.contactName = record.Contact__r.FirstName + ' ' + record.Contact__r.LastName;
                           						subChild.contactUrl = '/' + record.Contact__c;
                                			}    
  
											subChildrenToAdd.push(subChild);
                                            childToAdd._children = subChildrenToAdd;
                                            //console.log(childToAdd);    
                                            }
                                        }
                                        
                    				}
                    				else{
                        				productAdded[productId] = 1;
                                        if(record.Contact__c != null){    
                                           subChild.nodeName =  record.Product_Name__r.Name + ' (Contact)';
                                        }
                                        else{
                                           subChild.nodeName =  record.Product_Name__r.Name + ' (Account)';
                                        } 
                                        subChild.productName =  record.ProductName;
                           				subChild.productId = record.Id;
                                        subChild.nonErpId = record.Product_Name__r.Id;
                       					subChild.productUrl = prodUrl; 
                       					subChild.competitor = record.Product_Name__r.Competitor_Product__c;
					   					subChild.focusProduct = record.Product_Name__r.KeyProduct__c;                           		
                           				subChild.status = record.Status__c;
                           				subChild.quantity = q;
                                        
                                        if(record.Contact__c != null){
                           						subChild.contactName = record.Contact__r.FirstName + ' ' + record.Contact__r.LastName;
                           						subChild.contactUrl = '/' + record.Contact__c;
                                		}
                                
                                        subChildren.push(subChild);
                                        childToAdd._children = subChildren;
                                        childrenToAdd.push(childToAdd);
                    				}                                   
                                    
                                }
                        	}
                            //Handle records that do not have a category assigned
                           	else{
                                recordsWOCat.push(childToAdd);
                            }    
                       }
                                                                    
                   }
                   //Sort child records ascending 
                   this.sortTable(cmp, event, true, childrenToAdd, "nodeName");                    
                    
                   recordToAdd._children = childrenToAdd;
                         
                    //Add category and children as records
                    if(categories[catKey] != null){
                   		dataToAdd.push(recordToAdd); 
                   }    
                    
                }
                
                //Handle records that do not have a category assigned
                if(recordsWOCat.length > 0){
                    
                    var othersCat = {};
                    othersCat.nodeName = "Without Category";
                    othersCat.productUrl = "Others";
                    othersCat._children = recordsWOCat;
                    dataToAdd.push(othersCat);
                };
              
                data = dataToAdd;
                
                //Sort node records ascending 
                this.sortTable(cmp, event, true, data, "nodeName");               
               
                cmp.set('v.gridWrapperData', data);
                cmp.set('v.gridWrapperFilteredData', data);
                cmp.set('v.currentSelectedRows', []);                
                cmp.set('v.productProfilingData', productProfilingData);
           
               	//Expand all rows by default in the Desktop version
               	var formFactor = $A.get("$Browser.formFactor");
                
                if(formFactor == 'DESKTOP'){
                	var tree = cmp.find('mytree');
                    if(tree){
        				tree.expandAll();
                    }    
                }    
           	
            }else if(state === "ERROR"){
                alert('Problem with connection. Please try again.');
            }
        });
		$A.enqueueAction(action);
              
    },

        getRowActions: function (cmp, row, doneCallback) {
        var actions = [];
        if (row['productId']) {
 		{
            actions.push({
                'label': 'View',
                'iconName': 'utility:open',
                'name': 'view'
            });
            actions.push({
                'label': 'Edit',
                'iconName': 'utility:edit',
                'name': 'edit'
            });
            actions.push({
                'label':'Delete',
                'iconName':'utility:delete',
                'name':'delete'
            })
        }
        }    
        else{
            actions.push({
                'label': 'No action available',
                'iconName': 'utility:clear',
                'name': 'noAction'
            });
        }
        // simulate a trip to the server
        setTimeout($A.getCallback(function () {
            doneCallback(actions);
        }), 200);
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
    
    openProduct: function(cmp, event, recordId, action){
        var navService = cmp.find("navService");
		
        if(recordId != ''){
            
        var pageReference = {
            type: 'standard__recordPage',
            attributes: {
                recordId: recordId,
                objectApiName: 'Product_Profiling__c',
                actionName: action
            }
        };    
        event.preventDefault();
        navService.navigate(pageReference);
        }
        
    },

	deleteProduct: function(cmp, event, recordId, action, parentRecord){
        
        //console.log('Delete product ' + recordId);
        
       	var action = cmp.get("c.deleteProductProfilingRecord");
        	
        action.setParams({
           recordId : recordId
        });
        	
       	action.setCallback(this, function(response) {
         	var state = response.getState();
            
            if (state === "SUCCESS") {
                var result=response.getReturnValue();
                //console.log('Delete successful: ' + result);
                this.getProfilingHierarchy(cmp, event, parentRecord);
            }    
        });
        $A.enqueueAction(action);
 
    },
    
})