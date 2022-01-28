({
    getPreferredDealer :function (component,event,helper){
        var action = component.get("c.getAllPdeList");
        action.setStorable();
        action.setParams({
            'orderId':component.get("v.recordId")
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();	
                component.set("v.distributors",storeResponse);
            }
        });
        // enqueue the Action  
        $A.enqueueAction(action);
    },
    checkDealerPerm :function (component,event,helper){
        var action = component.get('c.CheckPermission');
        action.setStorable();
        action.setCallback(this, function(response){
            var result = response.getReturnValue();
            var state = response.getState();
            if (state === 'SUCCESS') {                
                component.set("v.showPage",result);
            }
            else {
                var errors = response.getError();
            }
        });
        $A.enqueueAction(action);
    },
    searchHelper : function(component,event,getInputkeyWord) {
        // call the apex class method 
        var pageNumber = component.get("v.PageNumber"); 
        var aaa=component.find("pageSize");
        if(component.find("pageSize")!=undefined){
            var pageSize = component.find("pageSize").get("v.value");
        }
        if(pageSize==undefined){
            pageSize=4;
        }
        var action = component.get("c.fetchLookUpValues");
        // set param to method  
        action.setParams({
            'searchKeyWord': getInputkeyWord,
            'pageNumber' :component.get("v.PageNumber"),
            'pageSize' :pageSize,
            'orderId':component.get("v.recordId")
        });
        // set a callBack    
        action.setCallback(this, function(response) {
            $A.util.removeClass(component.find("mySpinner"), "slds-show");
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                console.log(storeResponse.accountList.length);
                // if storeResponse size is equal 0 ,display No Records Found... message on screen.                }
                if (storeResponse.accountList.length == 0) {
                    component.set("v.Message", 'No Records Found...');
                } else {
                    component.set("v.Message", '');
                    // set searchResult list with return value from server.
                }
                component.set("v.listOfSearchRecords", storeResponse.accountList); 
                //component.set("v.ContactList", resultData.contactList);
                component.set("v.PageNumber", storeResponse.pageNumber);
                component.set("v.TotalRecords", storeResponse.totalRecords);
                component.set("v.RecordStart", storeResponse.recordStart);
                component.set("v.RecordEnd", storeResponse.recordEnd);
                component.set("v.TotalPages", Math.ceil(storeResponse.totalRecords / pageSize));
            }
        });
        // enqueue the Action  
        $A.enqueueAction(action);
    },
    getParameterByName: function(component, event, name) {
        name = name.replace(/[\[\]]/g, "\\$&");
        var url = window.location.href;
        var regex = new RegExp("[?&]" + name + "(=([^&#]*)|&|#|$)");
        var results = regex.exec(url);
        if (!results) return null;
        if (!results[2]) return '';
        return decodeURIComponent(results[2].replace(/\+/g, " "));
    },
    updateOrderInfo : function(component, event, name, OrderRecord){
        //updateDealer(Id dealerId,Id orderId)
        var orderRec = component.get("v.order");
        console.log('inside of select dealer helper ----');
        
        var action = component.get("c.updateDealerInfo");
        action.setParams({
            'orderId':component.get("v.recordId"),
            'dealerId':component.get("v.dealerId"),
            'orderRec':OrderRecord
        });
        action.setCallback(this, function(response){
            console.log('inside update order callback---------');
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log('inside success-----');
                // var storeResponse = response.getReturnValue();	
                var evt =  $A.get("e.force:navigateToURL"); 
                evt.setParams({
                    "url" : "/" + component.get("v.recordId")
                });
                evt.fire();
                // 
                var navEvt = $A.get("e.force:navigateToSObject");
                navEvt.setParams({
                    "recordId": component.get("v.recordId")
                    //"slideDevName": "Detail"
                });
                navEvt.fire();
            }
            else if(state === "ERROR"){
                console.log('inside error callback-----');
            }
        });
        // enqueue the Action  
       window.setTimeout(
		  $A.enqueueAction(action), 5000
	   );
     },
     getOrderToUpdate: function(component){
     var action=component.get("c.Initialize");
     var recId = component.get("v.recordId");
	 action.setParams({
            recordId:recId             
     });
     action.setCallback(this, function(data){
           console.log('initialize order call back---'+data.getReturnValue());
           component.set("v.order", data.getReturnValue());
         var orderrec = data.getReturnValue();
      });
     $A.enqueueAction(action);
    }
})