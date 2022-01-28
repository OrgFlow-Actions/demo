import { LightningElement, api, wire, track } from 'lwc';
import FORM_FACTOR from '@salesforce/client/formFactor';
import fetchRecordTypeValues from '@salesforce/apex/RecordTypePickerController.fetchRecordTypeValues';

export default class RecordTypePicker extends LightningElement {
    @api recordId;
    @api objectApiName;
    @api recordTypeLabel;
    @track recordTypes;
    selectedRecordTypeLabel;
    selectedRecordType;

    isDesktopFormFactor = FORM_FACTOR == 'Large';
    isLoading = true;

    error;

    @wire(fetchRecordTypeValues, { objectToCreate: '$objectApiName' })
    wiredRecordTypeValues({ error, data }) {
        if (data) {
            this.recordTypes = JSON.parse(data);
            if (this.recordTypes.length === 0) {
                this.navigateToNext();
            } else if (this.recordTypeLabel) {
                this.recordTypes.map(recordType => {
                    if (recordType.label === this.recordTypeLabel) {
                        this.selectedRecordType = recordType;
                        this.navigateToNext();
                    }
                })
            } else {
                this.selectedRecordType = this.recordTypes[0];
                this.isLoading = false;
            }
        } else if (error) {
            this.error = error;
            this.isLoading = false;
        }
    }

    handleRecordTypeSelected(event) {
        console.log(JSON.stringify(event.target.value, null, '\t'));
        const selectedRecordTypeId = event.target.value;
        for (const recordType of this.recordTypes) {
            if (recordType.value == selectedRecordTypeId) this.selectedRecordType = recordType;
        }
        this.navigateToNext();
    }

    navigateToNext() {
        const next = new CustomEvent('navigatenext', {
            detail: this.selectedRecordType//{ selectedRecordTypeLabel: this.selectedRecordTypeLabel }
        });
        this.dispatchEvent(next);
    }

    handleComboboxChange(event) {
        const selectedRecordTypeId = event.detail.value;
        for (const recordType of this.recordTypes) {
            if (recordType.value == selectedRecordTypeId) this.selectedRecordType = recordType;
        }
    }

    handleDesktopNext() {
        this.navigateToNext();
    }

    get defaultRecordType() {
        return this.selectedRecordType ? this.selectedRecordType.value : '';
    }
}