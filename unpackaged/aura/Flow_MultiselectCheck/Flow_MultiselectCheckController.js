({
	invoke : function(component, event, helper) {
		var multisel = component.get("v.multiselectString");
        var literal = component.get("v.literalCheck");
        console.log(multisel);
        
        literal = "'" + literal +"'";
        var stringLit = literal.toString();
        
        console.log(multisel[0].includes($stringLit));
        
        var isFound = multisel[0].indexOf(stringLit);
        console.log(isFound);
        
        if(isFound!=-1){
            component.set("v.checkOutput", true);
        }      
        
	}
})