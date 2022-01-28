public class TaskExtension extends WebApi
{
    private final Task task;
    @TestVisible private String accountId;
    @TestVisible private Date activityDate;
    @TestVisible private String callDisposition;
    @TestVisible private String taskId;
    @TestVisible private String userId;
    @TestVisible private String status;
    @TestVisible private String taskSubject;
    @TestVisible private String taskSubtype;
    @TestVisible private String whatId;
    @TestVisible private String whoId;
    @TestVisible private String accountName;
    
    public TaskExtension( MyTaskController stdController )
    {
        super();
        this.task = (Task)stdController.getTask();
        this.userId = UserInfo.getUserId();
        this.taskId = this.task.Id;
        this.taskSubject = this.task.Subject;
        this.accountId = this.task.AccountId;
        this.accountName = '';
        this.whatId = this.task.WhatId;
        this.whoId = this.task.WhoId;
    }
    
    public TaskExtension( Task task ) 
    {
        super();
        System.debug('INSIDE CONSTRUCTOR!!!');
        this.task = task;
        this.userId = UserInfo.getUserId();
        this.computerLogin = '';
        this.taskId = this.task.Id;
        this.taskSubject = this.task.Subject;
        System.debug('ACCOUNT ID IN CONSTRUCTOR = ' + this.task.AccountId);
        this.accountId = this.task.AccountId;
        this.activityDate = this.task.ActivityDate;
        this.callDisposition = this.task.CallDisposition;
        this.status = this.task.Status;
        this.taskSubType = this.task.TaskSubtype;
        this.whatId = this.task.WhatId;
        this.whoId = this.task.WhoId;
    }
        
    public override void getRequiredInfo()
    {
        System.debug('Get Required Info Started');
        Id taskId = task.Id;
        userId = UserInfo.getUserId();
        User[] user = [Select ComputerID__c From User Where Id = :userId];
        
        System.debug('userId = ' + userId );
        
        if ( user.size() > 0 )
        {
            if ( user[0].ComputerID__c != null ) 
            {
                computerLogin = user[0].ComputerID__c;
            }
            else 
            {
                System.debug('getRequiredInfo() was unable to get the computerLogin');
                throw new RequiredInfoException();
            }
        }
        else
        {
            System.debug('getRequiredInfo() was unable to get the computerLogin');
            throw new RequiredInfoException();
        }
        
        Task[] task = [SELECT Id, Subject, Type, TaskSubtype, Status, WhatId, 
                       WhoId, AccountId, ActivityDate, CallDisposition FROM Task WHERE id = :taskId];
        
        if ( task.size() > 0 )
        {   
            System.debug('Task is ' + task);
            
            Account[] account = [SELECT Name FROM Account WHERE id = :task[0].AccountId];
        
            if ( account.size() > 0 )
            {
                this.accountName = account[0].Name;
            }
            else 
            {
                System.debug('there was no account name :(');
            }
        
            System.debug('account id  = ' + this.accountId );
            System.debug('account name = ' + accountName );
            
         	accountId = task[0].AccountId;
         	activityDate = task[0].ActivityDate;
         	callDisposition = task[0].CallDisposition;
         	status = task[0].Status;
            taskSubject = task[0].Subject;
            taskSubtype = task[0].TaskSubtype;
            whatId = task[0].WhatId;
            whoId = task[0].WhoId;
            System.debug('WHOID now IS = ' + whoId);
        }
        
        System.debug('Task id = ' + taskId );
        System.debug('Task subject = ' + taskSubject );
    }
    
    // Creates the JSON object for the LogEvent call
    public override String buildLogEventJson()
    {
        System.debug('Starting to buildLogEventJson');
        JSONGenerator gen = JSON.createGenerator( true );
        gen.writeStartObject();
        Datetime currentTime = Datetime.now();
        gen.writeStringField( 'eventTimeStamp', '/Date(' + currentTime.getTime() + ')/' );
        gen.writeStringField( 'eventType', 'SalesforceTask' );
        gen.writeStringField( 'user', computerLogin );
        gen.writeStringField( 'machine', 'DUMMYTEXT' );
        
        // validate to make sure we should fire off the event
        // The AccountID must be populated. 
        if ( accountId == null || accountId.equals('') )
        {
            System.debug('Validation Failed: The account id was not set so we will not fire off the logEvent for this task');
            throw new RequiredInfoException();
        }
        else 
        {
            System.debug('AccountID = ' + accountId);
        }
        
        String ownerIdSubString = userId.substring(0,3);
        System.debug('userId substring = ' + ownerIdSubString);
        // The OwnerID must be populated and it must start with '005'. 
        // This is the prefix for User IDs.
        if ( !ownerIdSubString.equals('005') ) 
        {
            System.debug('Validation Failed: The OwnerId does not begin with 005');
            throw new RequiredInfoException();
        }
        else 
        {
            System.debug('OwnerId = ' + userId);
        }
        
        boolean isWhoPopulated = (whoId != null && !whoId.equals(''));
        boolean isWhatPopulated = (whatId != null && !whatId.equals(''));
        boolean isAtLeastOnePopulated = isWhoPopulated || isWhatPopulated; 
        
        // At least one of the WhatID or WhoID fields must be populated.
        if ( isAtLeastOnePopulated )
        {
            System.debug('WhoId = ' + whoId);
            if ( isWhoPopulated )
            {
                String whoIdPrefix = whoId.substring(0,3);
                System.debug('WhoIdPrefix = ' + whoIdPrefix);
                
                // If the WhoID is populated, it must start with '003'. 
                // This is the prefix for Contact IDs.
                if (!whoIdPrefix.equals('003'))
                {
                    System.debug('Validation Failed: The whoId does not start with 003');
                    throw new RequiredInfoException();
                }
                else 
                {
                    System.debug('WhoID is populated with ' + whoIdPrefix);
                }
            }
            else 
            {
               System.debug('WhoId is not populated'); 
            }
            
            if ( isWhatPopulated )
            {
                String whatIdPrefix = whatId.substring(0,3);
                
                // If the WhatID is populated, it must start with
                // '001', '006', '500'. '001' is the prefix for Account IDs, 
                // '006' is the prefix for Opportunity IDs, and '500' is the prefix for Case IDs.
                if ( whatIdPrefix.equals('001') || whatIdPrefix.equals('006') || 
                    whatIdPrefix.equals('500') || whatIdPrefix.equals('001') )
                {
                    System.debug('WhatID is populated with a prefix of ' + whatIdPrefix);
                }
                else 
                {  
                    System.debug('Validation Failed: The WhatID prefix does not equal 001, 006, 500, 001. WhatID prefix = ' + whatIdPrefix);
                    throw new RequiredInfoException();
                }
            }
        }
        else 
        {
             System.debug('Validation Failed: The WhoId and WhatId is not set and at least one needs to be');
             throw new RequiredInfoException();
        }
        
        String param1 = generatePipedParam1();
        System.debug('parameter 1 is generated as ' + param1);
        gen.writeStringField( 'parm1', param1 );
        
        String param2 = generatePipedParam2();
        System.debug('parameter 2 is generated as ' + param2);
        gen.writeStringField( 'parm2', param2 );
        
        String param3 = generatePipedParam3();
        System.debug('parameter 3 is generated as ' + param3);
        gen.writeStringField( 'parm3', param3 );
        
        gen.writeEndObject();
        
        System.debug('gen.getAsString(); = ' + gen.getAsString());
        return gen.getAsString();
    }
    
    @TestVisible private String generatePipedParam1() 
    {
        String pipedParam = '';
        
        if ( userId != null && !userId.equals(''))
        {
             pipedParam = userId;
        }
        else 
        {
            System.debug('The user id is missing, we will throw an exception');
            throw new RequiredInfoException();
        }
       
        if ( whatId != null )
        {
			String whatIdPrefix = whatId.substring(0,3);
           
            // If the prefix is '006', populate the following:
			// fldSFTRelatedTo with "Opportunity" 
			// fldSFOpportunityID with WhatID
			// fldSFOpportunityName with lookup of the name using  WhatID
            if ( whatIdPrefix.equals('006') )
            {
                pipedParam = pipedParam + '|' + 'Opportunity' + '|' + whatId;
                
                Opportunity[] opportunities = [Select Name From Opportunity Where AccountId = :accountId];
                
              	string opportunityName;
                if ( opportunities.size() > 0 )
                {
                    opportunityName = opportunities[0].Name;
                }
                
                if ( opportunityName != null && !opportunityName.equals('') )
                {
                     pipedParam = pipedParam + '|' + opportunityName;
                }
            }

            // If the prefix is '500', populate the following:
			// fldSFTRelatedTo with "Case"
			// fldSFCaseID with WhatID
			// fldSFCaseNumber with lookup of the name using  WhatID
            if ( whatIdPrefix.equals('500') ) 
        	{
        		pipedParam = pipedParam + '|' + 'Case' + '|' + whatId;
                
                Case[] cases = [Select CaseNumber From Case Where AccountId = :accountId ];
                
              	string caseNumber;
                if ( cases.size() > 0 )
                {
                    caseNumber = cases[0].CaseNumber;
                }
                
                if ( caseNumber != null && !caseNumber.equals('') )
                {
                     pipedParam = pipedParam + '|' + caseNumber;
                }
        	}
        }
        
     	return pipedParam;   
    }
    
    @TestVisible private String generatePipedParam2() 
    {
        String pipedParam = '';
        
        //Task ID | Account Id | Account Name | Due Date (ActivityDate) | Call Result | Status
        
        if ( taskId != null && !taskId.equals('') )  
        {
            pipedParam = taskId + '|';
        }
        else 
        {
            pipedParam = pipedParam + '|';
        }
        
        if ( accountId != null && !accountId.equals('') )
        {
            pipedParam = pipedParam + accountId + '|';
        }
        else
        {
            pipedParam = pipedParam + '|';
        }
        
        if ( accountName != null && !accountName.equals('') )
       	{
            pipedParam = pipedParam + accountName + '|';
        }
        else
        {
            pipedParam = pipedParam + '|';
        }
        
        if ( activityDate != null )
        {
            pipedParam = pipedParam + String.valueOf(activityDate) + '|';
        }
        else
        {
            pipedParam = pipedParam + '|';
        }
        
        if ( callDisposition != null && !callDisposition.equals('') )
        {
            pipedParam = pipedParam + callDisposition + '|';
        }
        else
        {
            pipedParam = pipedParam + '|';
        }
        
        if ( status != null && !status.equals('') )
        {
            pipedParam = pipedParam + status;
        }
        
        return pipedParam;
    }
    
    @TestVisible private String generatePipedParam3() 
    {
        System.debug('Generate Piped Param 3 called');
        String pipedParam = '';
        
        //Subject | Sub Type | What ID | Who ID | Task Link
        
        if ( taskSubject != null && !taskSubject.equals('') )  
        {
            pipedParam = taskSubject + '|';
        }
        else 
        {
            pipedParam = pipedParam + '|';
        }
        
        if ( taskSubtype != null && !taskSubtype.equals('') )
        {
            pipedParam = pipedParam + taskSubtype + '|';
        }
        else
        {
            pipedParam = pipedParam + '|';
        }
        
        System.debug('whatId = ' + whatId);
        if ( whatId != null && !whatId.equals('') )
        {
            String whatIdPrefix = whatId.substring(0,3);
            
            if ( whatIdPrefix.equals('001') ) 
            {
                System.debug('The WhatId is Account');
            	pipedParam = pipedParam + 'Account' + '|';    
            }
            
            if ( whatIdPrefix.equals('006') )
            {
                System.debug('The WhatId is Opportunity');
                pipedParam = pipedParam + 'Opportunity' + '|';
            }
            
            if ( whatIdPrefix.equals('500') ) 
            {
                System.debug('The WhatId is Case');
                pipedParam = pipedParam + 'Case' + '|';
            }
        } 
        else
        {
            pipedParam = pipedParam + '|';
        }
        
        System.debug('WhoID = ' + whoId);
        if ( whoId != null && !whoId.equals('') )
        {
            pipedParam = pipedParam + whoId + '|';
        } 
        else
        {
            System.debug('WhoId is NOT set');
            pipedParam = pipedParam + '|';
        }
        
        String taskUrl = URL.getSalesforceBaseUrl().toExternalForm() + '/' + taskId;
        
        System.debug('The taskUrl = ' + taskUrl);
        
        pipedParam = pipedParam + taskUrl;
      
        return pipedParam;
    }
}