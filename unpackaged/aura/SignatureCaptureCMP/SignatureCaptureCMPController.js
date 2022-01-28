({
    /* Method to clear the canvas */
    signatureClear : function(component, event, helper){
        //Canvas clearing
        var canvas=component.find('canvas').getElement();
        var ctx = canvas.getContext("2d");
        var w = canvas.width;
        var h = canvas.height;
        ctx.clearRect(0, 0, w, h);
        
        //Clear Title field is there is a value
        if(component.get("v.title"))
        	component.set("v.title",null);
        
        //Toggle button state if the button state is active(true)
        if(component.get("v.buttonstate"))
            helper.toggleButtonState(component);
    },
    
    /* Method to save the signature */
    signatureSave :function(component, event, helper){
        //Check if there is any signature
        if( component.get("v.blankCanvasData") === helper.getBase64ImageData(component)){
            alert('No Signature Detected');
            return;
        }
        component.set("v.showSpinner",true);
        //Call Controller Method to save the signature as a file
        var action = component.get("c.saveSignatureToRecord");
        action.setParams({
            recordId		 : component.get("v.recordId"),
            base64imageData  : 	helper.getBase64ImageData(component),
            fileName 		 : component.get("v.title")
        });
        
        action.setCallback(this,function(response){
            var state=response.getState();
            if(state==="SUCCESS"){
                component.set("v.contentDocumentID", response.getReturnValue().ContentDocumentId);
                //Change button state to true
                helper.toggleButtonState(component);
                //Fire toast
                helper.fireToast(
                    component,
                    'success',
                    'Upload Successful!',
                    'Yayye!',
                    '{0} to view your file.',
                    [{
                        'url'    : '/'+ response.getReturnValue().ContentDocumentId,
                        'label'  : 'Click here',
                        'target' : '_blank'
                    }]
                );
                
            }
            else{
                console.log('State: '+state);
                if(state==="ERROR"){
                    var errorMessage = response.getError()[0].message;
                    helper.fireToast(component,'error','Upload Failed!', 'Error: '+errorMessage);
                    console.log(JSON.stringify(response.getError()));
                }
            }
            component.set("v.showSpinner",false);
        });
        $A.enqueueAction(action);
        
    }
    
})