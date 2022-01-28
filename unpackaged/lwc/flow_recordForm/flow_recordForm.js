import { LightningElement, api, track, wire } from 'lwc';
import { FlowAttributeChangeEvent } from 'lightning/flowSupport';
import CONTACT_INSERT_EMAIL_MARKETING_CONSENT_FIELD from '@salesforce/schema/Contact.InsertEmailMarketingConsentCollected__c';

export default class Flow_recordForm extends LightningElement {
    @api recordId;
    @api sObjectName;
    @api title;
    @api icon;
    @api variant;
    @api fields;
    @api requiredFields;
    @api columns;
    @api mode;
    @track _fields = [];
    
    _contactEmail;
    _requiredFields = [];
    _requiredFieldsMissing = [];

    isLoading = true;

    connectedCallback() {
        if (this.fields) this._fields = JSON.parse(this.fields);
        if (this.requiredFields) this._requiredFields = JSON.parse(this.requiredFields);
    }

    handleLoad(event) {
        this.isLoading = false;
        const fields = event.detail.records[this.recordId].fields;
        if (this.sObjectName === 'Contact') {
            this._contactEmail = fields.Email.value;
        }
        this.validateRequiredFields(fields);
    }

    handleSubmit(event) {
        this.isLoading = true;
        event.preventDefault();
        const fields = event.detail.fields;
        console.log(`submit::${fields.Email}`);
        // Populate additional Contact fields
        if (this.sObjectName === 'Contact' && fields.Email != this._contactEmail) {
            fields[CONTACT_INSERT_EMAIL_MARKETING_CONSENT_FIELD.fieldApiName] = 'No';
            this._contactEmail = fields.Email;
        }

        this.template.querySelector('lightning-record-form').submit(fields);
    }

    handleSuccess(event) {
        this.isLoading = false;
    }

    validateRequiredFields(fields) {
        this._requiredFieldsMissing = [];
        for (const fieldName of this._requiredFields) {
            if (!fields[fieldName].value) this._requiredFieldsMissing.push(fieldName);
        }
    }

    @api
    validate() {
        if (this._requiredFieldsMissing.length > 0) {
            return {
                isValid: false,
                errorMessage: `The following fields are required: ${this._requiredFields}`
            };
        } else {
            return {
                isValid: true
            };
        }
    }
}