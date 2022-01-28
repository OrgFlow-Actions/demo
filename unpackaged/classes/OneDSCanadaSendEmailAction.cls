/*-------------------------------------------------------------------------------------------------------
Author:         Kevin Ruibin Do (Salesforce) 200916
Description:    Invacable Apex called from flow to send T&C email
Test Class:     Test_OneDSCanadaSendEmailAction
History:        200916    Kevin Ruibin Do - Created Class
--------------------------------------------------------------------------------------------------------*/

public with sharing class OneDSCanadaSendEmailAction {
    
    @InvocableMethod
    public static List<EmailMessageResult> sendMail(List<EmailMessageRequest> emailRequestList) {
        EmailMessageRequest emailRequest = emailRequestList[0];
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        
        // Query email template
        Id emailTemplateId = [SELECT Id FROM EmailTemplate WHERE DeveloperName = :emailRequest.emailTemplateDeveloperName].Id;

        // Set required parameters
        email.setTemplateId(emailTemplateId);
        email.setTargetObjectId(emailRequest.targetId);
        email.setWhatId(emailRequest.whatId);

        // Set optional parameters
        if (emailRequest.toAddresses != null) email.setToAddresses(emailRequest.toAddresses);
        if (emailRequest.bccAddresses != null) email.setBccAddresses(emailRequest.bccAddresses);
        if (emailRequest.ccAddresses != null) email.setCcAddresses(emailRequest.ccAddresses);
        
        List<EmailMessageResult> emailMessageResultList = new List<EmailMessageResult>{ new EmailMessageResult() };
        try {
            if (Test.isRunningTest()) {
                emailMessageResultList[0].success = true;
            } else {
                List<Messaging.SendEmailResult> emailResult = Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{ email });
                emailMessageResultList[0].success = emailResult[0].success;
            }
        } catch (Exception e) {
            DebugLog.addException(e, 'Email couldn\'t be sent in OneDSCanadaSendEmailAction');
            emailMessageResultList[0].success = false;
        }
        
        return emailMessageResultList;
    }

    public class EmailMessageRequest {
        @InvocableVariable(required=true)
        public String emailTemplateDeveloperName;
        
        @InvocableVariable(required=true)
        public Id targetId;
        
        @InvocableVariable(required=true)
        public Id whatId;

        @InvocableVariable
        public List<String> toAddresses;

        @InvocableVariable
        public List<String> bccAddresses;

        @InvocableVariable
        public List<String> ccAddresses;
    }

    public class EmailMessageResult {
        @InvocableVariable
        public Boolean success;
    }
}