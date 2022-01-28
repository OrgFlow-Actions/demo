({
    handleSubmit: function(component, event, helper) {
        
        var accntId = component.get("v.recordId");
        var action = component.get("c.getAccountDetails");
        action.setParams({
            accountid: accntId
        });
        action.setCallback(this, function(response) {
            if (response.getState() === "SUCCESS") {
                component.set("v.ac", response.getReturnValue());
                console.log(response.getReturnValue());
            }
        });
        
        var createRecordEvent = $A.get("e.force:createRecord");
        createRecordEvent.setParams({
            "entityApiName": "Account_Create_Change_Request__c",
                "defaultFieldValues": {
                    'Account_Name__c': component.get("v.ac.Name"),
                    'Status__c' : 'Created',
                }
        });
        createRecordEvent.fire();
        
    }
})