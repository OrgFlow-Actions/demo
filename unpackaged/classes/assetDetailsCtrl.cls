public class assetDetailsCtrl {
    
    @AuraEnabled
    public static Asset getAsset(String recordId, String objectType){
        String query = 'SELECT AssetId FROM ' + objectType + ' WHERE Id = \'' + recordId + '\'';
        List<sObject> sobjList = Database.query(query);
        
        String assetIdNum = String.valueOf(sobjList[0].get('AssetId'));
        System.debug(assetIDNum);

        Asset thisAsset = [SELECT Name, Status,Contact.Name, ContactId, SerialNumber
                           FROM Asset WHERE Id = :assetIDNum];        
        return thisAsset;
    }

}