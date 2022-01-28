({

    	getContactData : function(component, event) {

        var action = component.get("c.getTeamSetup");
            
        action.setCallback(this, function(data){
                   component.set('v.TeamSetup', data.getReturnValue());            
        });    
            
        $A.enqueueAction(action);
            
       var action2 = component.get("c.getUserInfo");
        
        action2.setParams({
    		recordId: component.get('v.recordId')
		});    
                        
        action2.setCallback(this, function(data) {
            component.set('v.UserToEdit', data.getReturnValue());
		});
		$A.enqueueAction(action2);     
                                  
        var action3 = component.get("c.getUserAccess");
        
        action3.setParams({
    		ComponentName: "Account_Strategy_Summary"
		});    
                        
        action3.setCallback(this, function(data) {
            component.set('v.isVisible', data.getReturnValue());
		});
		$A.enqueueAction(action3);
            
        var action4 = component.get("c.getUserSBUAccess");
        
        action4.setParams({
    		ComponentName: "Account_Strategy_Summary"
		});    
                        
        action4.setCallback(this, function(data) {
            component.set('v.ThisUser', data.getReturnValue());
		});
		$A.enqueueAction(action4);    
            
	},
        
        changeEditLayout : function(component, event, helper) {
        component.set("v.isEditPage", true);
        helper.removeDivider();
      
 
    },
    
        clickCancel : function(component, event, helper) {
        component.set("v.isEditPage", false);
    	helper.addDivider();
        helper.addEditIcon();
        $A.get('e.force:refreshView').fire();
 },
    
        clickSave : function(component, event, helper) {    	
                        
        var action = component.get("c.saveAccount"); 
            
        action.setParams({
    		recordId: component.get('v.recordId')           
		});  
           
        action.setCallback(this, function(response) {
    	var state = response.getState(); 
           if (state === "SUCCESS") {
            var results = response.getReturnValue();
            component.set("v.isEditPage", false);   
        } else {
            
        }
		});
        
        $A.enqueueAction(action);
            
        component.set("v.isEditPage", false);    
        //helper.addDivider();
        //helper.addEditIcon();
       
 },

    changeState : function changeState (component){ 
    component.set('v.isexpanded',!component.get('v.isexpanded'));
 	},

	onRadio: function(cmp, evt) {
		var selected = evt.getSource().get("v.label"); 
       	cmp.set('v.UserToEdit.Team_Setup_ID__c', selected);
        
        var action = cmp.get("c.saveUser");
        
        action.setParams({
            ThisUser : cmp.get('v.UserToEdit'),
        });
        
        action.setCallback(this, function(data) {
                      
        });
        
        $A.enqueueAction(action);
        
        //cmp.find("radioResult").set("v.value", selected);
        $A.get('e.force:refreshView').fire();
	 },    
    
})