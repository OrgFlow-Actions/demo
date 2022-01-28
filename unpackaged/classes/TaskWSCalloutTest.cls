@isTest
public class TaskWSCalloutTest {

    @isTest static void testValidation() 
    {
        System.debug('testValidation started');
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
            
            Contact contact = new Contact( FirstName = 'John', LastName='Doe', Email = 'jdoe@dentsplysirona.com', AccountId = account.Id, InsertEmailMarketingConsentCollected__c = 'No' );
            insert contact;

            Opportunity opportunity = new Opportunity( Name = 'Test Opportunity', AccountId = account.Id, StageName = 'Test', CloseDate=Date.newInstance(1960, 2, 17) );
            insert opportunity;
            
            Date nowDate = Date.today();
            
            Task aTask = new Task( 
                                   Subject='Test',
                                   Status='New',
                                   Priority='Normal',
                                   ActivityDate = nowDate,
                                   CallDisposition = 'Scheduled another call',
                                   TaskSubtype = 'Task'
                                 );
            insert aTask;
            
            MyTaskController controller = new MyTaskController( aTask );
            TaskExtension extension = new TaskExtension( controller );
            
            System.debug('DEBUGGING aTask.WhoId = ' + aTask.WhoId);
            System.debug('DEBUGGING aTask.WhatId = ' + aTask.WhatId);
            
            extension.getRequiredInfo();
            
            //test that if account id is not set we get an exception
            boolean isNoAccountExceptionThrown = false;
            try 
            {
                // this should throw an exception because the account id is not set
                extension.buildLogEventJson();
            }
            catch(Exception ex)
            {
                isNoAccountExceptionThrown = true;
            }
            finally
            {
                System.assert(isNoAccountExceptionThrown);
            }
            
            // test that if we do not have a what/who id we get an exception
            boolean isNoWhoWhatExceptionThrown = false;
            try 
            {
                extension.accountId = account.Id;
                // this should throw an exception because the WhatId and WhoID is not set
                extension.buildLogEventJson();
            }
            catch(Exception ex)
            {
                isNoWhoWhatExceptionThrown = true;
            }
            finally
            {
                System.assert(isNoWhoWhatExceptionThrown);
            }
            
            // test that if the user id does not have a prefix of 005 we get an exception
            boolean isWrongUserIdPrefixException = false;
            try 
            {
                extension.accountId = account.Id;
                extension.userId = '006abcd';
                // this should throw an exception because the user id does not have a prefix of 005
                extension.buildLogEventJson();
            }
            catch(Exception ex)
            {
                isWrongUserIdPrefixException = true;
            }
            finally
            {
                System.assert(isWrongUserIdPrefixException);
                extension.userId = u.Id;
            }            
            
            // test that if the WhatId prefix does not have a prefix of 001,006,500, or 001 we get an exception
            boolean isWrongWhatIdPrefixException = false;
            try 
            {
                extension.whatId = '600aeor';
                // this should throw an exception because the What Id has the wrong prefix
                extension.buildLogEventJson();
            }
            catch(Exception ex)
            {
                isWrongWhatIdPrefixException = true;
            }
            finally
            {
                System.assert(isWrongWhatIdPrefixException);
                extension.whatId = aTask.WhatId;
            } 
            
            // test that if the WhoId prefix does not have a prefix of 003 we get an exception
            boolean isWrongWhoIdPrefixException = false;
            try 
            {
                extension.whoId = '600aeor';
                // this should throw an exception because the WhoId has the wrong prefix
                extension.buildLogEventJson();
            }
            catch(Exception ex)
            {
                isWrongWhoIdPrefixException = true;
            }
            finally
            {
                System.assert(isWrongWhoIdPrefixException);
                extension.whoId = aTask.WhoId;
            }
        }
    }
    
    @isTest static void parameterGeneratorTestForTaskOpportunity()
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
            
            Contact contact = new Contact( FirstName = 'John', LastName='Doe', Email = 'jdoe@dentsplysirona.com', AccountId = account.Id, InsertEmailMarketingConsentCollected__c = 'No' );
            insert contact;

            Opportunity opportunity = new Opportunity( Name = 'Test Opportunity', AccountId = account.Id, StageName = 'Test', CloseDate=Date.newInstance(1960, 2, 17) );
            insert opportunity;
            
            Date nowDate = Date.today();
            
            Task aTask = new Task( WhatID = opportunity.id,
                                   WhoID = contact.Id,
                                   Subject='Test',
                                   Status='New',
                                   Priority='Normal',
                                   ActivityDate = nowDate,
                                   CallDisposition = 'Scheduled another call',
                                   TaskSubtype = 'Task'
                                 );
            insert aTask;
            
            MyTaskController controller = new MyTaskController( aTask );
            TaskExtension extension = new TaskExtension( controller );
            
            extension.getRequiredInfo();
            
            // Test the parameter 1 generator
            String expectedParam1 = u.Id + '|' + 'Opportunity' + '|' + opportunity.Id + '|' + opportunity.Name;
            String generatedParam1 = extension.generatePipedParam1();
            
            System.assertEquals( expectedParam1, generatedParam1 );
            
            // Test the parameter 2 generator
            String expectedParam2 = aTask.Id + '|' + account.Id + '|' + account.Name + '|' + String.valueOf(aTask.ActivityDate) + '|' + aTask.CallDisposition + '|' + aTask.Status;
            String generatedParam2 = extension.generatePipedParam2();

            System.assertEquals( expectedParam2, generatedParam2 );
            
            System.debug('aTask WhoID = ' + aTask.WhoId);
            String taskUrl = URL.getSalesforceBaseUrl().toExternalForm() + '/' + aTask.Id;
            // Test the parameter 3 generator
            String expectedParam3 = aTask.Subject + '|' + aTask.TaskSubtype + '|' + 'Opportunity' + '|' + aTask.WhoId + '|' + taskUrl;
            String generatedParam3 = extension.generatePipedParam3();
            
            System.assertEquals(expectedParam3, generatedParam3);
            
            System.debug('expectedParam3 = ' + expectedParam3);
            System.debug('generatedParam3 = ' + generatedParam3);
        }
    }
    
    @isTest static void parameterGeneratorTestForTaskCase()
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
            
            Contact contact = new Contact( FirstName = 'John', LastName='Doe', Email = 'jdoe@dentsplysirona.com', AccountId = account.Id, InsertEmailMarketingConsentCollected__c = 'No' );
            insert contact;

            Case aCase = new Case( AccountId = account.Id, ContactId = contact.Id );
            insert aCase;
            
            Case selectedCase = [select id, CaseNumber FROM Case where id = : aCase.id];
            
            Date nowDate = Date.today();
            
            Task aTask = new Task( WhatID = aCase.id,
                                   WhoID = contact.Id,
                                   Subject='Test',
                                   Status='New',
                                   Priority='Normal',
                                   ActivityDate = nowDate,
                                   CallDisposition = 'Scheduled another call',
                                   TaskSubtype = 'Task'
                                 );
            insert aTask;
            
            MyTaskController controller = new MyTaskController( aTask );
            TaskExtension extension = new TaskExtension( controller );
            
            extension.getRequiredInfo();
                
            // Test the parameter 1 generator
            String expectedParam1 = u.Id + '|' + 'Case' + '|' + aCase.Id + '|' + selectedCase.CaseNumber;
            String generatedParam1 = extension.generatePipedParam1();
            
            System.debug('expectedParam1 = ' + expectedParam1);
            System.debug('generatedParam1 = ' + generatedParam1);
            System.assertEquals( expectedParam1, generatedParam1 );
            
            // Test the parameter 2 generator
            String expectedParam2 = aTask.Id + '|' + account.Id + '|' + account.Name + '|' + String.valueOf(aTask.ActivityDate) + '|' + aTask.CallDisposition + '|' + aTask.Status;
            String generatedParam2 = extension.generatePipedParam2();

            System.assertEquals( expectedParam2, generatedParam2 );
            
            System.debug('aTask WhoID = ' + aTask.WhoId);
            String taskUrl = URL.getSalesforceBaseUrl().toExternalForm() + '/' + aTask.Id;
            // Test the parameter 3 generator
            String expectedParam3 = aTask.Subject + '|' + aTask.TaskSubtype + '|' + 'Case' + '|' + aTask.WhoId + '|' + taskUrl;
            String generatedParam3 = extension.generatePipedParam3();
            
            System.assertEquals(expectedParam3, generatedParam3);
            
            System.debug('expectedParam3 = ' + expectedParam3);
            System.debug('generatedParam3 = ' + generatedParam3);
    
        }
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
            
            Contact contact = new Contact( FirstName = 'John', LastName='Doe', Email = 'jdoe@dentsplysirona.com', AccountId = account.Id, InsertEmailMarketingConsentCollected__c = 'No' );
            insert contact;

            Opportunity opportunity = new Opportunity( Name = 'Test Opportunity', AccountId = account.Id, StageName = 'Test', CloseDate=Date.newInstance(1960, 2, 17) );
            insert opportunity;
            
            Date nowDate = Date.today();
            
            Task aTask = new Task( WhatID = opportunity.id,
                                   Subject='Test',
                                   Status='New',
                                   Priority='Normal',
                                   ActivityDate = nowDate,
                                   CallDisposition = 'Scheduled another call',
                                   WhoId = contact.Id
                                 );
            insert aTask;
            
            MyTaskController controller = new MyTaskController( aTask );
            TaskExtension extension = new TaskExtension( controller );
            
            extension.getRequiredInfo();
            
            System.assert(extension.buildLogEventJson() != null);
            
            boolean emptyControllerThrowsException = false;
            try 
            {
                // we should get an exception because of the code in the default constructor
                MyTaskController emptyController  = new MyTaskController();
            }
            catch (Exception ex)
            {
                emptyControllerThrowsException = true;
            }
            finally
            {
                System.assert( emptyControllerThrowsException );
            }
        }   
    } 
}