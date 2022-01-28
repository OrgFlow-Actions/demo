public without sharing class OrderPath_CC {

    @AuraEnabled
    public static boolean checkCancelOrderPermission(){
        try {
            return FeatureManagement.checkPermission('Order_Management_2_0_Cancel_Order');
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static string getStageGuidance(String orderId) {
        try {
            Order currentOrder = [SELECT Pricebook2Id, RecordType.DeveloperName, Status FROM ORDER WHERE Id = :orderId LIMIT 1];
            List<OrderStageGuidance__mdt> guidanceSettingList = [
                SELECT StageGuidance__c, StageGuidanceTitle__c, KeyFields__c, KeyFieldsReadOnly__c, KeyFieldsTitle__c, PriceBook2Id__c
                FROM OrderStageGuidance__mdt
                WHERE 
                    (PriceBook2Id__c = :currentOrder.Pricebook2Id OR PriceBook2Id__c = null)
                    AND OrderStatus__c = :currentOrder.Status
                ORDER BY PriceBook2Id__c NULLS LAST
            ];

            if (!guidanceSettingList.isEmpty()) {
                return JSON.serialize(guidanceSettingList?.get(0));
            } else {
                return null;
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static string submitForApproval(String orderId, String comment) {
        try {
            Approval.ProcessSubmitRequest approvalRequest = new Approval.ProcessSubmitRequest();
            approvalRequest.setComments(comment);
            approvalRequest.setObjectId(orderId);
            approvalRequest.setSubmitterId(UserInfo.getUserId());
            Approval.ProcessResult result = Approval.process(approvalRequest);
            return JSON.serialize(result.isSuccess());
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static string orderCancel(String orderId, String comment){
        try {
            Order orderToCancel = [SELECT Id, Status, Note_for_canceled_orders__c FROM Order WHERE Id = :orderId];
            orderToCancel.Status = 'Rejected';
            orderToCancel.Note_for_canceled_orders__c = comment;
            update orderToCancel;
            return 'SUCCESS';
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}