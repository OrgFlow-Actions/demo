/*-------------------------------------------------------------------------------------------------------
Author:         Kevin Do (Salesforce) 20190926
Description:    Test data factory for all Test classes.
Test Class:     N/A
History
20190926    Kevin Do    Created class
20200630    Roberto     Created  methods createAccountMergeRequests, returnAccountMergeRequests
20211101    Nihad       Created  method createObjective
--------------------------------------------------------------------------------------------------------*/

@isTest(seeAllData=false)
public class TestDataFactory {

    /*-------------------------------------------------------------------------------------------------------
    Author: Salesforce
    Description: Creates the GlobalBypassProcessesSettings__c needed to run automation
    --------------------------------------------------------------------------------------------------------*/
    public static GlobalBypassProcessesSettings__c createBypassCustomSetting(){
        List<GlobalBypassProcessesSettings__c> existingbypassSettings = [Select Id from GlobalBypassProcessesSettings__c]; 
        if (!existingbypassSettings.isEmpty()) return existingbypassSettings.get(0);
        GlobalBypassProcessesSettings__c bypassSetting = new GlobalBypassProcessesSettings__c();
        bypassSetting.RunTriggers__c  = true;
        bypassSetting.RunProcessBuilder__c = true;
        insert bypassSetting;
        return bypassSetting;
    }

    public static GlobalBypassProcessesSettings__c createBypassCustomSetting(Boolean runTriggers, Boolean runProcesBuilder){
        List<GlobalBypassProcessesSettings__c> existingbypassSettings = [Select Id from GlobalBypassProcessesSettings__c]; 
        if (!existingbypassSettings.isEmpty()) return existingbypassSettings.get(0);
        GlobalBypassProcessesSettings__c bypassSetting = new GlobalBypassProcessesSettings__c();
        bypassSetting.RunTriggers__c  = runTriggers;
        bypassSetting.RunProcessBuilder__c = runProcesBuilder;
        insert bypassSetting;
        return bypassSetting;
    }
    
    /*-------------------------------------------------------------------------------------------------------
    Author: Salesforce
    Description: Creates the Org Level Process Builder Bypasses (all false) needed to run automation
    --------------------------------------------------------------------------------------------------------*/
    
    public static void createDefaultOrgLevelBypassPB(){
        if (PbBypassAccountCs__c.getInstance() == null){ 
            PbBypassAccountCs__c accountBPSetting = new PbBypassAccountCs__c();
            accountBPSetting.Bypass__c = false;
            insert accountBPSetting ; 
        }
        
        if (PbBypassCampaignCs__c.getInstance() == null){ 
            PbBypassCampaignCs__c  campaignBPSetting = new PbBypassCampaignCs__c ();
            campaignBPSetting.Bypass__c = false;
            insert campaignBPSetting ;
        }
        
        if (PbBypassCaseCs__c.getInstance() == null){ 
            PbBypassCaseCs__c  caseBPSetting = new PbBypassCaseCs__c ();
            caseBPSetting.Bypass__c = false;
            insert caseBPSetting ;
        }
        
        if (PbBypassContractCs__c.getInstance() == null){ 
            PbBypassContractCs__c  contractBPSetting = new PbBypassContractCs__c ();
            contractBPSetting.Bypass__c = false;
            insert contractBPSetting ;
        }
        
        if (PbBypassOpportunityCs__c.getInstance() == null){ 
            PbBypassOpportunityCs__c  oppBPSetting = new PbBypassOpportunityCs__c ();
            oppBPSetting.Bypass__c = false;
            insert oppBPSetting ;
        }
        
        if (PbBypassOrderCs__c.getInstance() == null){ 
            PbBypassOrderCs__c  orderBPSetting = new PbBypassOrderCs__c ();
            orderBPSetting.Bypass__c = false;
            insert orderBPSetting ;
        }
        
        if (PbBypassUserCs__c.getInstance() == null){ 
            PbBypassUserCs__c  userBPSetting = new PbBypassUserCs__c ();
            userBPSetting.Bypass__c = false;
            insert userBPSetting ;
        }
        
    }
    /*-------------------------------------------------------------------------------------------------------
    Company: Salesforce
    Description: Creates the DEDiscountModel__c needed to run automation of the Contract Object
    Inputs :
    History :
    --------------------------------------------------------------------------------------------------------*/
    public static DEDiscountModel__c createDEDiscountModelCustomSetting(Discount_Model__c dModel){
        DEDiscountModel__c deDiscountModel = new DEDiscountModel__c();
        deDiscountModel.DiscountModelID__c = dModel.Id;
        insert deDiscountModel;
        return deDiscountModel;
    }
    /*-------------------------------------------------------------------------------------------------------
    Company: Salesforce
    Description: Inserts & returns a user list
    Inputs : Integer, String
    History :
    --------------------------------------------------------------------------------------------------------*/
    public static List<User> createUsers(Integer numRecords, String profileName)
    {
        List<User> lstUsers = returnUsers(numRecords, profileName);
        insert lstUsers;
        return lstUsers;
    }

    /*-------------------------------------------------------------------------------------------------------
    Company: Salesforce
    Description: Returns a user list
    Inputs : Integer, String
    History :
    --------------------------------------------------------------------------------------------------------*/
    public static List<User> returnUsers(Integer numRecords, String profileName){

        Profile profile = [select Id, Name from profile where Name =: profileName LIMIT 1];
        List<User> lstUsers = new List<User>();
        String baseUsrName = profile.Name.replaceAll('[ \\#\\:]', '');
        List<String> profileNameSplitted = baseUsrName.split('');

        for(Integer i = 1; i <= numRecords; i++)
        {
            Integer j = TestDataFactoryUtils.getRandomNumber(23*i) ;
            j+=i;
            String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
            Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
            //baseUsrName += dateString + randomInt;
            String userName = baseUsrName + dateString + randomInt 
                + TestDataFactoryUtils.getRandomString(profileNameSplitted) 
                + TestDataFactoryUtils.getRandomNumber(j) + '@dentsplysirona.com';
            User user = new User(
                    alias = 'test1'
                    , Email = userName
                    , emailencodingkey = 'UTF-8'
                    , FirstName = 'TestUser' + TestDataFactoryUtils.getRandomNumber(j)
                    , LastName = 'TestUser' + i
                    , languagelocalekey = 'en_US'
                    , Market__c = 'HQ'
                    , LocaleSidKey='en_US'
                    , ProfileId = profile.Id
                    , TimezoneSidKey = 'Europe/Berlin'
                    , UserName = userName
                    , User_Country__c = 'Belgium');

            lstUsers.add(user);
        }
        return lstUsers;
    }

    /*-------------------------------------------------------------------------------------------------------
    Company: Salesforce
    Description: Inserts & returns a list of Accounts
    Inputs : Integer, String, Id
    History :
    --------------------------------------------------------------------------------------------------------*/
    public static List<Account> createAccounts(Integer numRecords, String recordType, ID ownerId) {
        List<Account> lstAccount = returnAccounts(numRecords, recordType, ownerId);
        insert lstAccount;
        return lstAccount;
    }

    /*-------------------------------------------------------------------------------------------------------
    Company: Salesforce
    Description: Returns a list of Accounts
    Inputs : Integer, String, Id
    History :
    --------------------------------------------------------------------------------------------------------*/
    public static List<Account> returnAccounts(Integer numRecords, String recordType, ID ownerId) {

        RecordType rt = TestDataFactoryUtils.getRecordType('Account', recordType);

        List<Account> lstAccount = new List<Account>();

        for(Integer i = 0; i < numRecords; i++) {
            Account accnt = new Account(
                    Name = 'TestAccount' + i
                    , recordTypeId = rt.Id
                    , ownerId = ownerId);
            lstAccount.add(accnt);
        }

        return lstAccount;
    }
    /*-------------------------------------------------------------------------------------------------------
    Description: Creates the GlobalIntegrationSettings needed to run automation

    Inputs : @param usersList
    --------------------------------------------------------------------------------------------------------*/
    public static GlobalIntegrationSettings__c createGlobalIntegrationSettings(List<User> usersList){
        List<GlobalIntegrationSettings__c> existingGlobalIntegrationSettings = [Select Id from GlobalIntegrationSettings__c]; 
        if (!existingGlobalIntegrationSettings.isEmpty()) return existingGlobalIntegrationSettings.get(0);
        GlobalIntegrationSettings__c globalIntegrationSettings = new GlobalIntegrationSettings__c();
        if(usersList.size() > 0)  { 
            globalIntegrationSettings.GdwIntegration__c  = usersList.get(0).Id;
        }
        insert globalIntegrationSettings;
        return globalIntegrationSettings;
    }
    /*-------------------------------------------------------------------------------------------------------
    Description: Creates the GlobalIntegrationSettings needed to run automation

    Inputs : @param numRecords, @param profileName
    --------------------------------------------------------------------------------------------------------*/
    public static List<User> insertIntegrationUsers(Integer numRecords, String profileName)  {
        List<User> users = returnUsers(numRecords, profileName);
        if(users.size() > 0)  {
            users.get(0).alias = 'GdwIntg';
        }
        insert users;
        return users;
    }
    public static List<Account> bulkAccountReturn(String SObjectName , Integer numRecords, Id IntegrationUserId) {
        List<Account> accountList = new List<Account> ();
        Map<String,RecordTypeInfo> recordTypesInfo = Schema.getGlobalDescribe()
                                        .get(SObjectName)
                                        .getDescribe()
                                        .getRecordTypeInfosByDeveloperName();
        List<String> recordTypes =  new List<String> {'Lab_Prospect_D', 'Lab_Customer_D',
            'Clinical_Prospect_D', 'Clinical_Customer_D','Distributors_Customer_D','ERP_Lab_Account',
            'DNA_EndUser', 'DNA_Distributor', 'DNA_Event','CIM_Account','Partner_DI','Non_ERP_Account',
            'Non_ERP_Lab_Account', 'Non_ERP_Distributor','Competitor', 'Geographical_Account',
            'ERP_Distributor', 'DEX_Customer','Distributors_Prospect_D', 'DEX_D_Prospect','DNA_Internal',
            'Dummy_Dentsply_Implants_Account','Dummy_Wellspect_Account','ERP_Lab_Account'};

        List<Schema.PicklistEntry> countries = Account.Country__c.getDescribe().getPicklistValues();
        List<Schema.PicklistEntry> customSegmentations = Account.Custom_Segmentation__c.getDescribe().getPicklistValues();
        List<Schema.PicklistEntry> OneAccountTypes = Account.OneAccount_Type__c.getDescribe().getPicklistValues();
        List<Schema.PicklistEntry> VolumeImplants = Account.Volume_Implants__c.getDescribe().getPicklistValues();

        for(Integer i = 0; i < numRecords; i++) {
             Account newAccount = new Account (Name = 'TestAccount' + i,
                                              //RecordTypeId = recordTypesInfo.get(recordTypes.get(0)).getRecordTypeId(),
                                              Country__c = countries.get(Math.Mod((Math.Random() * 100).intValue(),countries.size())).getValue(),
                                              TQ_CY_D_DD_Abuts_Atlantis__c = Math.Mod((Math.Random() * 100).intValue(), 20),
                                              TQ_CY_D_DD_IsusProsth_Isus__c = Math.Mod((Math.Random() * 100).intValue(), 20),
                                              TQ_CY_D_DD_Guides_Simplant__c = Math.Mod((Math.Random() * 100).intValue(), 20), 
                                              TQ_CY_D_DI_Implants_AllBrands__c = Math.Mod((Math.Random() * 100).intValue(), 20), 
                                              Custom_Segmentation__c = customSegmentations.get(Math.Mod((Math.Random() * 100).intValue(),customSegmentations.size())).getValue(),
                                              Movex__c = 'XX34' + i,
                                              BillingCity = 'Test City' + i,
                                              Vat_Registration_No__c = 'Test' + i,
                                              OwnerId = IntegrationUserId,
                                              SP_Guides_Potential_Year__c = Math.Mod((Math.Random() * 100).intValue(), 40),
                                              Implants_Potential_Year__c = Math.Mod((Math.Random() * 100).intValue(), 130),  
                                              ATL_ISUS_Potential_Year__c = Math.Mod((Math.Random() * 100).intValue(), 110),
                                              ATL_Abut_Potential_Year__c = Math.Mod((Math.Random() * 100).intValue(), 310),
                                              //OneAccount_Type__c = OneAccountTypes.get(Math.Mod((Math.Random() * 100).intValue(),OneAccountTypes.size())).getValue(),
                                              Volume_Implants__c = VolumeImplants.get(Math.Mod((Math.Random() * 100).intValue(),VolumeImplants.size())).getValue(),
                                              Product_Area__c = '',
                                              Status__c = Math.mod(i,2) == 0 ? '90' : '10',
                                              Atlantis_Web_Order_Customer__c = (Math.mod(i,2) == 0),
                                              Movex_Product_Area_OKHAFE__c = 'xx',
                                              Movex_Reference_Reason__c = Math.mod(i,2));
            accountList.add(newAccount);
        }
        
        return accountList;
    }
    /*-------------------------------------------------------------------------------------------------------
    Company: Salesforce
    Description: Returns a list of Opportunities
    Inputs : Integer, String, Id
    History :
    --------------------------------------------------------------------------------------------------------*/
    public static List<Opportunity> returnOpportunities(Integer numRecords, String recordType, ID ownerId) {

        RecordType rt = TestDataFactoryUtils.getRecordType('Opportunity', recordType);

        List<Opportunity> opportunities = new List<Opportunity>();

        for(Integer i = 0; i < numRecords; i++) {
            Opportunity opportunity = new Opportunity(
                    Name = 'TestOpportunity' + i,
                    StageName = 'Scheduled',
                    CloseDate = Date.today(),
                    recordTypeId = rt.Id,
                    ownerId = ownerId);
            opportunities.add(opportunity);
        }

        return opportunities;
    }
    /*-------------------------------------------------------------------------------------------------------
    Company: Salesforce
    Description: Inserts & returns a list of Opportunities
    Inputs : Integer, String, Id
    History :
    --------------------------------------------------------------------------------------------------------*/
    public static List<Opportunity> createOpportunities(Integer numRecords, String recordType, ID ownerId) {
        List<Opportunity> opportunities = returnOpportunities(numRecords, recordType, ownerId);
        insert opportunities;
        return opportunities;
    }
    /*-------------------------------------------------------------------------------------------------------
    Company: Salesforce
    Description: Returns a list of Contacts
    Inputs : Integer, String, Id
    History :
    --------------------------------------------------------------------------------------------------------*/
    public static List<Contact> returnContacts(Integer numRecords, String recordType, ID ownerId) {

        RecordType rt = TestDataFactoryUtils.getRecordType('Contact', recordType);

        List<Contact> contacts = new List<Contact>();

        for(Integer i = 0; i < numRecords; i++) {
            Contact contact = new Contact(
                    LastName = 'TestContact' + i,
                    recordTypeId = rt.Id,
                    ownerId = ownerId);
            contacts.add(contact);
        }

        return contacts;
    }
    /*-------------------------------------------------------------------------------------------------------
    Company: Salesforce
    Description: Inserts & returns a list of Contacts
    Inputs : Integer, String, Id
    History :
    --------------------------------------------------------------------------------------------------------*/
    public static List<Contact> createContacts(Integer numRecords, String recordType, ID ownerId) {
        List<Contact> contacts = returnContacts(numRecords, recordType, ownerId);
        insert contacts;
        return contacts;
    }
    /*-------------------------------------------------------------------------------------------------------
    Company: Salesforce
    Description: Returns a list of CampaignMembers
    Inputs : Integer
    History :
    --------------------------------------------------------------------------------------------------------*/
    public static List<CampaignMember> returnCampaignMembers(Integer numRecords) {
        List<CampaignMember> campaignMembers = new List<CampaignMember>();

        for(Integer i = 0; i < numRecords; i++) {
            CampaignMember campaignMember = new CampaignMember();
            campaignMembers.add(campaignMember);
        }

        return campaignMembers;
    }
    /*-------------------------------------------------------------------------------------------------------
    Company: Salesforce
    Description: Inserts & returns a list of CampaignMembers
    Inputs : Integer
    History :
    --------------------------------------------------------------------------------------------------------*/
    public static List<CampaignMember> createCampaignMembers(Integer numRecords) {
        List<CampaignMember> campaignMembers = returnCampaignMembers(numRecords);
        insert campaignMembers;
        return campaignMembers;
    }
     /*-------------------------------------------------------------------------------------------------------
    Company: Salesforce
    Description: Returns a list of Contacts
    Inputs : Integer, String, Id
    History :
    --------------------------------------------------------------------------------------------------------*/
    public static List<Campaign> returnCampaigns(Integer numRecords, String recordType, ID ownerId) {

        RecordType rt = TestDataFactoryUtils.getRecordType('Campaign', recordType);

        List<Campaign> campaigns = new List<Campaign>();

        for(Integer i = 0; i < numRecords; i++) {
            Campaign campaign = new Campaign(
                    Name = 'TestCampaign' + Math.random()  + i,
                    recordTypeId = rt.Id,
                    ownerId = ownerId);
            campaigns.add(campaign);
        }

        return campaigns;
    }
    /*-------------------------------------------------------------------------------------------------------
    Company: Salesforce
    Description: Inserts & returns a list of Campaigns
    Inputs : Integer, String, Id
    History :
    --------------------------------------------------------------------------------------------------------*/
    public static List<Campaign> createCampaigns(Integer numRecords, String recordType, ID ownerId) {
        List<Campaign> campaigns = returnCampaigns(numRecords, recordType, ownerId);
        insert campaigns;
        return campaigns;
    }
    /*-------------------------------------------------------------------------------------------------------
    Company: Salesforce
    Description: Returns a list of Events
    Inputs : Integer, Id
    History :
    --------------------------------------------------------------------------------------------------------*/
    public static List<Event> returnEvents(Integer numRecords, ID ownerId) {
        
        List<Event> events = new List<Event>();
        datetime dateStart = Datetime.newInstance(2015, 20 , 12, 00, 00, 00);
        datetime dateEnd = Datetime.newInstance(2015, 20 , 12, 01, 00, 00);
        datetime dateEnd2 = Datetime.newInstance(2015, 19 , 12, 00, 00, 00);
        Date dates = date.newInstance(2016, 19 , 10);

        for(Integer i = 1; i <= numRecords; i++) {
            Event event = new Event(EndDateTime = dateEnd,
                                    StartDateTime = dateStart, 
                                    ActivityDateTime = dateStart, 
                                    DurationInMinutes = 60,
                                    //RecurrenceStartDateTime = dateStart,
                                    //RecurrenceEndDateOnly = dates,
                                    //RecurrenceType = 'RecursDaily',
                                    //RecurrenceInterval = i,
                                    ownerId = ownerId);
            events.add(event);
        }

        return events;
    }
    /*-------------------------------------------------------------------------------------------------------
    Company: Salesforce
    Description: Inserts & returns a list of Events
    Inputs : Integer, Id
    History :
    --------------------------------------------------------------------------------------------------------*/
    public static List<Event> createEvents(Integer numRecords, ID ownerId) {
        
        List<Event> events = returnEvents(numRecords, ownerId);
        insert events;
        return events;
    }
        /*-------------------------------------------------------------------------------------------------------
    Company: Salesforce
    Description: Returns a list of EventAttendees__c
    Inputs : Integer, ID, List
    History :
    --------------------------------------------------------------------------------------------------------*/
    public static List<EventAttendees__c> returnEventAttendees(Integer numRecords, ID ownerId, List<Event> events) {
        
        List<EventAttendees__c> eventAttendees = new List<EventAttendees__c>();

        for(Integer i = 1; i <= numRecords; i++) {
            EventAttendees__c eventAttendee = new EventAttendees__c(EventId__c = events.get(Math.mod(i, events.size())).Id,
                                                                   RelationId__c = ownerId);
            eventAttendees.add(eventAttendee);
        }

        return eventAttendees;
    }
    /*-------------------------------------------------------------------------------------------------------
    Company: Salesforce
    Description: Inserts & returns a list of EventAttendees__c
    Inputs : Integer, ID, List
    History :
    --------------------------------------------------------------------------------------------------------*/
    public static List<EventAttendees__c> createEventAttendees(Integer numRecords, ID ownerId, List<Event> events) {
        
        List<EventAttendees__c> eventAttendees = returnEventAttendees(numRecords, ownerId, events);
        insert eventAttendees;
        return eventAttendees;
    }
    /*-------------------------------------------------------------------------------------------------------
    Company: Salesforce
    Description: Returns a list of EventRelations
    Inputs : Integer
    History :
    --------------------------------------------------------------------------------------------------------*/
    public static List<EventRelation> returnEventRelations(Integer numRecords) {
        
        List<EventRelation> eventRelations = new List<EventRelation>();

        for(Integer i = 1; i <= numRecords; i++) {
            EventRelation eventRelation = new EventRelation();
            eventRelations.add(eventRelation);
        }

        return eventRelations;
    }
    /*-------------------------------------------------------------------------------------------------------
    Company: Salesforce
    Description: Inserts & returns a list of EventRelations
    Inputs : Integer
    History :
    --------------------------------------------------------------------------------------------------------*/
    public static List<EventRelation> createEventRelations(Integer numRecords) {
        
        List<EventRelation> eventRelations = returnEventRelations(numRecords);
        insert eventRelations;
        return eventRelations;
    }
    /*-------------------------------------------------------------------------------------------------------
    Company: Salesforce
    Description: Returns a list of Order
    Inputs : Integer, String, List
    History :
    --------------------------------------------------------------------------------------------------------*/
    public static List<Order> returnOrders(Integer numRecords, String recordType, List<Account> accounts) {
        
        RecordType rt = TestDataFactoryUtils.getRecordType('Order', recordType);
        List<Order> orders = new List<Order>();

        for(Integer i = 1; i <= numRecords; i++) {
            Order order = new Order(AccountId = accounts.get(Math.mod(i, accounts.size())).Id,
                                    EffectiveDate = Date.today(),
                                    Status = 'Created');
            orders.add(order);
        }

        return orders;
    }
    /*-------------------------------------------------------------------------------------------------------
    Company: Salesforce
    Description: Inserts & returns a list of Order
    Inputs : Integer, String, List
    History :
    --------------------------------------------------------------------------------------------------------*/
    public static List<Order> createOrders(Integer numRecords, String recordType, List<Account> accounts) {
        
        List<Order> orders = returnOrders(numRecords, recordType, accounts);
        insert orders;
        return orders;
    }
    /*-------------------------------------------------------------------------------------------------------
    Company: Salesforce
    Description: Returns a list of Contract
    Inputs : Integer, String, ID, List
    History :
    --------------------------------------------------------------------------------------------------------*/
    public static List<Contract> returnContracts(Integer numRecords, String recordType, ID ownerId, List<Account> accounts) {
        
        RecordType rt = TestDataFactoryUtils.getRecordType('Contract', recordType);
        List<Contract> contracts = new List<Contract>();

        for(Integer i = 1; i <= numRecords; i++) {
            Contract contract = new Contract(AccountId = accounts.get(Math.mod(i, accounts.size())).Id, OwnerId = ownerId, recordTypeId = rt.Id);
            contracts.add(contract);
        }

        return contracts;
    }
    /*-------------------------------------------------------------------------------------------------------
    Company: Salesforce
    Description: Inserts & returns a list of Contract
    Inputs : Integer, String, ID, List
    History :
    --------------------------------------------------------------------------------------------------------*/
    public static List<Contract> createContracts(Integer numRecords, String recordType, ID ownerId, List<Account> accounts) {
        
        List<Contract> contracts = returnContracts(numRecords, recordType, ownerId, accounts);
        insert contracts;
        return contracts;
    }
    /*-------------------------------------------------------------------------------------------------------
    Company: Salesforce
    Description: Returns a list of Expert__c
    Inputs : Integer, List
    History :
    --------------------------------------------------------------------------------------------------------*/
    public static List<Expert__c> returnExperts(Integer numRecords, List<Contact> contacts) {
        
        List<Expert__c> experts = new List<Expert__c>();

        for(Integer i = 1; i <= numRecords; i++) {
            Expert__c expert = new Expert__c(Contact__c = contacts.get(Math.mod(i, contacts.size())).Id);
            experts.add(expert);
        }

        return experts;
    }
    /*-------------------------------------------------------------------------------------------------------
    Company: Salesforce
    Description: Inserts & returns a list of Expert__c
    Inputs : Integer, List
    History :
    --------------------------------------------------------------------------------------------------------*/
    public static List<Expert__c> createExperts(Integer numRecords, List<Contact> contacts) {
        
        List<Expert__c> experts = returnExperts(numRecords, contacts);
        insert experts;
        return experts;
    }
    /*-------------------------------------------------------------------------------------------------------
    Company: Salesforce
    Description: Returns a list of Program__c
    Inputs : Integer
    History :
    --------------------------------------------------------------------------------------------------------*/
    public static List<Program__c> returnPrograms(Integer numRecords) {
        
        List<Program__c> programs = new List<Program__c>();

        for(Integer i = 1; i <= numRecords; i++) {
            Program__c program = new Program__c(Name = 'Test' + i);
            programs.add(program);
        }

        return programs;
    }
    /*-------------------------------------------------------------------------------------------------------
    Company: Salesforce
    Description: Inserts & returns a list of Program__c
    Inputs : Integer
    History :
    --------------------------------------------------------------------------------------------------------*/
    public static List<Program__c> createPrograms(Integer numRecords) {
        
        List<Program__c> programs = returnPrograms(numRecords);
        insert programs;
        return programs;
    }
    /*-------------------------------------------------------------------------------------------------------
    Company: Salesforce
    Description: Returns a list of Program_Participation__c
    Inputs : Integer, List, List
    History :
    --------------------------------------------------------------------------------------------------------*/
    public static List<Program_Participation__c> returnProgramParticipations(Integer numRecords, List<Contact> contacts, List<Program__c> programs) {
        
        List<Program_Participation__c> ProgramParticipations = new List<Program_Participation__c>();

        for(Integer i = 1; i <= numRecords; i++) {
            Program_Participation__c ProgramParticipation = new Program_Participation__c(Contact__c = contacts.get(Math.mod(i, contacts.size())).Id,
                                                                                         Participation_Type__c = 'Member',
                                                                                         Program__c = programs.get(Math.mod(i, programs.size())).Id,
                                                                                         SBU__c = 'Implants');
            ProgramParticipations.add(ProgramParticipation);
        }

        return ProgramParticipations;
    }
    /*-------------------------------------------------------------------------------------------------------
    Company: Salesforce
    Description: Inserts & returns a list of Program__c
    Inputs : Integer, List, List
    History :
    --------------------------------------------------------------------------------------------------------*/
    public static List<Program_Participation__c> createProgramParticipations(Integer numRecords, List<Contact> contacts, List<Program__c> programs) {
        
        List<Program_Participation__c> ProgramParticipations = returnProgramParticipations(numRecords, contacts, programs);
        insert ProgramParticipations;
        return ProgramParticipations;
    }
    /*-------------------------------------------------------------------------------------------------------
    Company: Salesforce
    Description: Returns a list of Case
    Inputs :  Integer, String, String
    History :
    --------------------------------------------------------------------------------------------------------*/
    public static List<Case> returnCases(Integer numRecords, String recordType, String OwnerId) {
        
        RecordType rt = TestDataFactoryUtils.getRecordType('Case', recordType);
        
        List<Case> cases = new List<Case>();

        for(Integer i = 1; i <= numRecords; i++) {
            Case casse = new Case(OwnerId = ownerId, Subject = 'TestCase', recordTypeId = rt.Id);
            cases.add(casse);
        }

        return cases;
    }
    /*-------------------------------------------------------------------------------------------------------
    Company: Salesforce
    Description: Inserts & returns a list of Case
    Inputs : Integer, String, String
    History :
    --------------------------------------------------------------------------------------------------------*/
    public static List<Case> createCases(Integer numRecords, String recordType, String OwnerId) {
        
        List<Case> cases = returnCases(numRecords, recordType, ownerId);
        insert cases;
        return cases;
    }
    /*-------------------------------------------------------------------------------------------------------
    Company: Salesforce
    Description: Returns a list of Queues
    Inputs : Integer
    History :
    --------------------------------------------------------------------------------------------------------*/
    public static List<Group> returnQueues(Integer numRecords) {
                
        List<Group> groups = new List<Group>();

        for(Integer i = 1; i <= numRecords; i++) {
            Group grp = new Group(Name = 'Queue'+ i, Type = 'Queue');
            groups.add(grp);
        }

        return groups;
    }
    /*-------------------------------------------------------------------------------------------------------
    Company: Salesforce
    Description: Inserts & returns a list of Queues
    Inputs : Integer, String
    History :
    --------------------------------------------------------------------------------------------------------*/
    public static List<Group> createQueues(Integer numRecords, String sObjectName) {
        
        List<Group> groups = returnQueues(numRecords);
        insert groups;
        List<QueuesObject> queuesObjects = new List<QueuesObject> ();
        for(Group grp : groups) {
            queuesObjects.add(new QueueSObject(QueueID = grp.id, SobjectType = sObjectName));
        }
        insert queuesObjects;
        return groups;
    }
    /*-------------------------------------------------------------------------------------------------------
    Company: Salesforce
    Description: Returns a list of Discount_Model__c
    Inputs :  Integer, String
    History :
    --------------------------------------------------------------------------------------------------------*/
    public static List<Discount_Model__c> returnDiscountModels(Integer numRecords, String OwnerId) {
                
        List<Discount_Model__c> discountModels = new List<Discount_Model__c>();

        for(Integer i = 1; i <= numRecords; i++) {
            Discount_Model__c discountModel = new Discount_Model__c(OwnerId = ownerId, Type__c = 'Contract ', Country__c = 'DE');
            discountModels.add(discountModel);
        }

        return discountModels;
    }
    /*-------------------------------------------------------------------------------------------------------
    Company: Salesforce
    Description: Inserts & returns a list of Discount_Model__c
    Inputs : Integer, String
    History :
    --------------------------------------------------------------------------------------------------------*/
    public static List<Discount_Model__c> createDiscountModels(Integer numRecords, String OwnerId) {
        
        List<Discount_Model__c> discountModels = returnDiscountModels(numRecords, ownerId);
        insert discountModels;
        return discountModels;
    }
    /*-------------------------------------------------------------------------------------------------------
    Company: Salesforce
    Description: Returns a list of EmailMessage
    Inputs :  Integer, List
    History :
    --------------------------------------------------------------------------------------------------------*/
    public static List<EmailMessage> returnEmailMessages(Integer numRecords, List<Case> cases) {
        
        
        List<EmailMessage> emailMessages = new List<EmailMessage>();

        for(Integer i = 1; i <= numRecords; i++) {
            EmailMessage emailMessage = new EmailMessage(RelatedToId = cases.get(Math.mod(i, cases.size())).Id);
            emailMessages.add(emailMessage);
        }

        return emailMessages;
    }
    /*-------------------------------------------------------------------------------------------------------
    Company: Salesforce
    Description: Inserts & returns a list of EmailMessage
    Inputs : Integer, List
    History :
    --------------------------------------------------------------------------------------------------------*/
    public static List<EmailMessage> createEmailMessages(Integer numRecords, List<Case> cases) {
        
        List<EmailMessage> emailMessages = returnEmailMessages(numRecords, cases);
        insert emailMessages;
        return emailMessages;
    }
    /*-------------------------------------------------------------------------------------------------------
    Company: Salesforce
    Description: Returns a list of Discount_rows__c
    Inputs :  Id
    History :
    --------------------------------------------------------------------------------------------------------*/
    public static List<Discount_row__c> returnDiscountRows(Id discountModelId) {
        List<Discount_row__c> discountRowList = new List<Discount_row__c>();
        Schema.DescribeFieldResult discountLever = Discount_row__c.Discount_lever__c.getDescribe();
        List<Schema.PicklistEntry> discountLeverEntryList = discountLever.getPicklistValues();
        System.debug('discountLeverEntryList::'+discountLeverEntryList);

        for (Schema.PicklistEntry discountLeverEntry : discountLeverEntryList) {
            Discount_row__c discountRowRecordLow = new Discount_row__c();
            discountRowRecordLow.Discount_Model__c = discountModelId;
            discountRowRecordLow.Discount_lever__c = discountLeverEntry.getValue();
            discountRowRecordLow.Allowed_discount__c = 1;
            discountRowRecordLow.Min__c = 0;
            discountRowRecordLow.Max__c = 50;
            discountRowRecordLow.Min_perc__c = 0;
            discountRowRecordLow.Max_perc__c = 50;
            discountRowRecordLow.Equals__c = discountLeverEntry.getValue() + 'LOW';
            discountRowList.add(discountRowRecordLow);

            Discount_row__c discountRowRecordHigh = new Discount_row__c();
            discountRowRecordHigh.Discount_Model__c = discountModelId;
            discountRowRecordHigh.Discount_lever__c = discountLeverEntry.getValue();
            discountRowRecordHigh.Allowed_discount__c = 1;
            discountRowRecordHigh.Min__c = 51;
            discountRowRecordHigh.Max__c = 100;
            discountRowRecordHigh.Min_perc__c = 51;
            discountRowRecordHigh.Max_perc__c = 100;
            discountRowRecordHigh.Equals__c = discountLeverEntry.getValue() + 'HIGH';
            discountRowList.add(discountRowRecordHigh);
        }
        return discountRowList;
    }
    /*-------------------------------------------------------------------------------------------------------
    Company: Salesforce
    Description: Inserts & returns a list of Discount_rows__c
    Inputs : Id
    History :
    --------------------------------------------------------------------------------------------------------*/
    public static List<Discount_row__c> createDiscountRows(Id discountModelId) {
        List<Discount_row__c> discountRowList = returnDiscountRows(discountModelId);
        insert discountRowList;
        return discountRowList;
    }
     /*-------------------------------------------------------------------------------------------------------
    Company: Salesforce
    Description: Returns a list of Pricebook2
    Inputs :  Integer, String
    History :
    --------------------------------------------------------------------------------------------------------*/
    public static List<Pricebook2> returnPricebooks(Integer numRecords, String pricebookName) {
                
        List<Pricebook2> pricebooks = new List<Pricebook2>();

        for(Integer i = 1; i <= numRecords; i++) {
            Pricebook2 pricebook = new Pricebook2(Name= pricebookName + i, isActive = true);
            pricebooks.add(pricebook);
        }

        return pricebooks;
    }
    /*-------------------------------------------------------------------------------------------------------
    Company: Salesforce
    Description: Inserts & returns a list of Pricebook2
    Inputs : Integer, String
    History :
    --------------------------------------------------------------------------------------------------------*/
    public static List<Pricebook2> createPricebooks(Integer numRecords, String pricebookName) {
        List<Pricebook2> pricebooks = returnPricebooks(numRecords, pricebookName);
        insert pricebooks;
        return pricebooks;
    }

    /*-------------------------------------------------------------------------------------------------------
    Company: Salesforce
    Description: Returns a list of Product2
    Inputs :  Integer, String
    History :
    --------------------------------------------------------------------------------------------------------*/
    public static List<Product2> returnProducts(Integer numRecords) {
                
        List<Product2> products = new List<Product2>();

        for(Integer i = 1; i <= numRecords; i++) {
            Product2 product = new Product2(Name= 'Product ', Article__c = 'Article' + i, isActive = true, CurrencyIsoCode ='USD');
            products.add(product);
        }
        return products;
    }
    /*-------------------------------------------------------------------------------------------------------
    Company: Salesforce
    Description: Inserts & returns a list of Product2
    Inputs : Integer, String
    History :
    --------------------------------------------------------------------------------------------------------*/
    public static List<Product2> createProducts(Integer numRecords) {
        List<Product2> products = returnProducts(numRecords);
        insert products;
        return products;
    }
    /*-------------------------------------------------------------------------------------------------------
    Company: Salesforce
    Description: Returns a list of PricebookEntry
    Inputs :  Integer, String
    History :
    --------------------------------------------------------------------------------------------------------*/
    public static List<PricebookEntry> returnPricebookEntries(Integer numRecords, List<Pricebook2> pricebooks, List<Product2> products) {
                
        List<PricebookEntry> pricebookEntries1 = new List<PricebookEntry>();
        List<PricebookEntry> pricebookEntries2 = new List<PricebookEntry>();
        for(Integer i = 1; i <= numRecords; i++) {
            String productId = products.get(Math.mod(i,products.size())).Id;
            PricebookEntry pricebookEntry1 = new PricebookEntry(Product2Id = productId, Pricebook2Id = Test.getStandardPricebookId(), UnitPrice=15, isActive = true);
            pricebookEntries1.add(pricebookEntry1);
            PricebookEntry pricebookEntry2 =  new PricebookEntry(Product2Id = productId, Pricebook2Id = pricebooks.get(Math.mod(i,pricebooks.size())).Id, UnitPrice = 10, isActive = true, CurrencyIsoCode = 'USD');
            pricebookEntries2.add(pricebookEntry2);
        }
        insert pricebookEntries1;
        return pricebookEntries2;
    }
    /*-------------------------------------------------------------------------------------------------------
    Company: Salesforce
    Description: Inserts & returns a list of PricebookEntry
    Inputs : Integer, String
    History :
    --------------------------------------------------------------------------------------------------------*/
    public static List<PricebookEntry> createPricebookEntries(Integer numRecords, List<Pricebook2> pricebooks, List<Product2> products) {
        List<PricebookEntry> pricebookEntries = returnPricebookEntries(numRecords, pricebooks, products);
        insert pricebookEntries;
        return pricebookEntries;
    }
    /*-------------------------------------------------------------------------------------------------------
    Company: Salesforce
    Description: Returns a list of OrderItem
    Inputs :  Integer, String
    History :
    --------------------------------------------------------------------------------------------------------*/
    public static List<OrderItem> returnOrderItems(Integer numRecords, List<Order> orders, List<PricebookEntry> pricebookEntries) {
                
        List<OrderItem> orderItems = new List<OrderItem>();

        for(Integer i = 1; i <= numRecords; i++) {
            OrderItem orderItem = new OrderItem(PricebookEntryId = pricebookEntries.get(Math.mod(i, pricebookEntries.size())).Id, OrderID = orders.get(Math.mod(i, orders.size())).Id, Quantity = i, UnitPrice = i);
            orderItems.add(orderItem);
        }
        return orderItems;
    }
    /*-------------------------------------------------------------------------------------------------------
    Company: Salesforce
    Description: Inserts & returns a list of OrderItem
    Inputs : Integer, String
    History :
    --------------------------------------------------------------------------------------------------------*/
    public static List<OrderItem> createOrderItems(Integer numRecords, List<Order> orders, List<PricebookEntry> pricebookEntries) {
        List<OrderItem> orderItems = returnOrderItems(numRecords, orders, pricebookEntries);
        insert orderItems;
        return orderItems;
    }
    /*-------------------------------------------------------------------------------------------------------
    Company: Salesforce
    Description: Returns a list of OrderItem
    Inputs :  Integer, String
    History :
    --------------------------------------------------------------------------------------------------------*/
    public static List<Preferred_dealer_item__c> returnpreferredDealers(Integer numRecords,List<Account> accounts, List<Order> orders) {
                
        List<Preferred_dealer_item__c> preferredDealers = new List<Preferred_dealer_item__c>();

        for(Integer i = 1; i <= numRecords; i++) {
            Preferred_dealer_item__c preferredDealer = new Preferred_dealer_item__c(Dealer__c = accounts.get(Math.mod(i, accounts.size())).Id, Account__c = orders.get(Math.mod(i, orders.size())).AccountId);
            preferredDealers.add(preferredDealer);
        }
        return preferredDealers;
    }
    /*-------------------------------------------------------------------------------------------------------
    Company: Salesforce
    Description: Inserts & returns a list of OrderItem
    Inputs : Integer, String
    History :
    --------------------------------------------------------------------------------------------------------*/
    public static List<Preferred_dealer_item__c> createpreferredDealers(Integer numRecords,List<Account> accounts, List<Order> orders) {
        List<Preferred_dealer_item__c> preferredDealers = returnpreferredDealers(numRecords, accounts, orders);
        insert preferredDealers;
        return preferredDealers;
    }
    /*-------------------------------------------------------------------------------------------------------
    Company: 
    Description: Returns a list of AccountMergeRequests
    Inputs : List of accounts, list of accounts, Id
    History :
    --------------------------------------------------------------------------------------------------------*/
    public static List<AccountMergeRequest__c> returnAccountMergeRequests(Integer numRecords, ID ownerId) {


        List<AccountMergeRequest__c> accountMergeRequests = new List<AccountMergeRequest__c>();

        for(Integer i = 0; i < numRecords; i++) {
            AccountMergeRequest__c accountMergeRequest = new AccountMergeRequest__c(
                ownerId = ownerId);
                accountMergeRequests.add(accountMergeRequest);
        }

        return accountMergeRequests;
    }
    /*-------------------------------------------------------------------------------------------------------
    Company: 
    Description: Returns a list of AccountMergeRequests
    Inputs : List of accounts, list of accounts, Id
    History :
    --------------------------------------------------------------------------------------------------------*/
    public static List<AccountMergeRequest__c> createAccountMergeRequests(Integer numRecords, ID ownerId) {
        List<AccountMergeRequest__c> accountMergeRequests = returnAccountMergeRequests(numRecords, ownerId);
        insert accountMergeRequests;
        return accountMergeRequests;
    }
    /*-------------------------------------------------------------------------------------------------------
    Company: 
    Description: Returns a list of AccountContactRelation 
    Inputs : List of accounts, list of accounts, Id
    History :
    --------------------------------------------------------------------------------------------------------*/
    public static List<AccountContactRelation> returnAccountContactRelationhip(Integer numRecords) {


        List<AccountContactRelation> AccountContactRelations = new List<AccountContactRelation>();

        for(Integer i = 0; i < numRecords; i++) {
            AccountContactRelation AccountContactRelationRecord = new AccountContactRelation(
                );
                AccountContactRelations.add(AccountContactRelationRecord);
        }

        return AccountContactRelations;
    }
    /*-------------------------------------------------------------------------------------------------------
    Company: 
    Description: Returns a list of Objectives
    Inputs : Number of records,  accountPlan Id
    History :
    --------------------------------------------------------------------------------------------------------*/
    public static List<Objective__c> createObjective(Integer numRecords, Id accountPlan) {
        List<Objective__c> objectives = returnObjectives(numRecords, accountPlan);
        insert objectives;
        return objectives;
    }
    /*-------------------------------------------------------------------------------------------------------
    Company: 
    Description: Returns a list of Objectives 
    Inputs : Number of records,  accountPlan Id
    History :
    --------------------------------------------------------------------------------------------------------*/
    public static List<Objective__c> returnObjectives(Integer numRecords, Id accountPlan) {


        List<Objective__c> objectivesList = new List<Objective__c>();

        for(Integer i = 0; i < numRecords; i++) {
            Objective__c objective = new Objective__c(AccountPlan__c= accountPlan ,Objective__c= 'test objective',
                                                      Goals__c= 'test goal',
                                                      Initiatives__c= 'test initiative',
                                                      Measures__c= 'test measures',
                                                      Status__c= 'Open', 
                                                      IndicatedActions__c= 'test indicated actions');
                objectivesList.add(objective);
        }

        return objectivesList;
    }
    /*-------------------------------------------------------------------------------------------------------
    Company: 
    Description: Returns a list of AccountPlans
    Inputs : Number of records,  account Id
    History :
    --------------------------------------------------------------------------------------------------------*/
    public static List<Account_Plan__c> createAccountPlan(Integer numRecords, Id accountId) {
        List<Account_Plan__c> accountPlans = returnAccountPlans(numRecords, accountId);
        insert accountPlans;
        return accountPlans;
    }
    /*-------------------------------------------------------------------------------------------------------
    Company: 
    Description: Returns a list of AccountPlan 
    Inputs :NUMBER OF RECORDS , Id of account
    History :
    --------------------------------------------------------------------------------------------------------*/
    public static List<Account_Plan__c> returnAccountPlans(Integer numRecords, Id accountId) {
    List<Account_Plan__c> accPlanList = new List<Account_Plan__c>();
        for(Integer i = 0; i < numRecords; i++) {
        Account_Plan__c accountPlan = new Account_Plan__c (AccountPlanOwner__c = UserInfo.getUserId(),
                                                            Year__c  = String.valueOf(2019+i),
                                                            Account__c = accountId);
            accPlanList.add(accountPlan);
        }
      return accPlanList;
    }
    /*-------------------------------------------------------------------------------------------------------
    Company: 
    Description: Returns a list of Source_Record__c records 
    Inputs : Integer
    History :
    --------------------------------------------------------------------------------------------------------*/
    public static List<Source_Record__c> returnSourceRecords(Integer numRecords) {
        List<Source_Record__c> sourceRecordsList = new List<Source_Record__c>();

        for(Integer i = 0; i < numRecords; i++) {
            Source_Record__c sourceRecord = new Source_Record__c();
            sourceRecordsList.add(sourceRecord);
        }
        return sourceRecordsList;
    }

}