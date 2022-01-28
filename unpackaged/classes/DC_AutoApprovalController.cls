//Author: Sergey Legostaev
//Date: 04/19/2018
public class DC_AutoApprovalController {
	
    private final Case caze;
    
    public DC_AutoApprovalController(ApexPages.StandardController controller) {
        this.caze = (Case) controller.getRecord();
    }
    
    public PageReference approveArticles() {
        RecordType caseRecordType = DC_RecordTypeDao.getRecordTypeByIdForObject(caze.RecordTypeId, 'Case');
        Set<String> allowCaseRecordTypes = DC_SettingsUtils.getStringValuesByName(DC_SettingsUtils.AUTO_APPROVE_CASE_RECORD_TYPE);
        if (caseRecordType != null && allowCaseRecordTypes.contains(caseRecordType.Name)) {
        	DC_AutoApprovalService.approveArticlesForCase(caze.Id);
        }
    	return new PageReference('/' + caze.Id);
    }
}