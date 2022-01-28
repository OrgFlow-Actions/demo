/*-------------------------------------------------------------------------------------------------------
Author:         Richard Trum (Glimt) 20200907
Description:    Opportunity Trigger Helper Class
Test Class:     Test_OpportunityPB 
History 
20210906    kdoruibin               TFUS-000002909: Updated setOpportunityName according to new naming framework
20200907    Richard Trum            Created trigger framework for Opportunities
----------------------------------------------------------------------------------------*/

public with sharing class OpportunityTriggerHelper {
                              
    /*------------------------------------------------------------  
    Description:    
    Inputs:         @param newOpportunityList and @param oldOpportunityMap
    ------------------------------------------------------------*/
    public static void setOpportunityName(List<Opportunity> newOpportunityList) {
		
        // Don't run unless configured to do so.
        BatchSettings__c settings = BatchSettings__c.getInstance('Default');
                    
        String recordTypeId = Schema.Sobjecttype.Opportunity.getRecordTypeInfosByDeveloperName().get('Lightning_Pipeline_Opportunity').getRecordTypeId();
        String dealerRecordTypeId = Schema.Sobjecttype.Opportunity.getRecordTypeInfosByDeveloperName().get('Dealer_Community').getRecordTypeId();
    
        Set<Id> accountIdSet = new Set<Id>();
        Set<Id> ownerIdSet = new Set<Id>();
        for (Opportunity oppty : newOpportunityList) {
            accountIdSet.add(oppty.AccountId);
            ownerIdSet.add(oppty.OwnerId);
        }

        // Get related accounts
        Map<Id, Account> accountMap = new Map<Id, Account>([SELECT Id, Name, Country__c FROM Account WHERE Id IN :accountIdSet]);
        // Get opportunity owners
        Map<Id, User> ownerMap = new Map<Id, User>([SELECT Id, Name FROM User WHERE Id IN :ownerIdSet]);

        // Get Opportunity Naming Settings
        Map<String, OpportunityNamingSetting__mdt> oppNameSettingMap = new Map<String, OpportunityNamingSetting__mdt>();
        for (OpportunityNamingSetting__mdt oppNameSetting : OpportunityNamingSetting__mdt.getAll().values()) {
            oppNameSettingMap.put(oppNameSetting.Country__c, oppNameSetting);
        }

        for (Opportunity oppty : newOpportunityList) {
            if (oppty.RecordTypeId != recordTypeId && oppty.RecordTypeId != dealerRecordTypeId) continue;
            if (oppty.ManualName__c != false) continue;

            Account relatedAccount = accountMap.get(oppty.AccountId);
            OpportunityNamingSetting__mdt relatedOpptyNamingSetting = oppNameSettingMap.containsKey(relatedAccount?.Country__c) ? 
                oppNameSettingMap.get(relatedAccount?.Country__c) : 
                oppNameSettingMap.get(null);

            if (relatedOpptyNamingSetting == null) continue;
            
            String stringOne = getNameField(relatedOpptyNamingSetting.Field1__c, oppty, accountMap, ownerMap);
            String stringTwo = getNameField(relatedOpptyNamingSetting.Field2__c, oppty, accountMap, ownerMap);
            String stringThree = getNameField(relatedOpptyNamingSetting.Field3__c, oppty, accountMap, ownerMap);
            String stringFour = getNameField(relatedOpptyNamingSetting.Field4__c, oppty, accountMap, ownerMap);
            String stringFive = getNameField(relatedOpptyNamingSetting.Field5__c, oppty, accountMap, ownerMap);
            
            List<String> fieldList = new List<String>{ stringOne, stringTwo, stringThree, stringFour, stringFive };
            
            String nameString = '';
            for (String field : fieldList) {
                if (String.isBlank(field)) continue;
                nameString = formatName(nameString, field, relatedOpptyNamingSetting.Separator__c);
            }

            // Opportunity Name max length 120
            oppty.Name = nameString.abbreviate(120);
        }
                  	
    }

    /**
    * @description Helper method for setOpportunityName(newOpportunityList)
    * @author kdoruibin@salesforce.com | 09-06-2021 
    * @param String fieldName 
    * @param Opportunity oppty 
    * @param Map<Id Account> accountMap 
    * @param Map<Id User> ownerMap 
    * @return String 
    **/
    private static String getNameField(String fieldName, Opportunity oppty, Map<Id, Account> accountMap, Map<Id, User> ownerMap) {
        // Set input token
        if ('Account.Name'.equals(fieldName)) {
            fieldName = accountMap.get(oppty.AccountId)?.Name;
        }
        if ('CloseDate'.equals(fieldName)) {
            fieldName = String.valueOf(oppty.CloseDate);
        }
        if ('NA_Category__c'.equals(fieldName)) {
            fieldName = oppty.NA_Category__c;
        }
        if ('NA_Brand__c'.equals(fieldName)) {
            fieldName = oppty.NA_Brand__c;
        }
        if ('Owner.Name'.equals(fieldName)) {
            fieldName = ownerMap.get(oppty.OwnerId)?.Name;
        }
        if ('Type'.equals(fieldName)) {
            fieldName = oppty.Type;
        }
        return fieldName;
    }

    /**
    * @description Helper method for setOpportunityName(newOpportunityList)
    * @author kdoruibin@salesforce.com | 09-06-2021 
    * @param String nameString 
    * @param String input 
    * @param String spacingToken 
    * @return String 
    **/
    private static String formatName(String nameString, String input, String spacingToken) {
        // Set spacing token, default to blank space if none
        spacingToken = String.IsNotBlank(spacingToken) ? ' ' + spacingToken + ' ' : ' ';

        if (String.isBlank(nameString)) {
            nameString = input;
        } else {
            nameString = String.IsNotBlank(input) ? nameString + spacingToken + input : nameString;
        }
        return nameString;
    }
    
    /*------------------------------------------------------------  
    Description:    
    Inputs:         @param newOpportunityList and @param oldOpportunityMap
    ------------------------------------------------------------*/
    public static void sendDealerEmail(List<Opportunity> newOpportunityList) {
		
        Set<Id> campaignIds = new Set<Id>();
        Set<Id> accountIds = new Set<Id>();
        Set<Id> dealerIds = new Set<Id>();

    	for (Opportunity o : newOpportunityList) {
        	if (o.CampaignId != null) {
            	campaignIds.add(o.CampaignId);
        	}
            if(o.AccountId != null){
                accountIds.add(o.AccountId);
            }
            if(o.Dealer__c != null){
                dealerIds.add(o.Dealer__c);
            }
    	}
        
        //Get all Customer Accounts related to the included Campaign Members
        Map<Id, Account> customers = new Map<Id, Account>(
            [SELECT Id, Name, Country__c FROM Account WHERE Id IN: accountIds]
        );
        
        //Get all countries related to the included Opportunities
        Set<String> countries = new Set<String>();
        for(Account customer : customers.values()){
            countries.add(customer.Country__c);
        }
        
        //Only loop if any German or Austrian opportunity is included
        if(countries.contains('DE') || countries.contains('AT')){        
        
        //Get all Campaigns related to the included Opportunities 
        Map<Id, Campaign> campaigns = new Map<Id, Campaign>(
        	[SELECT Id, RecordTypeId, OwnerId, Email_Template__c, ReplyToEmail__c, Brands__c, RecordType.DeveloperName, Include_in_Dealer_Community__c, Notify_Dealer_Sales_Rep_by_Email__c from Campaign where Id in :campaignIds]
        );

        //Get all Dealers related to the included Campaign Members
        Map<Id, Account> dealers = new Map<Id, Account>(
            [SELECT Id, Name, 
            (SELECT AccountId, ContactId, IsActive, IsDirect, Roles, Specialty__c, Contact.Email, Contact.Legacy_ID__c FROM AccountContactRelations)
            FROM Account WHERE Id IN: dealerIds]
        );
        
        //Get Custom Metadata records related to the previously queried countries
        LeadOpportunitySetting__mdt[] oppSettings = new LeadOpportunitySetting__mdt[]{};
        if(Test.IsRunningTest()){
            oppSettings = [SELECT DeveloperName, Category__c, Brands__c, Country__c, AssignOwnerFrom__c, UserRoles__c, IsTest__c FROM LeadOpportunitySetting__mdt WHERE IsTest__c =: true];
        }
        else{
        	oppSettings = [SELECT DeveloperName, Category__c, Brands__c, Country__c, AssignOwnerFrom__c, UserRoles__c, IsTest__c FROM LeadOpportunitySetting__mdt WHERE Country__c IN: countries AND IsTest__c =: false];
        }
        
        Map<String, LeadOpportunitySetting__mdt> settingsMap = new Map<String, LeadOpportunitySetting__mdt>();
        for(LeadOpportunitySetting__mdt setting: oppSettings){
            if(setting.Brands__c != null){
                String brands = setting.Brands__c;
                String[] brandList = brands.split(';');
                for(String brand : brandList){
                    settingsMap.put(brand, setting);
                }
            }
            else{
                settingsMap.put(setting.Category__c, setting);
            }    
        }
        
        
        //Loop Opportunities
        for(Opportunity opp: newOpportunityList){
            
            if(opp.CampaignId != null){
            String notifyDealerReps = campaigns.get(opp.CampaignId).Notify_Dealer_Sales_Rep_by_Email__c;
            System.debug('Notify dealer reps?: ' + notifyDealerReps);    
            String campaignRecordType = campaigns.get(opp.CampaignId).RecordType.DeveloperName;
            System.debug(campaignRecordType);
            String replyToAddress = campaigns.get(opp.CampaignId).ReplyToEmail__c;
            System.debug('ReplyTo address: ' + replyToAddress);    
			
                        if(notifyDealerReps == 'Yes' && campaignRecordType == 'Digital_Marketing_Campaign' && (customers.get(opp.AccountId).Country__c == 'DE' || customers.get(opp.AccountId).Country__c == 'AT') && opp.Dealer__c != null){
                            
                            Integer count = 10;
                            String emailTemplateId = campaigns.get(opp.CampaignId).Email_Template__c;
                            
                            if(emailTemplateId != null || emailTemplateId != ''){
                                                                
                                Set<String> roleMap = new Set<String>();
                				String roleList = settingsMap.get(opp.NA_Brand__c).UserRoles__c;
                				String[] roles = roleList.split(';');
                				for(String role:roles){
                    				roleMap.add(role);
                				}
                                
                                List<AccountContactRelation> dealerContacts = new List<AccountContactRelation>();
                					if(dealers!= null){
                    					Account dealerAcc = dealers.get(opp.Dealer__c);                    
                    						if(dealerAcc != null){
                    							dealerContacts = dealers.get(opp.Dealer__c).AccountContactRelations;
                    						}    
                				}
                                
                                List<Id> contactIds = new List<Id>();
                                
                                for(AccountContactRelation rel : dealerContacts){
                        			if(rel.Specialty__c != null){
                            			if(roleMap.contains(rel.Specialty__c)){
											 //toAddresses.add(rel.Contact.Email);
											 contactIds.add(rel.ContactId);                                
                            			}
                        			}
                    			}
								
                                if(!Test.isRunningTest()){
                            		Messaging.reserveSingleEmailCapacity(contactIds.size());
                                }
                                
                                for(Id contId : contactIds){
                            	Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                                
                            	// Assign the addresses for the To list to the mail object.    
                            	//mail.setToAddresses(toAddresses);
                            
                            	// Specify the name used as the display name.
								mail.setSenderDisplayName('Dentsply Sirona');
                            	mail.setTargetObjectId(contId);
                                //mail.setTreatTargetObjectAsRecipient(false);
                                
                                mail.setWhatId(opp.Id);
                                
                            	mail.setTemplateId(emailTemplateId);
                                    
                                if(replyToAddress != null){
                                    mail.setReplyTo(replyToAddress);
                                }    
                            
                                if(!Test.isRunningTest()){
                            		// Send the email
									Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
                                }
                                }
                            }
           					
                        }
            }
            
        }
            
        }    
    
    }

}