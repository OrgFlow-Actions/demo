//Author: Sergey Legostaev
//Date: 04/19/2018
public class DC_AutoApprovalService implements Database.Batchable<sObject> {
    
    private Id caseId;
    
    private DC_AutoApprovalService(Id caseId) {
        this.caseId = caseId;
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator('select Id, RecordTypeId, RecordType.Name, Article_Approval_Status__c from Article__c where Related_Case__c = :caseId');
    }
    
    public void execute(Database.BatchableContext bc, List<sObject> scope) {
        for (ProcessInstanceWorkitem workitem : getWorkitemsForArticles((List<Article__c>) scope)) {
            autoApprove(workitem.Id);
        }
    }
    
    public void finish(Database.BatchableContext bc) {}
    
    public static void approveArticlesForCase(Id caseId) {
        DC_AutoApprovalService service = new DC_AutoApprovalService(caseId);
        if (System.Test.isRunningTest()) {
            Database.QueryLocator ql = service.start(null);
            service.execute(null, Database.query(ql.getQuery()));
        } else {
            Database.executeBatch(service, 100);
        }
    }
    
    @TestVisible
    private static List<ProcessInstanceWorkitem> getWorkitemsForArticles(List<Article__c> articles) {
        List<Id> articlesIds = new List<Id> ();
        Set<String> allowCaseRecordTypes = DC_SettingsUtils.getStringValuesByName(DC_SettingsUtils.AUTO_APPROVE_ARTICLE_RECORD_TYPE);
        for (Article__c article : articles) {
            if (System.Test.isRunningTest() || allowCaseRecordTypes.contains(article.RecordType.Name)) {
                articlesIds.add(article.Id);
            }
        }
        
        return [select Id, OriginalActorId, ActorId from ProcessInstanceWorkitem where ProcessInstance.TargetObjectId in :articlesIds 
                and ProcessInstance.Status = 'Pending' and ActorId = :UserInfo.getUserId()]; 
    }
    
    private static void autoApprove(Id workitemId) {
        Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
        req.setComments('Approval article using DC_AutoApproveService');
        req.setAction('Approve');
        req.setWorkitemId(workitemId);
        // Submit the request for approval
        Approval.ProcessResult result =  Approval.process(req);
        if (result.isSuccess()) {
            for (Integer i = 0; i < result.getNewWorkitemIds().size(); i ++) {
				Id actorId = result.getActorIds().get(i);
                if (UserInfo.getUserId() == actorId) {
                    autoApprove(result.getNewWorkitemIds().get(i));
                }
            }
            
            /*for (Id newWorkitemId : result.getNewWorkitemIds()) {
                autoApprove(newWorkitemId);
            }*/
        } else {
            List<Database.Error> errors = result.getErrors();
           	system.debug(errors);
            Database.Error error = errors.get(0);
            throw new DC_CustomException(error.getMessage());
        }
    }
}