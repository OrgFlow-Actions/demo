/**
 * Created by kdoruibin on 22/11/2019.
 */

({
    /**
     * This function parses the fieldMap provided by the user and sets the fields
     * to query and populate.
     * If no Record Type options are available, createRecord() will be called.
     * @param {*} component 
     * @param {*} event 
     * @param {*} helper 
     */
    setFields: function(component, event, helper) {
        var defaultFieldMapString = component.get("v.defaultFieldMapString"),
            fieldMapString = component.get("v.fieldMapString"),
            defaultFieldMap = this.setFieldMap(defaultFieldMapString),
            fieldMap = this.setFieldMap(fieldMapString), //JSON.parse(fieldMapString);
            recordTypeOptions = component.get("v.recordTypeOptions"),
            recordTypeLabel = component.get("v.recordTypeLabel");
        component.set("v.defaultFieldMap", defaultFieldMap);
        component.set("v.fieldMap", fieldMap);
        component.set("v.fieldsToCreate", Object.keys(fieldMap));
        component.find("recordLoader").reloadRecord(false, function() {
            if (recordTypeOptions.length === 0) {
                helper.createRecord(component, event, helper);
            } else if (recordTypeLabel) {
                recordTypeOptions.forEach(function(option) {
                    if (option.label === recordTypeLabel) {
                        helper.createRecord(component, event, helper, option.value)
                    }
                });
            } else {
                component.set("v.isLoaded", true);
            }
        });
    },

    /**
     * Navigates to the create new record screen by firing 'e:force:createRecord'.
     * The Record Type is determined by recordTypeId.
     * @param {*} component 
     * @param {*} event 
     * @param {*} helper 
     * @param {string} recordTypeId - The Record Type to create.
     */
    createRecord: function(component, event, helper, recordTypeId) {
        var defaultFieldMap = this.setDefaultFieldMap(component),
            objectToCreate = component.get("v.objectToCreate"),
            createRecordEvent = $A.get("e.force:createRecord");
        createRecordEvent.setParams({
            "entityApiName": objectToCreate,
            "recordTypeId": recordTypeId,
            "defaultFieldValues": defaultFieldMap
        });
        createRecordEvent.fire();
        setTimeout(function () {
            component.set("v.isCreateRecord", true);
        }, 1000);
        
        // var navigate = component.get('v.navigateFlow');
        // navigate('FINISH');
        // var dismissActionPanel = $A.get("e.force:closeQuickAction");
        // dismissActionPanel.fire();
    },

    /**
     * Parses fieldMap input from Flow and sets the default fields to be populated
     * when navigating to the create new record screen.
     * @param {*} component 
     */
    setDefaultFieldMap: function(component) {
        var defaultFieldMap = component.get("v.defaultFieldMap"),
            fieldMap = component.get("v.fieldMap"),
            parentObject = component.get("v.record"),
            getProperty = this.getProperty;
        console.log('parentObject::'+JSON.stringify(parentObject));
        // var defaultFieldMap = new Object();

        Object.keys(fieldMap).forEach(function (item) {
            console.log('item::' + item);
            console.log('fieldMapValue::' + fieldMap[item]);
            // TEST
            var parentFieldValue = getProperty(item, parentObject);
            
            if (parentFieldValue) {
                var fields = Array.isArray(fieldMap[item]) ? 
                    [fieldMap[item][0], fieldMap[item][1]] :
                    [' ', fieldMap[item]];
                    
                defaultFieldMap[fields[1]] = defaultFieldMap[fields[1]] ?
                    defaultFieldMap[fields[1]] + fields[0] + parentFieldValue :
                    parentFieldValue;
            }

            /* if (Array.isArray(fieldMap[item])) {
                if (getProperty(item, parentObject)) {
                    defaultFieldMap[fieldMap[item][1]] = defaultFieldMap[fieldMap[item][1]] ?
                        defaultFieldMap[fieldMap[item][1]] + fieldMap[item][0] + getProperty(item, parentObject) :
                        getProperty(item, parentObject);
                }
            } else {
                if (getProperty(item, parentObject)) {
                    defaultFieldMap[fieldMap[item]] = defaultFieldMap[fieldMap[item]] ?
                        defaultFieldMap[fieldMap[item]] + ' ' + getProperty(item, parentObject) :
                        getProperty(item, parentObject);
                }
            } */

            // Simpler implementation that does not check if parent field is undefined
            //     /* defaultFieldMap[fieldMap[item]] = defaultFieldMap[fieldMap[item]] ? 
            //         defaultFieldMap[fieldMap[item]] + ', ' + parentObject[item] : 
            //         parentObject[item]; */
        });

        return defaultFieldMap;
    },

    /**
     * Get nested object properties with a dot-notated string.
     * @param {string} propertyName - The dot-notated string.
     * @param {Object} object - The object to search.
     */
    getProperty: function(propertyName, object) {
        var parts = propertyName.split("."),
            length = parts.length,
            property = object || this;

        for (var i = 0; i < length; i++) {
            property = property[parts[i]];
        }

        return property;
    },

    /**
     * Check if the input string starts and ends with curly brackets
     * Append appropriate curly bracket if it doesn't.
     * @param {string} fieldMapString 
     */
    setFieldMap: function (fieldMapString) {
        if (!/^{/.test(fieldMapString)) fieldMapString = '{' + fieldMapString;
        if (!/}$/.test(fieldMapString)) fieldMapString = fieldMapString + '}';
        var fieldMap = JSON.parse(fieldMapString);
        return fieldMap;
    },
});