//
//This class contains Unit tests for all classes which provide access to objects.
//Used abbreviations:
// - UT means 'Unit test'
//
//Author: Gennadiy Pervukhin [Cervello](13-11-2014)
@IsTest
private class DC_UT_DataAccessLevel
{
    //
    //Unit tests for 'DC_AttachmentDAO' class
    //
    @IsTest
    private static void test_AttachmentDAO_createSubQueryByFilter()
    {
        //incorrect parameters
        System.assertEquals(null, DC_AttachmentDAO.createSubQueryByFilter(null, null, null));
        //scenario with correct parameters is tested in other unit tests
    }
    //
    
    
    
    //
    //Unit tests for 'DC_EventDAO' class
    //
    @IsTest
    private static void test_EventDAO_getEventById()
    {
        DC_SettingsUtils.setTriggersSettingForCurrentRequest(false);
        
        //incorrect parameters
        System.assertEquals(null, DC_EventDAO.getEventById(null));
        
        //correct parameters
        //- create test event
        Event event1 = DC_UT_DataUtils.generateEvent('Event-1_1', DateTime.now(),
            DateTime.now().addHours(1));
        insert event1;
        System.assertEquals(event1.Id, DC_EventDAO.getEventById(event1.Id).Id);
    }
    
    @IsTest
    private static void test_EventDAO_getEventsByFilter()
    {
        DC_SettingsUtils.setTriggersSettingForCurrentRequest(false);
        
        //incorrect parameters
        System.assertEquals(null, DC_EventDAO.getEventsByFilter(null));
        
        //correct parameters
        //- create a test event
        Event event1 = DC_UT_DataUtils.generateEvent('Event-1_1', DateTime.now(),
            DateTime.now().addHours(1));
        Event event2 = DC_UT_DataUtils.generateEvent('Event-1_2', DateTime.now(),
            DateTime.now().addHours(1));
        insert new Event[] {event1, event2};
        //- create test attachments
        Attachment attachment1 = DC_UT_DataUtils.generateAttachment('A1', event1.Id,
            Blob.valueOf('Content1'));
        Attachment attachment2 = DC_UT_DataUtils.generateAttachment('A2', event1.Id,
            Blob.valueOf('Content2'));
        insert new Attachment[] {attachment1, attachment2};
        //- create a test contact
        Contact contact1 = DC_UT_DataUtils.generateContact('Contact1');
        insert contact1;
        //- create test event relations
        EventRelation relation11 = DC_UT_DataUtils.generateEventRelation(event1.Id, contact1.Id);
        insert relation11;
        
        //TEST #1
        //- initialize and configure the filter
        DC_EventDAO.Filter filter = new DC_EventDAO.Filter();
        filter.ids = new String[] {event1.Id};
        filter.selectRelations = true;
        filter.relationsFilter = new DC_EventRelationDAO.Filter();
        filter.selectAttachments = true;
        filter.attachmentsFilter = new DC_AttachmentDAO.Filter();
        filter.attachmentsFilter.sortingFields.add(new DC_SortingField(
            DC_AttachmentDAO.FIELD_NAME, DC_SoqlEnums.SortingOrder.Ascending));
        
        //- execute the method and check the results
        Event[] events = DC_EventDAO.getEventsByFilter(filter);
        System.assertEquals(1, events.size());
        Event resultEvent = events[0];
        System.assertEquals(event1.Id, resultEvent.Id);
        
        System.assertEquals(1, resultEvent.EventRelations.size());
        System.assertEquals(contact1.Id, resultEvent.EventRelations[0].RelationId);
        
        System.assertEquals(2, resultEvent.Attachments.size());
        System.assertEquals('A1', resultEvent.Attachments[0].Name);
        System.assertEquals('A2', resultEvent.Attachments[1].Name);
        
        //TEST #2
        filter.selectAttachments = false;
        filter.relationsFilter.relatedSObjectTypes = new String[] {DC_SObjectUtils.USER_TYPE};
        
        events = DC_EventDAO.getEventsByFilter(filter);
        System.assertEquals(1, events.size());
        resultEvent = events[0];
        System.assertEquals(event1.Id, resultEvent.Id);
        System.assertEquals(0, resultEvent.Attachments.size());
        System.assertEquals(0, resultEvent.EventRelations.size());
    }
    //
    
    
    
    //
    //Unit tests for 'DC_EventRelationDAO' class
    //
    @IsTest
    private static void test_EventRelationDAO_createSubQueryByFilter()
    {
        //incorrect parameters
        System.assertEquals(null, DC_EventRelationDAO.createSubQueryByFilter(null, null, null));
        //scenario with correct parameters is tested in other unit tests
    }
    
    @IsTest
    private static void test_EventRelationDAO_getRelationById()
    {
        DC_SettingsUtils.setTriggersSettingForCurrentRequest(false);
        
        //incorrect parameters
        System.assertEquals(null, DC_EventRelationDAO.getRelationById(null));
        
        //correct parameters
        //- create test event
        Event event1 = DC_UT_DataUtils.generateEvent('Event-1_1', DateTime.now(),
            DateTime.now().addHours(1));
        insert event1;
        //- create a test contact
        Contact contact1 = DC_UT_DataUtils.generateContact('Contact1');
        insert contact1;
        //- create test event relations
        EventRelation relation1 = DC_UT_DataUtils.generateEventRelation(event1.Id, contact1.Id);
        insert relation1;
        
        System.assertEquals(relation1.Id, DC_EventRelationDAO.getRelationById(relation1.Id).Id);
    }
    //
    
    
    
    //
    //Unit tests for 'DC_UserDAO' class
    //
    @IsTest
    private static void test_UserDAO_getUsersByIds()
    {
        //incorrect parameters
        System.assertEquals(null, DC_UserDAO.getUsersByIds(null));
        
        //correct parameters
        User[] users = DC_UserDAO.getUsersByIds(new String[] {UserInfo.getUserId()});
        System.assertEquals(1, users.size());
        System.assertEquals(UserInfo.getUserId(), users[0].Id);
    }
    //
    
    
    
    //
    //Unit tests for 'DC_EmailTemplateDAO' class
    //
    @IsTest
    private static void test_EmailTemplateDAO_getTemplateByDeveloperName()
    {
        //incorrect parameters
        System.assertEquals(null, DC_EmailTemplateDAO.getTemplateByDeveloperName(null));
        
        //correct parameters
        String templateName = 'DC_Template_' + DateTime.now().getTime();
        EmailTemplate emailTemplate = DC_UT_DataUtils.createOrGetEmailTemplate(templateName);
        
        //TEST #1
        EmailTemplate resultTemplate = DC_EmailTemplateDAO.getTemplateByDeveloperName(
            templateName);
        System.assertEquals(emailTemplate.Id, resultTemplate.Id);
        
        //TEST #2
        delete emailTemplate;
        resultTemplate = DC_EmailTemplateDAO.getTemplateByDeveloperName(templateName);
        System.assertEquals(null, resultTemplate);
    }
    //
    
    
    
    //
    //Unit tests for 'DC_SettingsUtils' class
    //
    @IsTest
    private static void test_SettingsUtils_getStringValueByName()
    {
        final String TEST_SETTING_NAME = 'TEST_PROPERTY';
        
        //setting does not exist
        System.assertEquals(null, DC_SettingsUtils.getStringValueByName(TEST_SETTING_NAME));
        //name is too long => exception should be thrown
        System.assertEquals(null, DC_SettingsUtils.getStringValueByName('Name'.repeat(10)));
        
        //setting exists
        DC_UT_DataUtils.createSetting(TEST_SETTING_NAME, 'TRUE');
        System.assertEquals('TRUE', DC_SettingsUtils.getStringValueByName(TEST_SETTING_NAME));
    }
    
    @IsTest
    private static void test_SettingsUtils_getBooleanValueByName()
    {
        final String TEST_BOOLEAN_SETTING_NAME = 'TEST_BOOLEAN_PROPERTY';
         
        //setting does not exist
        System.assertEquals(null, DC_SettingsUtils.getBooleanValueByName(TEST_BOOLEAN_SETTING_NAME));
        //name is too long => exception should be thrown
        System.assertEquals(null, DC_SettingsUtils.getBooleanValueByName('Name'.repeat(10)));
        
        //setting exists
        DC_Setting__c setting = DC_UT_DataUtils.createSetting(TEST_BOOLEAN_SETTING_NAME, 'TRUE');
        System.assertEquals(true, DC_SettingsUtils.getBooleanValueByName(TEST_BOOLEAN_SETTING_NAME));
        
        //setting exists, but it contains not a boolean value
        setting.Value__c = 'IncorrectValue';
        update setting;
        System.assertEquals(false, DC_SettingsUtils.getBooleanValueByName(TEST_BOOLEAN_SETTING_NAME));
    }
    
    @IsTest
    private static void test_SettingsUtils_triggersEnabled()
    {
        //setting does not exist (by default, triggers are enabled)
        System.assertEquals(true, DC_SettingsUtils.triggersEnabled());
        
        //disable triggers for current request only
        DC_SettingsUtils.setTriggersSettingForCurrentRequest(false);
        System.assertEquals(false, DC_SettingsUtils.triggersEnabled());
        
        //enable triggers for current request only
        DC_SettingsUtils.setTriggersSettingForCurrentRequest(true);
        System.assertEquals(true, DC_SettingsUtils.triggersEnabled());
    }
    
    @IsTest
    private static void test_SettingsUtils_triggersDisabled()
    {
        //read setting
        DC_UT_DataUtils.createSetting(DC_SettingsUtils.TRIGGERS_ENABLED, 'FALSE');
        System.assertEquals(false, DC_SettingsUtils.triggersEnabled());
        
        //enable triggers for current request only
        DC_SettingsUtils.setTriggersSettingForCurrentRequest(true);
        System.assertEquals(true, DC_SettingsUtils.triggersEnabled());
        
        //disable triggers for current request only
        DC_SettingsUtils.setTriggersSettingForCurrentRequest(false);
        System.assertEquals(false, DC_SettingsUtils.triggersEnabled());
    }
    
    @IsTest
    private static void test_SettingsUtils_getIdsOfEventRTsForNotices()
    {
        //setting doesn't exist
        System.assertEquals(0, DC_SettingsUtils.getIdsOfEventRTsForNotices().size());
        
        //setting exists
        RecordType[] recordTypes = [Select Id From RecordType limit 3];
        if (recordTypes != null && recordTypes.size() > 0)
        {
            Set<Id> recordTypesIds = new Map<Id, RecordType>(recordTypes).keySet();
            DC_UT_DataUtils.createSetting(DC_SettingsUtils.EVENT_RTs_FOR_CUSTOM_NOTICES,
                DC_StringUtils.safeJoin(new List<Id>(recordTypesIds), ', '));
            
            Set<Id> idsFromSetting = DC_SettingsUtils.getIdsOfEventRTsForNotices();
            System.assertEquals(recordTypesIds.size(), idsFromSetting.size());
        }
    }
    //
    
    
    
    //
    //Unit tests for 'DC_OrgWideEmailReader' class
    //
    @IsTest
    private static void test_OrgWideEmailReader_getOrgWideAddressIdByEmail()
    {
        //incorrect parameters
        System.assertEquals(null, DC_OrgWideEmailReader.getOrgWideAddressIdByEmail(null));
        
        //correct parameters (test with real organization data)
        OrgWideEmailAddress[] addresses = [Select Id, Address From OrgWideEmailAddress limit 1];
        if (addresses != null)
        {
            OrgWideEmailAddress address = addresses[0];
            //- get the value 1st time
            System.assertEquals(address.Id,
                DC_OrgWideEmailReader.getOrgWideAddressIdByEmail(address.Address));
            //- get the value 2nd time
            System.assertEquals(address.Id,
                DC_OrgWideEmailReader.getOrgWideAddressIdByEmail(address.Address));
        }
    }
    
    
    
    //
    //Unit tests for 'DC_PricebookDAO' class
    // 210408 kdoruibin TFUS-000002288: Removed PricebookDAO
    //
    /*@IsTest
    private static void test_PricebookDAO_getAllActivePricebooks()
    {
        //test #1
        Pricebook2[] pricebooks = DC_PricebookDAO.getAllActivePricebooks();
        System.assertEquals(0, pricebooks.size());
        
        //test #2
        //- create test data
        Pricebook2 pricebook1 = DC_UT_DataUtils.generatePricebook('Pricebook1', DOLLAR_CODE);
        Pricebook2 pricebook2 = DC_UT_DataUtils.generatePricebook('Pricebook2', EURO_CODE);
        insert new Pricebook2[] {pricebook1, pricebook2};
        
        //- execute the method and check the results
        pricebooks = DC_PricebookDAO.getAllActivePricebooks();
        System.assertEquals(2, pricebooks.size());
        
        //test #3
        //- modify test data
        pricebook2.IsActive = false;
        update pricebook2;
        
        //- execute the method and check the results
        pricebooks = DC_PricebookDAO.getAllActivePricebooks();
        System.assertEquals(1, pricebooks.size());
        System.assertEquals(pricebook1.Id, pricebooks[0].Id);
    }*/
    //
    
    
    
    //
    //Unit tests for 'DC_PricebookEntryDAO' class
    // 210408 kdoruibin TFUS-000002288: Removed PricebookEntryDAO
    //
    //- constants
    /* private static final String EURO_CODE = 'EUR';
    private static final String RUBLE_CODE = 'RUB';
    private static final String DOLLAR_CODE = 'USD';
    
    @IsTest
    private static void test_PricebookEntryDAO_generateQueryByFilter()
    {
        DC_PricebookEntryDAO.Filter filter = null;
        System.assertEquals(null, DC_PricebookEntryDAO.generateQueryByFilter(filter, false));
        System.assertNotEquals(null, DC_PricebookEntryDAO.generateQueryByFilter(filter, true));
        
        filter = new DC_PricebookEntryDAO.Filter();
        System.assertEquals(null, DC_PricebookEntryDAO.generateQueryByFilter(filter, false));
        System.assertNotEquals(null, DC_PricebookEntryDAO.generateQueryByFilter(filter, true));
        
        filter.keyword = 'keyword';
        System.assertNotEquals(null, DC_PricebookEntryDAO.generateQueryByFilter(filter, false));
        System.assertNotEquals(null, DC_PricebookEntryDAO.generateQueryByFilter(filter, true));
    }
    
    @IsTest
    private static void test_PricebookEntryDAO_getEntriesByFilter()
    {
        //incorrect parameters
        System.assertEquals(null, DC_PricebookEntryDAO.getEntriesByFilter(null, false));
        
        //CREATE TEST DATA:
        //- create test pricebooks (pricebook1 is a standard real pricebook)
        Pricebook2 pricebook1 = new Pricebook2(Id = Test.getStandardPricebookId());
        Pricebook2 pricebook2 = DC_UT_DataUtils.generatePricebook('Pricebook2', EURO_CODE);
        insert pricebook2;
        
        //- create test products
        Product2 product1 = DC_UT_DataUtils.generateProduct('Product1', 'Brand1',
            'Line1', 'L4_GD_P1');
        Product2 product2 = DC_UT_DataUtils.generateProduct('Product2', 'Brand2',
            'Line2', 'L4_GD_P2');
        insert new Product2[] {product1, product2};
        
        //- create test pricebook entries
        //pricebook1
        PricebookEntry entry11 = DC_UT_DataUtils.generatePricebookEntry(
            pricebook1.Id, product1.Id, 1000, RUBLE_CODE);
        PricebookEntry entry12 = DC_UT_DataUtils.generatePricebookEntry(
            pricebook1.Id, product1.Id, 25, EURO_CODE);
        PricebookEntry entry13 = DC_UT_DataUtils.generatePricebookEntry(
            pricebook1.Id, product2.Id, 5000, RUBLE_CODE);
        PricebookEntry entry14 = DC_UT_DataUtils.generatePricebookEntry(
            pricebook1.Id, product2.Id, 150, DOLLAR_CODE);
        insert new PricebookEntry[] {entry11, entry12, entry13, entry14};
        //pricebook2
        PricebookEntry entry21 = DC_UT_DataUtils.generatePricebookEntry(
            pricebook2.Id, product1.Id, 30, EURO_CODE);
        PricebookEntry entry22 = DC_UT_DataUtils.generatePricebookEntry(
            pricebook2.Id, product2.Id, 7000, RUBLE_CODE);
        entry22.IsActive = false;
        insert new PricebookEntry[] {entry21, entry22};
        
        //PERFORM TESTING:
        //- test #1: get all entries
        DC_PricebookEntryDAO.Filter filter = new DC_PricebookEntryDAO.Filter();
        PricebookEntry[] entries = DC_PricebookEntryDAO.getEntriesByFilter(filter, true);
        System.assertEquals(6, entries.size());
        
        //- test #2: get entries by ids
        filter.ids = new String[] {entry11.Id};
        entries = DC_PricebookEntryDAO.getEntriesByFilter(filter, true);
        System.assertEquals(1, entries.size());
        System.assertEquals(entry11.Id, entries[0].Id);
        
        //- test #3: get entries by keyword
        filter = new DC_PricebookEntryDAO.Filter();
        filter.keyword = 'Product1';
        entries = DC_PricebookEntryDAO.getEntriesByFilter(filter, true);
        System.assertEquals(3, entries.size());
        for (PricebookEntry entry : entries)
        {
            System.assertEquals(product1.Id, entry.Product2Id);
        }
        
        //- test #4: get active entries only
        filter = new DC_PricebookEntryDAO.Filter();
        filter.isActive = true;
        entries = DC_PricebookEntryDAO.getEntriesByFilter(filter, true);
        System.assertEquals(5, entries.size());
        for (PricebookEntry entry : entries)
        {
            System.assert(entry.IsActive);
        }
        
        //- test #5: get non active entries only
        filter.isActive = false;
        entries = DC_PricebookEntryDAO.getEntriesByFilter(filter, true);
        System.assertEquals(1, entries.size());
        System.assertEquals(entry22.Id, entries[0].Id);
        
        //- test #6: get entries for pricebook1 only
        filter = new DC_PricebookEntryDAO.Filter();
        filter.pricebookId = pricebook1.Id;
        entries = DC_PricebookEntryDAO.getEntriesByFilter(filter, true);
        System.assertEquals(4, entries.size());
        for (PricebookEntry entry : entries)
        {
            System.assertEquals(pricebook1.Id, entry.Pricebook2Id);
        }
        
        //- test #7: get entries for USD-currency only
        filter = new DC_PricebookEntryDAO.Filter();
        filter.currencyIsoCode = DOLLAR_CODE;
        entries = DC_PricebookEntryDAO.getEntriesByFilter(filter, true);
        System.assertEquals(1, entries.size());
        System.assertEquals(entry14.Id, entries[0].Id);
        
        //- test #8: get entries by brand of product1
        filter = new DC_PricebookEntryDAO.Filter();
        filter.productBrand = product1.Brand__c;
        entries = DC_PricebookEntryDAO.getEntriesByFilter(filter, true);
        System.assertEquals(3, entries.size());
        for (PricebookEntry entry : entries)
        {
            System.assertEquals(product1.Id, entry.Product2Id);
        }
        
        //- test #9: get entries by line of product2
        filter = new DC_PricebookEntryDAO.Filter();
        filter.productLine = product2.Product_Line__c;
        //simply cover getSorting() and setSorting() methods
        filter.setSorting(new DC_SortingField[0]);
        System.assertEquals(0, filter.getSorting().size());
        
        entries = DC_PricebookEntryDAO.getEntriesByFilter(filter, true);
        System.assertEquals(3, entries.size());
        for (PricebookEntry entry : entries)
        {
            System.assertEquals(product2.Id, entry.Product2Id);
        }
        
        //- test #10: get entries by group description of the 4th level
        filter = new DC_PricebookEntryDAO.Filter();
        filter.productGroup4_Description = product1.PG4_Desc__c;
        entries = DC_PricebookEntryDAO.getEntriesByFilter(filter, true);
        System.assertEquals(3, entries.size());
        for (PricebookEntry entry : entries)
        {
            System.assertEquals(product1.Id, entry.Product2Id);
        }
        
        //- test #11: complex filter
        filter = new DC_PricebookEntryDAO.Filter();
        filter.keyword = 'Product1';
        filter.pricebookId = pricebook1.Id;
        filter.isActive = true;
        filter.currencyIsoCode = RUBLE_CODE;
        filter.productBrand = product1.Brand__c;
        filter.productLine = product1.Product_Line__c;
        filter.productGroup4_Description = product1.PG4_Desc__c;
        
        entries = DC_PricebookEntryDAO.getEntriesByFilter(filter, true);
        System.assertEquals(1, entries.size());
        System.assertEquals(entry11.Id, entries[0].Id);
    }
    
    @IsTest
    private static void test_PricebookEntryDAO_getUniqueFieldValuesByFilter()
    {
        //incorrect parameters
        String[] values = DC_PricebookEntryDAO.getUniqueFieldValuesByFilter(null, null, null);
        System.assertEquals(null, values);
        
        //CREATE TEST DATA:
        //- create test pricebooks (pricebook1 is a standard real pricebook)
        Pricebook2 pricebook1 = new Pricebook2(Id = Test.getStandardPricebookId());
        Pricebook2 pricebook2 = DC_UT_DataUtils.generatePricebook('Pricebook2', EURO_CODE);
        insert pricebook2;
        
        //- create test products
        Product2 product1 = DC_UT_DataUtils.generateProduct('Product1', 'Brand1',
            'Line1', 'L4_GD_P1');
        Product2 product2 = DC_UT_DataUtils.generateProduct('Product2', 'Brand1',
            'Line1', 'L4_GD_P2');
        Product2 product3 = DC_UT_DataUtils.generateProduct('Product3', 'Brand2',
            'Line2', 'L4_GD_P3');
        insert new Product2[] {product1, product2, product3};
        
        //- create test pricebook entries
        //pricebook1
        PricebookEntry entry11 = DC_UT_DataUtils.generatePricebookEntry(
            pricebook1.Id, product1.Id, 1000, RUBLE_CODE);
        PricebookEntry entry12 = DC_UT_DataUtils.generatePricebookEntry(
            pricebook1.Id, product2.Id, 25, RUBLE_CODE);
        PricebookEntry entry13 = DC_UT_DataUtils.generatePricebookEntry(
            pricebook1.Id, product3.Id, 5000, RUBLE_CODE);
        insert new PricebookEntry[] {entry11, entry12, entry13};
        //pricebook2
        PricebookEntry entry21 = DC_UT_DataUtils.generatePricebookEntry(
            pricebook2.Id, product1.Id, 30, RUBLE_CODE);
        insert new PricebookEntry[] {entry21};
        
        
        //PERFORM TESTING:
        //- test #1: extract Ids of pricebooks
        DC_PricebookEntryDAO.Filter filter = new DC_PricebookEntryDAO.Filter();
        values = DC_PricebookEntryDAO.getUniqueFieldValuesByFilter('Pricebook2Id', filter, null);
        System.assertEquals(2, values.size());
        
        //- test #2: extract product brands
        values = DC_PricebookEntryDAO.getUniqueFieldValuesByFilter(
            DC_PricebookEntryDAO.FIELD_PRODUCT_BRAND, filter, DC_SoqlEnums.SortingOrder.Ascending);
        System.assertEquals(2, values.size());
        String[] expectedBrands = new String[] {product1.Brand__c, product3.Brand__c};
        expectedBrands.sort();
        DC_UT_TestManager.assertEqualStringLists(expectedBrands, values);
        
        //- test #3: extract product lines from the 2nd pricebook only
        filter = new DC_PricebookEntryDAO.Filter();
        filter.pricebookId = pricebook2.Id;
        values = DC_PricebookEntryDAO.getUniqueFieldValuesByFilter(
            DC_PricebookEntryDAO.FIELD_PRODUCT_LINE, filter, DC_SoqlEnums.SortingOrder.Ascending);
        System.assertEquals(1, values.size());
        System.assertEquals(product1.Product_Line__c, values[0]);
        
        //- test #4: extract group descriptions of the 4th level
        filter = new DC_PricebookEntryDAO.Filter();
        values = DC_PricebookEntryDAO.getUniqueFieldValuesByFilter(
            DC_PricebookEntryDAO.FIELD_PG4_DESCRIPTION, filter,
            DC_SoqlEnums.SortingOrder.Descending);
        System.assertEquals(3, values.size());
        System.assertEquals('L4_GD_P3', values[0]);
        System.assertEquals('L4_GD_P2', values[1]);
        System.assertEquals('L4_GD_P1', values[2]);
        
        //- test #5: extract group descriptions of the 4th level using a complex filter
        filter = new DC_PricebookEntryDAO.Filter();
        filter.pricebookId = pricebook1.Id;
        filter.productBrand = product1.Brand__c;
        values = DC_PricebookEntryDAO.getUniqueFieldValuesByFilter(
            DC_PricebookEntryDAO.FIELD_PG4_DESCRIPTION, filter,
            DC_SoqlEnums.SortingOrder.Ascending);
        System.assertEquals(2, values.size());
        System.assertEquals('L4_GD_P1', values[0]);
        System.assertEquals('L4_GD_P2', values[1]);
    }
    
    @IsTest
    private static void test_PricebookEntryDAO_filter()
    {
        //- initialize and fill the filter
        DC_PricebookEntryDAO.Filter filter = new DC_PricebookEntryDAO.Filter();
        filter.currencyIsoCode = 'USD';
        filter.pricebookId = 'Pricebook1Id';
        filter.keyword = 'Keyword';
        filter.productBrand = 'B1';
        filter.productLine = 'PLine';
        filter.productGroup4_Description = 'PGL4D';
        filter.isActive = true;
        filter.limitOfResult = 100;
        filter.ids = new String[] {'Id1', 'Id2'};
        filter.productArticleNumbers = new String[] {'N1', 'N2'};
        filter.sortingFields.add(new DC_SortingField(DC_PricebookEntryDAO.FIELD_PRODUCT_NAME));
        
        //- make a deep copy of the filter
        DC_PricebookEntryDAO.Filter clonedFilter = filter.makeDeepCopy();
        
        //- check that all properties are equal
        System.assertEquals(filter.currencyIsoCode, clonedFilter.currencyIsoCode);
        System.assertEquals(filter.isActive, clonedFilter.isActive);
        System.assertEquals(filter.keyword, clonedFilter.keyword);
        System.assertEquals(filter.limitOfResult, clonedFilter.limitOfResult);
        System.assertEquals(filter.pricebookId, clonedFilter.pricebookId);
        System.assertEquals(filter.productBrand, clonedFilter.productBrand);
        System.assertEquals(filter.productGroup4_Description, clonedFilter.productGroup4_Description);
        System.assertEquals(filter.productLine, clonedFilter.productLine);
        System.assertEquals(filter.ids.size(), clonedFilter.ids.size());
        System.assertEquals(filter.productArticleNumbers.size(),
            clonedFilter.productArticleNumbers.size());
        System.assertEquals(filter.sortingFields.size(), clonedFilter.sortingFields.size());
        
        //- make some changes in the original filter
        filter.pricebookId = 'Pricebook2';
        filter.ids.clear();
        filter.productArticleNumbers.clear();
        filter.sortingFields.clear();
        
        //- check that updated properties are not equal
        System.assertNotEquals(filter.ids.size(), clonedFilter.ids.size());
        System.assertNotEquals(filter.productArticleNumbers.size(),
            clonedFilter.productArticleNumbers.size());
        System.assertNotEquals(filter.sortingFields.size(), clonedFilter.sortingFields.size());
    } */
    //
    
    
    
}