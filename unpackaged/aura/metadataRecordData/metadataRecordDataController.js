/**
 * Copyright (c) 2017, Andrew Fawcett
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without modification, 
 *   are permitted provided that the following conditions are met:
 *
 * - Redistributions of source code must retain the above copyright notice, 
 *      this list of conditions and the following disclaimer.
 * - Redistributions in binary form must reproduce the above copyright notice, 
 *      this list of conditions and the following disclaimer in the documentation 
 *      and/or other materials provided with the distribution.
 * - Neither the name of the Andrew Fawcett, nor the names of its contributors 
 *      may be used to endorse or promote products derived from this software without 
 *      specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND 
 *  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES 
 *  OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL 
 *  THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, 
 *  EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 *  OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY
 *  OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 *  ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
**/
({
    doInit : function(cmp, event, helper) {

        var action = cmp.get("c.loadRecord");
        action.setParams({ fullName : cmp.get('v.recordFullName'), fields : cmp.get('v.targetFields'), Country: cmp.get('v.recordId') });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                cmp.set('v.targetRecord', result[0]);
				cmp.set('v.targetRecords', result);

                var messageEvent = cmp.getEvent('recordUpdated');
                messageEvent.setParam("changeType", "LOADED");
                messageEvent.fire();              
            } else {
                var errors = response.getError();
                var errorMessage = null;
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        errorMessage = errors[0].message;
                    }
                } else {
                    errorMessage = "Unknown error";
                }
                var messageEvent = cmp.getEvent('recordUpdated');
                messageEvent.setParam("result", errorMessage);
                messageEvent.setParam("changeType", "ERROR");
                messageEvent.fire();                            
            }            
        });
        $A.enqueueAction(action);
    
    },
 
    saveRecord : function(cmp, helper) {
        var inputs = cmp.get('v.targetRecords');
		var inputTest = cmp.get('v.specRecords');        
        for(var j=0; j<inputs.length; j++){
             
             var str = cmp.get('v.recordFullName');
 			 var devStr = 'Country_metadata.' + inputs[j].DeveloperName;

             if(devStr == str){
                   inputTest.push(inputs[j]);
             }
        }    
        
        for (var i = 0; i < inputTest.length; i++) {        
        var action = cmp.get("c.createCountryRecord");
        var input = inputTest[i];
        
        action.setParams({ recordLabel : inputTest[i].DeveloperName, TeamSetup : inputTest[i].Team_setup__r.Label, Cmp : inputTest[i].LightningComponent__r.Label, Visible : inputTest[i].Visible__c });
        action.setCallback(this, function(response) {
            var state = response.getState();            
            if (state === "SUCCESS") {
                cmp.set('v.deploymentId', response.getReturnValue());
            } else {
                var errors = response.getError();
                var errorMessage = null;
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        errorMessage = errors[0].message;
                    }
                } else {
                    errorMessage = "Unknown error";
                }
                var messageEvent = cmp.getEvent('recordUpdated');
                messageEvent.setParam("result", errorMessage);
                messageEvent.setParam("changeType", "ERROR");
                messageEvent.fire();                
            }        
        });
        $A.enqueueAction(action);
        };
    },
    handleDeploymentEvent : function(component, event, helper) {
        var payload = event.getParam("payload");
        var results = JSON.parse(payload.Result__c);
        var result = results[0];
        var deploymentId = payload.DeploymentId__c;
        if(deploymentId == component.get('v.deploymentId')) {
            var messageEvent = component.getEvent('recordUpdated');
            messageEvent.setParam("result", result);
            messageEvent.setParam("results", results);
            messageEvent.setParam("changeType", result.success ? "CHANGED" : "ERROR");            
            messageEvent.fire();           
        }        
    },
    
    fetchPickValues : function(cmp, event, helper) { 
    var action=cmp.get("c.fetchPickVal");                
    action.setParams({ record : cmp.get('v.recordId') });    
    action.setCallback(this, function(response){        
        var state = response.getState();
	    
        if (state === "SUCCESS") {
        var messageEvent = cmp.getEvent('recordUpdated');
	 	messageEvent.setParam("picklistVal", response.getReturnValue());
	 	messageEvent.fire();            
        }

		cmp.set('v.picklistVal', response.getReturnValue());

        });     	 
     $A.enqueueAction(action);      
    }
                            
});