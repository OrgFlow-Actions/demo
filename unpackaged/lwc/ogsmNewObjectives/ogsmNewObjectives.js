import { LightningElement,api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

import { encodeDefaultFieldValues } from 'lightning/pageReferenceUtils';

export default class OgsmNewObjectives extends NavigationMixin(LightningElement) {
    @api recordId;
    handleNewClicked() {
        console.log(this.recordId);
        const defaultValues = encodeDefaultFieldValues({
            AccountPlan__c: this.recordId
        });
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'Objective__c',  
                actionName: 'new'
            },
            state: {
                defaultFieldValues: defaultValues,
                navigationLocation: 'RELATED_LIST'
            }
        });
       
    }
    
    
}