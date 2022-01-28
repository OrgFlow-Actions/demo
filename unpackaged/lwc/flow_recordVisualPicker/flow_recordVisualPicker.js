import { LightningElement, api, track, wire } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import { FlowAttributeChangeEvent } from 'lightning/flowSupport';
import loadRelatedContacts from '@salesforce/apex/flowRecordVisualPickerController.getRelatedContacts';
import loadRecordCollection from '@salesforce/apex/flowRecordVisualPickerController.getRecords';
import FORM_FACTOR from '@salesforce/client/formFactor';

import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import CONTACT_TITLE_FIELD from '@salesforce/schema/Contact.Title';
import CONTACT_FIRSTNAME_FIELD from '@salesforce/schema/Contact.FirstName';
import CONTACT_LASTNAME_FIELD from '@salesforce/schema/Contact.LastName';
import CONTACT_PREFERRED_LANGUAGE_FIELD from '@salesforce/schema/Contact.Preferred_Language__c';
import CONTACT_EMAIL_FIELD from '@salesforce/schema/Contact.Email';
import CONTACT_MOBILE_FIELD from '@salesforce/schema/Contact.MobilePhone';
import CONTACT_PRIMARY_M_CONTACT_FIELD from '@salesforce/schema/Contact.PrimaryMethodOfContact__c';
import CONTACT_PROFESSION_FIELD from '@salesforce/schema/Contact.Profession__c';
import CONTACT_SPECIALTY_FIELD from '@salesforce/schema/Contact.Specialty__c';
import CONTACT_ACCOUNTID_FIELD from '@salesforce/schema/Contact.AccountId';
import CONTACT_INSERT_EMAIL_MARKETING_CONSENT_FIELD from '@salesforce/schema/Contact.InsertEmailMarketingConsentCollected__c';

const CONTACT_FIELDS = [
    CONTACT_TITLE_FIELD,
    CONTACT_FIRSTNAME_FIELD,
    CONTACT_LASTNAME_FIELD,
    CONTACT_PREFERRED_LANGUAGE_FIELD,
    CONTACT_EMAIL_FIELD,
    CONTACT_MOBILE_FIELD,
    CONTACT_PRIMARY_M_CONTACT_FIELD,
    CONTACT_PROFESSION_FIELD,
    CONTACT_SPECIALTY_FIELD
];

export default class Flow_recordVisualPicker extends LightningElement {
    @api recordId;
    _recordId;
    @api selectedContactId;
    @api selectedRecordId;
    @api JSONInput;
    @api required;
    @api iconName;
    @api visibleRows;
    @track _JSONInput;
    @track contacts;
    isLoading = false;
    error;

    contactCreationFields;
    @api requiredCreateFields = '';
    @track _createFields;
    newContact;

    connectedCallback() {
        // refreshApex(this.wiredContactsResult);
        refreshApex(this.wiredRecords);
        this._recordId = this.recordId;
        // if (this.JSONInput) this.contactCreationFields = this.JSONInput.split(',')

        if (this.JSONInput) {
            const createFields = this.JSONInput.split(',').map(item => item.trim());
            const requiredFields = this.requiredCreateFields.split(',').map(item => item.trim());
            this._createFields = createFields.map(item => {
                const isRequired = requiredFields.includes(item) ;
                return { fieldName: item, required: isRequired };
            });
        }
    }

    isFirstRender = true;
    renderedCallback() {
        if (!this.isFirstRender) return;
        this.isFirstRender = false;

        document.documentElement.style.setProperty('--visibleRows', this.visibleRows);
    }

    @api objectApiName;
    @wire(getObjectInfo, { objectApiName:  '$objectApiName'})
    objectInfo;

    get objectLabel() {
        return this.objectInfo.data ? this.objectInfo.data.label : '';
    }
    get titleFieldLabel() {
        return this.objectInfo.data ? this.objectInfo.data.fields[this.titleField].label : '';
    }
    get subFieldOneLabel() {
        return this.objectInfo.data ? this.objectInfo.data.fields[this.subFieldOne].label : '';
    }
    get subFieldTwoLabel() {
        return this.objectInfo.data ? this.objectInfo.data.fields[this.subFieldTwo].label : '';
    }
    get objectIconName() {
        const isCustomObject = this.objectInfo.data ? this.objectInfo.data.custom : true;
        const iconName = this.iconName ? this.iconName : 'standard:related_list';
        return isCustomObject ? iconName : `standard:${this.objectApiName.toLowerCase()}`;
    }
    get addRecordButtonLabel() {
        const objectLabel = this.objectLabel || this.objectApiName;
        return `Add ${objectLabel}`;
    }

    @api titleField;
    @api subFieldOne;
    @api subFieldTwo;

    @api queryString;
    wiredRecords;
    records;
    _hasRecords;
    @wire(loadRecordCollection, { recordId: '$_recordId', queryString: '$queryString' })
    wiredRecords(result) {
        this.wiredRecords = result;
        if (result.data) {
            // this.records = [...JSON.parse(result.data)];
            // this.records.forEach(item => {
            //     item.title = item[this.titleField];
            //     item.subFieldOne = item[this.subFieldOne];
            //     item.subFieldTwo = item[this.subFieldTwo];
            // });
            this.records = JSON.parse(result.data).map(item => {
                item.title = this.titleField.split('.').reduce((o,i)=>o[i], item);
                item.subFieldOne = this.subFieldOne.split('.').reduce((o,i)=>o[i], item);
                item.subFieldTwo = this.subFieldTwo.split('.').reduce((o,i)=>o[i], item);
                return item;
            });

            this._hasRecords = this.records ? this.records.length > 0 : false;
            console.log('hasRecords::'+this._hasRecords);
        } else {
            console.log(result.error);
        }
    }

    handleRecordSelected(event) {
        const selectedRecordId = event.target.value;
        this.selectedRecordId = selectedRecordId;

        const attributeChangeEvent = new FlowAttributeChangeEvent('selectedRecordId', this.selectedRecordId);
        this.dispatchEvent(attributeChangeEvent);
    }

    handleNewContact(event) {
        var result = event.target.value;
        console.log("Create a new contact");
        this.newContact = true;
        this.isLoading = false;
    }

    handleSubmit(event) {
        this.isLoading = true;
        event.preventDefault();
        const fields = event.detail.fields;
        
        // Populate additional Contact fields
        if (this.objectApiName === 'Contact') {
            if (this._recordId.substring(0, 3) === '001') fields[CONTACT_ACCOUNTID_FIELD.fieldApiName] = this._recordId;
            fields[CONTACT_INSERT_EMAIL_MARKETING_CONSENT_FIELD.fieldApiName] = 'No';
        }
        
        if (this.newContact) this.template.querySelector('lightning-record-edit-form').submit(fields);
    }

    handleCreatedContact(event) {
        this.newContact = false;
        this.isLoading = false;

        refreshApex(this.wiredRecords);

        /* // Create the recordInput object
        const fields = {};
        fields[ID_FIELD.fieldApiName] = contactId;
        fields[ACCOUNTID_FIELD.fieldApiName] = this.recordId;
        console.log(fields);
        const recordInput = {
            fields
        };

        updateRecord(recordInput)
            .then(() => {
                return refreshApex(this.wiredContactsResult);
            })
            .catch(error => {

            }); */

    };

    handleCloseModal() {
        this.newContact = false;
    }

    @api
    validate() {
        if (this.required && !this.selectedRecordId) {
            return {
                isValid: false,
                errorMessage: 'Please make a selection'
            };
        } else {
            return { isValid: true };
        }
    }

    get modalBackdropClass() {
        return FORM_FACTOR === 'Large' ? 'slds-backdrop slds-backdrop_open desktop-modal-backgrop' : 'slds-backdrop slds-backdrop_open'
    }

    get isPhoneFormFactor() {
        return FORM_FACTOR !== 'Large';
    }

        get listContainerClass() {
        return this.visibleRows ? 'list-container-scrollable' : 'list-container';
    }
}