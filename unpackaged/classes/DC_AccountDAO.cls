//Author: Sergey Legostaev
//Date: 04/20/2017
public with sharing class DC_AccountDAO {
    
    public static Account getAccountById(String accountId) {
        try {
			return [select Id, ShippingAddress,
                    (select Id, Subject, ActivityDate, WhoId, Who.Name, OwnerId, Owner.Name,
                     		WhatId, What.Name, Contact_Type__c,
                            Event_Status__c, Status, Description
                            from ActivityHistories order by ActivityDate desc, LastModifiedDate desc limit 200) 
                    from Account where Id = :accountId];
        } catch (Exception e) {
            System.debug('Account not found: ' + e.getMessage());
        }
        return null;
    }
}