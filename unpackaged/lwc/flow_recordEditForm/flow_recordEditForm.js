import { LightningElement, api, track, wire } from 'lwc';
import { FlowAttributeChangeEvent } from 'lightning/flowSupport';

export default class Flow_recordEditForm extends LightningElement {
    @api recordId;
    @api sObjectName;
    @api fields;
    @api readOnly = false;
    @api preventDefault = false;
    @api output;
    @track _fields = [];

    connectedCallback() {
        this._fields = JSON.parse(this.fields);
    }

    handleSubmit(event) {
         const fields = event.detail.fields;
         this.output = JSON.stringify(fields);
         console.log(`fields ${JSON.stringify(fields)}`);

         if (this.preventDefault) {
            event.preventDefault();
         }
    }

    @api
    validate() {
        if (true) {
            try {
                // this.template.querySelector('lightning-record-edit-form').submit();
                // Need to click a submit button to trigger the submit event
                this.template.querySelector('lightning-button').click();
            } catch (error) {
                return {
                    isValid: false,
                    errorMessage: 'Something went wrong'
                }     
            }
        }
    }
}