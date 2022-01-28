//Author: Sergey Legostaev
//Date: 04/20/2017
public with sharing class DC_OrderDAO {
	
    public static List<Order> getOrdersByAccountId(String accountId) {
        return [select Id, Name, OrderNumber, Status, EffectiveDate, Order_Type__c,
                 Order_Amount_global__c, Distributor__c, Distributor__r.Name from Order where AccountId = :accountId 
               order by EffectiveDate desc];
    }
}