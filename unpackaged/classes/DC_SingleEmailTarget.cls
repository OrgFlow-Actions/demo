//
//This class represents a target for a single email message.
//
//Author: Gennadiy Pervukhin (28-10-2014)
public virtual class DC_SingleEmailTarget
{
	//
	//Constructors
	//
	public DC_SingleEmailTarget(String targetObjectId, String[] emailAddresses)
	{
		this.targetObjectId = targetObjectId;
		this.emailAddresses = emailAddresses;
	}
	//
	
	//
	//Properties
	//
	public String targetObjectId {get; set;}
	public String[] emailAddresses {get; set;}
	//
	
	//
	//Public methods
	//
	public Boolean isEmpty()
	{
		return (String.isBlank(this.targetObjectId) &&
			(this.emailAddresses == null || this.emailAddresses.size() == 0));
	}
	//
}