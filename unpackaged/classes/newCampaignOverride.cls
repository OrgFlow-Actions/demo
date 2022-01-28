/*-------------------------------------------------------------------------------------------------------
Description:  Extension class to VF page newCampaignOverridePage
History
20210906    Richard    Adjusted newCampaignOverride to set Campaign Member RT automatically for physical campaigns (TFUS-3500) 
20210922 	Miguel 	   Bug Fix: Adjusted CampaignMemberRecordType Id to the one from Production
----------------------------------------------------------------------------------------*/

public with sharing class newCampaignOverride {
    private final Campaign pp;
    private ApexPages.StandardController controller;
    public String rType {get; set;}
    public String rTypename {get; set;}
    public String Link {get; set;}
    public String campaignMemberRecordType {get; set;}
    
    
    User u = [Select Id, Name, User_Country__c, SBU_Ratio_IMPL__c, SBU_Ratio_ENDO__c, SBU_Ratio_ORTH__c, SBU_Ratio_PREV__c, SBU_Ratio_PROS__c, SBU_Ratio_REST__c, SBU_Ratio_CERE__c, SBU_Ratio_IMAG__c, SBU_Ratio_INST__c, SBU_Ratio_TRCE__c,NA_Regional_Marketing_Coordinator__c,ManagerId,User_Region__c From User Where id = :UserInfo.getUserId()];
    string SBU = 'Implants';
    double currentSBUPercentage = u.SBU_Ratio_IMPL__c == null ? 0 : u.SBU_Ratio_IMPL__c;
    {
        SBU = 'Implants';
        if(u.SBU_Ratio_ENDO__c != null && u.SBU_Ratio_ENDO__c > currentSBUPercentage){
            SBU = 'Endodontics';
            currentSBUPercentage = u.SBU_Ratio_ENDO__c;
        }
        
        if(u.SBU_Ratio_ORTH__c != null && u.SBU_Ratio_ORTH__c > currentSBUPercentage){
            SBU = 'Orthodontics';
            currentSBUPercentage = u.SBU_Ratio_ORTH__c;
        }
        
        if(u.SBU_Ratio_PREV__c != null && u.SBU_Ratio_PREV__c > currentSBUPercentage){
            SBU = 'Preventive';
            currentSBUPercentage = u.SBU_Ratio_PREV__c;
        }
        
        if(u.SBU_Ratio_PROS__c  != null && u.SBU_Ratio_PROS__c > currentSBUPercentage){
            SBU = 'Prosthetics';
            currentSBUPercentage = u.SBU_Ratio_PROS__c;
        }
        
        if(u.SBU_Ratio_REST__c != null && u.SBU_Ratio_REST__c > currentSBUPercentage){
            SBU = 'Restorative';
            currentSBUPercentage = u.SBU_Ratio_REST__c;
        }
        if(u.SBU_Ratio_CERE__c != null && u.SBU_Ratio_CERE__c > currentSBUPercentage){
            SBU = 'CAD/CAM';
            currentSBUPercentage = u.SBU_Ratio_CERE__c;
        }
        if(u.SBU_Ratio_IMAG__c != null && u.SBU_Ratio_IMAG__c > currentSBUPercentage){
            SBU = 'Imaging Systems';
            currentSBUPercentage = u.SBU_Ratio_IMAG__c;
        }
        if(u.SBU_Ratio_INST__c != null && u.SBU_Ratio_INST__c > currentSBUPercentage){
            SBU = 'Instruments';
            currentSBUPercentage = u.SBU_Ratio_INST__c;
        }
        if(u.SBU_Ratio_TRCE__c != null && u.SBU_Ratio_TRCE__c > currentSBUPercentage){
            SBU = 'Treatment Centers';
            currentSBUPercentage = u.SBU_Ratio_TRCE__c;
        }
    }
    
    
    
    public newCampaignOverride(ApexPages.StandardController controller) {
        
        this.controller = controller;
        pp = (Campaign)Controller.getRecord();
        Link = ApexPages.currentPage().getParameters().get('LinkOrder');
        campaignMemberRecordType = ApexPages.currentPage().getParameters().get('CMRT');
        If(Link == null){
            pp.SBU_Focus__c=SBU;
            rType = ApexPages.currentPage().getParameters().get('RecordType');
        }
        
        
        If(Link=='Program'){
            rType='01220000000Ax3B';
            pp.Campaign_Coordinator__c=u.NA_Regional_Marketing_Coordinator__c;
            pp.Campaign_Approver__c= u.ManagerId;
            pp.Campaign_Region_DE__c=u.User_Region__c;
            //pp.Strategy__c='All';
        }
        
        If(Link=='Sponsorship'){
            rType='01220000000B2A7';
            pp.Campaign_Coordinator__c=u.NA_Regional_Marketing_Coordinator__c;
            pp.Campaign_Approver__c= u.ManagerId;
            pp.Campaign_Region_DE__c=u.User_Region__c;
        }
        
        If(Link=='Trade'){
            rType='01220000000B29s';
            pp.Campaign_Coordinator__c=u.NA_Regional_Marketing_Coordinator__c;
            pp.Campaign_Approver__c= u.ManagerId;
            pp.Campaign_Region_DE__c=u.User_Region__c;
        }
        
        If(Link!='Trade' && Link!='Sponsorship'&& Link!='Program' && Link!=null){//Mean that it will be a campaign ID
            rType='01220000000ANcm';
            Campaign Ca = [Select Id,Name,StartDate,EndDate,Country__c,Profession__c,Target_Country__c,Target_Group__c,Target_Type__c,Strategy__c,SBU_Focus__c,Venue__c from Campaign where Id =: Link];
            pp.Parent_Event__c = ca.Id;
            pp.Session_Start_Date_Time__c = Ca.StartDate;
            pp.Session_End_Date_Time__c = Ca.EndDate;
            pp.SBU_Focus__c = ca.SBU_Focus__c;
            pp.Profession__c = Ca.Profession__c;
            pp.Target_Country__c = Ca.Target_Country__c;
            pp.Target_Group__c = Ca.Target_Group__c;
            pp.Target_Type__c = Ca.Target_Type__c;
            pp.Strategy__c = Ca.Strategy__c;
            pp.Venue__c = Ca.Venue__c;
        }
        
        rTypename=Schema.SObjectType.Campaign.getRecordTypeInfosById().get(rType).getDeveloperName();
        
        if(rType=='01220000000Ax7r' || rType=='01220000000ANcl'){
            pp.Campaign_Coordinator__c=u.Id;
        }
        if(rType!='01220000000ANcm'){ //not for Campaign sessions
            pp.Campaign_Country__c=u.User_Country__c;
            pp.Country__c=u.User_Country__c;
            pp.Target_Country__c=u.User_Country__c;
            
            
            pp.StartDate=date.today();
            pp.EndDate=date.today();
            pp.OwnerId=u.Id;
            
        }
        
        pp.RecordTypeId=rType;
        pp.CampaignMemberRecordTypeId=campaignMemberRecordType;
        
        if(rTypename == 'InPersonEventCampaign'){
			// Production Campaign Member RT Id 
			pp.CampaignMemberRecordTypeId = '0126M000000jouBQAQ';
        }
        
    }
    public pagereference SBU(){
        Return null;
    }
    public PageReference cancel1(){
        If(Link==null){
            PageReference pr = new PageReference('/701/o');
            pr.setRedirect(true);
            
            return pr;
        }else{
            If(Link.startsWith('701')){
                PageReference pr = new PageReference('/' + Link);
                pr.setRedirect(true);
                return pr;
            }else{
                PageReference pr = new PageReference('/701/o');
                pr.setRedirect(true);
                
                return pr;
            }
        }
        //pr=PageReference('/' + Link);
    }
    
    public PageReference save1(){
        PageReference page;
        page = controller.save();
        if(ApexPages.hasMessages()){
            return page;
        }else{
            return page;}
    }
}