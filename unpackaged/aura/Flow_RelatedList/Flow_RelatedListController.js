({
    
    init: function(component, event, helper) {
		var action=component.get("c.searchDBexact");
        action.setParams({
            objectName: "Article__c",
            fld_API_Text: "Article_Number__c, Article_Description__c, Quantity__c, Original_Order_Number__c, Amount_Paid_each__c, Lot_Number__c, Purchase_Date__c",
            fld_API_Val: "Id",
            lim: "100",
            fld_API_Search: "Related_Case__c",
            searchText: component.get("v.recordId"),
            fld_API_Rel: "Name",            
        });
        action.setCallback(this, function(data){
		   
           var res = data.getReturnValue();
           console.log(res); 
           
           var resultList = JSON.parse(res); 
           component.set("v.articleList", resultList);
        });
        $A.enqueueAction(action);

    },

})