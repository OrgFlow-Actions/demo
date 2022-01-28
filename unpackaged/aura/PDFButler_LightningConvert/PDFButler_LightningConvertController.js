({
    //Call the convertor
	init : function(component, event, helper) {
        var spinner = component.find("mySpinner");
        //var action = component.get("c.convertToPdfLightning"); //DemoConvertController
        var action = component.get("c.convert");
        console.log("From Flow RecordId: " + component.get("v.recordId"));
        console.log("From Flow docConfigId: " + component.get("v.docConfigId"));
        //action.setParams({"objectId": component.get("v.recordId"), "docConfigId": "a040Y00000Hx6F9QAJ"});
        action.setParams({"docConfigId": component.get("v.docConfigId")
                          , "docConfigIds": component.get("v.docConfigIds")
                          , "objectId":component.get("v.recordId")
                          , "locale":component.get("v.locale")
                          ,"alternative":component.get("v.alternativeName")
                          ,"targetType":component.get("v.targetType")
                          ,"pdfActionType":component.get("v.pdfActionType")
                          ,"packId":component.get("v.packId")
                          ,"DeliveryTypeOverwrite":component.get("v.deliveryOverwrite")
                         });

        var doShowPreviewAfterGenerate = component.get("v.doShowPreviewAfterGenerate");
        var doDownloadAfterGenerate = component.get("v.doDownloadAfterGenerate");

        action.setCallback(this, function(response) {
            var state = response.getState();
            if(component.isValid() && state == "SUCCESS"){
                var docConfigData = JSON.parse(response.getReturnValue());
                
                
                if(doShowPreviewAfterGenerate) {
        			component.set("v.showPreview", true);
        			component.set("v.pdfData", docConfigData.base64);
                    
                } else {
                    //close popup
                    var dismissActionPanel = $A.get("e.force:closeQuickAction");
                    dismissActionPanel.fire();
            		$A.get('e.force:refreshView').fire();
                }
                if(doDownloadAfterGenerate) {
                    var dlnk = component.find("fileDownload").getElement(); //document.getElementById('fileDownload');
                    dlnk.href = "data:application/octet-stream;base64," + docConfigData.base64;  // Adds the pdf to the html anchor
                    dlnk.download = docConfigData.title; //  Sets the title (filename) of the document to download
                    dlnk.click();  //  initiates the download automatically when the document is generated, no user has to click 
                }
                
                var cmpTarget = component.find('ModalShowPDF');
                var cmpBack = component.find('Modalbackdrop');
                $A.util.addClass(cmpTarget, 'slds-fade-in-open');
                $A.util.addClass(cmpBack, 'slds-backdrop_open'); 
                
            } else {
                console.log('There was a problem and the state is: '+state);
            }
        	$A.util.toggleClass(spinner, "slds-hide");
        });
        
        $A.enqueueAction(action);
        
        
        var actionPackIds = component.get("v.actionPackIds");
        if(actionPackIds) {
            var action2 = component.get("c.initServerFileSelector");
            //dummy as this is not used
            action2.setParams({"objectId": null, "packDocConfigIds": actionPackIds});
            action2.setCallback(this, function(response) {
                var state = response.getState();
                if(component.isValid() && state == "SUCCESS"){
                    
                    if(response.getReturnValue()) {
                        var json = JSON.parse(response.getReturnValue());
                        var packs = json.packs;
                        component.set("v.packs", packs);
                    }
                } else {
                    console.log('There was a problem and the state is: '+state);
                }
            });
            
            $A.enqueueAction(action2);
        }

	},
    //Call the convertor
	closePreview : function(component, event, helper) {
        var dismissActionPanel = $A.get("e.force:closeQuickAction");
        dismissActionPanel.fire();

	},
	loadpdf : function(component,event){
		try{
			var pdfData = component.get('v.pdfData');
			var pdfjsframe = component.find('pdfFrame')
			if(typeof pdfData != 'undefined'){
                setTimeout(function(){
                	pdfjsframe.getElement().contentWindow.postMessage(pdfData, "*");
                }, 500);
			}
		}catch(e){
			alert('Error: ' + e.message);
		}
	},
    runPack: function(component, event, helper) {
        var packId = event.getSource().get("v.value");
        console.log("runPack: " + packId);
        // for Hide/Close Model,set the "isOpen" attribute to "Fasle"  
        
        
        var spinner = component.find("mySpinner");
      	$A.util.toggleClass(spinner, "slds-hide");
        
        var recordId = component.get("v.recordId");
        var docConfigId = component.get("v.docConfigId");//this is the leading one
        var docConfigIds = component.get("v.docConfigIds");//this is all ones
		//Set locale and alternative
        var locale = component.get("v.locale");
        
        var alternative = component.get("v.alternativeName");
        
        //deliveryTypeOverwrite (this is not used here, the overwrite is not for the pack)
        var deliveryTypeOverwrite = component.get("v.deliveryOverwrite");
        //Get the pack and get all docconfigs
        var packs = component.get("v.packs");
        var pack = null;
        //loop through all packs
        for (var i = 0; i < packs.length; i++) {
            var temp = packs[i];
            if(temp.Id === packId) {
               	pack = temp;
                break;
            }
        }
        
        var action = component.get("c.convert");
        action.setParams({"docConfigId": null, "docConfigIds": docConfigIds, "objectId":recordId, "locale":locale,"numCurrLocale":null,
                          "alternative":alternative,"targetType":null,"pdfActionType":"MERGE",
                          "contentDocumentIds":null,"packId":packId,"DeliveryTypeOverwrite":deliveryTypeOverwrite});
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(component.isValid() && state == "SUCCESS"){
                //alert(response.getReturnValue());
                if(response.getReturnValue()) {
                    var docConfigData = JSON.parse(response.getReturnValue());
                                     
                    for (var i = 0; i < docConfigData.issues.length; i++) {
                        //if WARNING => suppress
                        var issue = docConfigData.issues[i];
                        if( issue.level.toLowerCase() !== 'warning' ) {
                            var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                "title": issue.level,
                                "message": issue.description,
                                "type": issue.level.toLowerCase()
                            });
                            toastEvent.fire();
                        } else {
                            console.log("title:" + issue.level + " / message: " + issue.description);
                        }
                    }
                    
                    if(docConfigData.uiActions) {
                        for (var i = 0; i < docConfigData.uiActions.length; i++) {
                            
                            var uiAction = docConfigData.uiActions[i];
                            //if it starts with a "/" we must add the site-prefix
                            var myUrl = uiAction.description;
                            var prefix = component.get("v.sitePrefix");
                            if(myUrl.startsWith("/") && prefix) {
                                myUrl = prefix + uiAction.description;
                            }
                            
                            if(uiAction.action == "MESSAGE") {
                                var toastEvent = $A.get("e.force:showToast");
                                toastEvent.setParams({
                                    "title": "Message",
                                    "message": uiAction.description
                                });
                                toastEvent.fire();
                            } else if(uiAction.action == "FORWARD") {
                                
                                var urlEvent = $A.get("e.force:navigateToURL");
                                urlEvent.setParams({
                                    "url": myUrl
                                });
                                urlEvent.fire();
                            } else if(uiAction.action == "NEW_WINDOW") {
                                
                                var device = $A.get("$Browser.formFactor");
                                if(device == 'DESKTOP') {
                                	window.open(myUrl);
                                } else {
                                    //MOBILE
                                    component.find("navigationService").navigate({ 
                                        type: "standard__webPage", 
                                        attributes: { 
                                            url: myUrl
                                        } 
                                    });
                                }
                            } else if(uiAction.action == "AJAX_GET") {
                                
                                fetch(uiAction.description, {
                                    method: 'GET',
                                    headers:{
                                        'Authorization': 'Bearer ' + component.get("v.sessionId")
                                    }
                                })
                                .then(function(response) {
                                    return response.json();
                                })
                                .then(function(myJson) {
                                    //this will return a UI Action
                                    var toastEvent = $A.get("e.force:showToast");
                                    toastEvent.setParams({
                                        "title": myJson.key,
                                        "type": "success",
                                        "message": myJson.value
                                    });
                                    toastEvent.fire();
                                }) 
                                .catch(function(error) {
                                    //this will return a UI Action
                                    var toastEvent = $A.get("e.force:showToast");
                                    toastEvent.setParams({
                                        "title": "Message",
                                        "type": "error",
                                        "message": error
                                    });
                                    toastEvent.fire();
                                });
                            }
                        }
                    }
                    
                    $A.get('e.force:refreshView').fire();
                    var dismissActionPanel = $A.get("e.force:closeQuickAction");
                    dismissActionPanel.fire();
                    
                }
            } else {
                console.log('There was a problem and the state is: '+state);
            }            
        	$A.util.toggleClass(spinner, "slds-hide");
        });
        
        $A.enqueueAction(action);
    }
})