//
//This class builds 'SingleEmailMessage' object
//
//Author: Gennadiy Pervukhin (28-10-2014)
public class DC_SingleEmailMessageBuilder
{
	//
	//Constructors
	//
	public DC_SingleEmailMessageBuilder()
	{
		this.initialize();
	}
	
	public DC_SingleEmailMessageBuilder(String targetObjectId)
	{
		this.initialize();
		this.changeTarget(new DC_SingleEmailTarget(targetObjectId, null));
	}
	
	public DC_SingleEmailMessageBuilder(String[] toAddresses)
	{
		this.initialize();
		this.changeTarget(new DC_SingleEmailTarget(null, toAddresses));
	}
	
	public DC_SingleEmailMessageBuilder(DC_SingleEmailTarget target)
	{
		this.initialize();
		this.changeTarget(target);
	}
	//
	
	//
	//Properties
	//
	public String orgWideEmailAddressId {get; set;}
	
	public DC_SingleEmailTarget emailTarget {get; private set;}
	public String replyToAddress {get; set;}
	
	public String subject {get;	set;}
	
	public String htmlBody {get; set;}
	public String plainTextBody {get; set;}
	
	public List<Messaging.EmailFileAttachment> fileAttachments {get; private set;}
	
	public Boolean saveAsActivity {get; set;}
	//
	
	//
	//Private methods
	//
	private void initialize()
	{
		this.fileAttachments = new List<Messaging.EmailFileAttachment>();
		this.saveAsActivity = false;
	}
	//
	
	//
	//Public methods
	//
	public void addFileAttachment(String fileName, String contentType,
		String fileContent, Boolean isInline)
	{
		Messaging.EmailFileAttachment fileAttachment = new Messaging.EmailFileAttachment();
        fileAttachment.setFileName(fileName);
        fileAttachment.setContentType(contentType);
        fileAttachment.setBody(Blob.valueOf(fileContent));
        fileAttachment.setInline(isInline);
        
        this.fileAttachments.add(fileAttachment);
	}
	
	public void changeTarget(DC_SingleEmailTarget newEmailTarget)
	{
		this.emailTarget = (newEmailTarget != null
			? newEmailTarget : new DC_SingleEmailTarget(null, null));
	}
	
	public Messaging.SingleEmailMessage buildMessage()
	{
		//a target must not be empty
		if (this.emailTarget == null || this.emailTarget.isEmpty())
		{
			return null;
		}
		
		Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
		
		//STEP #1: set receivers
		//1.1) set receiver by SF Id
     	if (String.isNotBlank(this.emailTarget.targetObjectId))
     	{
     		try
     		{
     			email.setTargetObjectId(this.emailTarget.targetObjectId);
     		}
     		catch (Exception e)
     		{
     			System.debug(LoggingLevel.WARN, 'DC_SingleEmailMessageBuilder.buildMessage: '
     				+ 'message could not be generated because of incorrect targetObjectId ('
     				+ e.getMessage() + ')');
     			return null;
     		}
     	}
     	
     	//1.2) set receivers by direct email addresses
     	email.setToAddresses(this.emailTarget.emailAddresses);
     	
     	//STEP #2: set sender address
     	email.setOrgWideEmailAddressId(this.orgWideEmailAddressId);
     	
     	//STEP #3: set Reply-To address
     	email.setReplyTo(this.replyToAddress);
     	
     	//STEP #4: set subject, body and settings
 	  	email.setSubject(this.subject);
 	  	email.setHtmlBody(this.htmlBody);
 	  	email.setPlainTextBody(this.plainTextBody);
 	  	
 	  	email.saveAsActivity = this.saveAsActivity;
 	  	//
 	  	
 	  	//STEP #5: set file attachments
        email.setFileAttachments(this.fileAttachments);
        
        //return result
        return email;
	}
	//
}