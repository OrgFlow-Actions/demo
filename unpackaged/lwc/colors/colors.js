import { api, LightningElement,wire } from 'lwc';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import STATUS_FIELD from '@salesforce/schema/Objective__c.Status__c';
import OBJ_OBJECT from '@salesforce/schema/Objective__c';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
export default class Colors extends LightningElement {
    @api value;
    @api editable;
    @api rowKeyValue;
    @api colKeyValue;
    @api icon;
    _value;
    isEditMode= false;

    @wire(getObjectInfo, { objectApiName: OBJ_OBJECT })
    objectInfo;

    @wire(getPicklistValues, { recordTypeId: '$objectInfo.data.defaultRecordTypeId',
                               fieldApiName: STATUS_FIELD 
                            })
    picklistvalues({ error, data }) {
        // reset values to handle eg data provisioned then error provisioned
        this.options = undefined;
        if (data) {
            this.options = data.values;
            console.log('data',data);
        } else if (error) {
            console.log(error);
        }
    }  


    get statusClassName(){
        return this.value !== this._value ? 'edited' : '';
    }

    connectedCallback() {
        this._value = this.value;
        console.log('picklist',this.propertyOrFunction );
       
    }
    onclickHandle(){
        this.isEditMode = !this.isEditMode;
    }
    changeHandler(event){
        this._value = event.detail.value;
    }

    handlePicklistChange(event) {
        this._value = event.detail.value;
        //change the icon in the view 
            if(this._value  === 'Green'){
                this.icon = 'action:new_task';
            } else if (this._value  === 'Yellow'){
                this.icon = 'action:new_case';
            } else if(this._value  === 'Red'){
                this.icon = 'action:close';
            } else if(this._value  === 'Achieved'){
                this.icon = 'action:check';
            }  else if(this._value  === 'Open'){
                this.icon= 'action:follow';
            }

        //fire event to send context and selected value to the data table
        this.dispatchEvent(new CustomEvent('picklistchanged', {
            composed: true,
            bubbles: true,
            cancelable: true,
            detail: {
                value: this._value,
                rowKeyValue: this.rowKeyValue,
                fieldName: this.colKeyValue.split('-')[0]
            }
        }));
        this.isEditMode = false;
    }
}