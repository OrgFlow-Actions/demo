import { LightningElement, api, track, wire } from 'lwc';
import { handleApexError } from 'c/utils';
import { getRecord, getFieldValue, getRecordNotifyChange } from 'lightning/uiRecordApi';
import FORM_FACTOR from '@salesforce/client/formFactor';
import getEventRecord from '@salesforce/apex/RelatedRecordWidget_CC.getEventRecord';
import completeEvent from '@salesforce/apex/RelatedRecordWidget_CC.completeEvent';
import USER_COUNTRY_FIELD from '@salesforce/schema/User.User_Country__c';
import USER_DEFAULT_CFE_SBU_FIELD from '@salesforce/schema/User.Default_CFE_SBUs__c';
import EVENT_CALL_REPORT_FIELD from '@salesforce/schema/Event.Call_Report__c';
import CALL_REPORT_PRODUCT_GROUP_FIELD from '@salesforce/schema/Call_Report__c.ProductGroup__c';
import userId from '@salesforce/user/Id';

const USER_FIELDS = [USER_COUNTRY_FIELD, USER_DEFAULT_CFE_SBU_FIELD];
const SBU_FIELDS = {
    impl: "Implants",
    orth: "Orthodontics",
    endo: "Endodontics",
    prev: "Preventive",
    pros: "Prosthetics",
    rest: "Restorative",
    cdcm: "CAD/CAM",
    inst: "Instruments",
    trce: "Treatment Centers",
    imag: "Imaging Systems"
};

export default class EventCallReportWidget extends LightningElement {
    @api recordId;
    @api objectApiName;
    @track callReportId;
    @track userId = userId;
    @track isEditMode = false;
    enableEditMode;
    @track error;
    @track isDesktopFormFactor = FORM_FACTOR === 'Large';
    @track isLoading = true;
    @track isInitialLoad = true;

    @track eventSbu;
    @track callReportProductGroup;
    @track curProductGroupSelection;

    @track callReport;

    @track isSubmitted = false;
    @track isDirty = false;
    @track saveAndComplete = false;
    disableSaveAndComplete = false;


    // Get current User.User_Country__c to be used in Call_Report__c.Assigned_To_User_Country__c
    @wire(getRecord, { recordId: '$userId', fields: USER_FIELDS })
    currentUser;

    get userCountry() {
        return getFieldValue(this.currentUser.data, USER_COUNTRY_FIELD);
    }

    get productGroupEditForm() {
        return this.isDirty ? this.curProductGroupSelection : this.productGroupViewForm ||
            getFieldValue(this.currentUser.data, USER_DEFAULT_CFE_SBU_FIELD) ||
            '';
    }

    get productGroupViewForm() {
        return this.curProductGroupSelection ||
            this.callReportProductGroup ||
            this.eventSbu ||
            '';
    }

    connectedCallback() {
        // this.getEventFields();
    }

    @wire(getEventRecord, { recordId: '$recordId', fields: 'Call_Report__c, SBU__c, IsChild, Created_by_me__c, Event_Status__c' })
    wiredEventRecord({ error, data }) {   
        if (data) {
            this.callReportId = data.Call_Report__c;
            this.eventSbu = data.SBU__c;
            this.enableEditMode = data.IsChild || !data.Created_by_me__c ? false : true;
            this.disableSaveAndComplete = data.Event_Status__c === 'Completed';
        } else if (error) {
            this.isLoading = false;
            this.error = handleApexError({ error: error });
        }
    }

    /* async getEventFields() {
        try {
            const eventRecord = await getEventRecord({
                recordId: this.recordId,
                fields: 'Call_Report__c, SBU__c, IsChild, Created_by_me__c, Event_Status__c'
            });
            this.callReportId = eventRecord.Call_Report__c;
            this.eventSbu = eventRecord.SBU__c;
            this.enableEditMode = eventRecord.IsChild || !eventRecord.Created_by_me__c ? false : true;
            this.disableSaveAndComplete = eventRecord.Event_Status__c === 'Completed';
        } catch (error) {
            this.isLoading = false;
            this.error = handleApexError({ error: error });
        }
    } */

    async setEventToCompleted() {
        try {
            const completedEvent = await completeEvent({ recordId: this.recordId });
            this.disableSaveAndComplete = true;
            getRecordNotifyChange([{ recordId: this.recordId }]);
            const refreshView = new CustomEvent('refreshview');
            this.dispatchEvent(refreshView);
            // this.getEventFields();
            this.isLoading = false;
        } catch (error) {
            this.isLoading = false;
            this.error = handleApexError({ error: error });
        }
    }

    toggleSubSbuFieldVisibility(sbuString = '') {
        const sbuList = typeof sbuString === 'string' ? sbuString.split(';') : sbuString;
        Object.keys(SBU_FIELDS).forEach(element => {
            const sbu = SBU_FIELDS[element];
            const inputField = this.template.querySelector(`.${element}`);
            if (inputField) {
                if (sbuList.find(item => item === sbu)) {
                    inputField.classList.remove('slds-hide');
                } else if (!inputField.classList.contains('slds-hide')) {
                    inputField.classList.add('slds-hide');
                    inputField.value = null;
                }
            }
        });
    }

    handleCardAction(event) {
        this.isLoading = true;
        this.isSubmitted = false;
        this.isDirty = false;

        this.curProductGroupSelection = null;
        this.isEditMode = !this.isEditMode;
        this.error = null;
    }

    handleFormLoad(event) {
        if (!this.isDirty) {
            this.callReport = event.detail.records[this.callReportId].fields;
            if (this.callReport && this.callReport[CALL_REPORT_PRODUCT_GROUP_FIELD.fieldApiName]) {
                this.callReportProductGroup = this.callReport[CALL_REPORT_PRODUCT_GROUP_FIELD.fieldApiName].value;
            }
            
            if (this.isEditMode) {
                this.toggleSubSbuFieldVisibility(this.productGroupEditForm);
                if (event.detail.hasOwnProperty('picklistValues') && !this.isSubmitted) this.isLoading = false;
            } else if (!this.isEditMode) {
                this.toggleSubSbuFieldVisibility(this.productGroupViewForm);
                this.isLoading = false;
                this.isInitialLoad = false;
            }
        }
    }

    // Show or hide input fields depending on if SBU is selected
    handleSbuInputChange(event) {
        this.isDirty = true;
        this.curProductGroupSelection = event.target.value || '';
        this.toggleSubSbuFieldVisibility(this.curProductGroupSelection);
    }

    handleUserSubmit() {
        this.isLoading = true;
        this.isSubmitted = true;
        this.template.querySelector('lightning-record-edit-form').submit();
    }

    handleUserSubmitAndComplete() {
        this.saveAndComplete = true
        this.handleUserSubmit();
    }
    
    handleSuccess(event) {
        const callReport = event.detail;
        if (this.saveAndComplete) {
            this.setEventToCompleted();
            this.saveAndComplete = false;
        } 
        // this.isLoading = false;
        this.eventSbu = callReport.fields[CALL_REPORT_PRODUCT_GROUP_FIELD.fieldApiName] ? callReport.fields[CALL_REPORT_PRODUCT_GROUP_FIELD.fieldApiName].value : '';
        this.isEditMode = false;
        this.error = null;
        this.isDirty = false;
        const refreshView = new CustomEvent('refreshview');
        this.dispatchEvent(refreshView);
        console.log('eventCallReportWidgetSuccess::'+JSON.stringify(callReport));
    }
    
    handleError(event) {
        this.saveAndComplete = false;
        this.isLoading = false;
        this.error = event.detail;
    }

    get spinnerVariant() {
        return this.isInitialLoad ? 'base' : 'brand';
    }

    get callNotes() {
        return this.callReport ? this.callReport.Call_Notes__c.value : '';
    }

    get showHideUserCountry() {
        return this.userCountry ? 'slds-hide' : 'slds-show';
    }
}