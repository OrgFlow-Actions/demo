({
	
    //Initialize function where we populate most tables and picklists
    init: function(cmp, event, helper) {
        
        //Action to load records of Team_setup__mdt
        var action = cmp.get("c.loadRelatedRecord");
        action.setParams({ fullName : "Team_setup.SE1", fields : "DeveloperName, Label, Country__c, SBU__c, Description__c, Status__c"});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();                
                cmp.set('v.Team', result[0]);
                cmp.set('v.Teams', result);
 				             
            } else {
                var errors = response.getError();
                var errorMessage = null;
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        errorMessage = errors[0].message;
                    }
                } else {
                    errorMessage = "Unknown error";
                }                          
            }            
        });
        $A.enqueueAction(action);
        
        //Action to load records of Lightning_component__mdt
        var action2 = cmp.get("c.loadRelatedRecord");
        action2.setParams({ fullName : "Lightning_Component.", fields : "DeveloperName, Label, Description__c, Category__c, Managed_by__c, Status__c"});
        action2.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();                
                cmp.set('v.Cmp', result[0]);
                cmp.set('v.Cmps', result);
 				             
            } else {
                var errors = response.getError();
                var errorMessage = null;
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        errorMessage = errors[0].message;
                    }
                } else {
                    errorMessage = "Unknown error";
                }                          
            }            
        });
        $A.enqueueAction(action2);
        
        //Action to load available picklist values for the field Country__c on Team_setup__mdt
        var action3 = cmp.get("c.getPickListValuesIntoList");
        action3.setParams({CmpName : 'Team_setup__mdt', fldName : 'Country__c'});
        action3.setCallback(this, function(response) {
        cmp.set('v.CmpCountries', response.getReturnValue());   
        });    
        $A.enqueueAction(action3);
        
        cmp.set('v.columns', [
            {label: 'Country', fieldName: 'Country__c', type: 'text', sortable:true},
        	{label: 'SBU', fieldName: 'SBU__c', type: 'text', sortable:true},
            {label: 'Component', fieldName: 'Component__c', type: 'text', sortable:true},
            {label: 'Visible?', fieldName: 'Visible__c', type: 'boolean'},
        ]);
                    
        //Action to load list of available users in the system    
        var action4 = cmp.get("c.getUserList");
            action4.setParams({searchStr : '*', Country:''});
            action4.setCallback(this, function(response) {
            cmp.set('v.UserList', response.getReturnValue())           
            });    
        $A.enqueueAction(action4);
        
        //Action to load available values in the User_Country__c picklist field on the User object    
        var action5 = cmp.get("c.getPickListValuesIntoList");
        action5.setParams({CmpName : 'User', fldName : 'User_Country__c'});
        action5.setCallback(this, function(response) {
        cmp.set('v.UserCountries', response.getReturnValue());        
        });    
        $A.enqueueAction(action5);  
            
        var action6 = cmp.get("c.getPickListValuesIntoList");
        action6.setParams({CmpName : 'Lightning_component__mdt', fldName : 'Status__c'});
        action6.setCallback(this, function(response) {
        cmp.set('v.StatusPicklist', response.getReturnValue());        
        });    
        $A.enqueueAction(action6);
                               
        cmp.set('v.columns', [
            { label: 'FirstName', fieldName: 'FirstName', type: 'text' },
            { label: 'LastName', fieldName: 'LastName', type: 'text' },
            { label: 'Profile', fieldName: 'Profile__c', type: 'text' },
            { label: 'Team', fieldName: 'Team_Setup_Id__c', type: 'text' }
            //{ type: 'action', typeAttributes: { rowActions: actions } }
        ]);    
            
    },

    
    //Function to handle updates of Country_metadata__mdt records
    handleCountrySave : function(component, event, helper) {
	    
        component.find('saveButton').set('v.disabled', true);
        component.find('recordData').saveRecord();
        
	},
    
    //Function to handle results after updating Country_metadata__mdt      
	handleSaveResult : function(component, event, helper) {
        
        var changeType = event.getParam('changeType');
        var result = event.getParam("result");
		var results = event.getParam("results");
 
        if(changeType == 'CHANGED') {
            alert("Components where updated");	
            component.set('v.errors', null);
            component.find('saveButton').set('v.disabled', false);
        } else if(changeType == 'ERROR') {
            component.set('v.errors', result.fullName ? result.message : result);
        } else if(changeType == 'LOADED') {
            component.set('v.errors', null);
        }
        
        var picklistVal = event.getParam("picklistVal");
        component.set('v.picklistVal', picklistVal);
        component.set('v.records', component.find('recordData').get('v.targetRecords'));
        
        //Function to check the user's current app
        /*var action7 = component.get("c.getCurrentApplication");
        action7.setCallback(this, function(response){
        alert(response.getReturnValue());           
    	});        
    	$A.enqueueAction(action7);*/
                
	},
   
   //Function to save new records of Lightning_Component__mdt 
   handleCmpSave : function(component, event, helper) {
	    
        component.find('saveCmp').set('v.disabled', true);
        component.set('v.NewCmp.Label', component.find('NewCompName').get("v.value"));
        component.set('v.NewCmp.DeveloperName', component.find('NewCompName').get("v.value"));
        component.set('v.NewCmp.Description__c', component.find('NewCompDescr').get("v.value"));
        component.set('v.NewCmp.Managed_by__c', component.find('NewCompManage').get("v.value"));
        component.set('v.NewCmp.Status__c', component.find('NewCompStatus').get("v.value"));
       
       	var action = component.get("c.upsertCmp");
       	action.setParams({ record : component.find('NewCompName').get("v.value") });
      	action.setCallback(this, function(response) {
            var state = response.getState();
            
            if (state === "SUCCESS") {
                component.set('v.deploymentId', response.getReturnValue());
            } else {
                var errors = response.getError();
                var errorMessage = null;
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        errorMessage = errors[0].message;
                    }
                } else {
                    errorMessage = "Unknown error";
                }              
            }        
        });
        $A.enqueueAction(action);
    
       	var inputs = component.get('v.Teams');
        
       	for (var i = 0; i < inputs.length; i++) {
				       
        component.set('v.NewCountryRecord.LightningComponent__r.Label', component.find('NewCompName').get("v.value"));
        component.set('v.NewCountryRecord.Team_setup__r.Label', inputs[i].Label);
        component.set('v.NewCountryRecord.Visible__c', inputs[i].Visible__c);
        component.set('v.NewCountryRecord.DeveloperName',  inputs[i].Label + '_'+ component.find('NewCompName').get("v.value"));
        component.set('v.NewCountryRecord.Label', inputs[i].Label + '_'+ component.find('NewCompName').get("v.value") );
             	
        }
        component.find('NewCountryRecordData').saveRecord(); 
       
        component.find('saveCmp').set('v.disabled', false);
        $A.get('e.force:refreshView').fire();
	},

   //Function to handle updates of existing records of Lightning_Component__mdt     
    handleCmpUpdate : function(component, event, helper) {
	    component.set('v.SelectedCmp', component.find('UpdateCmp').get("v.value"));
		component.set('v.SelectedCmp.Country__c', component.get('v.SelectedCmpCountry'));
		component.set('v.SelectedCmp.Description__c', component.get('v.SelectedCmpDescr'));
		component.set('v.SelectedCmp.Status__c', component.get('v.SelectedCmpStatus'));
        
       	var action = component.get("c.upsertCmp");
        action.setParams({ record : component.get('v.SelectedCmp'), Descr: component.get('v.SelectedCmpDescr'), Status: component.get('v.SelectedCmpStatus'), Manager: component.get('v.SelectedCmpManage') });
      	action.setCallback(this, function(response) {
            var state = response.getState();
            
            if (state === "SUCCESS") {
                component.set('v.deploymentId', response.getReturnValue());
                alert('Component ' + component.get('v.SelectedCmp') + ' has been updated');
            } else {
                var errors = response.getError();
                var errorMessage = null;
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        errorMessage = errors[0].message;
                    }
                } else {
                    errorMessage = "Unknown error";
                }              
            }        
        });
        $A.enqueueAction(action);

    },

   //Function to save new records of Team_Setup__mdt     
    
    handleTeamSave : function(component, event, helper) {
	    
        component.find('saveTeam').set('v.disabled', true);
        component.set('v.NewTeam.Label', component.find('NewTeamName').get("v.value"));
        component.set('v.NewTeam.DeveloperName', component.find('NewTeamName').get("v.value"));
		component.set('v.NewTeam.Country__c', component.find('NewTeamCountry').get("v.value"));
		component.set('v.NewTeam.Status__c', component.find('NewTeamStatus').get("v.value"));       
        
       	var action = component.get("c.upsertTeam");
        action.setParams({ record : component.find('NewTeamName').get("v.value"), Country : component.find('NewTeamCountry').get("v.value"), Status : component.find('NewTeamStatus').get("v.value")});
      	action.setCallback(this, function(response) {
            var state = response.getState();
            
            if (state === "SUCCESS") {
                alert('Team ' + component.get('v.NewTeam.DeveloperName') + ' has been created');
                component.set('v.deploymentId', response.getReturnValue());
            } else {
                var errors = response.getError();
                var errorMessage = null;
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        errorMessage = errors[0].message;
                    }
                } else {
                    errorMessage = "Unknown error";
                }              
            }        
        });
        $A.enqueueAction(action);
    	
       	var inputs = component.get('v.Cmps');
        alert(inputs.length);
       	for (var i = 0; i < inputs.length; i++) {
				       
        component.set('v.NewCountryRecord.LightningComponent__r.Label', inputs[i].Label);
        component.set('v.NewCountryRecord.Team_setup__r.Label', component.find('NewTeamName').get("v.value"));
        component.set('v.NewCountryRecord.Visible__c', inputs[i].Visible__c);
        component.set('v.NewCountryRecord.DeveloperName',  component.find('NewTeamName').get("v.value") + '_'+ inputs[i].Label);
        component.set('v.NewCountryRecord.Label', component.find('NewTeamName').get("v.value") + '_'+ inputs[i].Label);
        component.find('NewCountryRecordData').saveRecord();
        }
        
        
        component.find('saveTeam').set('v.disabled', false);
        //$A.get('e.force:refreshView').fire();
	},
    
   //Function to handle updates of existing records of Team_Setup__mdt     
    
        handleTeamUpdate : function(component, event, helper) {
	    
		component.set('v.SelectedTeam.Country__c', component.get('v.SelectedTeamCountry'));
		component.set('v.SelectedTeam.Description__c', component.get('v.SelectedTeamDescr'));
		component.set('v.SelectedTeam.Status__c', component.get('v.SelectedTeamStatus'));
        
       	var action = component.get("c.upsertTeam");
        action.setParams({ record : component.get('v.SelectedTeam.DeveloperName'), Country : component.get('v.SelectedTeam.Country__c'), Descr: component.get('v.SelectedTeam.Description__c'), Status:component.get('v.SelectedTeam.Status__c') });
      	action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                alert('Team ' + component.get('v.SelectedTeam.DeveloperName') + ' has been updated');
                component.set('v.deploymentId', response.getReturnValue());
            } else {
                var errors = response.getError();
                var errorMessage = null;
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        errorMessage = errors[0].message;
                    }
                } else {
                    errorMessage = "Unknown error";
                }              
            }        
        });
        $A.enqueueAction(action);

    },
         
    fetchPicklistVal: function(component, event, helper) {        
    component.find('recordData').fetchPickValues();    
    var appEvent = component.find('recordEvent');          
	component.set('v.picklistVal', component.find('recordData').get('v.picklistVal'));                    
    },
                
    updateColumnSorting: function (cmp, event, helper) {
        var fieldName = event.getParam('fieldName');
        var sortDirection = event.getParam('sortDirection');
        cmp.set("v.sortedBy", fieldName);
        cmp.set("v.sortedDirection", sortDirection);
        helper.sortData(cmp, fieldName, sortDirection);
    },
    
    //Function to handle filtering based on Component and Country in the Overview tab    
    
    onCountryFilterChange: function(cmp, event, helper) {
    var Country = cmp.find('SelCountry').get("v.value");
    var Comp = cmp.find('SelCmp').get("v.value");
    cmp.set('v.CountryFilter', Country);
    cmp.set('v.CmpFilter', Comp);        
	            
    },
    
    //Function to handle filtering based on Team and Country in the User tab
    
    onUserFilterChange: function(cmp, event, helper) {
    var Country = cmp.find('FilterUserCountry').get("v.value");
    cmp.set('v.UserCountryFilter', Country);
    
    var Team = cmp.find('FilterUserTeam').get("v.value");
    cmp.set('v.UserTeamFilter', Team);
            
    var queryTerm = cmp.find('enter-search').get('v.value');
            
    var action = cmp.get("c.getUserList");
        action.setParams({searchStr : queryTerm, Country: cmp.get('v.UserCountryFilter'), Team: Team});
        action.setCallback(this, function(response) {
    	cmp.set('v.UserList', response.getReturnValue())           
           });    
    $A.enqueueAction(action);
                      
    },
    
    //Function to filter shown record of Team_setup__mdt in the Team -> Edit tab
    
    onTeamSelect: function(cmp, event, helper){
    var selectTeam = cmp.find("UpdateTeam").get("v.value");    
	var selectedTeams = cmp.get("v.Teams");
    
            for(var i=0; i<selectedTeams.length; i++) {
            	if(selectedTeams[i].DeveloperName == selectTeam) {
            		cmp.set('v.SelectedTeam', selectedTeams[i]);
        		}            
            }
              
	cmp.set('v.SelectedTeamCountry', cmp.get("v.SelectedTeam.Country__c"));    
    cmp.set('v.SelectedTeamStatus', cmp.get("v.SelectedTeam.Status__c"));
    if(cmp.get("v.SelectedTeam.Description__c")!=null){
    cmp.set('v.SelectedTeamDescr', cmp.get("v.SelectedTeam.Description__c"));
	}
 	else{
 	cmp.set('v.SelectedTeamDescr',"");
 	}
    
    },
    
    //Function to filter shown record of Lightning_Component__mdt in the Component Edit tab
    onCmpSelect: function(cmp, event, helper){
    var selectCmp = cmp.find("UpdateCmp").get("v.value");    
	var selectedCmps = cmp.get("v.Cmps");
    
    for(var i=0; i<selectedCmps.length; i++) {
            	if(selectedCmps[i].DeveloperName == selectCmp) {
            		cmp.set('v.SelectedCmp', selectedCmps[i]);
        		}            
            }
              
    if(cmp.get("v.SelectedCmp.Description__c")!=null){	        
    cmp.set('v.SelectedCmpDescr', cmp.get("v.SelectedCmp.Description__c"));
	}
 	else{
 	cmp.set('v.SelectedCmpDescr',"");
 	}
        
    if(cmp.get("v.SelectedCmp.Managed_by__c")!=null){	        
    cmp.set('v.SelectedCmpManage', cmp.get("v.SelectedCmp.Managed_by__c"));
	}
 	else{
 	cmp.set('v.SelectedCmpManage',"");
 	}    
        
    cmp.set('v.SelectedCmpStatus', cmp.get("v.SelectedCmp.Status__c"));
        
    },
    
    //Function to handle search functionality in the User tab
    //When the user presses Enter after having written something in the search field,
    //this function initializes the search and updates the table of users
    handleKeyUp: function (cmp, evt) {
        var isEnterKey = evt.keyCode === 13;
        if (isEnterKey) {
            var queryTerm = cmp.find('enter-search').get('v.value');
            
            	        var action = cmp.get("c.getUserList");
            			action.setParams({searchStr : queryTerm, Country: cmp.get('v.UserCountryFilter'), Team: cmp.get('v.UserTeamFilter')});
            			action.setCallback(this, function(response) {
            			cmp.set('v.UserList', response.getReturnValue())           
            			});    
        				$A.enqueueAction(action);
            
        }
    },
    
    
    //Function to handle modifications to which team that a user belongs to
    //This function is collecting information from the event LightningCompSetupEv, 
    //that in turn is connected to the component TeamForce_ComponentConfig_UserRow
    onUserUpdate: function(cmp,evt){
        
    	var Team2Upd = evt.getParam("SelTeam");
        var index = evt.getParam("indexVar");
        var UserList = cmp.get("v.UserList");
        var User = UserList[index];
		        
		var action = cmp.get("c.updateUser");
        action.setParams({Usr2Upd: User, Team2Upd: Team2Upd});
        action.setCallback(this, function(response) {          
        })        
        $A.enqueueAction(action);
		
	}
  
})