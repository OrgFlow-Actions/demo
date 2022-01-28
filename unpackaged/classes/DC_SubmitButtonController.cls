/*
 * Author: SLegostaev
 * Created: 9/21/2017
 */
public class DC_SubmitButtonController {
    private final Case caze;
    
    private static final Set<String> EXCLUDED_APROVAL_STATUSES 
        = new Set<String> {'In Process', 'Approved', 'Exception Request'};

    public DC_SubmitButtonController(ApexPages.StandardController controller) {
        this.caze = (Case) controller.getRecord();
    }
    
    public PageReference submitArticlesForApproval() {
        RecordType caseRecordType = DC_RecordTypeDao.getRecordTypeByIdForObject(caze.RecordTypeId, 'Case');
        system.debug(caseRecordType);
        Set<String> allowCaseRecordTypes = getRecordTypesFrom(DC_SettingsUtils.CASE_RECORD_TYPE_NAME);
        system.debug(allowCaseRecordTypes);
        //system.debug(caseRecordType.Name.equals(allowCaseRecordType));
        //if (caseRecordType != null && caseRecordType.Name.equals(allowCaseRecordType)) {
        if (caseRecordType != null && allowCaseRecordTypes.contains(caseRecordType.Name)) {
            //final String allowArticleRecordType = DC_SettingsUtils.getStringValueByName(DC_SettingsUtils.ARTICLE_RECORD_TYPE_NAME);
            Set<String> allowArticleRecordTypes = getRecordTypesFrom(DC_SettingsUtils.ARTICLE_RECORD_TYPE_NAME);
            List<RecordType> articleRecordTypes = DC_RecordTypeDao.getRecordTypeByNamesForObject(allowArticleRecordTypes, 'Article__c');
            system.debug(articleRecordTypes);
            if (articleRecordTypes.isEmpty() == false) {
                system.debug(caseRecordType);
                List<Approval.ProcessSubmitRequest> requests = new List<Approval.ProcessSubmitRequest>();
                for (Article__c article : DC_ArticleDao.getArticlesByCaseId(caze.Id)) {
                    for (RecordType articleRecordType : articleRecordTypes) {
                        system.debug('article.RecordTypeId == articleRecordType.Id ' + (article.RecordTypeId == articleRecordType.Id));
                        system.debug('article.Article_Approval_Status__c ' + article.Article_Approval_Status__c);
                        if (article.RecordTypeId == articleRecordType.Id 
                            && (article.Article_Approval_Status__c == null || !EXCLUDED_APROVAL_STATUSES.contains(article.Article_Approval_Status__c))) {
                            requests.add(createApprovalRequest(article));
                        }
                    }
                }
                system.debug('requests: ' + requests);
                if (!requests.isEmpty()) {
                    Approval.process(requests, false);
                }
            }
            
        }
        return new PageReference('/' + caze.Id);
    }
    
    private Approval.ProcessSubmitRequest createApprovalRequest(Article__c article) {
         // Create an approval request for the article__c
        Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
        req1.setComments('Submitting request for approval.');
        req1.setObjectId(article.id);
        return req1;
    }
    
    private Set<String> getRecordTypesFrom(String settingsName) {
        system.debug('settingsName: ' + settingsName);
        final String value = DC_SettingsUtils.getStringValueByName(settingsName);
        system.debug('value: ' + value);
        return String.isBlank(value) ? new Set<String>() : new Set<String>(value.split(','));
    }
}