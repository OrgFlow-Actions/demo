import { LightningElement, track, api, wire } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import { handleApexError } from 'c/utils';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import FORM_FACTOR from '@salesforce/client/formFactor';
/** SampleLookupController.search() Apex method */
import apexSearch from '@salesforce/apex/EventMultiWhoController.search';
/** SampleLookupController.getEventWhoIds() Apex method */
import getEventWhoIds from '@salesforce/apex/EventMultiWhoController.getEventWhoIds';
/** SampleLookupController.setEventWhoIds() Apex method */
import setEventWhoIds from '@salesforce/apex/EventMultiWhoController.setEventWhoIds';
import getEventRecord from '@salesforce/apex/RelatedRecordWidget_CC.getEventRecord';

export default class EventMultiWhoLwc extends LightningElement {
    @api recordId;
    // Use alerts instead of toast to notify user
    @api notifyViaAlerts = false;
    errors = [];
    error;
    isDesktopFormFactor = FORM_FACTOR === 'Large';
    enableEditMode;
    isLoading = true;
    isInitialLoad = true;
    
    // Tile data test
    @track initialSelection = [];
    @track _selection = [];
    // test uniqueTileAction
    isEditMode = false;

    connectedCallback() {
        console.log('connectedCallback::');
        console.log('eventId::'+this.recordId);
        // this.refreshContacts();
        // this.isLoading = true;
    }

    @wire(getEventRecord, { recordId: '$recordId', fields: 'IsChild, Created_by_me__c' })
    wiredEventRecord({ error, data }) {   
        if (data) {
            this.enableEditMode = data.IsChild || !data.Created_by_me__c ? false : true;
        } else if (error) {
            this.isLoading = false;
            this.error = handleApexError({ error: error });
        }
    }

    @track wiredEventWhoIds
    @wire(getEventWhoIds, { eventId: '$recordId' })
    wiredGetEventWhoIds(value) {
        this.wiredEventWhoIds = value;
        const { data, error } = value;
        if (data) {
            this.initialSelection = [...data];
            // this._selection = [...data];
            this.isLoading = false;
            this.isInitialLoad = false;
        } else if (error) {
            this.isLoading = false;
            this.error = handleApexError({ error: error });
        }
    }

    @api
    async refreshContacts() {
        // if (!this.isEditMode) this.isLoading = true;
        // try {
        //     const eventWhoIds = await getEventWhoIds({ eventId: this.recordId });
        //     this.initialSelection = [...eventWhoIds];
        //     this._selection = [...eventWhoIds];
        //     this.isLoading = false;
        //     this.isInitialLoad = false;
        // } catch (error) {
        //     this.isLoading = false;
        //     this.error = handleApexError({ error: error });
        // }
        refreshApex(this.wiredEventWhoIds);
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
        this._selection = selection.map(element => element);
        console.log('eventMiltiWhoLwc::selection::' + JSON.stringify(selection.map(element => element.id)));
    }

    // card action TEST
    handleCardAction(event) {
        console.log('eventMultiWho::handleCardAction::'+JSON.stringify(event.target));
        this.isEditMode = !this.isEditMode;
        if (this.isEditMode) {
            // this.refreshContacts();
            this._selection = [...this.initialSelection];
        } else if (!this.isEditMode) {
            this.error = null;
            this.errors = [];
        }
    }
    // card action TEST end

    // Selection remove TEST
    handleTileAction(event) {
        // Get the value of the selected action
        console.log('eventMultiWhoLwc::handleAction::'+JSON.stringify(event));
        const tileAction = event.detail.action;
        if (tileAction.value === 'remove') {
            this._selection = this._selection.filter(item => item.id !== tileAction.id);
        } else if (tileAction.value === 'promote') {
            let index = this._selection.findIndex(item => item.id === tileAction.id);
            if (index !== 0) this._selection.unshift(this._selection.splice(index, 1)[0]);
        }
    }
    // Selection remove TEST end

    handleUserSubmit() {
        this.isLoading = true;
        this.checkForErrors();
        // Set new Event Contacts (EventRelations) TEST
        console.log('eventMultiWhoLwc::setEventWhoIds'+JSON.stringify(this._selection.map(element => element.id)));
        if (this.errors.length === 0) {
            this.setEventWhoIds();
        } else {
            this.isLoading = false;
        }
    }

    async setEventWhoIds() {
        try {
            await setEventWhoIds({
                eventId: this.recordId,
                whoIdList: this._selection.map(element => element.id)
            });
            this.initialSelection = [...this._selection];
            this.isLoading = false;
            this.isEditMode = false;
            this.error = null;
            this.errors = [];
            const refreshView = new CustomEvent('refreshview');
            this.dispatchEvent(refreshView);
        } catch (error) {
            this.isLoading = false;
            this.error = handleApexError({ error: error });
        }
    }

    checkForErrors() {
        const selection = this._selection;
        if (selection.length === 0) {
            this.errors = [{
                    message: 'You must add a contact before saving'
                },
                {
                    message: 'Please add a contact and try again.'
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

    //test function to assign action
    appendActions(element, showActions) {
        let tempElement = Object.assign({}, element);
        tempElement['tileActions'] = showActions ?
            [{
                label: 'Promote to Primary',
                value: 'promote',
                iconName: 'utility:change_owner',
                id: tempElement.id
            }, {
                label: 'Remove',
                value: 'remove',
                iconName: 'utility:close',
                id: tempElement.id
            }, ] :
            [];
        tempElement['href'] = `/${tempElement.id}`;
        return tempElement;
    }
    // test getter to dynamicaly enable and disable tile actions
    get getSelection() {
        return this.isEditMode ?
            this._selection.map(element => this.appendActions(element, true)) :
            this.initialSelection.map(element => this.appendActions(element, false));
    }

    get spinnerVariant() {
        return this.isInitialLoad ? 'base' : 'brand';
    }
}