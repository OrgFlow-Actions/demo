/**
 * Created by kdoruibin on 22/11/2019.
 */

({
    /**
     * On Init, this function calls the apex controller method
     * which returns the available Record Types of the source object
     * and set it to the RecordTypeList attribute to display record Type values.
     * This also sets the fields passed in by the user that force:recordData should load.
     * 
     * If only one Record Type is available or if a Record Type is provided from the flow,
     * The user will be navigated to the record create screen immediately.
     * @param {*} component 
     * @param {*} event 
     * @param {*} helper 
     */
    onInit: function(component, event, helper) {
        var isPhone = $A.get("$Browser.formFactor") === "DESKTOP" ? false : true,
            objectToCreate = component.get("v.objectToCreate"),
            action = component.get("c.fetchRecordTypeValues");
        console.log('isPhone::'+isPhone);
        component.set("v.isPhone", isPhone);
        action.setParams({
            "objectToCreate": objectToCreate
        });
        action.setCallback(this, function(response) {
            var recordTypeOptions = JSON.parse(response.getReturnValue());
            component.set("v.recordTypeOptions", recordTypeOptions);
            component.set("v.recordTypeDefaultOption", recordTypeOptions[0].value);
            // component.find("rtSelectId").set("v.value", recordTypeOptions[0].value);
            // component.find("rtSelectId").set("v.disabled", false);
            helper.setFields(component, event, helper);
        });
        $A.enqueueAction(action);
    },

   /**
     * This method is called when the user has selected a Record Type and clicks on next.
     * createRecord() is called with the selected Record Type.
     * @param {*} component 
     * @param {*} event 
     * @param {*} helper 
     */
    handleDesktopCreateRecord: function (component, event, helper) {
        var recordTypeId = component.find("rtSelectId").get("v.value");
        helper.createRecord(component, event, helper, recordTypeId);
    },

    /**
     * Event handler for mobile Record Type selection.
     * @param {*} component 
     * @param {*} event 
     * @param {*} helper 
     */
    handleMobileCreateRecord: function(component, event, helper) {
        var recordTypeId = event.target.value;
        helper.createRecord(component, event, helper, recordTypeId)
    },

    toastInfo: function(component, event, helper) {
        alert("Toast detected: "+event.getParams().message);
    }
})