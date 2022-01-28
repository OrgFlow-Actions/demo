import { LightningElement, track, api, wire} from 'lwc';
import { showToast, goToRecord } from 'c/utils';
import apexSearch from '@salesforce/apex/flowLookupLwcController.search';
import getRecentlyViewed from '@salesforce/apex/flowLookupLwcController.getRecentlyViewed';

export default class Flow_lookupLwc extends LightningElement {

    @api recordId;
    @api accountId;
    // Use alerts instead of toast to notify user
    @api notifyViaAlerts = false;
    @api label;
    @api sObjectName;
    @api isMultiEntry;
    @api maxSelectionSize;
    @track loading = false;
    @track keyword = '';

    initialSelection = [];
    errors = [];
    recentlyViewed = [];

    newRecordOptions = [
        { value: 'Contact', label: 'New Contact'}
    ];


    /**
     * Loads recently viewed records and set them as default lookpup search results (optional)
    */
         @wire(getRecentlyViewed, { accountId: '$accountId', recordId: '$recordId'})
         getRecentlyViewed({ data }) {
             console.log('Recently viewed: ', data);
             if (data) {
                 this.recentlyViewed = data;
                 this.initLookupDefaultResults();
             }
         }

    connectedCallback(){

        //this.initLookupDefaultResults();
    }

    async handleLookupSearch(event) {
        console.log('Handling lookup search');
        let objectsToSearch = [];
        objectsToSearch.push('Contact');
        let searchTerm = event.detail;
        console.log('Search string: ' + JSON.stringify(searchTerm.searchTerm));
        
        try {
            const searchResults = await apexSearch({searchTerm: searchTerm.searchTerm, accountId: this.accountId, searchObjects: objectsToSearch});
            this.template.querySelector('c-lookup').setSearchResults(searchResults);
        } catch (error) {
            console.error('Lookup error', JSON.stringify(error));
            this.errors = [error];
        }

    } 
    
    handleLookupSelectionChange(event) {
        this.checkForErrors();
        const value = this.template.querySelector('c-lookup').getSelection();
        console.log(value);
        const valueString = JSON.stringify(value);
        this.recordId = value[0].id;
        console.log('Assigned the following id: ' + this.recordId);

    }  
    
    initLookupDefaultResults() {
        // Make sure that the lookup is present and if so, set its default results
        const lookup = this.template.querySelector('c-lookup');
        if (lookup) {
            console.log('Recently viewed length', this.recentlyViewed.length);
            if(this.recentlyViewed.length == 1){
                this.initialSelection = [{
                    id: this.recentlyViewed[0].id,
                    sObjectType: this.recentlyViewed[0].sObjectType,
                    icon: this.recentlyViewed[0].icon,
                    title: this.recentlyViewed[0].name
                }];
                lookup.initialSelection = this.initialSelection;
            }
            else if(this.recentlyViewed.length>1){
                lookup.setDefaultResults(this.recentlyViewed);
            }
        }
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



}