/*-------------------------------------------------------------------------------------------------------
Author: 		Ahmed LOUDRASSI (Salesforce) 20191218
Description:   	EmailMessage Trigger Handler Class
History	
--------------------------------------------------------------------------------------------------------*/
public class EmailMessageTriggerHandler extends TriggerHandler {
	private List<EmailMessage> oldEmailMessageList, newEmailMessageList;
    private Map<Id, EmailMessage> oldEmailMessageMap, newEmailMessageMap;
    
    public EmailMessageTriggerHandler() {
        oldEmailMessageList = (List<EmailMessage>) Trigger.old;
        newEmailMessageList = (List<EmailMessage>) Trigger.new;
        oldEmailMessageMap = (Map<Id, EmailMessage>) Trigger.oldMap;
        newEmailMessageMap = (Map<Id, EmailMessage>) Trigger.newMap;
    }
    protected override void beforeDelete() {
        EmailMessageTriggerHelper.preventDeleteEmailMessages(oldEmailMessageList);
    }
}