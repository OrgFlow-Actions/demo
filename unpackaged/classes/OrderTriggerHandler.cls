/*------------------------------------------------------------  
Author: 		Miguel Coimbra (Salesforce) 2020-06-09
Description:    Order Trigger Handler Class. 
History 
<Date>      <Authors Name>     <Brief Description of Change>
------------------------------------------------------------*/
public class OrderTriggerHandler extends TriggerHandler {
    private List<Order> oldOrderList, newOrderList;
    private Map<Id, Order> oldOrderMap, newOrderMap;
    
    public OrderTriggerHandler() {
        oldOrderList = (List<Order>) Trigger.old;
        newOrderList = (List<Order>) Trigger.new;
        oldOrderMap = (Map<Id, Order>) Trigger.oldMap;
        newOrderMap = (Map<Id, Order>) Trigger.newMap;
    }
    
    protected override void beforeInsert() {
        OrderTriggerHelper.setAccountOwnerAndRegionalManagerOnOrder(newOrderList);
    }
    
    protected override void beforeUpdate() {
        OrderTriggerHelper.setAccountOwnerAndRegionalManagerOnOrder(newOrderList);
        OrderTriggerHelper.calculateAllowedDiscount(newOrderList);   
    }
    /*
    protected override void afterInsert() {
    }
    protected override void afterUpdate() {
    }
    protected override void afterDelete() {
    }*/
}