import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import COUNTRY_FIELD from '@salesforce/schema/Account.Country__c';
import DEALER_FIELD from '@salesforce/schema/Account.DistributorCategorisation__c';

export default class DealerCategorisation extends LightningElement {
    @api recordId;
    @api isLoading = false;

    fields = [COUNTRY_FIELD, DEALER_FIELD];

    handleSubmit(event){
        event.preventDefault();
        //this.isLoading = false;
        const fields = event.detail.fields;
        fields.DistributorCategories__c = fields.DistributorCategorisation__c;
        this.template.querySelector('lightning-record-form').submit(fields);
     }

     handleSuccess(event) {
        const evt = new ShowToastEvent({
            title: "Distributor updated",
            variant: "success"
        });
        this.dispatchEvent(evt);
    }

}