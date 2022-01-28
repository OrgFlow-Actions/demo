/*-------------------------------------------------------------------------------------------------------
Author:         Kevin Ruibin Do (Salesforce) 20200903
Description:    LoyaltyProgramParticipant__c Trigger Helper Class
History 
20200903        Kevin Ruibin Do - Created LoyaltyProgramParticipantTriggerHelper
20200903        Kevin Ruibin Do - Created Class
--------------------------------------------------------------------------------------------------------*/

/**
 * Author: Kevin Ruibin Do
 * Description: Generates random string and assigns that to ExternalId__c
 */
public with sharing class LoyaltyProgramParticipantTriggerHelper {
    public static void setExternalId(List<LoyaltyProgramParticipant__c> newLoyaltyProgramParticipantList) {
        for(LoyaltyProgramParticipant__c lPParticipant : newLoyaltyProgramParticipantList) {
            Blob b = Crypto.GenerateAESKey(128);
            String h = EncodingUtil.ConvertTohex(b);
            String guid = h.SubString(0,8)+ '-' + h.SubString(8,12) + '-' + h.SubString(12,16) + '-' + h.SubString(16,20) + '-' + h.substring(20);
            lPParticipant.ExternalId__c = guid;
        }
    }
}