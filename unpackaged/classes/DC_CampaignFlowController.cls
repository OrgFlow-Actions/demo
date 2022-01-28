//Author: Sergey Legostaev
//Date: 04/20/2017
public with sharing class DC_CampaignFlowController {

    public final String selectedCampaignId { get; set; }
    public final String campaignMemberId {get; private set;}
    public String selectedContactId {get; set;}
    
    public CampaignMember cm {get; private set;} 
    public Account acc {get; private set;}
    
    public List<DC_ActivityDTO> activities {get; private set;}
    public List<Campaign> campaigns {get; private set;}
    public List<Order> orders {get; private set;}
    public boolean areThereActiveCampigns {get; private set;}
    
    public List<Contact> contacts {get; private set;}
    public String fullAddress {get; private set;}
    
    private static Set<String> recordTypes = new Set<String> {'Mailing', 'DNA Campaign'}; 
	private static final String DEFAULT_RESPONSE_SETTING_NAME = 'Default';
    
    public String responseSettingsName {get; private set;}
    
    public DC_CampaignFlowController() {
        campaignMemberId = ApexPages.currentPage().getParameters().get('varInputMemberID');
        selectedCampaignId = ApexPages.currentPage().getParameters().get('selectedCampaignId');
        selectedContactId = ApexPages.currentPage().getParameters().get('selectedContactId');
    }
    
    public void init() {
        
        if (String.isNotBlank(campaignMemberId)) {
            cm = DC_CampaignMembersDAO.getCampaignMemberById(campaignMemberId);
            if (cm == null || cm.ContactId == null) {
                return;
            }
            
            acc = DC_AccountDAO.getAccountById(cm.Contact.AccountId);
            if (acc != null) {
                Address accAddress = acc.ShippingAddress;
                if (accAddress != null) {
                	fullAddress = String.format('{0} {1} {2} {3} {4}', 
                                            new String[] { accAddress.getStreet(), 
                                                accAddress.getCity(),
                                                accAddress.getState(),
                                                accAddress.getPostalCode(),
                                                accAddress.getCountry()
                                            });
                    
                }
            }
            
            activities = DC_ActivityService.getActivitiesByAccountId(cm.Contact.AccountId);
			initCampaignsForMemberByContactId(cm.ContactId);
            initOrdersByAccountId(cm.Account__c);
            
			if (String.isBlank(selectedContactId)) {
                selectedContactId = cm.ContactId;
            }
            contacts = acc.Contacts;
            responseSettingsName = getResponseSettingName(cm.Campaign.RecordType.Name);
        }
    }
    
    public PageReference onSelectCampaignAction() {
        return createPage(campaignMemberId, selectedCampaignId, selectedContactId);
    }
    
    private String getResponseSettingName(String recordType) {
        return recordTypes.contains(recordType) ? recordType : DEFAULT_RESPONSE_SETTING_NAME;
    }
    
    /*private void initContacts() {
        contacts = new List<SelectOption>();
        for (Contact cont : acc.Contacts) {
            contacts.add(new SelectOption(cont.Id, createContactLabel(cont)));
        }
    }
    
    private String createContactLabel(Contact cont) {
        return cont.Name + (cont.Title == null ? '' : ' Title: ' + cont.Title) 
            + (cont.Contact_Type__c == null ? '' : ' Contact Type: ' + cont.Contact_Type__c)
            + (cont.Sub_Contact_Type__c == null ? '' : ' Contact Sub-Type: ' + cont.Sub_Contact_Type__c);
    }*/
    
    private void initCampaignsForMemberByContactId(String contactId) {
        campaigns = new List<Campaign>();
        for (CampaignMember member : DC_CampaignMembersDAO.getActiveCampaignMembersByContactId(contactId)) {
        	campaigns.add(new Campaign(Id = member.CampaignId, Name = member.Campaign.Name, 
                                       Status = member.Status));
        }
        areThereActiveCampigns = campaigns.size() > 0;
    }
    
    private void initOrdersByAccountId(String accountId) {
        orders = DC_OrderDAO.getOrdersByAccountId(accountId);
    }
    
    public PageReference getCurrentPage() {
        return createPage(campaignMemberId, null, null);
    }
    
    private PageReference createPage(String cmId, String campId, String contId) {
		PageReference customPage = Page.DNA_Campaign_Flow;
		customPage.setRedirect(true);
        customPage.getParameters().put('varInputMemberID', cmId);
        customPage.getParameters().put('selectedCampaignId', campId);
        customPage.getParameters().put('selectedContactId', contId);
        return customPage;
    }
    
}