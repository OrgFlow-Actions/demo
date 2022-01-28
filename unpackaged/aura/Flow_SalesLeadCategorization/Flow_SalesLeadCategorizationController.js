({
	init : function(cmp, event, helper) {
       	if(sessionStorage){
            console.log('Validation check: ' + sessionStorage.getItem('validationfailed'));
            if(sessionStorage.getItem('validationfailed')){
                console.log('Session storage true');
                if(sessionStorage.getItem('isCategoryValid')){
					
                    if(sessionStorage.getItem('category')!=null){
            	        cmp.find('catField').set('v.value',sessionStorage.getItem('category'));
           	     	}
                    if(sessionStorage.getItem('brand')!=null){
                        cmp.find('brandField').set('v.value',sessionStorage.getItem('brand'));
                    }

                    /*if(sessionStorage.getItem('buyDate')!='undefined' && sessionStorage.getItem('buyDate')!='null'){
                        cmp.find('buydateField').set('v.value',sessionStorage.getItem('buyDate'));
                    }*/
					if(sessionStorage.getItem('showDealer')==true){
                        cmp.find('dealerField').set('v.value',sessionStorage.getItem('dealer'));
                    }    
                    //Submit form to store values if the user does not do any changes
					$A.enqueueAction(cmp.get('c.submitTest'));
                }
       		}
        }
        
        helper.checkDealerVisible(cmp, event);
                          
       	helper.checkValidity(cmp, event);
             
	},
    
	submitTest : function(cmp, event, helper) {    
        console.log('Submitting');
        
        var categoryOutput = cmp.find("catField").get("v.value");
        
        if(categoryOutput != ''){
        	helper.checkDealerVisible(cmp, event);
		   
        	var brandOutput = cmp.find("brandField").get("v.value");
            var subCategoryOutput = cmp.find("subCatField").get("v.value");
            
            cmp.set("v.categoryOutput", categoryOutput);
        	cmp.set("v.brandOutput", brandOutput);
            cmp.set("v.subCategoryOutput", subCategoryOutput);
            
            var objType = cmp.get("v.objType");
            var buydateOutput = null;
            if(objType != 'Opportunity'){
                buydateOutput = cmp.find("buydateField").get("v.value");
            }
            var hideDealer = cmp.get("v.hideDealer");
            if(hideDealer == false){
            	var dealerOutput = cmp.find("dealerField").get("v.value");
                console.log('Dealer: ', dealerOutput);
            }
            if(buydateOutput != null){
                cmp.set("v.buydateOutput", buydateOutput);
            }    
            if(dealerOutput != null){
            	//cmp.set("v.dealerOutput", dealerOutput);
            }    
        	console.log("The following values are assigned: Category - " + cmp.get("v.categoryOutput"));
        	helper.checkValidity(cmp, event);
        } else {
            //When no Category return null.
            cmp.set("v.categoryOutput", null);
        	cmp.set("v.brandOutput", null);
        }
    },
    
    submitDealer : function(cmp, event, helper) {
            var data = event.getParam('data');
            var dataString = JSON.stringify(data);
            if(dataString != '[]'){
                var dealerId = data[0].id;            
                console.log(dealerId)
                cmp.set("v.dealerOutput", dealerId);
                helper.checkValidity(cmp, event);
            }
            else{
                cmp.set("v.dealerOutput", null);  
            }
        	
    }
  
})