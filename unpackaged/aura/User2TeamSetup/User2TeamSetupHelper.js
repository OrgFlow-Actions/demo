({
	    
    addDivider : function() {
    var x = document.getElementsByClassName("hasDiv");
    	for(var i=0; i<x.length; i++){
    		x[i].classList.add("slds-has-divider--bottom");
    	}
	},

    removeDivider : function() {
    var x = document.getElementsByClassName("hasDiv");
        for(var i=0; i<x.length; i++){
            x[i].classList.remove("slds-has-divider--bottom");
        } 
	},
    
    addEditIcon : function() {
    var x = document.getElementsByClassName("editIcon");
    	for(var i=0; i<x.length; i++){
    		x[i].classList.remove("slds-hide");
    	}
	},

    removeEditIcon : function() {
    var x = document.getElementsByClassName("editIcon");
        for(var i=0; i<x.length; i++){
            x[i].classList.add("slds-hide");
        } 
	}
    
})