({
    /* After Render  */
    afterRender : function(component, helper){
        this.superAfterRender();
        //Call helper method to initialize Canvas
        helper.initSignatureCanvas(component);
        
        //Get blank canvas Base64 encoded image data
        component.set("v.blankCanvasData",helper.getBase64ImageData(component));
    }
})