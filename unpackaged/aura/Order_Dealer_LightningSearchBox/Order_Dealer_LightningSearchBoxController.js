({
    doInit : function(component,event,helper){
        helper.checkDealerPerm(component,event,helper);
        console.log('record Id '+component.get("v.recordId"));
        var id=helper.getParameterByName(component, event, 'id');
        if(id==null){
            var url = window.location.href;
            var strList=url.split('Order/');
            id= strList[1].split('/view')[0];
        }
        component.set("v.recordId",id);
        helper.getPreferredDealer(component,event,helper);
        helper.getOrderToUpdate(component);
    },
     showSpinner: function(component,event,helper){
     component.set("v.showSpinner",true);   
    },
    hideSpinner: function(component,event,helper){
        component.set("v.showSpinner",false);
    },
    
    selectedDealer : function(component,event,helper){
        var target = event.getSource(); 
        var txtVal = target.get("v.value") ;
        component.set("v.dealerId",txtVal);
    },
    SaveDealerInfo : function(component,event,helper){
       // helper.updateOrderInfo(component,event,helper,component.get("v.order"));
        var orderRec = component.get("v.order");
        console.log('inside of select dealer controller ----');
        
        var action = component.get("c.updateDealerInfo");
        action.setParams({
            'dealerId':component.get("v.dealerId"),
            'orderRec':orderRec
        });
        action.setCallback(this, function(response){
            console.log('inside update order callback---------');
            var state = response.getState();
            if (state === "SUCCESS") {
                // var storeResponse = response.getReturnValue();	
                var evt =  $A.get("e.force:navigateToURL"); 
                evt.setParams({
                    "url" : "/" + component.get("v.recordId")
                });
                evt.fire();
                $A.get("e.force:refreshView").fire();
            }
            else if(state === "ERROR"){
                console.log('inside error callback-----');
            }
        });
        // enqueue the Action  
       	  $A.enqueueAction(action);
    },
    onblur : function(component,event,helper){
        // on mouse leave clear the listOfSeachRecords & hide the search result component 
        component.set("v.listOfSearchRecords", null );
        component.set("v.SearchKeyWord", '');
        component.set("v.PageNumber",1);
        var forclose = component.find("searchRes");
        $A.util.addClass(forclose, 'slds-is-close');
        $A.util.removeClass(forclose, 'slds-is-open');
    },
    onfocus : function(component,event, helper){
        // show the spinner,show child search result component and call helper function
        $A.util.addClass(component.find("mySpinner"), "slds-show");
        component.set("v.listOfSearchRecords", null ); 
        component.set("v.PageNumber",1);
        var forOpen = component.find("searchRes");
        $A.util.addClass(forOpen, 'slds-is-open');
        $A.util.removeClass(forOpen, 'slds-is-close');
        // Get Default 5 Records order by createdDate DESC 
        var getInputkeyWord = '';
        //helper.searchHelper(component,event,getInputkeyWord);
    },
    keyPressController : function(component, event, helper) {
        $A.util.addClass(component.find("mySpinner"), "slds-show");
        var getInputkeyWord = component.get("v.SearchKeyWord");
        if(getInputkeyWord.length > 0){
            var forOpen = component.find("searchRes");
            $A.util.addClass(forOpen, 'slds-is-open');
            $A.util.removeClass(forOpen, 'slds-is-close');
            helper.searchHelper(component,event,getInputkeyWord);
        }
        else{  
            component.set("v.listOfSearchRecords", null ); 
            var forclose = component.find("searchRes");
            $A.util.addClass(forclose, 'slds-is-close');
            $A.util.removeClass(forclose, 'slds-is-open');
        }
    },
    // function for clear the Record Selaction 
    clear :function(component,event,helper){
        var selectedPillId = event.getSource().get("v.name");
        var AllPillsList = component.get("v.lstSelectedRecords"); 
        
        for(var i = 0; i < AllPillsList.length; i++){
            if(AllPillsList[i].Id == selectedPillId){
                AllPillsList.splice(i, 1);
                component.set("v.lstSelectedRecords", AllPillsList);
            }  
        }
        component.set("v.SearchKeyWord",null);
        component.set("v.listOfSearchRecords", null );      
    },
    // This function call when the end User Select any record from the result list.   
    handleComponentEvent : function(component, event, helper) {
        component.set("v.SearchKeyWord",null);
        // get the selected object record from the COMPONENT event 	 
        var listSelectedItems =  component.get("v.lstSelectedRecords");
        var selectedAccountGetFromEvent = event.getParam("recordByEvent");
        listSelectedItems.push(selectedAccountGetFromEvent);
        component.set("v.lstSelectedRecords" , listSelectedItems); 
        
        console.log('listSelectedItems'+listSelectedItems);
        var forclose = component.find("lookup-pill");
        $A.util.addClass(forclose, 'slds-show');
        $A.util.removeClass(forclose, 'slds-hide');
        
        var forclose = component.find("searchRes");
        $A.util.addClass(forclose, 'slds-is-close');
        $A.util.removeClass(forclose, 'slds-is-open'); 
    },
    handleClick : function(component, event, helper){
        var action = component.get("c.saveDealer");
        action.setParams({
            'accList': component.get("v.lstSelectedRecords"),
            'orderId':component.get("v.recordId")
            
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.distributors",response.getReturnValue());
            }
        });
        // enqueue the Action  
        $A.enqueueAction(action);
        // var selectedRecordList =  component.get("v.lstSelectedRecords");
        // component.set("v.distributors",selectedRecordList);
    },
    handleNext: function(component, event, helper) {
        var pageNumber = component.get("v.PageNumber");  
        //var pageSize = component.find("pageSize").get("v.value");
        pageNumber++;
        component.set("v.PageNumber",pageNumber);
        var getInputkeyWord = component.get("v.SearchKeyWord");
        helper.searchHelper(component,event,getInputkeyWord);
    },
    
    handlePrev: function(component, event, helper) {
        var pageNumber = component.get("v.PageNumber");  
        // var pageSize = component.find("pageSize").get("v.value");
        pageNumber--;
        component.set("v.PageNumber",pageNumber);
        var getInputkeyWord = component.get("v.SearchKeyWord");
        helper.searchHelper(component,event,getInputkeyWord);
        // helper.getContactList(component, pageNumber, pageSize);
    },
    onSelectChange: function(component, event, helper) {
    },
    
})