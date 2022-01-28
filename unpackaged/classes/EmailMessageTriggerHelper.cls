/*-------------------------------------------------------------------------------------------------------
Author: 		Ahmed LOUDRASSI (Salesforce) 20191218
Description:   	EmailMessage Trigger Helper Class
History	
--------------------------------------------------------------------------------------------------------*/
public class EmailMessageTriggerHelper {

    /*------------------------------------------------------------
    Description:    Prevent Deletion of EmailMessages related to Cases
    Inputs:         @param oldEmailMessageList
    ------------------------------------------------------------*/
    public static void preventDeleteEmailMessages(List<EmailMessage> oldEmailMessageList) {
        for(EmailMessage emailMessage : oldEmailMessageList) {
            if(emailMessage.RelatedToId != null 
               && 'Case'.equals(emailMessage.RelatedToId.getSObjectType().getDescribe().getName())) {
                emailMessage.adderror(Label.PreventDeleteEmailMessage);
            }
        }
    }
}