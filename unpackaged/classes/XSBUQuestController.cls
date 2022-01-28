public class XSBUQuestController {
    public static String UserLanguage {get;set;}
    public static String Country {get;set;}
    public static String AccountId {get;set;}
    public static String QuestionnaireSetupId {get;set;}
    public static String QuestionnaireType {get;set;}
    public static String SourceId {get;set;}
    public static Boolean NotSBUSPecific {get;set;}
    public static String CreateOpportunity {get;set;}
    public Static String QuestionnaireName {get;set;}
    public Static String AccountName {get;set;}
    public Static Boolean Show_contacts {get; set;}
    public Static Boolean Show_owner {get; set;}
    public Static String Opp_owner {get; set;}
    public Static User DefaultUser {get; set;}
    public Static List<XSBUProduct__c> ProductsToAdd {get; set;}
    public Static List<OpportunityLineItem> AddedProducts {get; set;}
    public Static List<Pricebook2> pb {get; set;}
    public Static List<UserTerritory2Association> TestingETM {get; set;}
    public Static List<ObjectTerritory2Association> Account2ETM {get;set;}
    public Static List<User> UsETM {get; set;}
    private final Account acct;

    public XSBUQuestController(ApexPages.StandardController stdController) {

        UserLanguage = [SELECT LanguageLocaleKey FROM User WHERE Id = :UserInfo.getUserId()].LanguageLocaleKey;
        System.debug('UserLanguage: ' + Userlanguage);

        AccountId = ApexPages.currentPage().getParameters().get('Id');

        If (AccountId != null) {
            acct = [select Name, Country__c FROM Account where Id = :AccountId];

            Country = acct.Country__c;
            AccountName = acct.Name;
            AccountId = acct.Id; 
        }

        System.debug('Country: ' + Country);
        System.debug('Name: ' + AccountName);

        String productLine;
        
        DefaultUser = new User();

        SourceId = ApexPages.currentPage().getParameters().get('SourceId');

        QuestionnaireType = ApexPages.currentPage().getParameters().get('QType');
        if(QuestionnaireType != null) {
            Questionnaire_Setup__c[] qs = [SELECT Id, Product_Line__c, Name, Create_Opportunity__c, Show_contact_option__c, Show_manual_assignment_of_owner_option__c, Owner_Of_Opportunity__c, Default_User__c FROM Questionnaire_Setup__c WHERE Questionnaire_Type__c = :QuestionnaireType and Country__c includes (:Country) and Status__c = 'Active'];

            if(qs.size() > 0) {
                productLine  = qs[0].Product_Line__c; 
                QuestionnaireSetupId  = qs[0].Id;  
                CreateOpportunity = qs[0].Create_Opportunity__c; 
                QuestionnaireName = qs[0].Name;
                Show_contacts = qs[0].Show_contact_option__c;
                Show_owner = qs[0].Show_manual_assignment_of_owner_option__c;
                Opp_owner = qs[0].Owner_Of_Opportunity__c;
                DefaultUser = [SELECT Id, FirstName, LastName, UserRole.Name FROM User WHERE Id =: qs[0].Default_User__c];                
                
            } else {
                System.debug('Questionnaire setup cannot be found.');
            }
        }

        NotSBUSPecific = false;

        if(productLine == 'Not SBU-Specific') {
            NotSBUSPecific = true;
        }
                    
    }

    @RemoteAction
    public static List<String> GetSBUList() {

        List<String> values = new List<String>(); 

        Schema.DescribeFieldResult fieldResult =
                Questions__c.Product_Line__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        
        values.add('--' + Label.xsbu_Select_SBU);
        system.debug(ple);
        for( Schema.PicklistEntry f : ple)
        {
            values.add(f.getValue());
            system.debug(f.getValue());
            system.debug(f.getLabel());
        }       
        return values;
    }

    @RemoteAction
    public static List<String> GetProductLineList(String questionnaireTypex, String countryx) {

        List<String> values = new List<String>(); 
        Questionnaire_Setup__c[] productLine;

        System.debug('GetProductLineList QuestionnaireType: ' + questionnaireTypex + ' country: ' + countryx);

        productLine  = [SELECT toLabel(Product_Line__c) FROM Questionnaire_Setup__c WHERE Questionnaire_Type__c = :questionnaireTypex and Country__c includes (:countryx)  and Status__c = 'Active'];
        values.add('--' + Label.xsbu_Select_Product_Line);
       
       if(productLine.size() > 0) {
            for( String s : productLine[0].Product_Line__c.Split(';'))
            {
                values.add(s);
            }       
       }
        return values;
    }
        
    @RemoteAction
    public static List<Contact> GetContactList(string accountIdx) {

        List<String> values = new List<String>(); 

        List<Contact> contactIds = [SELECT Id, FirstName, LastName, Phone, Email FROM Contact WHERE AccountId =: accountIdx];
               
        return contactIds;
    }
    
    @RemoteAction    
    public static List<UserTerritory2Association> getUserList(String accountIdx) {
    Account2ETM = [SELECT ObjectId, Territory2Id FROM ObjectTerritory2Association WHERE ObjectId =: accountIdx];
    TestingETM = new List<UserTerritory2Association> ();    
    for(Integer i=0; i<Account2ETM.size(); i++) {        
    List<UserTerritory2Association> TestETM = [SELECT Territory2Id, UserId, RoleInTerritory2, Territory2.Name, User.FirstName, User.LastName, User.Id, User.Profile.Name, User.UserRole.Name, User.UserRoleId FROM UserTerritory2Association WHERE Territory2Id =: Account2ETM[i].Territory2Id];
    TestingETM.addAll(TestETM);   
    }
    
    UsETM = new List<User>();
    
    if(TestingETM.size()>0){        
    for(Integer i=0; i<TestingETM.size(); i++) {                 
        UsETM.add([Select FirstName, LastName, Id, Profile.Name, UserRole.Name FROM User WHERE Id =: TestingETM[i].UserId]);        
    }
    }
    else{
            UsETM.add([SELECT FirstName, LastName, Id, Profile.Name, UserRole.Name FROM User WHERE Id =: UserInfo.getUserId()]);
    }    
      
        
    /*List<String> values = new List<String>();
    
    if(UsETM.size() > 0) {
            for(Integer i = 0; i<UsETM.size(); i++)
            {
                values.add(UsETM[i].FirstName + ' ' + UsETM[i].LastName);
            }       
       }*/
      
    return TestingETM;    
             
    }

    @RemoteAction
    public static List<Question> GetQuestions(String QuestionnaireSetupIdx, String notSBUSPecificx, String productLine)
    {
        List<Question> wrappedQuestionList = new List<Question>();
        Integer i = 1;

        System.debug('GetQuestions QuestionnaireSetupId: ' + QuestionnaireSetupIdx);

        List<Questions__c> questionList;

        if(notSBUSPecificx == 'true') {
            questionList = [SELECT 
                            Id, 
                            Name, 
                            Question_Body__c, 
                            Question_Order__c, 
                            Question_Type__c, 
                            Responses__c, 
                            Status__c,
                            Required_Question__c,
                            Product_Line__c
                        FROM Questions__c WHERE Status__c = 'Active' AND Questionnaire_Setup__c = :QuestionnaireSetupIdx ORDER BY Question_Order__c ASC];
        } else {
            questionList = [SELECT 
                            Id, 
                            Name, 
                            Question_Body__c, 
                            Question_Order__c, 
                            Question_Type__c, 
                            Responses__c, 
                            Status__c,
                            Required_Question__c,
                            Product_Line__c
                            FROM Questions__c WHERE Status__c = 'Active' AND Questionnaire_Setup__c = :QuestionnaireSetupIdx AND tolabel(Product_Line__c) = :productLine ORDER BY Question_Order__c ASC];

        }

        for(Questions__c q1 : questionList) {
            
            Question q2 = new Question();

            q2.Id = q1.Id;
            q2.QuestionOrder = i++;
            q2.Required = q1.Required_Question__c;
            q2.QuestionBody = q1.Question_Body__c;
            q2.QuestionType = q1.Question_Type__c;
            q2.QuestionnaireSetupIdxx = QuestionnaireSetupIdx;
            q2.Responses = q1.Responses__c;
            q2.PickListDefaultValue = Label.xsbu_Select_Answer;

            wrappedQuestionList.add(q2);
        }           
        return wrappedQuestionList;
    }

    public class Question {
       public String Id {get;set;}
       public Integer QuestionOrder {get;set;}
       public Boolean Required {get;set;}
       public String QuestionBody {get;set;}
       public String QuestionType {get;set;}
       public String Responses {get;set;}
       public String Answer {get;set;}
       public String theAccountId {get;set;}
       public String QuestionnaireSetupIdxx {get;set;}
       public String PickListDefaultValue {get;set;}
    }

    @RemoteAction
    public static String Save(String questions, String productLine, String CreateOpportunityx, String answerName, String accountIdx, String questionnaireSetupIdx, String sourceIdx, String contactIdx, String userIdx)
    {
        Opportunity opp;
        System.debug('Questions: ' + questions);

        System.debug('Save CreateOpportunityx: ' + CreateOpportunityx);

        if(CreateOpportunityx != 'Do Not') {
            
            opp = new Opportunity();

            System.debug('productLine: ' + productLine);

            opp.AccountId = accountIdx;

            if(productLine != '--' + Label.xsbu_Select_Product_Line) {
                opp.Name = productline + '-prospect';
            } else {
                opp.Name = 'Not SBU-specific-prospect';
            }
            opp.StageName = 'Submitted';
            opp.CloseDate =  date.today().addMonths(3);
                        
            if(userIdx != ''){
            opp.Assign_Owner_Automatically__c = false;
            opp.OwnerId = userIdx;
            //opp.Description = userIdx;    
            }
            else{
            opp.Assign_Owner_Automatically__c = true;   
            }
                       
            if(productLine != '--' + Label.xsbu_Select_Product_Line) {
                opp.Product_Line_Interested_In__c = getTranslation(productLine);
            }
            if(questionnaireSetupIdx != '') {
                opp.Questionnaire_Id__c = questionnaireSetupIdx;
            }
            
            if(contactIdx !='') {
                opp.Primary_contact__c = contactIdx;
            }

            opp.RecordTypeId = [Select Id From RecordType  Where SobjectType = 'Opportunity' and DeveloperName = 'xsbu_prospecting'].Id;
            pb = [Select Id from Pricebook2 Where Name =: 'Sirona Products'];
            opp.Pricebook2Id = pb[0].Id;
            
            Account CurrencyAcc = [SELECT CurrencyISOCode From Account Where Id=:accountIdx];            
            opp.CurrencyIsoCode = CurrencyAcc.CurrencyISOCode; 
            insert(opp);
            
            ProductsToAdd = [SELECT Id, Product__c, Price__c FROM XSBUProduct__c Where (QuestionnaireSetup__c =:QuestionnaireSetupIdx AND Product_line__c =:productLine)]; 
            
            AddedProducts = new List<OpportunityLineItem>();
            
            if(ProductsToAdd.size()>0) {            
                for (XSBUProduct__c entry: ProductsToAdd) {
                    List<PricebookEntry> pricebitem = new List<PricebookEntry>();
                    pricebitem = [SELECT Id FROM PricebookEntry WHERE (Pricebook2Id =: Opp.Pricebook2Id AND Product2Id =: entry.Product__c AND CurrencyISOCode =:opp.CurrencyIsoCode)];                    
                    
                    OpportunityLineItem ItemToAdd = new OpportunityLineItem();
                    ItemToAdd.OpportunityId = opp.Id;
                    ItemToAdd.PricebookEntryId = pricebitem[0].Id;
                    ItemToAdd.Product2Id = entry.Product__c;
                    ItemToAdd.Quantity = 1;
                    ItemToAdd.UnitPrice = entry.Price__c;
                                        
                    addedProducts.add(ItemToAdd);        
                    
                }
                      
                 try{
                    insert(addedProducts);
                 }
                    catch(exception e) {
                        apexpages.addmessages(e);

                    }                
            }
                
                        
        }
        
        List<Question> questionList = new List<Question>();

        if(questions != '') {
            questionList = (List<Question>)JSON.deserialize(questions, List<Question>.class);
        }

        List<Q_A__c> answers = new List<Q_A__c>();
        Q_A__c answer;

        for(question q : questionList) {
            System.debug('Account: ' + q.theAccountId + ' Answer: ' + q.QuestionBody + ' : ' + q.Answer);

            answer = new Q_A__c();
            answer.Name = answerName;
            answer.Account_Name__c = q.theAccountId; 
            answer.Answer__c = q.Answer;
            answer.Question__c = q.QuestionBody;
            answer.Questionnaire_Setup__c = q.QuestionnaireSetupIdxx;
            answer.Submitted_By__c  = UserInfo.getUserId();
            answer.Source_Id__c = sourceIdx;

            if(CreateOpportunityx != 'Do Not') {
                answer.Opportunity_Name__c = opp.Id;
            }

            answers.add(answer);
        }

        insert(answers);

        // Synch opp and QA to Sirona
        // TODO : Check if it is a sirona opp.

        User user = [SELECT User_Country__c FROM User WHERE Id = :UserInfo.getUserId()];
        
        XSBU_2_orgs__c XSBUConfig = XSBU_2_orgs__c.getValues(user.User_Country__c);

        if(XSBUConfig != null) {
            OpportunitySynch.SynchOpportunityInsert(opp.Id);
        }
        
        System.debug('Save return Success');        
        return 'Success';
    }
// new class to translate
        
    public static String getTranslation(string value_to_translate)
    { 
        Schema.DescribeFieldResult Field = Questionnaire_Setup__c.Product_Line__c.getDescribe();
        List<Schema.PicklistEntry> Picklistvalues = Field.getPicklistValues();
        Map<String, String> mapMyFieldTranslation = new Map<String, String>();
        
        for(Schema.PicklistEntry entry : Picklistvalues)
        {
            mapMyFieldTranslation.put(entry.label, entry.value);
        }
        
        String Translated = mapMyFieldTranslation.get(value_to_translate);
        return Translated;
    }
}