import { LightningElement, api, wire, track } from 'lwc';
import loadRelatedContacts from '@salesforce/apex/flowContactController.getRelatedContacts';
import { refreshApex } from '@salesforce/apex';
import { updateRecord } from 'lightning/uiRecordApi';

import ID_FIELD from '@salesforce/schema/Contact.Id';
import ACCOUNTID_FIELD from '@salesforce/schema/Contact.AccountId';
import CONTACT_INSERT_EMAIL_MARKETING_CONSENT_FIELD from '@salesforce/schema/Contact.InsertEmailMarketingConsentCollected__c';

export default class Flow_ContactUpdate extends LightningElement {
    @api recordId;
    @track contacts;
    @track newContact = false;
    @api sObjectName = 'LoyaltyProgramParticipant__c';
    @api accountField = 'Account__c';    
    @api fields;
    @api recordTypeId = '01220000000CyRUAA0';
    @api layoutFields = '["FirstName", "LastName", "Contact_Type__c", "Sub_Contact_Type__c", "Title", "Email", "MobilePhone"]';
    @api readOnly = false;
    @api preventDefault = false;
    @api output;
    @track _fields = [];

    wiredContactsResult;

    connectedCallback() {
        this._fields = JSON.parse(this.layoutFields);
        console.log(this._fields);
        var i;
        var fieldString;
        for (i=0; i<this._fields.length; i++){
            if(i==0){
                fieldString = this._fields[i];    
            }else{
            fieldString = fieldString + ', ' + this._fields[i];
            }
        }
        this.fields = fieldString;
    }

    @wire(loadRelatedContacts, { recordId: '$recordId', sObjectName : '$sObjectName', accountField: '$accountField', contactFields: '$fields' })
    wiredContacts(result){
        this.wiredContactsResult = result;

        if(result.data){

            result.data = JSON.parse(JSON.stringify(result.data));

            result.data.forEach((contact) =>{
                contact.header = contact.FirstName + ' ' + contact.LastName;
            });
            this.contacts = result.data;
            console.log(this.contacts);

        }else{
            console.log("Error: " + result.error);
        } 

    };

    handleNewContact(event){
        var result = event.target.value;
        this.newContact = true;
    };

    handleCreatedContact(event){
        this.newContact = false;
        return refreshApex(this.wiredContactsResult);
        
    };

    handleSubmitNew(event) {
        event.preventDefault();
        const fields = event.detail.fields;
        this.newContact = false;
        var contactListSize = this.contacts.length;

        if(contactListSize >0){
        fields[ACCOUNTID_FIELD.fieldApiName] = this.contacts[0].AccountId;
        fields[CONTACT_INSERT_EMAIL_MARKETING_CONSENT_FIELD.fieldApiName] = 'No';
        
        console.log('Target Id: ' + event.target.id);

        var forms = this.template.querySelectorAll('lightning-record-form');
        
        forms.forEach(function(element){
            if(element.name=="contactmodal"){
                element.submit(fields);
            }
        })

        }

    };

    handleSubmitUpdate(event) {
        event.preventDefault();
        const fields = event.detail.fields;
        fields[CONTACT_INSERT_EMAIL_MARKETING_CONSENT_FIELD.fieldApiName] = 'No';
        
        console.log('Target value: ' + event.target.value);

        var forms = this.template.querySelectorAll('lightning-record-form');
        
        forms.forEach(function(element){
            if(element.name==event.detail.id){
                console.log(event.detail.id);
                element.submit(fields);
            }
        })

    };    
    

    closeModal() {
        this.newContact = false;
    };

}