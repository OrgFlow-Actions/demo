/*-------------------------------------------------------------------------------------------------------
Author: 	    	Roberto Narbona 20200706
Description:   	This is a controller of LWC "approvalOrderRelatedProductsDetails" and the code is covered 
                in the next class "Test_getApprovalOrderItems"
History	

--------------------------------------------------------------------------------------------------------*/


public with sharing class getApprovalProcessRecordDetailController {
  
    @AuraEnabled(cacheable=true)
      public static List<OrderItem> getOrderItems(Id recordId) {
          ProcessInstanceWorkitem approvalRequest;
          approvalRequest= [SELECT ProcessInstance.TargetObjectId FROM ProcessInstanceWorkitem where id =: recordId];
          List<OrderItem> relatedOI = new List<OrderItem>();
          relatedOI=[Select Id, OrderId, Quantity, Article_Number__c, Discount_Percent__c, Product2.Name From OrderItem Where OrderId =: approvalRequest.ProcessInstance.TargetObjectId ];
          return relatedOI;
      }
      
    }