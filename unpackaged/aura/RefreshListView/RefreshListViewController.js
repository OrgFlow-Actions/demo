({
    // toggleAutoRefresh triggers upon button click
    toggleAutoRefresh: function(component, event, helper) {
        let refreshing = component.get('v.refreshing');
        // Save button state in sessionStorage
        window.sessionStorage.setItem('refreshIndicator', refreshing);
        
        if (!refreshing) { // check if the button is turned-on
			var refreshAction = component.get('c.doRefresh');
            $A.enqueueAction(refreshAction);
            window.sessionStorage.setItem('refreshIndicator', true);
        } else { // check if the button is turned-off
            var noRefreshAction = component.get('c.noRefresh');
            $A.enqueueAction(noRefreshAction);
            window.sessionStorage.setItem('refreshIndicator', false);
            window.sessionStorage.removeItem('refreshIndicator');
        }
    },
		// works on Page load
    doInit: function(component, event, helper) {
        var action = component.get("c.getUserPermission");
        var indicator = window.sessionStorage.getItem('refreshIndicator');
        
        action.setCallback(this, function(response){
            var state = response.getState();
            console.log ('State is '+ state);
            var permission = response.getReturnValue();
     		console.log('User permssions in JS'+ permission);
            if(state == 'SUCCESS' && permission == true) {
              	  var refresh = component.get('c.doRefresh');
           		  $A.enqueueAction(refresh);
           		  window.sessionStorage.setItem('refreshIndicator', true);   
                
            }
        });
        $A.enqueueAction(action);
        
        if (!indicator) { // If the button is turned-off
			var noRefreshAction = component.get('c.noRefresh');
            $A.enqueueAction(noRefreshAction);

        } else { // If the button is turned-on
            var refreshAction = component.get('c.doRefresh');
            $A.enqueueAction(refreshAction);

        }
    },
		// Refresh list view every 60 seconds if the button is turned-on
    doRefresh: function(component,event,helper) {
        const refreshInterval = component.get('v.refreshInterval');
        const intervalId = window.setInterval(() => {
            helper.refreshListView(component);
        }, refreshInterval * 1000);
         component.set('v.intervalId', intervalId);
         component.set('v.refreshing', true);
    },
            
    noRefresh: function(component,event,helper){
         const intervalId = component.get('v.intervalId');
         window.clearInterval(intervalId);
         component.set('v.intervalId', null);
         component.set('v.refreshing', false);
            }


})