//
//This class creates data for Unit tests.
//
//Used abbreviations:
//- UT: unit tests
//Author: Gennadiy Pervukhin (13-11-2014)
@IsTest
public class DC_UT_DataUtils
{
    //
    //Constants
    //
    public static final String ADMINISTRATOR_PROFILE_NAME = 'System Administrator';
    
    //max length of dynamic part of user name (the part which comes before @-char).
    //It's specific for our implementation only. In fact, User object has limit in 40
    //chars for username, nickname, firstname and etc.
    private static final Integer MAX_LENGTH_OF_USER_NICKNAME = 15;
    //
    
    //Allow only few domains
    private static final String EMAIL_DOMAIN = 'dentsplysirona.com';
    
    //
    //Private static methods
    //
    private static User createSfUser(String userName, String email, String alias,
        String profileName)
    {
        //1) try to get the profile by name
        Profile[] profiles = [SELECT Id FROM Profile WHERE Name = :profileName];
        if (profiles.size() == 0)
        {
            throw new DC_CustomException(String.format(
                'Unit Test expects that "{0}" profile exists in your org',
                new String[] {profileName}));
        }
        
        User sfUser = new User();
        sfUser.ProfileId = profiles[0].Id;
        sfUser.IsActive = true;
        sfUser.Username = userName;
        sfUser.FirstName = userName;
        sfUser.LastName = userName;
        sfUser.Email = email;
        sfUser.Alias = alias;
        sfUser.CommunityNickname = email;
        sfUser.LocaleSidKey = 'en_US';
        sfUser.LanguageLocaleKey = 'en_US';
        sfUser.EmailEncodingKey = 'ISO-8859-1';
        sfUser.TimeZoneSidKey = 'America/New_York';
        sfUser.SBU_Ratio_ENDO__c = 100;
        
        Boolean isInsertionSuccessful = DC_SoqlUtils.tryPerformDmlOperation(
            DC_SoqlEnums.DmlOperation.Inserting, sfUser);
        if (!isInsertionSuccessful)
        {
            sfUser = null;
        }
        return sfUser;
    }
    //
    
    //
    //Public static methods which generate test objects, but do not insert them
    //
    public static Event generateEvent(String subject, DateTime startDateTime, DateTime endDateTime)
    {
        Event newEvent = new Event();
        newEvent.Subject = subject;
        newEvent.StartDateTime = startDateTime;
        newEvent.EndDateTime = endDateTime;
        //we need to set this value to 'false' to pass a validation rule
        newEvent.Customer_Facing_Event__c = false;
        return newEvent;
    }
    
    public static EventRelation generateEventRelation(String eventId, String relationId)
    {
        EventRelation relation = new EventRelation();
        relation.EventId = eventId;
        relation.RelationId = relationId;
        return relation;
    }
    
    public static Contact generateContact(String lastName)
    {
        Contact newContact = new Contact();
        newContact.LastName = lastName;
        return newContact;
    }
    
    public static Attachment generateAttachment(String attachmentName, String parentId, Blob body)
    {
        Attachment newAttachment = new Attachment();
        newAttachment.Name = attachmentName;
        newAttachment.ParentId = parentId;
        newAttachment.Body = body;
        return newAttachment;
    }
    
    public static Pricebook2 generatePricebook(String name, String currencyIsoCode)
    {
        Pricebook2 newPricebook = new Pricebook2();
        newPricebook.Name = name;
        newPricebook.CurrencyIsoCode = currencyIsoCode;
        newPricebook.IsActive = true;
        return newPricebook;
    }
    
    public static Product2 generateProduct(String name, String brand, String line,
        String groupDescriptionL4)
    {
        Product2 newProduct = new Product2();
        newProduct.Name = name;
        newProduct.Description = 'Description_' + name;
        newProduct.Article__c = 'Article_' + name;
        newProduct.IsActive = true;
        
        newProduct.Brand__c = brand;
        newProduct.Product_Line__c = line;
        newProduct.PG4_Desc__c = groupDescriptionL4;
        return newProduct;
    }
    
    public static PricebookEntry generatePricebookEntry(String pricebookId,
        String productId, Double unitPrice, String currencyIsoCode)
    {
        PricebookEntry newEntry = new PricebookEntry();
        newEntry.Pricebook2Id = pricebookId;
        newEntry.Product2Id = productId;
        newEntry.UnitPrice = unitPrice;
        newEntry.CurrencyIsoCode = currencyIsoCode;
        newEntry.IsActive = true;
        return newEntry;
    }
    
    public static PricebookEntry[] generatePricebookEntries(String pricebookId,
        Product2[] products, Double unitPrice, String currencyIsoCode)
    {
        List<PricebookEntry> newEntries = new List<PricebookEntry>();
        for (Product2 product : products)
        {
            newEntries.add(generatePricebookEntry(pricebookId, product.Id,
                unitPrice, currencyIsoCode));
        }
        return newEntries;
    }
    
        public static Product_bundle__c generateBundle(String bundleName, String pricebookId, String Bundlecurrency)
    {
        Product_bundle__c newEntry = new Product_bundle__c();
        newEntry.Name = bundleName;
        newEntry.Price_Book__c = pricebookId;
        newEntry.Quantity__c = 1;
        newEntry.currencyISOcode = Bundlecurrency;
        return newEntry;
    }
    
        public static BOM__c generateBOM(String bomName, String bundleID, Double quantity)
    {
        BOM__c newEntry = new BOM__c();
        newEntry.Name = bomName;
        newEntry.Product_bundle__c = bundleID;
        newEntry.Quantity__c = quantity;
        return newEntry;
    }
    
    
    public static Account generateAccount(String name)
    {
        Account newAccount = new Account();
        newAccount.Name = name;
        return newAccount;
    }
    
    public static Order generateOrder(String accountId, Date effectiveDate,
        String currencyIsoCode)
    {
        Order newOrder = new Order();
        newOrder.AccountId = accountId;
        newOrder.EffectiveDate = effectiveDate;
        newOrder.CurrencyIsoCode = currencyIsoCode;
        newOrder.Status = 'Created';
        return newOrder;
    }
    //
    
    
    
    //
    //Public static methods which generate test objects and insert them
    //
    public static Event[] createTestEvents(Integer numberOfEvents)
    {
        List<Event> newEvents = new List<Event>();
        DateTime startDateTime = DateTime.now();
        DateTime endDateTime = DateTime.now().addHours(1);
        for (Integer indexOfEvent = 0; indexOfEvent < numberOfEvents; indexOfEvent++)
        {
            Event newEvent = DC_UT_DataUtils.generateEvent('Event-' + indexOfEvent,
                startDateTime, endDateTime);
            newEvents.add(newEvent);
        }
        insert newEvents;
        return newEvents;
    }
    
    public static DC_Setting__c createSetting(String name, String value)
    {
        DC_Setting__c setting = new DC_Setting__c();
        setting.Name = name;
        setting.Value__c = value;
        insert setting;
        return setting;
    }
    
    public static User createSfUser(String nickName, String profileName)
    {
        //correct nickname
        nickName = (nickName.length() > MAX_LENGTH_OF_USER_NICKNAME ?
            nickName.substring(0, MAX_LENGTH_OF_USER_NICKNAME) : nickName);
        
        //username will be of format, like nickname12345@cs8.salesforce.com
        String userName = nickName + String.valueOf(Math.round(100000 * Math.random()))
            + '@' + EMAIL_DOMAIN; //Url.getSalesforceBaseUrl().getHost();
        String alias = userName.substring(0, 8);
        String email = userName;
        
        User sfUser = createSfUser(userName, email, alias, profileName);
        return sfUser;
    }
    
    public static User createSfUser(String nickName)
    {
        return createSfUser(nickName, ADMINISTRATOR_PROFILE_NAME);
    }
    
    public static EmailTemplate createOrGetEmailTemplate(String developerName)
    {
        EmailTemplate template = DC_EmailTemplateDAO.getTemplateByDeveloperName(developerName);
        if (template == null)
        {
            template = new EmailTemplate();
            template.Name = developerName;
            template.DeveloperName = developerName;
            template.Subject = 'Test Subject';
            template.HtmlValue = '<html><head></head><body><div>Content</div></body></html>';
            template.TemplateType = 'custom';
            template.FolderId = UserInfo.getUserId();
            insert template;
        }
        return template;
    }
    //
}