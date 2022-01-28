/*Version History
 * Date: 05-Dec-2018
 * Class Name: ModifyCampaignDetails
 * Created By: Sanjay Pandey
 * Related to: Account Lightning Page 
 * Related Test Class: ModifyCampaignDetailsTest.cls
 */
public with Sharing class ModifyCampaignDetails {
    public static List<Task>createTaskList =  new List<Task>();
    public static Map<String, String> campStatusMap = new Map<String, String>();
    
    @AuraEnabled
    public static List<Campaign> getCampaignDetails(Id accountId) {
        List<Campaign> camp = [SELECT Name, (SELECT Status FROM CampaignMembers where contactid in(SELECT id FROM Contact where Accountid =: accountId)),(SELECT Offer_Code__r.Name from Campaign_Offer_Codes__r) FROM Campaign where IsActive = true AND RecordType.Name = 'Inside Sales Campaign' AND id in(SELECT CampaignId FROM CampaignMember where Account__c =: accountId) limit 25];
        
        return camp;
    }
     @AuraEnabled
    public static String setReminderDate(String dueDate) {
        DateTime nw = System.now();
        string dateTimeStr = nw.formatGMT('yyyy-MM-dd HH:mm:ss');
        String[] splDt = dateTimeStr.split('\\s+');
        String dtNewStr = dueDate + ' ' + splDt[1];
        Datetime dtNew = DateTime.valueOfGMT(dtNewStr);
        //2019-03-16T00:00:00.000Z
        String formattedDate = dtNew.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');       
        return formattedDate ;        
    }
    
    @AuraEnabled
    public static List<Campaign> filterSelectedRecords(List<id> lstRecordId, Id accountId) {
        List<Campaign> campfil = [SELECT Id, Name, (SELECT Id,Status FROM CampaignMembers where contactid in(SELECT id FROM Contact where Accountid =: accountId)),(SELECT Offer_Code__r.Name from Campaign_Offer_Codes__r) FROM Campaign where id IN :lstRecordId];
        return campfil;
    }
    
    @AuraEnabled
    public static void createTask (Task task, List<id> selectedRecordsIds, Id accountId){
        task.OwnerId = UserInfo.getUserId();
        task.Priority = 'Normal';
        task.Status = 'Not Started';
        task.RecordTypeId = [Select Id From RecordType where Name ='Task DI' and SobjectType ='Task' limit 1].Id;
        task.WhatId = accountId;
        task.IsReminderSet = true;
        try{
            if(task != null){
                insert task;
            }
        }
        catch (Exception ex){
     
        }
    
    }
    
  
    @AuraEnabled
    public static List < String > getPickValues_Typ() {
    List < String > allOpts = new list < String > ();

    Schema.DescribeFieldResult fieldResult = ActivityHistory.Contact_Type__c.getDescribe();
    List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
    for( Schema.PicklistEntry pickListVal : ple){
        allOpts.add(pickListVal.getLabel());
    }    

    allOpts.sort();
    return allOpts;
    }
     @AuraEnabled
    public static List < String > getPickValues_Act() {
        List < String > allOpts = new list < String > ();
        Schema.DescribeFieldResult fieldResult = ActivityHistory.Activity_Result__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple){
            allOpts.add(pickListVal.getLabel());
        }    

        allOpts.sort();
        return allOpts;
    }  
    @AuraEnabled
    public static List < String > getPickValues_Stat() {
        List < String > allOpts = new list < String > ();      
        Schema.DescribeFieldResult fieldResult = Inside_Sales_Campaign_Picklist__mdt.Picklist_Value__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple){
            allOpts.add(pickListVal.getLabel());
        }  
        return allOpts;
    }   
    @AuraEnabled
    public static void updateTask(String data, Id accountId) {
        JSONParser parser = JSON.createParser(data);
        Map<String,String> dataParsed = new Map<String,String>();
        List<Map<String,String>> dataList = new List<Map<String,String>>();
        List<CampaignMember> updateCampMemberList = new List<CampaignMember>();
        List<Id> campIds = new List<Id>();
        while(parser.nextToken()!= null){
            if(parser.getCurrentToken()==JSONToken.END_OBJECT){
                dataList.add(dataParsed);
                dataParsed = new Map<String,String>();
            }
            if((parser.getCurrentToken() == JSONToken.FIELD_NAME) && parser.getText()=='notes'){
                parser.nextToken();
                dataParsed.put('notes',parser.getText());
            }else if((parser.getCurrentToken() == JSONToken.FIELD_NAME) && parser.getText()=='pick1'){
                parser.nextToken();
                dataParsed.put('pick1',parser.getText());
            }else if((parser.getCurrentToken() == JSONToken.FIELD_NAME) && parser.getText()=='pick2'){
                parser.nextToken();
                dataParsed.put('pick2',parser.getText());
            }else if((parser.getCurrentToken() == JSONToken.FIELD_NAME) && parser.getText()=='pick3'){
                parser.nextToken();
                dataParsed.put('pick3',parser.getText());
            }else if((parser.getCurrentToken() == JSONToken.FIELD_NAME) && parser.getText()=='campId'){
                parser.nextToken();
                dataParsed.put('campId',parser.getText());
                campIds.add(parser.getText());
            }
        }
        Map<Id,Id> CampContactMap = new Map<Id,Id> ();
        //for(CampaignMember camp : [select CampaignId, ContactId FROM CampaignMember WHERE CampaignId in: campIds]){
        for(CampaignMember camp : [SELECT ContactId,CampaignId  FROM CampaignMember where contactid in(SELECT id FROM Contact where Accountid =: accountId) AND CampaignId in: campIds]){
            CampContactMap.put(camp.CampaignId,Camp.ContactId);
        }
        //({notes=testt, pick1=value1, pick2=value2, pick3=value3}, {notes=testt, pick1=value1, pick2=value2, pick3=value3})
        for(Map<String,String> each : dataList){
            Task tskRec =  new Task();
            tskRec.OwnerId = UserInfo.getUserId();
            tskRec.Priority = 'Normal';
            tskRec.Status = 'Completed';
            tskRec.subject = 'Campaign Response';
            tskRec.RecordTypeId = [Select Id From RecordType where Name ='DNA: Campaign Response' and SobjectType ='Task' limit 1].Id;
            tskRec.Description = each.get('notes');
            tskRec.WhatId = each.get('campId');
            tskRec.WhoId = CampContactMap.get(each.get('campId'));
            tskRec.Contact_Type__c =each.get('pick2');
            tskRec.Activity_Result__c = each.get('pick1');
            tskRec.ActivityDate = System.Today();
            createTaskList.add(tskRec);
            campStatusMap.put(each.get('campId'), each.get('pick3'));
            
        }
        List<CampaignMember> cmpMemberList = [select Id, Status,contactid, CampaignId  from CampaignMember where CampaignId IN : campStatusMap.keySet() and contactid in(SELECT id FROM Contact where Accountid =: accountId)];
        for(CampaignMember each : cmpMemberList ){
            if(each.Status != campStatusMap.get(each.CampaignId)){
                each.status = campStatusMap.get(each.CampaignId);
                updateCampMemberList.add(each);
            }
        }
        try{
            if(createTaskList != null){
                insert createTaskList;
            }
        }
        catch(Exception e){
            System.debug('Exception occured--' + e);
        }
        try{
            if(updateCampMemberList != null){
            update updateCampMemberList;
            }
        }
        catch(Exception e){
            System.debug('Exception occured--' + e);
        }
    }
}