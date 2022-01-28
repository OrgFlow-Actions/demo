public class CaseExtension extends WebApi {
    
    private final Case aCase;
    private String caseId;
    private String caseNumber;
    private String contactId;
    private String accountId;

    private String accountName;
    private String contactFirstName;
    private String contactLastName;
    private String contactEmail;
    
    public CaseExtension( ApexPages.StandardController stdController ) 
    {
        super();
        this.aCase = (Case)stdController.getRecord();
        this.userId = UserInfo.getUserId();

        reset();        
    }
    
    public CaseExtension( Case aCase ) 
    {
        super();
        this.aCase = aCase;
        this.userId = UserInfo.getUserId();
        
        reset();
    }
    
    private void reset()
    {
        this.caseId = '';
        this.caseNumber = '';
        this.contactId = '';
        this.accountId = '';
        
        this.accountName = '';
        this.contactFirstName = '';
        this.contactLastName = '';
        this.contactEmail = '';
    }
    
    public override void getRequiredInfo() 
    {
        caseId = aCase.Id;
        User[] user = [Select ComputerID__c From User Where Id = :UserInfo.getUserId()];
        
        if ( user.size() > 0 )
        {
            if ( user[0].ComputerID__c != null ) 
            {
                computerLogin = user[0].ComputerID__c;
            }
            else 
            {
                System.debug('Validation Error: getRequiredInfo() was unable to get the computerLogin');
                throw new RequiredInfoException();
            }
        }
        else
        {
            System.debug('Validation Error: getRequiredInfo() was unable to get the computerLogin');
            throw new RequiredInfoException();
        }
        
        Case[] aCase = [Select CaseNumber, ContactId, AccountId  From Case Where Id = :caseId];
        
        if ( aCase.size() > 0 ) 
        {
            caseNumber = aCase[0].CaseNumber;
            accountId = aCase[0].AccountId;
            contactId = aCase[0].ContactId;
            
            Account[] account = [Select Name From Account Where Id = :accountId];
            
            if ( account.size() > 0 ) 
            {
                accountName = account[0].Name;
            }
            
            Contact[] contact = [Select FirstName, LastName, Email From Contact Where Id = :contactId];
            
            if ( contact.size() > 0 ) 
            {
                contactFirstName = contact[0].FirstName;
                contactLastName = contact[0].LastName;
                contactEmail = contact[0].Email;
            }
        }
    }
    
    public override String buildLogEventJson()
    {
        JSONGenerator gen = JSON.createGenerator( true );
        
        Datetime currentTime = Datetime.now();
        
        gen.writeStartObject();
        gen.writeStringField( 'eventTimeStamp', '/Date(' + currentTime.getTime() + ')/' );
        gen.writeStringField( 'eventType', 'SalesforceCase' );
        gen.writeStringField( 'user', computerLogin );
        gen.writeStringField( 'machine', 'DUMMYTEXT' );
        
        if ( userId != null && !userId.equals('') )
        {
            gen.writeStringField( 'parm1', userId );
        }
        else 
        {
            System.debug( 'Validation Error: The userId is missing, we will throw an exception' );
            throw new RequiredInfoException();
        }
        
        if ( caseId != null && !caseId.equals('') )
        {
            gen.writeStringField( 'parm2', caseId );
        }
        else 
        {
            System.debug('Validation Error: The caseId is missing, we will throw an exception');
            throw new RequiredInfoException();
        }
        
        gen.writeStringField( 'parm3', generatePipedParam() );
        gen.writeEndObject();
        
        return gen.getAsString();
    }
    
    @TestVisible private String generatePipedParam() 
    {
        String pipedParam = '';
        
        //contactLastName, contactFirstName | contactEmail | accountName |accountId|contactId|caseNumber
        
        if ( contactLastName != null && !contactLastName.equals('') )   
        {
            pipedParam = contactLastName;
        }
        
        if ( contactFirstName != null && !contactFirstName.equals('') ) 
        {
            pipedParam = pipedParam + ',' + contactFirstName + '|';
        }
        else 
        {
            pipedParam = pipedParam + '|';
        }
        
        if ( contactEmail != null && !contactEmail.equals('') ) 
        {
            pipedParam = pipedParam + contactEmail + '|';
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
        
        if ( accountId != null && !accountId.equals('') )
        {
            pipedParam = pipedParam + accountId + '|';
        }
        else
        {
            pipedParam = pipedParam + '|';
        }
        
        if ( contactId != null && !contactId.equals('') )
        {
            pipedParam = pipedParam + contactId + '|';
        }
        else
        {
            pipedParam = pipedParam + '|';
        }
        
        if ( caseNumber != null && !caseNumber.equals('') )
        {
            pipedParam = pipedParam + caseNumber;
        }
        
        return pipedParam;
    }
    
}