({
	checkValidity : function(cmp, event) {
		cmp.find('catField').reportValidity();
        cmp.find('dealerField').reportValidity();
	},
    
    checkDealerVisible : function(cmp, event){
        
        var action = cmp.get("c.getSalesLeadSettings");
        action.setParams({
            category: cmp.find("catField").get("v.value"),
            country: cmp.get("v.country")
        });
        action.setCallback(this, function(result){
            
            var state = result.getState();
            if (cmp.isValid() && state === "SUCCESS"){
                var resultList = result.getReturnValue();                
                console.log(resultList);
                if(resultList.length>0){
                	if(resultList[0].ShowDistributor__c == true){
                    	cmp.set("v.hideDealer", false);
                	}
                    else{
                        cmp.set("v.hideDealer", true);
                    }
                }    
                else{
                    cmp.set("v.hideDealer", false);
                }
                cmp.find('catField').reportValidity();
                cmp.find('brandField').reportValidity();
            }
        });
        $A.enqueueAction(action);
    },
    
    checkValidity: function(cmp, event){
       	//cmp.find('catField').reportValidity();
        //cmp.find('brandField').reportValidity();

  		console.log("Session storage: " + sessionStorage);
        console.log("Assigning session storage");
        var categoryInput = cmp.find("catField").get("v.value");
        var brandInput = cmp.find("brandField").get("v.value");
        //var buydateInput =  cmp.find("buydateField").get("v.value");
        var userCountryInput =  cmp.find("userCountry").get("v.value");
        var hideDealer = cmp.get('v.hideDealer');
        var dealerInput = '';
        if(hideDealer == false){
        	dealerInput = cmp.find("dealerField").get("v.value");
            //sessionStorage.setItem('dealer', dealerInput);
            //sessionStorage.setItem('showDealer', true);
        }else{
            //sessionStorage.setItem('showDealer', false);
        }
        
        /*sessionStorage.setItem('isCategoryValid',true);
        sessionStorage.setItem('category', categoryInput);
        sessionStorage.setItem('category', categoryInput);
        sessionStorage.setItem('brand', brandInput);
       	sessionStorage.setItem('userCountry', userCountryInput);
		sessionStorage.setItem('buyDate', buydateInput);*/          
                        
        cmp.set('v.validate', function(){
             
           if(categoryInput == '') {
               console.log("Missing category");
               if(sessionStorage){
            	sessionStorage.setItem('validationfailed',true);
                cmp.find('catField').reportValidity();   
           	   } 
               return { isValid: false, errorMessage: ''};            
           }
           else {       
                			if(sessionStorage){
                                sessionStorage.setItem('validationfailed',false);
           	   				} 
           		return { isValid: true};
                   
           }
        })
	}
})