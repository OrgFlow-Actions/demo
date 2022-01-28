/*------------------------------------------------------------  
Author: 		LOUDRASSI Ahmed (Salesforce) 2020-02-25
Description:    OrderItem Trigger Handler Class. 
History 
<Date>      <Authors Name>     <Brief Description of Change>
------------------------------------------------------------*/

public class OrderItemTriggerHandler extends TriggerHandler {
    private List<OrderItem> oldOrderItemList, newOrderItemList;
    private Map<Id, OrderItem> oldOrderItemMap, newOrderItemMap;
    
    public OrderItemTriggerHandler() {
        oldOrderItemList = (List<OrderItem>) Trigger.old;
        newOrderItemList = (List<OrderItem>) Trigger.new;
        oldOrderItemMap = (Map<Id, OrderItem>) Trigger.oldMap;
        newOrderItemMap = (Map<Id, OrderItem>) Trigger.newMap;
    }
    protected override void beforeInsert() {
        OrderItemTriggerHelper.set100PercentForFOC(newOrderItemList);
        OrderItemTriggerHelper.totalAmountOfSamplesAndFreeProducts(newOrderItemList);
        OrderItemTriggerHelper.orderProductEvaluation(newOrderItemList);
    }
    protected override void beforeUpdate() {
        OrderItemTriggerHelper.set100PercentForFOC(newOrderItemList);
        OrderItemTriggerHelper.totalAmountOfSamplesAndFreeProducts(newOrderItemList);
        OrderItemTriggerHelper.orderProductEvaluation(newOrderItemList);
    }
    protected override void afterInsert() {
        OrderItemTriggerHelper.setDiscountAllowedforTurkey(newOrderItemList);
    }
    protected override void afterUpdate() {
        OrderItemTriggerHelper.setDiscountAllowedforTurkey(newOrderItemList);
    }
    protected override void afterDelete() {
        OrderItemTriggerHelper.setDiscountAllowedforTurkey(oldOrderItemList);
    }
}