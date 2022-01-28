/*
 * Author: SLegostaev
 * Created: 9/21/2017
 */
public class DC_ArticleDao {
    
    public static List<Article__c> getArticlesByCaseId(String caseId) {
        return [select Id, RecordTypeId, RecordType.Name, Article_Approval_Status__c from Article__c where Related_Case__c = :caseId];
    }
}