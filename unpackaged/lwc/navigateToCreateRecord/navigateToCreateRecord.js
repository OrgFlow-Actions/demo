import { LightningElement, api, track, wire } from 'lwc';
import Id from '@salesforce/user/Id';
import getRecord from '@salesforce/apex/NavigateToCreateRecordController.getRecord';

export default class NavigateToCreateRecord extends LightningElement {
    @api recordId;
    @api defaultFieldValuesString;

    userId = Id;
    @track fieldsToQuery = new Set();
    @track userFieldsToQuery = new Set();
    @track sourceRecord;
    @track userRecord;

    error;

    connectedCallback() {
        this.processDefaultFields();
        this.getSourceRecord();
        // this.navigateToCreateRecord();
    }

    processDefaultFields() {
        const defaultFieldValues = JSON.parse(this.defaultFieldValuesString);
        Object.entries(defaultFieldValues).map(([key, value]) => {
            const matches = value.matchAll(/\$(.*?)}/g);
            for (const match of matches) {
                const userRegExp = new RegExp('User\\.', 'i');
                if (match[1].match(userRegExp)) {
                    this.userFieldsToQuery.add(match[1].replace(userRegExp, ''));
                } else {
                    this.fieldsToQuery.add(match[1]);
                }
            }
        })
    }

    async getSourceRecord() {
        try {
            if (this.fieldsToQuery.size > 0) {
                const sourceRecord = await getRecord({
                    recordId: this.recordId,
                    fields: [...this.fieldsToQuery].join(),
                });
                this.sourceRecord = JSON.parse(sourceRecord);
            }

            if (this.userFieldsToQuery.size > 0) {
                const userRecord = await getRecord({
                    recordId: this.userId,
                    fields: [...this.userFieldsToQuery].join(),
                });
                this.userRecord = JSON.parse(userRecord);
            }

            this.navigateToCreateRecord();
        } catch (error) {
            this.error = error;
        }
    }

    navigateToCreateRecord() {
        let finalString = this.defaultFieldValuesString;
        for (const field of this.fieldsToQuery) {
            const regex = new RegExp(`{([^{]*)\\$(${field})}`, 'g');
            const fieldValue = this.getProperty({ propertyName: field, object: this.sourceRecord });
            const replacementString = fieldValue ? `$1${fieldValue}` : '';
            finalString = finalString.replace(regex, replacementString);
        }
        for (const field of this.userFieldsToQuery) {
            const regex = new RegExp(`{([^{]*)\\$(User\\.${field}})`, 'gi');
            const fieldValue = this.getProperty({ propertyName: field, object: this.userRecord });
            const replacementString = fieldValue ? `$1${fieldValue}` : '';
            finalString = finalString.replace(regex, replacementString);
        }
        //finalString = finalString.replace(/(:")\W[^\w"']*(")/g, '$1$2');
        console.log('finalString::' + finalString);
        const navigateToCreateRecord = new CustomEvent('navigatetonewrecord', {
            detail: {
                defaultFields: finalString
            }
        });
        this.dispatchEvent(navigateToCreateRecord);
    }

    getProperty({ propertyName, object }) {
        const parts = propertyName.split('.');
        let property = object;
        for (let i = 0; i < parts.length; i++) {
            property = property[parts[i]];
        }
        return property;
    }
}