@isTest
public class CaseWSCalloutTest {
    
    @isTest static void parsePayloadTest()
    {
        Case aCase = new Case();
        
        ApexPages.StandardController controller = new ApexPages.StandardController( aCase );
        
        CaseExtension extension = new CaseExtension( controller );
        
        String payload = '{"responseCode":100}';
        
        Map<String, String> payloadMap = CaseExtension.parseLogEventPayload( payload );
        
        System.assertEquals( '100', payloadMap.get('responseCode') );
    }
    
    @isTest static void buildLogEventTest()
    {
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        
        String orgId = UserInfo.getOrganizationId();
        String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
        Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
        String uniqueName = orgId + dateString + randomInt;
        String email = uniqueName + '@dentsplysirona.com';
        
        User u = new User(Alias = 'unittest', Email = email, 
                          EmailEncodingKey='UTF-8', LastName='exception', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName = email, ComputerID__c = 'unittest');
        
        System.runAs(u) {
            Account account = new Account(Name ='John Doe Account');
            insert account;
            
            Contact contact = new Contact( FirstName = 'John', LastName='Doe', Email = 'testuser@dentsplysirona.com', AccountId = account.Id, InsertEmailMarketingConsentCollected__c = 'No' );
            insert contact;
            
            Case aCase = new Case( AccountId = account.Id, ContactId = contact.Id );
            insert aCase;
            ApexPages.StandardController controller = new ApexPages.StandardController( aCase );
            
            CaseExtension extension = new CaseExtension( controller );
            
            extension.getRequiredInfo();
            
            System.assert(extension.buildLogEventJson() != null);
            
            JSONParser parser = JSON.createParser(extension.buildLogEventJson());
            
            system.debug(extension.buildLogEventJson());
            
            while (parser.nextToken() != null) {
                if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && 
                    (parser.getText() == 'user')) 
                {
                    // Get the value.
                    parser.nextToken();
                    System.assert(parser.getText() != null);
                }
                
                if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && 
                    (parser.getText() == 'parm3')) 
                {
                     Case[] bCase = [Select CaseNumber, ContactId, AccountId  From Case Where Id = :aCase.Id];

                    //contactLastName, contactFirstName | contactEmail | accountName |accountId|contactId|caseNumber
                    String pipedParams = 'Doe,John|testuser@dentsplysirona.com|' + account.Name + '|' + account.Id + '|' + contact.Id + '|' + bCase[0].CaseNumber;
                    System.Debug( 'PipedParams:' + pipedParams );
                    
                    // Get the value.
                    parser.nextToken();
                    System.Debug( 'parser.getText():' + parser.getText() );
                    
                    System.assertEquals(pipedParams, parser.getText());
                }
            }
            
        }
    }
    
    
    @isTest static void testNoComputerLoginId()
    {
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        
        String orgId = UserInfo.getOrganizationId();
        String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
        Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
        String uniqueName = orgId + dateString + randomInt;
        String email = uniqueName + '@dentsplysirona.com';
        
        // test no ComputerID__c
        User u = new User(Alias = 'unittest', Email = email, 
                          EmailEncodingKey='UTF-8', LastName='exception', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName = email, ComputerID__c = null);
        
        System.runAs(u) {
            Account account = new Account(Name ='John Doe Account');
            insert account;
            
            Contact contact = new Contact( FirstName = 'John', LastName='Doe', Email = 'testuser@dentsplysirona.com', AccountId = account.Id, InsertEmailMarketingConsentCollected__c = 'No' );
            insert contact;
            
            Case aCase = new Case( AccountId = account.Id, ContactId = contact.Id );
            insert aCase;
            ApexPages.StandardController controller = new ApexPages.StandardController( aCase );
            
            CaseExtension extension = new CaseExtension( controller );
            
            System.debug('About to start getRequiredInfo');
            boolean isExceptionCaught = false;
            try 
            {
                extension.getRequiredInfo();
            } 
            catch (Exception e)
            {
                isExceptionCaught = true;
            }
            finally 
            {
                System.assert( isExceptionCaught );  
            }
            
        }
    }
    
    @isTest static void testException()
    {
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        
        String orgId = UserInfo.getOrganizationId();
        String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
        Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
        String uniqueName = orgId + dateString + randomInt;
        String email = uniqueName + '@dentsplysirona.com';
        
        // test no ComputerID__c
        User u = new User(Alias = 'unittest', Email = email, 
                          EmailEncodingKey='UTF-8', LastName='exception', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName = email, ComputerID__c = null);
        
        System.runAs(u) {
            Account account = new Account(Name ='John Doe Account');
            insert account;
            
            Contact contact = new Contact( FirstName = 'John', LastName='Doe', Email = 'testuser@dentsplysirona.com', AccountId = account.Id, InsertEmailMarketingConsentCollected__c = 'No' );
            insert contact;
            
            Case aCase = new Case( AccountId = account.Id, ContactId = contact.Id );
            insert aCase;
            ApexPages.StandardController controller = new ApexPages.StandardController( aCase );
            
            CaseExtension extension = new CaseExtension( controller );
            
            System.debug('About to test buildLogEventJson');
            boolean isExceptionCaught = false;
            try 
            {
                extension.buildLogEventJson();
            } 
            catch (Exception e)
            {
                isExceptionCaught = true;
            }
            finally 
            {
                System.assert( isExceptionCaught );  
            }
            
            System.debug('About to test generatePipedParam');
            String pipedParams = extension.generatePipedParam();
            System.debug('generatePipedParam returns: ' + pipedParams);
            System.assertEquals(pipedParams, '|||||');
            
        }
    }
}