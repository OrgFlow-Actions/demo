/*Version History
 * Date: 09-Jan-2019
 * Class Name: ModifyCampaignDetailsTest
 * Created By: Sanjay Pandey/Nishi Jain
 * Related to: Campaign Tracker
 * Related Class: ModifyCampaignDetails.cls
 */
@isTest
private class ModifyCampaignDetailsTest {
    @isTest
    static void getCampaignDetailsMethod() {
        Campaign cam = new Campaign(name = 'Testcampaign', StartDate = Date.newInstance(2019, 01, 10), EndDate = Date.newInstance(2019, 01, 12), Status = 'Proposed', IsActive = true, of_Participants_Reported__c = 10, SBU_Focus__c = 'Implants');
        insert cam;
        
        Campaign camnew = new Campaign(name = 'TestcampaignNew', StartDate = Date.newInstance(2019, 01, 11), EndDate = Date.newInstance(2019, 01, 15), Status = 'Proposed', IsActive = true, of_Participants_Reported__c = 11, SBU_Focus__c = 'Implants');
        insert camnew;
        
        ModifyCampaignDetails.getCampaignDetails(cam.id);
        System.assertNotEquals(Null, cam);
        
        List<id> lstRecordId = new List<id>();
        lstRecordId.add(cam.id);
        lstRecordId.add(camnew.id);
        
        //ModifyCampaignDetails.filterSelectedRecords(lstRecordId);
        User u1 = new User();
        u1.LastName= 'tstUsr1';
        u1.Alias= 'tstUsr1';
        u1.TimeZoneSidKey= 'Asia/Taipei';
        u1.LocaleSidKey= 'en_US';
        u1.EmailEncodingKey= 'ISO-8859-1';
        u1.LanguageLocaleKey = 'en_US';
        u1.Username = 'Tst111@dentsplysirona.com';
        u1.Email = 'Tst@dentsplysirona.com';
        u1.ProfileId = [select id from profile where Name like '%Lightning Inside Sales Rep%' Limit 1][0].Id;
        insert u1;
        Account a = new Account(name = 'Testdata', Phone = '567', billingstate = 'California', billingcity = 'anah', billingcountry = 'United States', billingpostalcode = '92801', billingstreet = 'ls');
        insert a;
        List<Id> campIds = new List<Id>();
        campIds.add(cam.id);
        campIds.add(camnew.id);
        ModifyCampaignDetails.filterSelectedRecords(lstRecordId,a.Id);
        
        Contact con = New Contact(LastName = 'Test', AccountId = a.id);
        insert con;
        
        //Map<String, String> campStatusMap = new Map<String, String>();
       // campStatusMap.put('campId', '7011x0000001Y46');
        
        CampaignMember cm= New CampaignMember(ContactId= con.Id, Status='Busy',CampaignId = cam.id); 
        insert cm;
        
        List<RecordType> recTypId = [select id, developerName from RecordType where developerName Like '%Task_DI_New%'];
        
        List<RecordType> recTypId1 = [select id, developerName from RecordType where developerName Like '%DNA_Campaign_Response%'];
        
        Task task = new Task(OwnerId = u1.Id, Priority = 'Normal', Status = 'Not Started', RecordTypeId = recTypId[0].Id , WhatId = a.Id, IsReminderSet = true, Contact_Type__c = 'Dental Assistant', Astra_Tech_Type__c = 'Other');
        insert task;
        
        Task taskcam = new Task(OwnerId = u1.Id, Priority = 'Normal', Status = 'Not Started', RecordTypeId = recTypId1[0].Id, WhoId = cam.Id,WhatId = cm.Id, subject = 'Campaign Response', Contact_Type__c = 'Doctor');
        //insert taskcam;
        String camid = cam.id;
        String data = '{"notes":"notesTest", "pick1":"pick1Test", "pick2":"pick2Test", "pick3":"pick3Test", "campId": "' + camid + '"}';
        Date dt = System.today();
        String strDate = string.valueOfGmt(dt);       
        ModifyCampaignDetails.createTask(task, lstRecordId, cam.id);
        ModifyCampaignDetails.getPickValues_Typ();
        ModifyCampaignDetails.getPickValues_Act();
        ModifyCampaignDetails.getPickValues_Stat();
        ModifyCampaignDetails.updateTask(data, a.id);
        ModifyCampaignDetails.setReminderDate(strDate);
    }  
      
}