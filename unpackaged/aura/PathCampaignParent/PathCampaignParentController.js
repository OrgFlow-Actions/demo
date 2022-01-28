({
	navigate2PathCampaign : function(component, event, helper) { 
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef : "c:PathCampaign",
            componentAttributes: {
            recordId : component.get("v.recordId")
        }
        });
        evt.fire();
    },
    
    foo: function(cmp, evt, helper) {
        cmp.find("nav").navigate({
            type: "standard__component",
            attributes: {
                componentName: "c__PathCampaign"

            },
            state: {
                recordId: cmp.get("v.recordId")
            }
        });
    },
    
    openTab : function(component, event, helper) {
    var workspaceAPI = component.find("workspace");
        workspaceAPI.openTab({
            pageReference: {
                "type": "standard__component",
                "attributes": {
                    "componentName": "c__PathCampaign"  // c__<comp Name>
                },
                "state": {
                    recordId: component.get("v.recordId")
                }
            },
            focus: true
        }).then((response) => {
               workspaceAPI.setTabLabel({
                  tabId: response,
                  label: "Campaign Tracker"
               });
        }).catch(function(error) {
            console.log(error);
        });
},
    
    
    getEnclosingTabId : function(component, event, helper) {
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getEnclosingTabId().then(function(tabId) {
            console.log(tabId);
       })
        .catch(function(error) {
            console.log(error);
        });
    },

    
    setFocusedTabLabel : function(component, event, helper) {
        var workspaceAPI = component.find("workspace");
    workspaceAPI.getFocusedTabInfo().then(function(response) {
        console.log('response: ' + JSON.stringify(response));
        var focusedTabId = response.subtabs[0].tabId;
        console.log('focusTabId@123'+focusTabId);
        workspaceAPI.setTabLabel({
            tabId: focusedTabId,
            label: "Focused Tab"
        });
        workspaceAPI.setTabIcon({
            tabId: focusedTabId,
            icon: "standard:timesheet",
            iconAlt: "Focused Tab"
        });
    })
    .catch(function(error) {
        console.log(error);
    });
        
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef : "c:PathCampaign",
            componentAttributes: {
            recordId : component.get("v.recordId")
        }
        });
        evt.fire();
        
    },
    
    focusNewTab : function(component, event, helper) {
        var workspaceAPI = component.find("workspace");
        var currentTabId = event.getParam('currentTabId');
        console.log('currentTabId@123'+currentTabId);
        var previousTabId = event.getParam('previousTabId');
        console.log('previousTabId@123'+previousTabId);
        workspaceAPI.openTab({
            url: 'https://dentsplysirona--magnet2.lightning.force.com/lightning/r/Contact/0030D000007OO8MQAW/view?0.source=alohaHeader',
            label: 'Global Media'
        }).then(function(response) {
            workspaceAPI.focusTab({tabId : response});
       })
        .catch(function(error) {
            console.log(error);
        });
    }

    
})