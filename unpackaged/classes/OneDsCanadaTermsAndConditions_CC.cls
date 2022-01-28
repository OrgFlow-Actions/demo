/*-------------------------------------------------------------------------------------------------------
Author:         Kevin Ruibin Do (Salesforce) 20200911
Description:    Custom controller for OneDSCanadaTermsAndConditions vf page
                TFUS-000002124
Tesst Class:    Test_OneDSCanadaTermsAndConditions_CC
History:        20200911    Kevin Ruibin Do - Created Class
--------------------------------------------------------------------------------------------------------*/

public without sharing class OneDsCanadaTermsAndConditions_CC {
    private final LoyaltyProgramParticipant__c lPParticipant { get; set; }
    private final OneDSTermsAndConditionsSetting__mdt pageSetting { get; set; }

    public String title { get; set; }
    public String infoText { get; set; }
    
    public String documentLink { get; set; }
    public String termsAndConditionsLabel { get; set; }
    
    public String firstName { get; set; }
    public String firstNameLabel { get; set; }
    
    public String lastName { get; set; }
    public String lastNameLabel { get; set; }
    
    public String practiceName { get; set; }
    public String practiceNameLabel { get; set; }

    public String paymentPreference { get; set; }
    public String paymentPreferenceLabel { get; set; }
    
    public String email { get; set; }
    public String emailLabel { get; set; }

    public String consentLabel { get; set; }
    public String consentStatement { get; set; }

    public String submitLabel { get; set; }
    public String successMessage { get; set; }
    public String errorMessage { get; set; }
    
    public Boolean hasAccepted { get; set; }
    public Boolean error { get; set; }
    public Boolean isSubmitted { get; set; }
    
    public String customerId { get; set; }

    // Default values
    {
        title = 'One DS Rewards Terms and Conditions';
        errorMessage = 'Something went wrong';
    }

    public OneDsCanadaTermsAndConditions_CC(/* ApexPages.StandardController stdController */) {
        // Get the id url parameter to use as query key
        customerId = Apexpages.currentPage().getParameters().get('id');
        String preferredLanguage = 'English';

        List<LoyaltyProgramParticipant__c> lPParticipantList = new List<LoyaltyProgramParticipant__c>();
        List<OneDSTermsAndConditionsSetting__mdt> OneDSTermsAndConditionsSettingList = new List<OneDSTermsAndConditionsSetting__mdt>();

        try {
            // Query participant record that has a matching ExternalID__c to the id url-parameter

            // TODO EMAIL readonly populated from related Contact
            lPParticipantList = [
                SELECT Name, FirstName__c, LastName__c, PracticeName__c, Email__c, AcceptedTermsAndConditions__c, TermsAndConditionsConsentDate__c, PaymentPreference__c, Contact__c, Contact__r.Preferred_Language__c, Contact__r.Email, LoyaltyProgram__r.Name, Account__r.Name
                FROM LoyaltyProgramParticipant__c
                WHERE ExternalId__c =: customerId
                LIMIT 1
            ];

            if (!lPParticipantList.isEmpty()) {
                // Query custom metadata type record with correct language settings
                lPParticipant = lPParticipantList[0];
                if (String.isNotBlank(lPParticipant.Contact__r.Preferred_Language__c)) preferredLanguage = lPParticipant.Contact__r.Preferred_Language__c;
                String programName = lPParticipant?.LoyaltyProgram__r?.Name;
                // preferredLanguage = lPParticipant.Contact__r.Preferred_Language__c;
                OneDSTermsAndConditionsSettingList = [
                    SELECT Title__c, InfoText__c, DocumentPublicLink__c, LabelTermsAndConditions__c, LabelFirstName__c, LabelLastName__c, LabelPracticeName__c, LabelPaymentPreference__c, LabelEmail__c, LabelConsent__c, ConsentStatement__c, LabelSubmit__c, SuccessMessage__c, Language__c
                    FROM OneDSTermsAndConditionsSetting__mdt
                    WHERE Language__c = :preferredLanguage AND ProgramName__c = :programName
                    LIMIT 1
                ];
            }

            if (!OneDSTermsAndConditionsSettingList.isEmpty()) {
                // Check if customer has already accepted T&C
                hasAccepted = lPParticipant.AcceptedTermsAndConditions__c;
                firstName = lPParticipant.FirstName__c;
                lastName = lPParticipant.LastName__c;
                practiceName = String.isNotEmpty(lPParticipant.PracticeName__c) ? lPParticipant.PracticeName__c : lPParticipant.Account__r?.Name;
                paymentPreference = lPParticipant.PaymentPreference__c;
                email = lPParticipant.Contact__r.Email;
                // Set labels and text based on the cusstomm metadata type record
                pageSetting = OneDSTermsAndConditionsSettingList[0];
                title = pageSetting.Title__c;
                infoText = pageSetting.InfoText__c;
                documentLink = pageSetting.DocumentPublicLink__c;
                termsAndConditionsLabel = pageSetting.LabelTermsAndConditions__c;
                firstNameLabel = pageSetting.LabelFirstName__c;
                lastNameLabel = pageSetting.LabelLastName__c;
                practiceNameLabel = pageSetting.LabelPracticeName__c;
                paymentPreferenceLabel = pageSetting.LabelPaymentPreference__c;
                emailLabel = pageSetting.LabelEmail__c;
                consentLabel = pageSetting.LabelConsent__c;
                consentStatement = pageSetting.ConsentStatement__c;
                submitLabel = pageSetting.LabelSubmit__c;
                successMessage = pageSetting.SuccessMessage__c;
            } else {
                error = true;
            }
        } catch (Exception e) {
            error = true;
        }
    }

    public PageReference accept() {
        //TODO email consent should be set as yes

        // Custom validation if user has clicked the accept checkbox, surface error if not
        if(!hasAccepted) {
            Apexpages.addMessage(
                new ApexPages.Message(
                    ApexPages.Severity.ERROR,
                    'Please accept the terms and conditions before submitting.'
                )
            );
            return null;
        }

        // Assign LoyaltyProgramParticipant__c field values from form
        lPParticipant.FirstName__c = firstName;
        lPParticipant.LastName__c = lastName;
        lPParticipant.PracticeName__c = practiceName;
        lPParticipant.Email__c = email;
        lPParticipant.AcceptedTermsAndConditions__c = hasAccepted;
        lPParticipant.TermsAndConditionsConsentDate__c = System.now();
        lPParticipant.TermsAndConditionsDocumentLink__c = pageSetting.DocumentPublicLink__c;

        // Query and set information on related Contact record
        Contact contactToUpdate = [
            SELECT Id, Email_Consent_Collected__c, WhenCollected__c, WhereCollected__c, HowCollected__c
            FROM Contact
            WHERE Id = :lPParticipant.Contact__c
        ];
        // contactToUpdate.Email_Consent_collected__c = 'Yes';
        contactToUpdate.InsertEmailMarketingConsentCollected__c = 'Yes';
        contactToUpdate.WhenCollected__c = lPParticipant.TermsAndConditionsConsentDate__c;
        contactToUpdate.WhereCollected__c = 'Canada One DS Terms and Conditions Site';
        contactToUpdate.HowCollected__c = 'Digitally';
        
        Savepoint sp = Database.setSavepoint();
        try {
            update lPParticipant;
            update contactToUpdate;
        } catch (Exception e) {
            Database.rollback(sp);
            error = true;
            DebugLog.addException(e, 'OneDsCanadaTermsAndConditions_CC DML error');
        }
        
        isSubmitted = true;
        return null;
    }
}