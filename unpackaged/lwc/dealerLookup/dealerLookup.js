import { LightningElement, track, api, wire} from 'lwc';
import { showToast, goToRecord } from 'c/utils';

//Apex Controllers
import getDistributors from '@salesforce/apex/LeadController.getDistributors';
import getDealers from '@salesforce/apex/LeadController.getDealers';

import searchApex from '@salesforce/apex/LeadController.search';
import getRecentlyViewed from '@salesforce/apex/LeadController.getRecentlyViewed';

export default class OrderDealerLwc extends LightningElement {
    @api recordId;
    @api category;
    @api dealerOutput;
    @track loading = false;
    @track keyword = '';
    @track distributors = [];
    @track defaultDistributors =[];
    @track selectedDistributors = [];
    @track dealers = [];
    @track selectedDealer = -1;
    @track noDistributorsFound = false;
    @track userUiTheme;
    @track selectedDealerId ='';
    @track isLookupOpen = false;

    isMultiEntry = false;
    maxSelectionSize = 1;
    initialSelection = [];
    
    errors = [];
    recentlyViewed = [];

    @wire(getRecentlyViewed, {recordId: '$recordId', category: '$category'})
    getRecentlyViewed({ data }) {
        if (data) {
            this.recentlyViewed = data;
            this.initLookupDefaultResults();
        }
    }

    connectedCallback() {
        this.getDealers();
        this.initLookupDefaultResults();
    }

    getDealers() {
        getDealers({orderId : this.recordId, category: this.category})
        .then(result => {
            this.dealers = result;
            for(let i = 0; i<result.length;i++){
                var distributor = {};
                distributor.Id = result[i].Dealer__c;
                distributor.Name = result[i].Dealer__r.Name;
                this.distributors.push(distributor);
                this.defaultDistributors.push(distributor);                
            }

        })
        .catch(error => {
            console.log(error);
            //showToast(this, '', 'ERROR', error.body.message + error.body.stackTrace, 'error');
        });
    }
    keywordHandleUpdate(event) {
        
        this.keyword = event.target.value;
        this.isLookupOpen = true;
        console.log(this.keyword);
        this.isFirstTime = false;
        if(this.keyword && this.keyword.length > 3) {
            this.getDistributors();
        } else {
            this.distributors = this.defaultDistributors;
        }
    }

    getDistributors() {
        getDistributors({keyword : this.keyword, orderId : this.recordId})
        .then(result => {
            if(result.length > 0) {
                this.distributors = [];
                for(let i = 0; i < result.length; i++) {
                    let distributor = result[i];
                    this.distributors.push(distributor);
                }
                this.noDistributorsFound = false;
            } else {
                this.distributors = null;
                this.noDistributorsFound = true;
            }
            
        }).catch(error => {
            console.log(error);
            //showToast(this, '', 'ERROR', error.body.message + error.body.stackTrace, 'error');
        });
    }

    clearSelection(){
        this.selectedDealerId='';
    }

    initLookupDefaultResults() {
        // Make sure that the lookup is present and if so, set its default results
        const lookup = this.template.querySelector('c-lookup');
        if (lookup) {
            lookup.setDefaultResults(this.recentlyViewed); 
        }
    }

     /**
     * Handles the lookup search event.
     * Calls the server to perform the search and returns the resuls to the lookup.
     * param event `search` event emmitted by the lookup
     */
    handleLookupSearch(event) {
        // Call Apex endpoint to search for records and pass results to the lookup
        searchApex({searchTerm: event.detail.searchTerm, category : this.category}) //{searchTerm : event.detail, category : this.category}
            .then((results) => {
                this.template.querySelector('c-lookup').setSearchResults(results);
            })
            .catch((error) => {
                //this.notifyUser('Lookup Error', 'An error occured while searching with the lookup field.', 'error');
                // eslint-disable-next-line no-console
                console.error('Lookup error', JSON.stringify(error));
                this.errors = [error];
            });
    }

    /**
     * Handles the lookup selection change
     * @param {event} event `selectionchange` event emmitted by the lookup.
     * The event contains the list of selected ids.
     */
    // eslint-disable-next-line no-unused-vars
    handleLookupSelectionChange(event) {
        this.checkForErrors();

        //const value = event.target.value;
        const value = this.template.querySelector('c-lookup').getSelection();
        console.log(value);
        const valueString = JSON.stringify(value);
        if (valueString != '[]') {  
          this.dealerOutput = value;
        }
        else{
            this.dealerOutput = [];
        }    
          const valueChangeEvent = new CustomEvent("valuechange", {
            detail: { data: this.dealerOutput }
          });
          // Fire the custom event
          this.dispatchEvent(valueChangeEvent);
          //this.initialSelection = [];
        
    }

    // All functions below are part of the sample app form (not required by the lookup).

    handleLookupTypeChange(event) {
        this.initialSelection = [];
        this.errors = [];
        this.isMultiEntry = event.target.checked;
    }

    handleMaxSelectionSizeChange(event) {
        this.maxSelectionSize = event.target.value;
    }

    handleSubmit() {
        this.checkForErrors();
        if (this.errors.length === 0) {
            this.notifyUser('Success', 'The form was submitted.', 'success');
        }
    }

    handleClear() {
        this.initialSelection = [];
        this.dealerOutput = '';
        this.errors = [];
    }

    checkForErrors() {
        this.errors = [];
        const selection = this.template.querySelector('c-lookup').getSelection();
        // Custom validation rule
        if (this.isMultiEntry && selection.length > this.maxSelectionSize) {
            this.errors.push({ message: `You may only select up to ${this.maxSelectionSize} items.` });
        }
        // Enforcing required field
        if (selection.length === 0) {
            this.errors.push({ message: 'Please make a selection.' });
        }
    }

    notifyUser(title, message, variant) {
        if (this.notifyViaAlerts) {
            // Notify via alert
            // eslint-disable-next-line no-alert
            alert(`${title}\n${message}`);
        } else {
            // Notify via toast (only works in LEX)
            const toastEvent = new ShowToastEvent({ title, message, variant });
            this.dispatchEvent(toastEvent);
        }
    }
    
}