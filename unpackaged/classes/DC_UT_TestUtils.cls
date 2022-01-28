//Author: Sergey Legostaev (slegostaev@mycervello.com) 
//Created: 8/15/2017
@isTest
public class DC_UT_TestUtils {
    
    public static void createTerritorySettings() {
        DC_User_Territory_Mapping__c territorySettings = new DC_User_Territory_Mapping__c();
        system.assert(territorySettings != null, 'DC_User_Territory_Mapping__c should not be null');
        territorySettings.Name = DC_TerritorySettings.TERRITORY_SETTINGS_NAME;
        territorySettings.User_Territory_1__c = 'Territory_1_User__c';
        territorySettings.User_Territory_2__c = 'Territory_2_User__c';
        territorySettings.User_Territory_3__c = 'Territory_3_User__c';
        territorySettings.User_Territory_4__c = 'Territory_4_User__c';
        territorySettings.User_Territory_7__c = 'Territory_7_User__c';
        territorySettings.User_Territory_9__c = 'Territory_9_User__c';
        territorySettings.User_Territory_10__c = 'Territory_10_User__c';
        territorySettings.User_Territory_11__c = 'Territory_11_User__c';
        territorySettings.User_Territory_17__c = 'Territory_17_User__c';
        territorySettings.User_Territory_20__c = 'Territory_20_User__c';
        territorySettings.User_Territory_24__c = 'Territory_24_User__c';
        territorySettings.User_Territory_25__c = 'Territory_25_User__c';
        insert territorySettings;
    }
    
    public static Account createAccount() {
        Account acc = new Account(Name = 'test account');
        acc.BillingPostalCode = '02110';
        insert acc;
        return acc;
    }
    
    public static Postal_Codes__c createPostalCodes() {
        Postal_Codes__c postalCodes = new Postal_Codes__c(Name = '02110',DC_ETM_Code_Last_Updated__c = DateTime.newInstance(2017, 01, 01));
        insert postalCodes;
        return postalCodes;
    }
}