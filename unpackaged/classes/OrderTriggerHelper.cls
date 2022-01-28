/*-------------------------------------------------------------------------------------
Author: 		Miguel Coimbra (Salesforce) 2020-06-10
Description:    Order Trigger Helper Class
Test Class:     Test_OrderTrigger
History 
----------------------------------------------------------------------------------------*/
public class OrderTriggerHelper {
    /*------------------------------------------------------------  
    Description:    User Story: #1833: Caculate the Allowed Discount for Turkish Orders (Of Type "Implants")
                    This method is called from the Order trigger before updating a new Order and is fired upon adding, editing or deleting 
                    a new Order Item (where the parent is updated) If the code on the Order Item trigger is removed. This logic is no longer called! 
    ------------------------------------------------------------*/
    
    public static void calculateAllowedDiscount(List<Order> ordersList){

        if (ordersList.isEmpty()) return ;

        Set<Id> newOrderIdsSet = (new Map<Id,SObject>(ordersList)).keySet();

        Map<Id, Id> pbId_dmIdMap= new Map<Id,Id>{};

        for (Order o : [SELECT Pricebook2.Discount_Model__c FROM Order WHERE  Country__c = 'TR' AND Order_Type__c = 'Implants' AND Id in: newOrderIdsSet]){
            pbId_dmIdMap.put(o.Pricebook2Id, o.Pricebook2.Discount_Model__c);
        }

        if (pbId_dmIdMap.isEmpty()) return ; 

        final String REVENUE_MATERIALS = 'Revenue: materials';
        final String PAYMENT_TYPE = 'Payment type';
        // Provide all related Discount Rows (associated with the relevant Discount Models 
        List<Discount_row__c> discountRowsList = [SELECT Id, Max__c, Min__c, Discount_Model__c, Discount_lever__c, Equals__c, Allowed_discount__c, Payment_terms_months__c FROM Discount_row__c WHERE 
                                                        (Discount_lever__c =: REVENUE_MATERIALS OR Discount_lever__c =: PAYMENT_TYPE ) and Discount_Model__c in: pbId_dmIdMap.Values()];

        for (Order o: ordersList){
            // OrderAmountglobal is calculated with the right value when a field referenced by a Roll Up Summary field is modified. (This happens for instance when a new value is added) 
            Double OrderAmountglobal = o.Order_Amount_global__c ; 
            if (String.isBlank(o.Payment_type__c)){
                o.Payment_type_discount__c = 0 ;
            }else{
                for (Discount_row__c dr: discountRowsList){
                    if (dr.Discount_Model__c == pbId_dmIdMap.get(o.Pricebook2Id) && PAYMENT_TYPE.equals(dr.Discount_Lever__c) && dr.Equals__c == o.Payment_type__c){
                        o.Payment_type_discount__c = dr.Allowed_Discount__c;
                        break ; 
                    }
                }
            }
            
            for (Discount_row__c dr: discountRowsList){
                if (dr.Discount_Model__c == pbId_dmIdMap.get(o.Pricebook2Id) && REVENUE_MATERIALS.equals(dr.Discount_Lever__c) 
                && dr.Max__c >= OrderAmountglobal && dr.Min__c <= OrderAmountglobal){
                    o.Allowed_Discount__c = dr.Allowed_Discount__c ;
                    o.Allowed_payment_terms_months__c = dr.Payment_terms_months__c ;
                    break ; 
                }
            }
        }     
    }
     /*------------------------------------------------------------  
    Description:    Code migrated from OrderSetAccountOwner (as a result,  OrderSetAccountOwner.trigger has been removed. )
                    Called before Insert and before Update                    
    Author:    Miguel Coimbra (20200615)
    ------------------------------------------------------------*/

    public static void setAccountOwnerAndRegionalManagerOnOrder(List<Order> newOrdersList){ 
        
        // Don't run unless configured to do so.
        BatchSettings__c settings = BatchSettings__c.getInstance('Default');
        if (!Test.isRunningTest() && !settings.OrderSetAccountOwnerIsEnabled__c)
            return; 

        Set<ID> relatedAccountIds = new Set<ID>();
        for (Order o : newOrdersList)
            if (o.AccountId != null)
                relatedAccountIds.add(o.AccountId);
        Map<ID, Account> accountMap = new Map<Id, Account>([SELECT Id, OwnerId, Owner.ManagerId FROM Account WHERE Id IN :relatedAccountIds]);

        for (Order o : newOrdersList)
        {
            if (o.AccountId != null)
            {
                Account a = accountMap.get(o.AccountId);
                if (a != null)
                {
                    o.Account_Owner__c = a.OwnerId; 
                    o.Regional_Manager__c = a.Owner.ManagerId; 
                }
            }
        }
    }

}