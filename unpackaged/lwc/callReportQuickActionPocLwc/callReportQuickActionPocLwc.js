import { LightningElement, track, api, wire } from 'lwc';
import { handleApexError } from 'c/utils';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecord, getFieldValue, deleteRecord } from 'lightning/uiRecordApi';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { NavigationMixin } from 'lightning/navigation';
import FORM_FACTOR from '@salesforce/client/formFactor';
import CALL_REPORT_OBJECT from '@salesforce/schema/Call_Report__c'
import CALL_REPORT_EVENT_WHOIDS_FIELD from '@salesforce/schema/Call_Report__c.EventWhoIds__c';
import Id from '@salesforce/user/Id';

const USER_FIELDS = ['User.User_Country__c', 'User.Default_CFE_SBUs__c', 'User.Default_Activity_Length_In_Minutes__c'];
// test SBU Field configurations
const SBU_FIELDS = {
    impl: "Implants"
    , orth: "Orthodontics"
    , endo: "Endodontics"
    , prev: "Preventive"
    , pros: "Prosthetics"
    , rest: "Restorative"
    , cdcm: "CAD/CAM"
    , inst: "Instruments"
    , trce: "Treatment Centers"
    , imag: "Imaging Systems"
};

/** SampleLookupController.search() Apex method */
import apexSearch from '@salesforce/apex/EventMultiWhoController.search';
// Get current contact to set as initialSelection
import getContacts from '@salesforce/apex/EventMultiWhoController.getContacts';
// test createEvent Apex method
import createEvent from '@salesforce/apex/CallReportQuickActionPocController.createEvent';
import getCotravelPicklist from '@salesforce/apex/CallReportQuickActionPocController.getPickListValuesIntoList';

export default class CallReportQuickActionPocLwc extends NavigationMixin(LightningElement) {

    @wire(getObjectInfo, { objectApiName: Event })
    eventObjectInfo;
    //picklist 
    // @wire(getCotravelPicklist)
    // coTravelPicklistValues;

    //
    @api recordId;
    @api sObjectName;
    // Use alerts instead of toast to notify user
    @api notifyViaAlerts = false;
    @track _mobileFormFactor = FORM_FACTOR == 'Small';
    @track isMultiEntry = true;
    @track initialSelection = [];
    @track errors = [];
    @track error;
    @track isLoading = false;
    @track isInitialLoad = true;
    @track callReportId;
    
    renderInputs;

    @track _startTime;
    @track _endTime;
    @track endTimeDirty;
    // Current User Id
    userId = Id;
    coTravelTypes = [];
    selectedCoTravelType;
    @wire(getObjectInfo, { objectApiName: CALL_REPORT_OBJECT })
    callReportInfo;

    // Get current User.User_Country__c to be used in Call_Report__c.Assigned_To_User_Country__c
    @track currentUser;
    @wire(getRecord, { recordId: '$userId', fields: USER_FIELDS })
    wiredUser(value) {
        this.currentUser = value;
        const { data, error } = value;
        if (data) {
            const userDefaultActivityLength = getFieldValue(this.currentUser.data, USER_FIELDS[2]);
            if (userDefaultActivityLength) this._startTime = this.nearestQuarterDateTime(-userDefaultActivityLength);
        }
    }

    get callReportRTId() {
        let recordTypeId = '';
        if (this.callReportInfo.data) {
            const rtis = this.callReportInfo.data.recordTypeInfos;
            recordTypeId = Object.keys(rtis).find(rti => rtis[rti].name === 'Call Report CFE 2.0');
        }
        return recordTypeId;
    }

    constructor(){
        super()
        getCotravelPicklist().then((params) => {
            this.coTravelTypes = params.map(function (coTravelType) {
                return {
                    label: coTravelType,
                    value:coTravelType
                }
            });
        })

    }
    get userCountry() {
        return getFieldValue(this.currentUser.data, USER_FIELDS[0]);
    }

    get userDefaultSbu() {
        const defaultSbu = getFieldValue(this.currentUser.data, USER_FIELDS[1]);
        return defaultSbu || '';
    }

    get userDefaultActivityLength() {
        const defaultActivityLength = getFieldValue(this.currentUser.data, USER_FIELDS[2]);
        return defaultActivityLength || '';
    }

    get showIfLoaded() {
        return this.isInitialLoad ? 'slds-hide' : 'slds-show';
    }

    get showHideUserCountry() {
        return this.userCountry ? 'slds-hide' : 'slds-show';
    }

    get startTime() {
        return this._startTime.toISOString();
    }

    get endTime() {
        return this._endTime.toISOString();
    }

    handleStartTimeChange(event) {
        const newStartTime = new Date(event.target.value);
        if (!this.endTimeDirty || newStartTime >= this._endTime) {
            this._endTime = new Date(newStartTime.getTime() + (this._endTime - this._startTime));
        }
        this._startTime = newStartTime;
    }

    handleEndTimeChange(event) {
        const newEndTime = new Date(event.target.value);
        if (newEndTime <= this._startTime) {
            this._startTime = new Date(newEndTime.getTime() - (this._endTime - this._startTime));
        }
        this._endTime = newEndTime;
        this.endTimeDirty = true;
    }
    
    handleCoTravelChange(event){
        this.selectedCoTravelType = event.detail.value;
        console.log('selectedCoTravelType',this.selectedCoTravelType);
    }

    connectedCallback() {
        // Might need to add case for 'Medium' since that is tablet form factor
        // this._mobileFormFactor = FORM_FACTOR == 'Small' ? true : false;
        this.renderInputs = true;
        this._startTime = this.nearestQuarterDateTime(-60);
        this._endTime = this.nearestQuarterDateTime();
        this.endTimeDirty = false;
        if (this.sObjectName === 'Contact') this.getContacts();
    }

    async getContacts() {
        try {
            const contacts = await getContacts({ contactId: this.recordId });
            this.initialSelection = [...contacts];
        } catch (error) {
            this.isLoading = false;
            this.error = handleApexError({ error: error });
        }
    }

    /* @wire(getContacts, { contactId: '$recordId' })
    wiredContacts(value) {
        const { data, error } = value;
        if (data) {
            this.initialSelection = [...data];
        } else if (error) {
            this.error = handleApexError({ error: error });
        }
    } */


    nearestQuarterDateTime(minutes = 0, date = Date.now()) {
        let timeToReturn = new Date(date + minutes * 60000);
        timeToReturn.setMilliseconds(Math.round(timeToReturn.getMilliseconds() / 1000) * 1000);
        timeToReturn.setSeconds(Math.round(timeToReturn.getSeconds() / 60) * 60);
        timeToReturn.setMinutes(Math.round(timeToReturn.getMinutes() / 15) * 15);
        return timeToReturn;
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

    handleStartDateTimeChange(event) {
        const newStartDateTime = new Date(event.target.value);
        this.startDateTimeDefault = newStartDateTime;
    }

    // Show or hide input fields depending on if SBU is selected
    handleSbuInputChange(event) {
        const sbuList = event.target.value.split(';');
        this.toggleSubSbuFieldVisibility(sbuList);
    }
    
    handleLookupTypeChange(event) {
        this.initialSelection = [];
        this.errors = [];
        this.isMultiEntry = event.target.checked;
    }

    async handleSearch(event) {
        try {
            const searchResults = await apexSearch(event.detail);
            this.template.querySelector('c-lookup-lwc').setSearchResults(searchResults);
        } catch (error) {
            console.error('Lookup error', JSON.stringify(error));
            this.errors = [error];
        }
    }

    handleSelectionChange() {
        this.errors = [];
        const selection = this.template.querySelector('c-lookup-lwc').getSelection();
        console.log('selection::' + JSON.stringify(selection.map(element => element.id)));
        // console.table(selection);
    }

    handleLoad(event) {
        if (this.isInitialLoad) {
            const sbuList = this.userDefaultSbu.split(';');
            this.toggleSubSbuFieldVisibility(sbuList);
            this.isInitialLoad = false;
            this.isLoading = false;
        } 
        console.log('initialLoadSbu::'+this.userDefaultSbu);
    }

    handleCancel() {
        const closeQA = new CustomEvent('close');
        this.dispatchEvent(closeQA);
    }

    isSaveAndNew = false;
    handleSaveAndNew(event) {
        this.isSaveAndNew = true;
    }
    
    handleSubmit(event) {
        this.isLoading = true;
        event.preventDefault();
        const eventWhoIdsSelection = this.template.querySelector('c-lookup-lwc').getSelection();
        const fields = event.detail.fields;
        fields[CALL_REPORT_EVENT_WHOIDS_FIELD.fieldApiName] = JSON.stringify(eventWhoIdsSelection.map(element => element.id));
        
        // this.checkForErrors();
        if (this.errors.length === 0) {
            this.template.querySelector('lightning-record-edit-form').submit(fields);
            // this.notifyUser('Success', 'The form was submitted.', 'success');
        } else {
            this.isLoading = false;
        }
    }

    handleError(event) {
        this.error = event.detail;
        this.isLoading = false;
    }

    handleSuccess(event) {
        const payload = event.detail;
        this.callReportId = payload.id;
        this.error = null;
        console.log('success::'+JSON.stringify(payload));
        this.createEvent();
    }

    async createEvent() {
        try {
            const eventWhatId = this.recordId;
            const newEventId = await createEvent({ callReportId: this.callReportId, eventWhatId: eventWhatId, coTravel: this.selectedCoTravelType });
            const eventPageRef = {
                type: 'standard__recordPage',
                attributes: {
                    recordId: newEventId,
                    objectApiName: 'Event',
                    actionName: 'view'
                },
            };

            /* // POC same behavior for mobile and desktop
            const event = new ShowToastEvent({
                title: 'Success!',
                message: 'Your call report was successfully created.',
                variant: 'success'
            });
            this.dispatchEvent(event);
            this[NavigationMixin.Navigate](eventPageRef);
            // POC end */

            // Don't navigate to the event, but provide link in toast message if desktop
            // On mobile, navigate to the new event
            if (!this.isSaveAndNew) {
                const toast = new ShowToastEvent({
                    title: 'Success!',
                    message: 'Your call report was created.',
                    variant: 'success'
                });
                this.dispatchEvent(toast);
                this[NavigationMixin.Navigate](eventPageRef);
            } else if (this.isSaveAndNew) {
                const linkToNewEvent = await this[NavigationMixin.GenerateUrl](eventPageRef);
                const toast = new ShowToastEvent({
                    title: 'Success!',
                    message: 'Your call report was created. {0}.',
                    messageData: [{
                        url: linkToNewEvent,
                        label: 'Navigate to it here'
                    }],
                    variant: 'success'
                });
                this.dispatchEvent(toast);
                // this.resetForm();
                // 200511 poc for opening 'new event' action
                const refreshView = new CustomEvent('refreshview');
                this.dispatchEvent(refreshView);
                const newEvent = new CustomEvent('newevent');
                this.dispatchEvent(newEvent);
            }
        } catch (error) {
            deleteRecord(this.callReportId);
            this.isLoading = false;
            this.error = handleApexError({ error: error });
        }
    }

    resetForm() {
        const refreshView = new CustomEvent('refreshview');
        this.dispatchEvent(refreshView);

        // const inputFields = this.template.querySelectorAll('lightning-input-field');
        // if (inputFields) inputFields.forEach(field => field.reset());

        // const contactLookupField = this.template.querySelector('c-lookup-lwc');
        // contactLookupField.selection = [...this.initialSelection];
        
        // this.connectedCallback();
        this.isLoading = false;
        this.isInitialLoad = true;
        this.renderInputs = false;
        this.isSaveAndNew = false;
        setTimeout(() => this.connectedCallback(), 0);
    }

    checkForErrors() {
        const selection = this.template.querySelector('c-lookup-lwc').getSelection();
        if (selection.length === 0) {
            this.errors = [{
                    message: 'You must select a Contact before submitting!'
                },
                {
                    message: 'Please select a Contact and try again.'
                }
            ];
        } else {
            this.errors = [];
        }
    }

    notifyUser(title, message, variant) {
        if (this.notifyViaAlerts) {
            // Notify via alert
            // eslint-disable-next-line no-alert
            alert(`${title}\n${message}`);
        } else {
            // Notify via toast
            const toastEvent = new ShowToastEvent({
                title,
                message,
                variant
            });
            this.dispatchEvent(toastEvent);
        }
    }
}