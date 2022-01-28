@isTest
public class DC_UT_AutoApprovalController {
	
    private static Case caze;
    private static Article__c article;
    
    private static final String CASE_RECORD_TYPE = 'Return Authorizations';
    private static final String ARTICLE_RECORD_TYPE = 'Return Authorization';
    
    private static void beforeTest() {
        
        User currentUser = new User(Id = UserInfo.getUserId());
        currentUser.Market__c = 'NA';
        update currentUser;
        
        RecordType rt = [select Name from RecordType where Name = :CASE_RECORD_TYPE];
        
        //create test Case
        caze = new Case();
        caze.RecordTypeId = rt.Id;
        insert caze;
        
        rt = [select Name from RecordType where Name = :ARTICLE_RECORD_TYPE];
        //create Article__c object
        article = new Article__c();
        article.Related_Case__c = caze.Id;
        article.RecordTypeId = rt.Id;
        article.Return_Exception_Requested__c = 'Writing on Product';
        article.Rep_Assigned__c = UserInfo.getUserId();
        article.Manager_Assigned__c = UserInfo.getUserId();
        insert article;
        
        //create custom settings for test
        DC_Setting__c settings = new DC_Setting__c();
        settings.Name = DC_SettingsUtils.AUTO_APPROVE_CASE_RECORD_TYPE;
        settings.Value__c = CASE_RECORD_TYPE;
        insert settings;
        
        DC_Setting__c settings2 = new DC_Setting__c();
        settings2.Name = DC_SettingsUtils.AUTO_APPROVE_ARTICLE_RECORD_TYPE;
        settings2.Value__c = ARTICLE_RECORD_TYPE;
        insert settings2;
    }
    
    private static testMethod void approveArticlesForCaseTest() {
        beforeTest();
        system.assertNotEquals(null, caze.Id);
        
        Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
        req1.setComments('Submitting request for approval.');
        req1.setObjectId(article.id);
        Approval.ProcessResult result = Approval.process(req1, false);
        System.assert(result.isSuccess());
        List<ProcessInstanceWorkitem> workitems = DC_AutoApprovalService.getWorkitemsForArticles(new List<Article__c> { article });
        system.assertEquals(1, workitems.size());
        
        List<Article__c> articles = DC_ArticleDao.getArticlesByCaseId(caze.Id);
        system.debug(articles);
        
        //DC_AutoApprovalService.approveArticlesForCase(caze.Id);
        ApexPages.StandardController sc = new ApexPages.StandardController(caze);
        DC_AutoApprovalController controller = new DC_AutoApprovalController(sc);
        controller.approveArticles();
        
        workitems = DC_AutoApprovalService.getWorkitemsForArticles(new List<Article__c> { article });
        system.assertEquals(0, workitems.size());
    }    
}