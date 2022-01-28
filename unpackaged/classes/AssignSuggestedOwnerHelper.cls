/**
 * @description       : This class provides helper methods for BatchSalesLeadAssignSuggestedOwner and BatchOpportunityAssignSuggestedOwner
 * @author            : kdoruibin@salesforce.com
 * @group             : 
 * @last modified on  : 06-15-2021
 * @last modified by  : kdoruibin@salesforce.com
 * Modifications Log 
 * Ver   Date         Author                     Modification
 * 1.0   06-15-2021   kdoruibin@salesforce.com   Initial Version
**/
public without sharing class AssignSuggestedOwnerHelper {
    private static Map<String, List<LeadOpportunitySetting__mdt>> leadOpptySettingMap = new Map<String, List<LeadOpportunitySetting__mdt>>();
    private static Map<Id,List<Id>> accountTerritoryMap = new Map<Id,List<Id>>();
    private static Set<Id> flattenedTerritoryIdSet = new Set<Id>();
    private static Map<Id, Map<String, UserTerritory2Association>> territoryIdUserAssociationMap = new Map<Id, Map<String, UserTerritory2Association>>();

    public static void initialize(Set<Id> accountIdSet) {
        leadOpptySettingMap = getLeadOpportunitySettings();
        accountTerritoryMap = getAccountTerritoryMap(accountIdSet);
        flattenedTerritoryIdSet = getFlattenedTerritoryIdSet(accountTerritoryMap);
        territoryIdUserAssociationMap = getTerritoryIdUserAssociationMap(flattenedTerritoryIdSet);
    }
    
    public static Map<String, List<LeadOpportunitySetting__mdt>> getLeadOpportunitySettings() {
        Map<String, List<LeadOpportunitySetting__mdt>> leadOpptySettingMap = new Map<String, List<LeadOpportunitySetting__mdt>>();
        for (LeadOpportunitySetting__mdt leadOpptySetting : LeadOpportunitySetting__mdt.getAll().values()) {
            // Skip setting if mandatory fields are empty
            if (String.isEmpty(leadOpptySetting.Country__c)) continue;
            if (String.isEmpty(leadOpptySetting.Category__c)) continue;
            if (String.isEmpty(leadOpptySetting.UserRoles__c)) continue;
            if (String.isEmpty(leadOpptySetting.Brands__c)) continue;
            
            // Construct Map of settings with Country__c + Category__c as key (e.g. USImplants)
            String settingKeyString = leadOpptySetting.Country__c + leadOpptySetting.Category__c;
            if (leadOpptySettingMap.containsKey(settingKeyString)) {
                leadOpptySettingMap.get(settingKeyString).add(leadOpptySetting);
                } else {
                leadOpptySettingMap.put(settingKeyString, new List<LeadOpportunitySetting__mdt>{leadOpptySetting});
            }
        }
        return leadOpptySettingMap;
    }

    public static Map<Id,List<Id>> getAccountTerritoryMap(Set<Id> accountIdSet) {
        Map<Id,List<Id>> accountTerritoryMap = new Map<Id,List<Id>>();
        for (ObjectTerritory2Association accTerritoryAssociation : [
                SELECT ObjectId, Territory2Id
                FROM ObjectTerritory2Association
                WHERE ObjectId IN :accountIdSet
            ]) {
                // Construct Map of accounts and territories where an accountId leads to a list of associated territories
                if (accountTerritoryMap.containsKey(accTerritoryAssociation.ObjectId)) {
                    accountTerritoryMap.get(accTerritoryAssociation.ObjectId).add(accTerritoryAssociation.Territory2Id);
                } else {
                    accountTerritoryMap.put(accTerritoryAssociation.ObjectId, new List<Id>{accTerritoryAssociation.Territory2Id});
                }
            }
        return accountTerritoryMap;
    }

    public static Set<Id> getFlattenedTerritoryIdSet(Map<Id,List<Id>> listMap) {
        Set<Id> flattenedIdSet = new Set<Id>();
        for (List<Id> idList : listMap.values()) {
            flattenedIdSet.addAll(idList);
        }
        return flattenedIdSet;
    }

    public static Map<Id, Map<String, UserTerritory2Association>> getTerritoryIdUserAssociationMap(Set<Id> flattenedTerritoryIdSet) {
        Map<Id, Map<String, UserTerritory2Association>> territoryIdUserAssociationMap = new Map<Id, Map<String, UserTerritory2Association>>();
        for (UserTerritory2Association userTerritoryAssociation : [
                SELECT Id, Territory2Id, UserId, RoleInTerritory2
                FROM UserTerritory2Association
                WHERE Territory2Id IN :flattenedTerritoryIdSet
            ]) {
                // Construct Map of territories and associated users based on RoleInTerritory2
                if (territoryIdUserAssociationMap.containsKey(userTerritoryAssociation.Territory2Id)) {
                    territoryIdUserAssociationMap.get(userTerritoryAssociation.Territory2Id).put(userTerritoryAssociation.RoleInTerritory2, userTerritoryAssociation);
                } else {
                    territoryIdUserAssociationMap.put(userTerritoryAssociation.Territory2Id, new Map<String, UserTerritory2Association>{userTerritoryAssociation.RoleInTerritory2 => userTerritoryAssociation});
                }
            }
        return territoryIdUserAssociationMap;
    }
}