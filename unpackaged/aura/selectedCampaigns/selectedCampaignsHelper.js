({
    getCampaignList: function(component, event, helper) {
        var action = component.get('c.getCampaignDetails');
        // Set up the callback
        var self = this;
        action.setParams({
            accountId: component.get("v.recordId")
        })
        action.setCallback(this, function(actionResult) {
            component.set('v.campaigns', actionResult.getReturnValue());
            var campaigns1 = component.get('v.campaigns');
            component.get("v.campaigns").forEach(function(aa){
            	var conType = aa.Status;
           });       
        });
        var section1InputValue = component.get('v.displayedSection');
        var recID = component.get("v.recordId");
        $A.enqueueAction(action);
    },

    getPickValTyp: function(component, event, helper) {
        var p = [];
        var action = component.get('c.getPickValues_Typ');
        var self = this;
        action.setCallback(this, function(actionResult) {
            var state = actionResult.getError();
            p = actionResult.getReturnValue();
            var opts = [];
            for (var i = 0; i < p.length; i++) {
            	opts.push({
                    class: "optionClass",
                    label: p[i],
                    value: p[i]
                });
            }
            component.set("v.options2", opts);
        });
        $A.enqueueAction(action);
    },
    getPickValAct: function(component, event, helper) {
        var p = [];
        var action = component.get('c.getPickValues_Act');
        var self = this;
        action.setCallback(this, function(actionResult) {
            var state = actionResult.getError();
            p = actionResult.getReturnValue();
            var opts = [];
            for (var i = 0; i < p.length; i++) {
                opts.push({
                    class: "optionClass",
                    label: p[i],
                    value: p[i]
                });
            }
            component.set("v.options1", opts);
        });
        $A.enqueueAction(action);
    },
    
    getPickValStat: function(component, event, helper) {
        var p = [];
        var action = component.get('c.getPickValues_Stat');
        var self = this;
        action.setCallback(this, function(actionResult) {
            p = actionResult.getReturnValue();
            var opts = [];
            for (var i = 0; i < p.length; i++) {
                opts.push({
                    class: "optionClass",
                    label: p[i],
                    value: p[i]
                });
            }
            component.set("v.options3", opts);
        });
        $A.enqueueAction(action);
    },
    
    getshowNext1: function(component, event, selectedRecordsIds) {
		var arg = [];
        component.get("v.selectedCampaigns").forEach(function(selectedCampaign) {
           arg.push({
                'notes': selectedCampaign.Notes,
                'pick1': selectedCampaign.pick1,
                'pick2': selectedCampaign.pick2,
                'pick3': selectedCampaign.pick3,
                'campId': selectedCampaign.Id
            });
        });
        
        //getting the task information
        var task = component.get("v.task");
        var dueDate = component.get("v.task.ActivityDate");
        var subject = component.get("v.task.Subject");
        var reminderTime = component.get("v.task.ReminderDateTime");
        var today = new Date();
        var formatToday = $A.localizationService.formatDate(today, "yyyy MM dd, HH a");
        var formatDueDate = $A.localizationService.formatDate(dueDate, "yyyy MM dd, HH a");
        var formatReminderTime = $A.localizationService.formatDate(reminderTime, "yyyy MM dd, HH a");
        var formatToday_Date = $A.localizationService.formatDate(today, "yyyy MM dd");
        var formatDueDate_Date = $A.localizationService.formatDate(dueDate, "yyyy MM dd");
        var formatReminderTime_Date = $A.localizationService.formatDate(reminderTime, "yyyy MM dd");
        console.log('formatToday_Date-' + formatToday_Date);
        console.log('formatDueDate_Date-' + formatDueDate_Date);
        console.log('formatReminderTime_Date-' + formatReminderTime_Date);
        console.log('formatToday-' + formatToday);
        console.log('formatDueDate-' + formatDueDate);
        console.log('formatReminderTime-' + formatReminderTime);
        console.log('dueDate-' + dueDate);
        console.log('reminderTime-' + reminderTime);
        console.log('today-' + today);
        //Validation
        if (dueDate && subject && (formatDueDate_Date >= formatReminderTime_Date) && (formatDueDate_Date >= formatToday_Date) && (formatReminderTime >= formatToday)) {
		    //Calling the Apex Function
		    //method to create campaign task
		    var action1 = component.get("c.updateTask");
            action1.setParams({
                'data': JSON.stringify(arg),
                accountId: component.get("v.recordId")
            });
            action1.setCallback(this, function(result) {
            });
            $A.enqueueAction(action1);
            //method to create follow-up task
            var action = component.get("c.createTask");

            //Setting the Apex Parameter
            action.setParams({
                task: task,
                selectedRecordsIds: selectedRecordsIds,
                accountId: component.get("v.recordId")
            });

            //Setting the Callback
            action.setCallback(this, function(a) {
                //get the response state
                var state = a.getState();

                //check if result is successfull
                if (state == "SUCCESS") {
                    //Reset Form
                    var newTask = {
                        'sobjectType': 'Task',
                        'ActivityDate': '',
                        'IsReminderSet': '',
                        'Subject': '',
                        'Owner': '',
                        'Priority': '',
                        'Status': ''
                    };
                    //resetting the Values in the form
                    component.set("v.task", newTask);
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        message: 'Task(s) created',
                        duration: '3000',
                        type: 'success'
                    });
                    toastEvent.fire();
                   $A.get("e.force:refreshView").fire(); 
                }
                else if (state == "ERROR") {
                    //alert('Error in calling server side action');
                }
            });
		    component.set("v.childAttr", "Select Campaigns");
            component.set("v.displayedSection", "section1");
            var displaysection = component.get("v.displayedSection");
           //adds the server-side action to the queue  
            $A.enqueueAction(action);
            return;
        } else if (!dueDate || !subject) {
            alert('Due Date and Subject are Required');
        }
        else if (formatDueDate_Date < formatReminderTime_Date) {
            alert('Due Date must be greater than Reminder Time');
        }
        else if (formatDueDate_Date < formatToday_Date) {
            alert('Due Date must be greater than  or equal to Today');
        }
        else if (formatReminderTime < formatToday) {
            alert('Reminder Time must be greater than or equal to Today');
        }
    },

    getshowNext2: function(component, event, selectedRecordsIds) {
        var task = component.get("v.task");
        var arg = [];
        component.get("v.selectedCampaigns").forEach(function(selectedCampaign) {
           arg.push({
                'notes': selectedCampaign.Notes,
                'pick1': selectedCampaign.pick1,
                'pick2': selectedCampaign.pick2,
                'pick3': selectedCampaign.pick3,
                'campId': selectedCampaign.Id
            });
        });
        var action = component.get("c.updateTask");
        action.setParams({
            data: JSON.stringify(arg),
            accountId: component.get("v.recordId")
        });

        //Setting the Callback
        action.setCallback(this, function(a) {
            //get the response state
            var state = a.getState();

            //check if result is successfull
            if (state == "SUCCESS") {
                //Reset Form
                var newTask = {
                    'sobjectType': 'Task',
                    'ActivityDate': '',
                    'IsReminderSet': '',
                    'Subject': '',
                    'Owner': '',
                    'Priority': '',
                    'Status': ''
                };
                //resetting the Values in the form
                component.set("v.task", newTask);
                //alert('Record is Created Successfully');
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    message: 'Task(s) created',
                    duration: '3000',
                    type: 'success'
                });
                
                toastEvent.fire();
               $A.get("e.force:refreshView").fire();
            } else if (state == "ERROR") {
                //alert('Error in calling server side action');
            }
        });

        component.set("v.childAttr", "Select Campaigns");
        component.set("v.displayedSection", "section1");
        var displaysection = component.get("v.displayedSection");
        
        //adds the server-side action to the queue  
        $A.enqueueAction(action);
    },

    showSelectedCampaignsHelper: function(component, event, selectedRecordsIds) {
        //call apex class method
        var selectedRecordsIdsNew = component.get('v.selectedRecordsIds');
        var action = component.get('c.filterSelectedRecords');
       // pass the all selected record's Id's to apex method 
        action.setParams({
            "lstRecordId": selectedRecordsIds,
            accountId: component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
           component.set('v.selectedCampaigns', response.getReturnValue());
            var selectedCampaignsNew = component.get('v.selectedCampaigns');
           //store state of response
            var state = response.getState();
    	});
        $A.enqueueAction(action);
    },
})