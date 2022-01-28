@isTest
public class XSBUQuestControllerTest {
    static testMethod void test() {
        Account testAccount = new Account();
        testAccount.Name = 'TestAccount';
        testAccount.Country__c = 'GB';
        testAccount.CurrencyISOCode = 'GBP';
        insert testAccount;
        
        Contact testContact = new Contact();
        testContact.FirstName = 'Test';
        testContact.LastName = 'Testsson';
        testContact.AccountId = testAccount.Id;
        insert testContact;
        
        Questionnaire_Setup__c testQuestionnaire = new Questionnaire_Setup__c();

        Pricebook2 pricebook1 = new Pricebook2(Id = Test.getStandardPricebookId());
		        	
        Pricebook2 TestPricebook = DC_UT_DataUtils.generatePricebook('Sirona Products', 'GBP');
        User u = [Select id, Market__c from User where Id=: UserInfo.getUserId()];
        TestPricebook.Market__c = u.Market__c;
        insert TestPricebook;
              
        Product2 product1 = DC_UT_DataUtils.generateProduct('Product 1', 'Implants', 'Line', 'Test');
        product1.RecordTypeId = '0120J000000cmdI';
        insert product1;
        
        PricebookEntry pbe0 = DC_UT_DataUtils.generatePricebookEntry(pricebook1.id, product1.id, 10, 'GBP');
        insert pbe0;
        
        PricebookEntry pbe1 = DC_UT_DataUtils.generatePricebookEntry(TestPricebook.Id, product1.id, 10, 'GBP');
        insert pbe1;       

        testQuestionnaire.Questionnaire_Type__c = 'xSBU';
        testQuestionnaire.Country__c = 'GB';
        testQuestionnaire.Name = 'Test';
        testQuestionnaire.Product_Line__c = 'Imaging';
        testQuestionnaire.Status__c = 'Active';
        testQuestionnaire.Create_Opportunity__c = 'Sirona Opportunity';
        testQuestionnaire.Owner_Of_Opportunity__c = 'Default User';
        testQuestionnaire.Partner_Assignment__c = 'Auto';
        testQuestionnaire.Default_User__c= UserInfo.getUserId();
        testQuestionnaire.Show_contact_option__c = true;

        insert testQuestionnaire;
          
        XSBUProduct__c Xpbe1 = new XSBUProduct__c();
        Xpbe1.Product__c = product1.id;
        Xpbe1.Price__c = 10;
        Xpbe1.CurrencyISOCode = 'GBP';
        Xpbe1.QuestionnaireSetup__c = testQuestionnaire.Id;
        Xpbe1.Product_line__c = 'Imaging';
        insert Xpbe1;
        
        Questions__c q = new Questions__c();

        q.Product_Line__c = 'Imaging';
        q.Status__c = 'Active';
        q.Question_Type__c = 'Free Text';
        q.Question_Body__c = 'The question';
        q.Questionnaire_Setup__c = testQuestionnaire.Id;
        q.Question_Order__c = 1;
        
        insert q;
                
        List<Questions__c> qList = new List<Questions__c>();
        qList.add(q);
        //insert qList;
               
        Test.startTest();
                
        PageReference pageRef = Page.XSBUQuest;
        Test.setCurrentPage(pageRef);
                
        ApexPages.currentPage().getParameters().put('id', testAccount.id);
        ApexPages.currentPage().getParameters().put('QuestionnaireSetupId', testQuestionnaire.id);
        ApexPages.currentPage().getParameters().put('Country', testQuestionnaire.Country__c);
        ApexPages.currentPage().getParameters().put('QuestionnaireName', testQuestionnaire.Name);
        ApexPages.currentPage().getParameters().put('QuestionnaireType', 'xSBU');
        ApexPages.currentPage().getParameters().put('QType', 'xSBU');
        ApexPages.currentPage().getParameters().put('selectedContact', testContact.id);
        ApexPages.currentPage().getParameters().put('theAccountId', testAccount.id);
        
        ApexPages.StandardController ctrl = new ApexPages.StandardController(testAccount);
        XSBUQuestController ctrlExt = new XSBUQuestController(ctrl);
        
        List<String> sbuList = XSBUQuestController.GetSBUList();
        System.assertNotEquals(null, sbuList);
        
        List<Contact> contactList = XSBUQuestController.GetContactList(String.valueOf(testAccount.Id));
        System.assertNotEquals(null, contactList);  

        List<String> productLineList = XSBUQuestController.GetProductLineList('xSBU','GB');
        System.assertNotEquals(null, productLineList);
        
        List<XSBUQuestController.Question> questionList = XSBUQuestController.GetQuestions(testQuestionnaire.Id,'false', 'Imaging');
        System.assertNotEquals(null, questionList); 

        questionList = XSBUQuestController.GetQuestions(testQuestionnaire.Id,'true', 'Imaging');
        System.assertNotEquals(null, questionList); 

        //Try witout user
        XSBUQuestController.Save('', 'Imaging', 'Sirona Opportunity', '', testAccount.Id, testQuestionnaire.Id, '', testContact.Id, ''); //JSON.serialize(qList)
		
        //Try with user
        XSBUQuestController.Save('', 'Imaging', 'Sirona Opportunity', '', testAccount.Id, testQuestionnaire.Id, '', testContact.Id, UserInfo.getUserId()); //JSON.serialize(qList)
		
        /*Territory2 TestETM = new Territory2();
        TestETM.DeveloperName = 'Test_ETM';
        insert TestETM;
        
        ObjectTerritory2Association Acc2ETM = new ObjectTerritory2Association();
        Acc2ETM = [SELECT ObjectId, Territory2Id FROM ObjectTerritory2Association WHERE ObjectId =: testAccount.Id];
        Acc2ETM.ObjectId = testAccount.Id;
        Acc2ETM.Territory2Id = TestETM.Id;
        insert Acc2ETM;
                
        UserTerritory2Association User2ETM = new UserTerritory2Association();
        User2ETM.Territory2Id = TestETM.Id;
        User2ETM.UserId = UserInfo.getUserId();
        insert User2ETM;*/
        
        List<UserTerritory2Association> UsrLst = XSBUQuestController.getUserList(testAccount.Id);
        System.assertNotEquals(null, UsrLst);
        
        Test.stopTest();
    }
 }