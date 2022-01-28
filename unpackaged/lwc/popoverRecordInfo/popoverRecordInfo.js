import { LightningElement, api } from 'lwc';
import FORM_FACTOR from '@salesforce/client/formFactor';

export default class PopoverRecordInfo extends LightningElement {
    @api recordId;
    @api objectApiName;
    @api iconName;
    @api title;
    @api url;
    @api fields;
    @api mode = 'readonly';
    @api columns = FORM_FACTOR === 'Large' ? 2 : 1;;

    get recordUrl() {
        return this.url ? `/${this.url}` : `/${this.recordId}`;
    }
}